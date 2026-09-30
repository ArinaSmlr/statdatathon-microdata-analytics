from pathlib import Path
import textwrap

import matplotlib.pyplot as plt
import pandas as pd

try:
    from IPython.display import display
except ImportError:
    display = print

folder = Path(r"C:\Stat.Datathon\Datathon_data")
d004_folders = sorted(p for p in folder.rglob("d004")
                      if p.is_dir() and "documentation" not in p.parts)

print("Найдено папок d004 с данными:", len(d004_folders))

for path in d004_folders:
    print("\nПапка:", path)

    for year in sorted(path.iterdir()):
        if year.is_dir():
            csv_files = list(year.rglob("*.csv"))
            print(f"{year.name}: {len(csv_files)} CSV-файлов")

d004_path = d004_folders[0]
quarter_path = d004_path / "2024" / "1kv"

overview = []

for file in sorted(quarter_path.glob("*.csv")):
    table = pd.read_csv(file)

    overview.append({
        "Таблица": file.name,
        "Строк": len(table),
        "Столбцов": len(table.columns),
        "Домохозяйств": table["NOMER"].nunique()
    })

display(pd.DataFrame(overview))

participants = pd.read_csv(quarter_path / "kv_vopr0.csv")

print("Коды участия: 1 — участвовали, 2 — отказались")
print(participants["REZ"].value_counts(dropna=False))

checks = []

for number in range(1, 8):
    file = quarter_path / f"kv_vopr{number}.csv"
    table = pd.read_csv(file)
    amounts = pd.to_numeric(table["STOIMK"], errors="coerce")

    checks.append({
        "Таблица": file.name,
        "Строк": len(table),
        "Пропуски / нечисловые суммы": amounts.isna().sum(),
        "Отрицательные суммы": (amounts < 0).sum(),
        "Нулевые суммы": (amounts == 0).sum()
    })

display(pd.DataFrame(checks))

expenses = []
participation = []
audit = []

for year in range(2021, 2025):
    for quarter in range(1, 5):
        path = d004_path / str(year) / f"{quarter}kv"

        people = pd.read_csv(path / "kv_vopr0.csv")
        people["year"] = year
        people["quarter"] = quarter
        participation.append(people)

        for number in range(1, 8):
            table = pd.read_csv(path / f"kv_vopr{number}.csv")
            table["STOIMK"] = pd.to_numeric(
                table["STOIMK"], errors="coerce"
            )

            table["year"] = year
            table["quarter"] = quarter
            table["section"] = number
            expenses.append(table)

            audit.append({
                "Год": year,
                "Строк расходов": len(table),
                "Пропуски сумм": table["STOIMK"].isna().sum(),
                "Отрицательные суммы": (table["STOIMK"] < 0).sum(),
                "Нулевые суммы": (table["STOIMK"] == 0).sum()
            })

expenses = pd.concat(expenses, ignore_index=True)
participation = pd.concat(participation, ignore_index=True)

print("Загружено таблиц расходов:", len(audit))
display(pd.DataFrame(audit).groupby("Год").sum())

display(
        expenses[["year", "quarter", "section", "NOMER", "STOIMK"]]
        .head(10)
)

keys = ["year", "quarter", "NOMER"]

expenses_checked = expenses.merge(
    participation[keys + ["REZ"]],
    on=keys,
    how="left",
    validate="many_to_one"
)

print("Количество записей расходов по коду участия:")
print(expenses_checked["REZ"].value_counts(dropna=False))

expenses_valid = expenses_checked[
    expenses_checked["REZ"] == 1
].copy()

print("\nЗаписей расходов участников:", len(expenses_valid))
print("Записей вне расчёта:",
      len(expenses_checked) - len(expenses_valid))

section_names = {
    1: "Непродовольственные товары",
    2: "Жильё, коммунальные услуги и топливо",
    3: "Связь",
    4: "Образование",
    5: "Здравоохранение",
    6: "Прочие услуги и финансовые расходы",
    7: "Транспорт"
}

section_totals = (
    expenses_valid
    .groupby(["section", "year"])["STOIMK"]
    .sum()
    .unstack("year")
    .rename(index=section_names)
)

