income_path = d004_path / "2024" / "1kv" / "kv_vopr11.csv"
income = pd.read_csv(income_path)
['TE', 'K', 'NOMP', 'VOZ', 'POL', 'NOMVOPR', 'NOMVNEW', 'GR1', 'GR2', 'GR3', 'GR4', 'GR5', 'GR6', 'GR7', 'GR8', 'GR9', 'GR10', 'GR11', 'GR12', 'GR13', 'GR14', 'GR15', 'GR16', 'GR17', 'GR18', 'GR19', 'GR20', 'GR21', 'GR22', 'GR23', 'KVARTAL', 'GOD', 'NOMER']
gr_columns = [col for col in income.columns if col.startswith("GR")]
income_check = pd.DataFrame({
    "Столбец": gr_columns,
    "Ненулевых значений": [
        (pd.to_numeric(income[col], errors="coerce").fillna(0) != 0).sum()
        for col in gr_columns
    "Сумма": [
        pd.to_numeric(income[col], errors="coerce").fillna(0).sum()
        for col in gr_columns
})
income_view = income[
    ["NOMER", "NOMP", "GOD", "KVARTAL"] + gr_columns
].copy()
gr_columns = [col for col in income.columns if col.startswith("GR")]
for col in gr_columns:
    income[col] = pd.to_numeric(income[col], errors="coerce").fillna(0)
income["total_income_person"] = income[gr_columns].sum(axis=1)
income_household = (
    income
    .groupby(["NOMER", "GOD", "KVARTAL"])["total_income_person"]
    .sum()
    .reset_index()
)
income_household = income_household.rename(
    columns={"total_income_person": "income"}
)
      len(income_household))
income_all = []
for year in range(2021, 2025):
    for quarter in range(1, 5):
        path = d004_path / str(year) / f"{quarter}kv" / "kv_vopr11.csv"
        table = pd.read_csv(path)
        gr_columns = [col for col in table.columns if col.startswith("GR")]
        for col in gr_columns:
            table[col] = pd.to_numeric(
                table[col], errors="coerce"
            ).fillna(0)
        table["total_income_person"] = table[gr_columns].sum(axis=1)
        table["year"] = year
        table["quarter"] = quarter
        income_all.append(
            table[[
                "NOMER",
                "NOMP",
                "year",
                "quarter",
                "total_income_person"
        )
income_all = pd.concat(income_all, ignore_index=True)
income_household_all = (
    income_all
    .groupby(["NOMER", "year", "quarter"])["total_income_person"]
    .sum()
    .reset_index()
    .rename(columns={
        "total_income_person": "income"
    })
)
    "Домохозяйств-кварталов с доходом:",
    len(income_household_all)
)
expenses_household = (
    expenses_valid
    .groupby(["NOMER", "year", "quarter"])["STOIMK"]
    .sum()
    .reset_index()
    .rename(columns={
        "STOIMK": "expenses"
    })
)
    "Домохозяйств-кварталов с расходами:",
    len(expenses_household)
)
financial = income_household_all.merge(
    expenses_household,
    on=["NOMER", "year", "quarter"],
    how="inner",
    validate="one_to_one"
)
financial["balance"] = financial["income"] - financial["expenses"]
financial["deficit"] = financial["expenses"] > financial["income"]
    "Домохозяйств-кварталов с дефицитом:",
    financial["deficit"].sum()
)
    "Доля домохозяйств-кварталов с дефицитом:",
    round(financial["deficit"].mean() * 100, 2),
    "%"
)
    financial[
        ["NOMER", "year", "quarter", "income", "expenses", "balance", "deficit"]
    ].head(10)
)
    financial["income"].quantile(
    ).round(0)
)
financial["income_decile"] = pd.qcut(
    financial["income"],
    labels=False,
    duplicates="drop"
) + 1
h1_deciles = (
    financial
    .groupby("income_decile")
    .agg(
        Домохозяйств=("NOMER", "size"),
        Средний_доход=("income", "mean"),
        Медианный_доход=("income", "median"),
        Дефицитных=("deficit", "sum"),
        Доля_дефицита=("deficit", "mean")
    )
    .reset_index()
)
h1_deciles["Доля_дефицита"] = (
    h1_deciles["Доля_дефицита"] * 100
)
import matplotlib.pyplot as plt
fig, ax = plt.subplots(figsize=(11, 6))
bars = ax.bar(
    h1_deciles["income_decile"],
    h1_deciles["Доля_дефицита"],
    color="#7155B5",
    edgecolor="white"
)
ax.bar_label(
    bars,
    labels=[f"{v:.1f}%" for v in h1_deciles["Доля_дефицита"]],
    padding=4,
    fontsize=10
)
ax.set_title(
    "Финансовый дефицит по группам дохода, 2021–2024",
    fontsize=15,
    pad=15
)
ax.set_xlabel("Дециль дохода")
ax.set_ylabel("Доля домохозяйств с дефицитом, %")
ax.set_xticks(range(1, 11))
ax.grid(
    axis="y",
    alpha=0.2
)
ax.set_axisbelow(True)
ax.spines["top"].set_visible(False)
ax.spines["right"].set_visible(False)
fig.text(
    "1-й дециль — самый низкий доход • 10-й — самый высокий\n"
    "Финансовый дефицит: расходы превышают доходы",
    ha="center",
    fontsize=9,
    color="gray"
)
plt.tight_layout(rect=[0, 0.07, 1, 1])
plt.show()
h1_by_year = (
    financial
    .groupby(["year", "income_decile"])["deficit"]
    .mean()
    .mul(100)
    .reset_index()
)
fig, ax = plt.subplots(figsize=(11, 6))
for year in sorted(h1_by_year["year"].unique()):
    data = h1_by_year[h1_by_year["year"] == year]
    ax.plot(
        data["income_decile"],
        data["deficit"],
        marker="o",
        linewidth=2,
        label=str(year)
    )