print("Суммы записанных расходов по разделам, млн тенге:")
display((section_totals / 1_000_000).round(2))

values = (section_totals[2024] / 1_000_000).sort_values()
labels = [textwrap.fill(name, width=30) for name in values.index]

fig, ax = plt.subplots(figsize=(12, 7))

bars = ax.barh(labels, values.values, color="#7155B5")

ax.bar_label(
    bars,
    labels=[f"{v:,.1f}".replace(",", " ") for v in values],
    padding=6,
    fontsize=10
)

ax.set_title("Записанные расходы по разделам D004, 2024 год",
             fontsize=14, pad=15)
ax.set_xlabel("Сумма за четыре квартала, млн тенге")
ax.set_xlim(0, values.max() * 1.18)
ax.set_axisbelow(True)
ax.grid(axis="x", alpha=0.2)

ax.spines["top"].set_visible(False)
ax.spines["right"].set_visible(False)

fig.text(
    0.5, 0.02,
    "Синтетические данные • Без весов • Разделы kv_vopr1–7\n"
    "Раздел 6 включает прочие услуги и финансовые расходы",
    ha="center", fontsize=9, color="gray"
)

plt.tight_layout(rect=[0, 0.08, 1, 1])
plt.show()

# Количество участвовавших домохозяйств в каждом квартале
household_counts = (
    participation[participation["REZ"] == 1]
    .groupby(["year", "quarter"])["NOMER"]
    .nunique()
)

# Суммы по каждому разделу, году и кварталу
quarter_totals = (
    expenses_valid
    .groupby(["year", "quarter", "section"])["STOIMK"]
    .sum()
    .unstack("section")
)

# Делим суммы на число участников соответствующего квартала
quarter_means = quarter_totals.div(household_counts, axis=0)

# Среднее из четырёх квартальных показателей каждого года
year_means = (
    quarter_means.groupby(level="year")
    .mean()
    .rename(columns=section_names)
)

print("Средние записанные расходы за квартал")
print("на одно участвовавшее домохозяйство, тенге:")
display(year_means.round(0).T)

fig2, axes = plt.subplots(4, 2, figsize=(13, 13))
axes = axes.flatten()

for ax, name in zip(axes, year_means.columns):
    values = year_means[name] / 1000

    ax.plot(
        values.index, values.values,
        marker="o", linewidth=2.5, color="#7155B5"
    )

    for year, value in values.items():
        ax.annotate(
            f"{value:.1f}",
            (year, value),
            xytext=(0, 8),
            textcoords="offset points",
            ha="center", fontsize=9
        )

    ax.set_title(textwrap.fill(name, 35), fontsize=11)
    ax.set_xticks([2021, 2022, 2023, 2024])
    ax.set_ylabel("тыс. тенге за квартал")
    ax.set_ylim(0, values.max() * 1.25)
    ax.grid(alpha=0.2)
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)

axes[-1].axis("off")

fig2.suptitle(
    "Записанные расходы на участвовавшее домохозяйство",
    fontsize=16, y=0.99
)

fig2.text(
    0.5, 0.015,
    "Среднее четырёх квартальных показателей • Синтетические данные\n"
    "Без весов и поправки на инфляцию • Масштабы панелей различаются",
    ha="center", fontsize=10, color="gray"
)

plt.tight_layout(rect=[0, 0.06, 1, 0.96])
plt.show()

section6 = expenses_valid[expenses_valid["section"] == 6]

print("Сочетания кодов в шестом разделе:")
display(
    section6.groupby(
        ["year", "KOD", "NOMVOPR"], dropna=False
    ).agg(
        Строк=("STOIMK", "size"),
        Сумма=("STOIMK", "sum")
    ).reset_index()
)

detail_names = {
    60: "Отдых и культура",
    61: "Индивидуальные и прочие услуги",
    62: "Прочие финансовые расходы"
}

section6_totals = (
    section6.groupby(["NOMVOPR", "year"])["STOIMK"]
    .sum()
    .unstack("year")
    .rename(index=detail_names)
)

print("Детализация шестого раздела, млн тенге:")
display((section6_totals / 1_000_000).round(2))

# Суммы по трём категориям раздела 6 за каждый квартал
detail_quarter_totals = (
    section6.groupby(["year", "quarter", "NOMVOPR"])["STOIMK"]
    .sum()
    .unstack("NOMVOPR")
)

# Делим на число участвовавших домохозяйств
detail_quarter_means = detail_quarter_totals.div(
    household_counts, axis=0
)

# Среднее четырёх кварталов каждого года
detail_year_means = (
    detail_quarter_means.groupby(level="year")
    .mean()
    .rename(columns=detail_names)
)

# Заменяем общий раздел 6 тремя подробными категориями
final_year_means = pd.concat(
    [
        year_means.drop(columns=[section_names[6]]),
        detail_year_means
    ],
    axis=1
)

print("Средние квартальные расходы на участвовавшее домохозяйство, тенге")
print("Синтетические данные • Без весов и поправки на инфляцию")

display(final_year_means.T.round(0))

# Исправленный график: категории по горизонтали, годы в легенде

plot_data = final_year_means.T / 1000

ax = plot_data.plot(
    kind="bar",
    figsize=(15, 7),
    color=["#7155B5", "#8E7CC3", "#A99AD8", "#C2B8E8"],
    edgecolor="white"
)

ax.set_title(
    "Средние квартальные расходы домохозяйства по категориям",
    fontsize=15,
    pad=15
)
ax.set_xlabel("Категория расходов")
ax.set_ylabel("Тысяч тенге")
ax.set_xticklabels(plot_data.index, rotation=45, ha="right")
ax.grid(axis="y", alpha=0.25)
ax.legend(title="Год")

plt.figtext(
    0.5, 0.01,
    "Синтетические данные • Среднее за 4 квартала • Без весов и поправки на инфляцию",
    ha="center",
    fontsize=9,
    color="gray"
)

plt.tight_layout(rect=[0, 0.05, 1, 1])
plt.show()

# Выбираем строки за нужные годы
values_2021 = final_year_means.loc[2021]
values_2024 = final_year_means.loc[2024]

growth_table = pd.DataFrame({
    "2021, тыс. тг": values_2021 / 1000,
    "2024, тыс. тг": values_2024 / 1000,
    "Изменение, тыс. тг": (values_2024 - values_2021) / 1000,
    "Рост, %": (values_2024 / values_2021 - 1) * 100
})

display(
    growth_table.sort_values("Рост, %", ascending=False).round(1)
)

# Сколько разных кодов расходов входит в каждую категорию по годам
code_counts = (
    section6.groupby(["NOMVOPR", "year"])["KODNU"]
    .nunique()
    .unstack("year")
    .rename(index=detail_names)
)

print("Количество разных кодов расходов по категориям:")
display(code_counts)

# Проверяем, встречался ли один код в разных категориях
code_categories = section6.groupby("KODNU")["NOMVOPR"].nunique()
changed_codes = code_categories[code_categories > 1].index

print("Кодов, встречавшихся в разных категориях:", len(changed_codes))

if len(changed_codes) > 0:
    display(
        section6.loc[
            section6["KODNU"].isin(changed_codes),
            ["year", "KODNU", "NOMVOPR"]
        ]
        .drop_duplicates()
        .sort_values(["KODNU", "year", "NOMVOPR"])
        .head(30)
    )

# Коды отдыха и культуры, встречающиеся в каждом из четырёх лет
culture = section6[section6["NOMVOPR"] == 60]

years_per_code = culture.groupby("KODNU")["year"].nunique()
common_codes = years_per_code[years_per_code == 4].index

# Расчёт только по общим кодам
culture_common = culture[culture["KODNU"].isin(common_codes)]

common_quarter_totals = (
    culture_common.groupby(["year", "quarter"])["STOIMK"].sum()
)

common_year_means = (
    common_quarter_totals.div(household_counts)
    .groupby(level="year").mean()
)

comparison = pd.DataFrame({
    "Все коды, тенге": final_year_means["Отдых и культура"],
    "Общие коды, тенге": common_year_means
})

display(comparison.round(0))