ax.set_title(
    "Финансовый дефицит по децилям дохода: динамика 2021–2024",
    fontsize=15,
    pad=15
)
ax.set_xlabel("Дециль дохода")
ax.set_ylabel("Доля домохозяйств-кварталов с дефицитом, %")
ax.set_xticks(range(1, 11))
ax.grid(axis="y", alpha=0.2)
ax.set_axisbelow(True)
ax.spines["top"].set_visible(False)
ax.spines["right"].set_visible(False)
ax.legend(title="Год")
fig.text(
    "1-й дециль — самый низкий доход • 10-й — самый высокий\n"
    "Дефицит: расходы превышают доходы",
    ha="center",
    fontsize=9,
    color="gray"
)
plt.tight_layout(rect=[0, 0.07, 1, 1])
plt.show()
h1_balance = (
    financial
    .groupby("income_decile")["balance"]
    .median()
    .reset_index()
)
fig, ax = plt.subplots(figsize=(11, 6))
bars = ax.bar(
    h1_balance["income_decile"],
    h1_balance["balance"] / 1000,
    color="#7155B5"
)
ax.axhline(
    color="black",
    linewidth=1
)
ax.bar_label(
    bars,
    labels=[
        f"{v:.0f}"
        for v in h1_balance["balance"] / 1000
    padding=4,
    fontsize=9
)
ax.set_title(
    "Медианный финансовый баланс по децилям дохода, 2021–2024",
    fontsize=15,
    pad=15
)
ax.set_xlabel("Дециль дохода")
ax.set_ylabel("Медианный баланс, тыс. тенге за квартал")
ax.set_xticks(range(1, 11))
ax.grid(
    axis="y",
    alpha=0.2
)
ax.set_axisbelow(True)
ax.spines["top"].set_visible(False)
ax.spines["right"].set_visible(False)
fig.text(
    "Баланс = доходы − расходы • 1-й дециль — самый низкий доход",
    ha="center",
    fontsize=9,
    color="gray"
)
plt.tight_layout(rect=[0, 0.07, 1, 1])
plt.show()
h1_summary = pd.DataFrame({
    "Показатель": [
        "Доля дефицита, 1-й дециль",
        "Доля дефицита, 10-й дециль",
        "Разрыв между 1-м и 10-м децилем"
    "Значение": [
        h1_deciles.loc[h1_deciles["income_decile"] == 1, "Доля_дефицита"].iloc[0],
        h1_deciles.loc[h1_deciles["income_decile"] == 10, "Доля_дефицита"].iloc[0],
        (
            h1_deciles.loc[h1_deciles["income_decile"] == 1, "Доля_дефицита"].iloc[0]
            h1_deciles.loc[h1_deciles["income_decile"] == 10, "Доля_дефицита"].iloc[0]
        )
    "Единица": ["%", "%", "п.п."]
})
h1_income_expenses = (
    financial
    .groupby("income_decile")
    .agg(
        Медианный_доход=("income", "median"),
        Медианные_расходы=("expenses", "median")
    )
    .reset_index()
)
fig, ax = plt.subplots(figsize=(11, 6))
x = range(len(h1_income_expenses))
width = 0.38
bars_income = ax.bar(
    [i - width / 2 for i in x],
    h1_income_expenses["Медианный_доход"] / 1000,
    width=width,
    label="Медианный доход"
)
bars_expenses = ax.bar(
    [i + width / 2 for i in x],
    h1_income_expenses["Медианные_расходы"] / 1000,
    width=width,
    label="Медианные расходы"
)
ax.set_title(
    "Медианный доход и расходы по децилям, 2021–2024",
    fontsize=15,
    pad=15
)
ax.set_xlabel("Дециль дохода")
ax.set_ylabel("Тысяч тенге за квартал")
ax.set_xticks(list(x))
ax.set_xticklabels(range(1, 11))
ax.grid(axis="y", alpha=0.2)
ax.set_axisbelow(True)
ax.spines["top"].set_visible(False)
ax.spines["right"].set_visible(False)
ax.legend()
fig.text(
    "1-й дециль — самый низкий доход • 10-й — самый высокий",
    ha="center",
    fontsize=9,
    color="gray"
)
plt.tight_layout(rect=[0, 0.07, 1, 1])
plt.show()
merge_check = income_household_all.merge(
    expenses_household,
    on=["NOMER", "year", "quarter"],
    how="outer",
    indicator=True,
    validate="one_to_one"
)
    merge_check.loc[
        merge_check["_merge"] == "left_only",
        ["NOMER", "year", "quarter", "income"]
    ].head(20)
)
    merge_check.loc[
        merge_check["_merge"] == "right_only",
        ["NOMER", "year", "quarter", "expenses"]
    ].head(20)
)
both          188117
right_only       987
left_only          5
right_only = merge_check.loc[
    merge_check["_merge"] == "right_only",
    ["NOMER", "year", "quarter", "expenses"]
].copy()
      len(right_only))
    right_only
    .groupby("year")
    .agg(
        Наблюдений=("NOMER", "size"),
        Сумма_расходов=("expenses", "sum"),
        Медианные_расходы=("expenses", "median")
    )
    .reset_index()
    .round(0)
)
missing_income_by_year = (
    right_only
    .groupby("year")
    .size()
    .reset_index(name="Количество")
)
fig, ax = plt.subplots(figsize=(10, 5))
bars = ax.bar(
    missing_income_by_year["year"],
    missing_income_by_year["Количество"],
    edgecolor="white"
)
ax.bar_label(
    bars,
    padding=4,
    fontsize=10
)
ax.set_title(
    "Наблюдения с расходами, но без записи о доходе",
    fontsize=14,
    pad=15
)
ax.set_xlabel("Год")
ax.set_ylabel("Количество наблюдений")
ax.set_xticks(missing_income_by_year["year"])
ax.grid(
    axis="y",
    alpha=0.2
)
ax.set_axisbelow(True)
ax.spines["top"].set_visible(False)
ax.spines["right"].set_visible(False)
fig.text(
    "Всего наблюдений: 987 • Проверка полноты объединения D004",
    ha="center",
    fontsize=9,
    color="gray"
)
plt.tight_layout(rect=[0, 0.07, 1, 1])
plt.show()