growth_common = (
    common_year_means.loc[2024] / common_year_means.loc[2021] - 1
) * 100

print("Рост по общим кодам:", round(growth_common, 1), "%")

print("Столбцы таблицы участия:")
print(participation.columns.tolist())

print("\nСтолбцы таблиц расходов:")
print(expenses_valid.columns.tolist())

# Ищем пояснения о весах в руководстве к данным
guide_files = [
    p for p in d004_path.parent.rglob("*")
    if p.is_file()
    and "data-guide" in p.name.lower()
    and p.suffix.lower() in [".rmd", ".md", ".txt", ""]
]

found = False

for path in guide_files:
    lines = path.read_text(encoding="utf-8", errors="replace").splitlines()

    for i, line in enumerate(lines):
        if any(word in line.lower() for word in [
            "weight", "весов", "взвеш", "веса", "вес "
        ]):
            found = True
            print(f"\nФайл: {path.name}, строка {i + 1}")
            print("\n".join(lines[max(0, i - 2):i + 3]))

if not found:
    print("Упоминаний весов в проверенных текстовых руководствах не найдено.")

print("\nПроверено файлов:", len(guide_files))

docs_path = d004_path.parent / "documentation" / "d004"

print("Документация d004:")

if docs_path.exists():
    for path in sorted(docs_path.rglob("*")):
        if path.is_file() and path.suffix.lower() in [
            ".doc", ".docx", ".pdf", ".xls", ".xlsx", ".txt"
        ]:
            print(path.relative_to(docs_path))
else:
    print("Папка не найдена:", docs_path)

# Проверяем цели покупки непродовольственных товаров
purchase_purpose = (
    expenses_valid[expenses_valid["section"] == 1]
    .groupby(["year", "CELPOK"], dropna=False)
    .agg(
        Записей=("STOIMK", "size"),
        Сумма_тенге=("STOIMK", "sum")
    )
    .reset_index()
)

display(purchase_purpose)

purpose_names = {
    1: "Личное потребление",
    2: "Подарок",
    9: "Другое"
}

purpose_summary = purchase_purpose.copy()

purpose_summary["Цель покупки"] = (
    purpose_summary["CELPOK"].map(purpose_names)
)

year_totals = (
    purpose_summary.groupby("year")["Сумма_тенге"].transform("sum")
)

purpose_summary["Доля расходов, %"] = (
    purpose_summary["Сумма_тенге"] / year_totals * 100
)

display(
    purpose_summary.pivot(
        index="Цель покупки",
        columns="year",
        values="Доля расходов, %"
    ).round(2)
)

output_folder = Path(r"C:\Python\PythonProject\Datathon\results_d004")
output_folder.mkdir(parents=True, exist_ok=True)

final_year_means.T.to_csv(
    output_folder / "01_quarterly_expenses.csv",
    sep=";", decimal=",", encoding="utf-8-sig"
)

growth_table.to_csv(
    output_folder / "02_growth_2021_2024.csv",
    sep=";", decimal=",", encoding="utf-8-sig"
)

purpose_summary.to_csv(
    output_folder / "03_purchase_purposes.csv",
    sep=";", decimal=",", encoding="utf-8-sig",
    index=False
)

comparison.to_csv(
    output_folder / "04_culture_comparison.csv",
    sep=";", decimal=",", encoding="utf-8-sig"
)

print("Таблицы сохранены в:", output_folder)
for file in sorted(output_folder.glob("*.csv")):
    print(file.name)

plot_data = final_year_means.T / 1000

fig_export, ax_export = plt.subplots(figsize=(14, 8))

plot_data.plot.bar(
    ax=ax_export,
    color=["#493078", "#7155B5", "#A28ACC", "#D0C3E6"],
    edgecolor="white",
    width=0.8
)

ax_export.set_title(
    "Выбранные расходы d004 за 2021–2024 годы",
    fontsize=16, pad=16
)
ax_export.set_ylabel(
    "Средние квартальные расходы\nна участвовавшее домохозяйство, тыс. тенге"
)
ax_export.set_xlabel("")
ax_export.set_xticklabels(
    [textwrap.fill(name, 19) for name in plot_data.index],
    rotation=45, ha="right", fontsize=9
)
ax_export.legend(title="Год")
ax_export.set_axisbelow(True)
ax_export.grid(axis="y", alpha=0.2)

fig_export.text(
    0.5, 0.02,
    "Синтетические данные • Среднее четырёх кварталов • Без весов и поправки на инфляцию\n"
    "Разделы 1–7: включая финансовые расходы; покупки товаров — для всех целей",
    ha="center", fontsize=9, color="gray"
)

fig_export.tight_layout(rect=[0, 0.09, 1, 1])

chart_path = output_folder / "05_expenses_2021_2024.png"
fig_export.savefig(chart_path, dpi=300, bbox_inches="tight")

plt.show()
print("График сохранён:", chart_path)

# Складываем выбранные расходы каждого домохозяйства за квартал
household_totals = (
    expenses_valid
    .groupby(["year", "quarter", "NOMER"])["STOIMK"]
    .sum()
    .rename("Расходы")
    .reset_index()
)

# Включаем всех участников, даже если записей расходов нет
household_stats_data = (
    participation.loc[
        participation["REZ"] == 1,
        ["year", "quarter", "NOMER"]
    ]
    .drop_duplicates()
    .merge(
        household_totals,
        on=["year", "quarter", "NOMER"],
        how="left",
        validate="one_to_one"
    )
)

missing_count = household_stats_data["Расходы"].isna().sum()
print("Домохозяйств-кварталов без записей расходов:", missing_count)

# Нет записей — ноль зарегистрированных расходов
household_stats_data["Расходы"] = (
    household_stats_data["Расходы"].fillna(0)
)

def mode_values(series):
    modes = series.mode()
    if len(modes) == series.nunique():
        return "Нет выделяющейся моды"
    return "; ".join(f"{value:,.0f}" for value in modes)

descriptive_stats = (
    household_stats_data.groupby("year")["Расходы"]
    .agg(
        Наблюдений="size",
        Среднее="mean",
        Медиана="median",
        Мода=mode_values,
        Минимум="min",
        Максимум="max",
        Стандартное_отклонение="std",
        Нижний_квартиль=lambda s: s.quantile(0.25),
        Верхний_квартиль=lambda s: s.quantile(0.75)
    )
)

print("\nОписательная статистика квартальных расходов, тенге")
print("Разделы 1–7 d004 • Синтетические данные • Без весов")
display(descriptive_stats.round(1).T)

descriptive_stats.to_csv(
    output_folder / "06_descriptive_statistics.csv",
    sep=";", decimal=",", encoding="utf-8-sig"
)

print("\nТаблица сохранена: 06_descriptive_statistics.csv")

data_chart = descriptive_stats[["Среднее", "Медиана"]] / 1000

fig_stats, ax_stats = plt.subplots(figsize=(10, 6))

data_chart.plot.bar(
    ax=ax_stats,
    color=["#7155B5", "#B5A0DB"],
    rot=0,
    width=0.65
)

for bars in ax_stats.containers:
    ax_stats.bar_label(bars, fmt="%.1f", padding=4)

ax_stats.set_title("Выбранные квартальные расходы: среднее и медиана")
ax_stats.set_xlabel("Год")
ax_stats.set_ylabel("Тысяч тенге на домохозяйство за квартал")
ax_stats.set_ylim(0, data_chart.max().max() * 1.18)
ax_stats.set_axisbelow(True)
ax_stats.grid(axis="y", alpha=0.2)
ax_stats.legend(title="Показатель")

fig_stats.text(
    0.5, 0.02,
    "Синтетические данные d004 • Разделы 1–7 • Без весов и поправки на инфляцию\n"
    "Наблюдение — домохозяйство за квартал; 5 наблюдений без записей учтены как 0",
    ha="center", fontsize=9, color="gray"
)

fig_stats.tight_layout(rect=[0, 0.10, 1, 1])
fig_stats.savefig(
    output_folder / "07_mean_median.png",
    dpi=300, bbox_inches="tight"
)

plt.show()
print("Сохранено: 07_mean_median.png")