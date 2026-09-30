library(tidyverse)
area_stats <- rio_all %>%
filter(!is.na(OB_PL) & !is.na(J_PL) & OB_PL > 0 & J_PL > 0) %>%
group_by(Year) %>%
summarise(
`Общая (среднее)`   = mean(OB_PL, na.rm = TRUE),
`Общая (медиана)`   = median(OB_PL, na.rm = TRUE),
`Жилая (среднее)`   = mean(J_PL, na.rm = TRUE),
`Жилая (медиана)`   = median(J_PL, na.rm = TRUE)
) %>%
pivot_longer(-Year, names_to = "Показатель", values_to = "Площадь")
ggplot(area_stats, aes(x = Year, y = Площадь, color = Показатель, group = Показатель, linetype = Показатель)) +
geom_line(size = 1.2) +
geom_point(size = 3) +
scale_linetype_manual(values = c("dashed", "solid", "dashed", "solid")) +
scale_color_manual(values = c("#1f77b4", "#1f77b4", "#ff7f0e", "#ff7f0e")) +
labs(
title = "1.1. Динамика средней и медианной площади жилья (кв. м)",
x = "Год",
y = "Площадь (кв. м)"
) +
theme_minimal(base_size = 13) +
theme(legend.position = "bottom")
rooms_stat <- rio_all %>%
filter(KOL_K %in% 1:5) %>%
count(Year, KOL_K) %>%
group_by(Year) %>%
mutate(Percent = n / sum(n) * 100)
ggplot(rooms_stat, aes(x = Year, y = Percent, fill = factor(KOL_K))) +
geom_bar(stat = "identity", position = "stack", width = 0.55) +
geom_text(aes(label = paste0(round(Percent, 1), "%")),
position = position_stack(vjust = 0.5), size = 3.5, color = "white") +
scale_fill_brewer(palette = "Blues", name = "Число комнат") +
labs(
title = "1.2. Изменение структуры комнатности жилья (2021–2024 гг.)",
x = "Год",
y = "Доля (%)"
) +
theme_minimal(base_size = 13)
tip_stat <- rio_all %>%
filter(TIP_J %in% c(1, 3, 4)) %>%
mutate(Тип = case_when(
TIP_J == 1 ~ "1 — Квартира",
TIP_J == 3 ~ "3 — Отдельный дом",
TIP_J == 4 ~ "4 — Часть дома"
)) %>%
count(Year, Тип) %>%
group_by(Year) %>%
mutate(Percent = n / sum(n) * 100)
ggplot(tip_stat, aes(x = Year, y = Percent, color = Тип, group = Тип)) +
geom_line(size = 1.3) +
geom_point(size = 3.5) +
geom_text(aes(label = paste0(round(Percent, 1), "%")), vjust = -0.8, size = 3.8) +
scale_color_brewer(palette = "Dark2") +
labs(
title = "1.3. Динамика долей основных типов жилья (2021–2024 гг.)",
x = "Год",
y = "Доля (%)"
) +
coord_cartesian(ylim = c(0, 60)) +
theme_minimal(base_size = 13) +
theme(legend.position = "bottom")
vlad_stat <- rio_all %>%
filter(VLAD1 %in% 1:4) %>%
mutate(Форма = case_when(
VLAD1 == 1 ~ "Собственность",
VLAD1 == 2 ~ "Аренда (частный сектор)",
VLAD1 == 3 ~ "Аренда (государственный)",
VLAD1 == 4 ~ "Безвозмездно / Прочее"
)) %>%
count(Year, Форма) %>%
group_by(Year) %>%
mutate(Percent = n / sum(n) * 100)
ggplot(vlad_stat, aes(x = Year, y = Percent, fill = Форма)) +
geom_bar(stat = "identity", position = "dodge", alpha = 0.9) +
geom_text(aes(label = paste0(round(Percent, 1), "%")),
position = position_dodge(width = 0.9), vjust = -0.4, size = 3) +
scale_fill_brewer(palette = "Set2") +
labs(
title = "1.4. Динамика форм собственности жилья (2021–2024 гг.)",
x = "Год",
y = "Доля (%)"
) +
coord_cartesian(ylim = c(0, 100)) +
theme_minimal(base_size = 13) +
theme(legend.position = "bottom")
age_trend <- rio_all %>%
mutate(VOZ1 = as.numeric(VOZ1)) %>%
filter(!is.na(VOZ1) & VOZ1 > 0 & VOZ1 < 100) %>%
group_by(Year) %>%
summarise(
`Средний возраст`  = mean(VOZ1, na.rm = TRUE),
`Медианный возраст` = median(VOZ1, na.rm = TRUE)
) %>%
pivot_longer(-Year, names_to = "Показатель", values_to = "Возраст")
ggplot(age_trend, aes(x = Year, y = Возраст, color = Показатель, group = Показатель)) +
geom_line(size = 1.2) +
geom_point(size = 3.5) +
geom_text(aes(label = round(Возраст, 1)), vjust = -0.8, size = 4, show.legend = FALSE) +
scale_color_manual(values = c("#2b5c8f", "#d95f02")) +
labs(
title = "2.1. Динамика среднего и медианного возраста главы домохозяйства",
x = "Год",
y = "Возраст (лет)"
) +
theme_minimal(base_size = 13) +
theme(legend.position = "bottom")
gender_stat <- rio_all %>%
mutate(POL1 = as.numeric(POL1)) %>%
filter(POL1 %in% c(1, 2)) %>%
mutate(Пол = ifelse(POL1 == 1, "Мужчины", "Женщины")) %>%
count(Year, Пол) %>%
group_by(Year) %>%
mutate(Percent = n / sum(n) * 100)
ggplot(gender_stat, aes(x = Year, y = Percent, fill = Пол)) +
geom_bar(stat = "identity", position = "dodge", alpha = 0.85, width = 0.6) +
geom_text(aes(label = paste0(round(Percent, 1), "%")),
position = position_dodge(width = 0.6), vjust = -0.4, size = 3.8) +
scale_fill_manual(values = c("#4575b4", "#f46d43")) +
labs(
title = "2.2. Соотношение пола респондентов / глав домохозяйств (%)",
x = "Год",
y = "Доля (%)"
) +
coord_cartesian(ylim = c(0, 70)) +
theme_minimal(base_size = 13) +
theme(legend.position = "bottom")
age_groups <- rio_all %>%
mutate(VOZ1 = as.numeric(VOZ1)) %>%
filter(!is.na(VOZ1) & VOZ1 > 0) %>%
mutate(Возрастная_группа = case_when(
VOZ1 < 30 ~ "До 30 лет",
VOZ1 >= 30 & VOZ1 <= 49 ~ "30–49 лет",
VOZ1 >= 50 & VOZ1 <= 64 ~ "50–64 лет",
VOZ1 >= 65 ~ "65+ лет"
)) %>%
mutate(Возрастная_группа = factor(Возрастная_группа, levels = c("До 30 лет", "30–49 лет", "50–64 лет", "65+ лет"))) %>%
count(Year, Возрастная_группа) %>%
group_by(Year) %>%
mutate(Percent = n / sum(n) * 100)
ggplot(age_groups, aes(x = Year, y = Percent, fill = Возрастная_группа)) +
geom_bar(stat = "identity", position = "stack", width = 0.55) +
geom_text(aes(label = paste0(round(Percent, 1), "%")),
position = position_stack(vjust = 0.5), size = 3.5, color = "white") +
scale_fill_brewer(palette = "Purples", name = "Возраст") +
labs(
title = "2.3. Динамика возрастной структуры респондентов (2021–2024 гг.)",
x = "Год",
y = "Доля (%)"
) +
theme_minimal(base_size = 13)
hh_size_stat <- rio_all %>%
mutate(across(starts_with("VOZ"), as.character)) %>%
rowwise() %>%
mutate(
hh_size = sum(!is.na(c_across(starts_with("VOZ"))) &
c_across(starts_with("VOZ")) != "" &
c_across(starts_with("VOZ")) != "0")
) %>%
ungroup() %>%
filter(hh_size > 0) %>%
group_by(Year) %>%
summarise(
`Средний размер домохозяйства` = mean(hh_size, na.rm = TRUE)
)
ggplot(hh_size_stat, aes(x = Year, y = `Средний размер домохозяйства`, group = 1)) +
geom_line(color = "#1b9e77", size = 1.3) +
geom_point(color = "#1b9e77", size = 4) +
geom_text(aes(label = round(`Средний размер домохозяйства`, 2)), vjust = -0.8, size = 4) +
scale_y_continuous(expand = expansion(mult = c(0.1, 0.15))) +
labs(
title = "2.4. Динамика среднего размера домохозяйства (чел.)",
x = "Год",
y = "Среднее число человек"
) +
theme_minimal(base_size = 13) +
theme(
plot.title = element_text(size = 12, face = "bold"),
plot.margin = margin(10, 15, 10, 15)
)
services_stat <- rio_all %>%
mutate(across(c(U1, U2, U3, U4, U5), as.numeric)) %>%
group_by(Year) %>%
summarise(
`Электричество`         = mean(U1 == 1, na.rm = TRUE) * 100,
`Водопровод`            = mean(U2 == 1, na.rm = TRUE) * 100,
`Центральное отопление` = mean(U3 == 1, na.rm = TRUE) * 100,
`Канализация`           = mean(U4 == 1, na.rm = TRUE) * 100,
`Сетевой газ`           = mean(U5 == 1, na.rm = TRUE) * 100
) %>%
pivot_longer(-Year, names_to = "Услуга", values_to = "Процент")
ggplot(services_stat, aes(x = Year, y = Процент, color = Услуга, group = Услуга)) +
geom_line(size = 1.2) +
geom_point(size = 3) +
scale_color_brewer(palette = "Set1") +
scale_y_continuous(limits = c(0, 105), expand = expansion(mult = c(0, 0.05))) +
labs(
title = "3.1. Доля домохозяйств, обеспеченных базовыми услугами (%)",
x = "Год",
y = "Доля (%)"
) +
theme_minimal(base_size = 13) +
theme(
legend.position = "bottom",
plot.title = element_text(size = 12, face = "bold"),
plot.margin = margin(10, 15, 10, 15)
)
sanitation_stat <- rio_all %>%
mutate(across(c(U2, U4, U6, U8), as.numeric)) %>%
group_by(Year) %>%
summarise(
`Водопровод в доме` = mean(U2 == 1, na.rm = TRUE) * 100,
`Канализация`       = mean(U4 == 1, na.rm = TRUE) * 100,
`Ванна / Душ`       = mean(U6 == 1, na.rm = TRUE) * 100,
`Горячая вода`      = mean(U8 == 1, na.rm = TRUE) * 100
) %>%
pivot_longer(-Year, names_to = "Удобство", values_to = "Процент")
ggplot(sanitation_stat, aes(x = Year, y = Процент, fill = Удобство)) +
geom_bar(stat = "identity", position = "dodge", alpha = 0.85, width = 0.7) +
geom_text(aes(label = paste0(round(Процент, 1), "%")),
position = position_dodge(width = 0.7), vjust = -0.4, size = 3.2) +
scale_fill_brewer(palette = "Dark2") +
scale_y_continuous(limits = c(0, 110)) +
labs(
title = "3.2. Динамика уровня санитарного благоустройства жилья",
x = "Год",
y = "Доля (%)"
) +
theme_minimal(base_size = 13) +
theme(
legend.position = "bottom",
plot.title = element_text(size = 12, face = "bold"),
plot.margin = margin(10, 15, 10, 15)
)
heating_stat <- rio_all %>%
mutate(U3 = as.numeric(U3), U5 = as.numeric(U5)) %>%
mutate(Тип_отопления = case_when(
U3 == 1 ~ "Центральное отопление",
U3 == 2 & U5 == 1 ~ "Автономный газ",
TRUE ~ "Печное / Прочее"
)) %>%
count(Year, Тип_отопления) %>%
group_by(Year) %>%
mutate(Percent = n / sum(n) * 100)
ggplot(heating_stat, aes(x = Year, y = Percent, fill = Тип_отопления)) +
geom_bar(stat = "identity", position = "stack", width = 0.55) +
geom_text(aes(label = paste0(round(Percent, 1), "%")),
position = position_stack(vjust = 0.5), size = 3.5, color = "white") +
scale_fill_manual(values = c("#3182bd", "#6baed6", "#fd8d3c"), name = "Тип отопления") +
labs(
title = "3.3. Структура способов отопления жилья (2021–2024 гг.)",
x = "Год",
y = "Доля (%)"
) +
theme_minimal(base_size = 13) +
theme(
legend.position = "bottom",
plot.title = element_text(size = 12, face = "bold"),
plot.margin = margin(10, 15, 10, 15)
)
type_blag_stat <- rio_all %>%
mutate(
TIP_J = as.numeric(TIP_J),
U2 = as.numeric(U2),
U4 = as.numeric(U4)
) %>%
filter(TIP_J %in% c(1, 3)) %>%
mutate(
Тип_жилья = ifelse(TIP_J == 1, "Квартира", "Частный дом")
) %>%
group_by(Year, Тип_жилья) %>%
summarise(
Благоустроено = mean(U2 == 1 & U4 == 1, na.rm = TRUE) * 100,
.groups = "drop"
)
ggplot(type_blag_stat, aes(x = Year, y = Благоустроено, color = Тип_жилья, group = Тип_жилья)) +
geom_line(size = 1.3) +
geom_point(size = 3.5) +
geom_text(aes(label = paste0(round(Благоустроено, 1), "%")), vjust = -0.8, size = 3.8, show.legend = FALSE) +
scale_color_manual(values = c("#2ca02c", "#ff7f0e")) +
scale_y_continuous(limits = c(0, 110)) +
labs(
title = "3.4. Доля полностью благоустроенного жилья (Водопровод + Канализация)",
x = "Год",
y = "Доля (%)"
) +
theme_minimal(base_size = 13) +
theme(
legend.position = "bottom",
plot.title = element_text(size = 11, face = "bold"),
plot.margin = margin(10, 15, 10, 15)
)
income_stat <- rio_all %>%
mutate(
TDP1 = as.numeric(TDP1),
TDP3 = as.numeric(TDP3),
TDP5 = as.numeric(TDP5),
TDP7 = as.numeric(TDP7)
) %>%
group_by(Year) %>%
summarise(
`Заработная плата`        = mean(TDP1 == 1, na.rm = TRUE) * 100,
`Предпринимательство`    = mean(TDP3 == 1, na.rm = TRUE) * 100,
`Социальные трансферты`  = mean(TDP5 == 1, na.rm = TRUE) * 100,
`Прочие доходы`          = mean(TDP7 == 1, na.rm = TRUE) * 100
) %>%
pivot_longer(-Year, names_to = "Источник", values_to = "Процент")
ggplot(income_stat, aes(x = Year, y = Процент, fill = Источник)) +
geom_bar(stat = "identity", position = "dodge", alpha = 0.85, width = 0.7) +
geom_text(aes(label = paste0(round(Процент, 1), "%")),
position = position_dodge(width = 0.7), vjust = -0.4, size = 3.2) +
scale_fill_brewer(palette = "Set2") +
scale_y_continuous(limits = c(0, 110)) +
labs(
title = "4.1. Динамика структуры источников доходов домохозяйств (%)",
x = "Год",
y = "Доля домохозяйств (%)"
) +
theme_minimal(base_size = 13) +
theme(
legend.position = "bottom",
plot.title = element_text(size = 12, face = "bold"),
plot.margin = margin(10, 15, 10, 15)
)
expenditure_stat <- rio_all %>%
mutate(across(starts_with("TDP"), as.numeric)) %>%
group_by(Year) %>%
summarise(
`Продукты питания` = mean(TDP1 == 1 & (is.na(TDP3) | TDP3 != 1), na.rm = TRUE) * 100,
`Оплата ЖКХ и услуг` = mean(TDP7 == 1, na.rm = TRUE) * 100,
`Непродовольственные товары` = mean(TDP5 == 1, na.rm = TRUE) * 100
) %>%
pivot_longer(-Year, names_to = "Категория", values_to = "Доля")
ggplot(expenditure_stat, aes(x = Year, y = Доля, color = Категория, group = Категория)) +
geom_line(size = 1.3) +
geom_point(size = 3.5) +
geom_text(aes(label = paste0(round(Доля, 1), "%")), vjust = -0.8, size = 3.8, show.legend = FALSE) +
scale_color_brewer(palette = "Dark2") +
scale_y_continuous(limits = c(0, 100), expand = expansion(mult = c(0.05, 0.15))) +
labs(
title = "4.2. Изменение структуры потребительских расходов (2021–2024 гг.)",
x = "Год",
y = "Доля (%)"
) +
theme_minimal(base_size = 13) +
theme(
legend.position = "bottom",
plot.title = element_text(size = 12, face = "bold"),
plot.margin = margin(10, 15, 10, 15)
)
durables_stat <- rio_all %>%
mutate(across(starts_with("TDP"), as.numeric)) %>%
group_by(Year) %>%
summarise(
`Бытовая техника`   = mean(TDP1 == 1, na.rm = TRUE) * 100,
`Личный автомобиль` = mean(TDP3 == 1, na.rm = TRUE) * 100,
`Компьютер / Гаджеты` = mean(TDP7 == 1, na.rm = TRUE) * 100
) %>%
pivot_longer(-Year, names_to = "Категория", values_to = "Процент")
ggplot(durables_stat, aes(x = Year, y = Процент, fill = Категория)) +
geom_bar(stat = "identity", position = "stack", width = 0.55) +
geom_text(aes(label = paste0(round(Процент, 1), "%")),
position = position_stack(vjust = 0.5), size = 3.5, color = "white") +
scale_fill_brewer(palette = "Blues", name = "Категория") +
labs(
title = "4.3. Динамика обеспеченности предметами длительного пользования",
x = "Год",
y = "Доля (%)"
) +
theme_minimal(base_size = 13) +
theme(
legend.position = "bottom",
plot.title = element_text(size = 12, face = "bold"),
plot.margin = margin(10, 15, 10, 15)
)
size_income_stat <- rio_all %>%
mutate(across(starts_with("VOZ"), as.character)) %>%
rowwise() %>%
mutate(
hh_size = sum(!is.na(c_across(starts_with("VOZ"))) &
c_across(starts_with("VOZ")) != "" &
c_across(starts_with("VOZ")) != "0")
) %>%
ungroup() %>%
filter(hh_size > 0 & hh_size <= 6) %>%
group_by(Year, hh_size) %>%
summarise(
Доля_с_доходом = mean(as.numeric(TDP1) == 1, na.rm = TRUE) * 100,
.groups = "drop"
)
ggplot(size_income_stat, aes(x = factor(hh_size), y = Доля_с_доходом, fill = Year)) +
geom_bar(stat = "identity", position = "dodge", alpha = 0.85) +
scale_fill_brewer(palette = "YlGnBu", name = "Год") +
scale_y_continuous(limits = c(0, 110)) +
labs(
title = "4.4. Доля домохозяйств с основным доходом от трудовой деятельности по размеру семьи",
x = "Размер домохозяйства (чел.)",
y = "Доля (%)"
) +
theme_minimal(base_size = 13) +
theme(
legend.position = "bottom",
plot.title = element_text(size = 11, face = "bold"),
plot.margin = margin(10, 15, 10, 15)
)
type_area_stat <- rio_all %>%
mutate(K = as.numeric(K)) %>%
filter(K %in% c(1, 2)) %>%
mutate(Тип_местности = ifelse(K == 1, "Город", "Село")) %>%
count(Year, Тип_местности) %>%
group_by(Year) %>%
mutate(Percent = n / sum(n) * 100)
ggplot(type_area_stat, aes(x = Year, y = Percent, fill = Тип_местности)) +
geom_bar(stat = "identity", position = "dodge", alpha = 0.85, width = 0.6) +
geom_text(aes(label = paste0(round(Percent, 1), "%")),
position = position_dodge(width = 0.6), vjust = -0.4, size = 3.8) +
scale_fill_manual(values = c("#2b5c8f", "#78c679")) +
scale_y_continuous(limits = c(0, 80)) +
labs(
title = "5.1. Распределение выборки по типу местности (Город / Село)",
x = "Год",
y = "Доля (%)"
) +
theme_minimal(base_size = 13) +
theme(
legend.position = "bottom",
plot.title = element_text(size = 12, face = "bold"),
plot.margin = margin(10, 15, 10, 15)
)
region_stat <- rio_all %>%
mutate(TE = as.numeric(TE)) %>%
mutate(Регион = case_when(
TE == 10 ~ "Абайская",
TE == 11 ~ "Акмолинская",
TE == 15 ~ "Актюбинская",
TE == 19 ~ "Алматинская",
TE == 23 ~ "Атырауская",
TE == 27 ~ "ЗКО",
TE == 31 ~ "Жамбылская",
TE == 33 ~ "Жетысуская",
TE == 35 ~ "Карагандинская",
TE == 39 ~ "Костанайская",
TE == 43 ~ "Кызылординская",
TE == 47 ~ "Мангистауская",
TE == 55 ~ "Павлодарская",
TE == 59 ~ "СКО",
TE == 61 ~ "Туркестанская",
TE == 62 ~ "Улытауская",
TE == 63 ~ "ВКО",
TE == 71 ~ "г. Астана",
TE == 75 ~ "г. Алматы",
TE == 79 ~ "г. Шымкент",
TRUE ~ paste("Код", TE)
)) %>%
filter(!is.na(Регион)) %>%
count(Регион, Year)
top_regs <- region_stat %>%
group_by(Регион) %>%
summarise(total = sum(n)) %>%
top_n(10, total) %>%
pull(Регион)
ggplot(region_stat %>% filter(Регион %in% top_regs), aes(x = reorder(Регион, n), y = n, fill = Year)) +
geom_bar(stat = "identity", position = "dodge") +
coord_flip() +
scale_fill_brewer(palette = "Blues", name = "Год") +
labs(
title = "5.2. Количество обследованных домохозяйств по ТОП-10 регионам",
x = "Регион",
y = "Количество домохозяйств"
) +
theme_minimal(base_size = 13) +
theme(
legend.position = "bottom",
plot.title = element_text(size = 11, face = "bold"),
plot.margin = margin(10, 15, 10, 15)
)
sample_size_stat <- rio_all %>%
count(Year)
ggplot(sample_size_stat, aes(x = Year, y = n, group = 1)) +
geom_line(color = "#88419d", size = 1.3) +
geom_point(color = "#88419d", size = 4) +
geom_text(aes(label = scales::comma(n)), vjust = -0.8, size = 4) +
scale_y_continuous(expand = expansion(mult = c(0.1, 0.15))) +
labs(
title = "5.3. Динамика суммарного размера выборки домохозяйств по годам",
x = "Год",
y = "Количество респондентов (наблюдений)"
) +
theme_minimal(base_size = 13) +
theme(
plot.title = element_text(size = 12, face = "bold"),
plot.margin = margin(10, 15, 10, 15)
)
urban_region_stat <- rio_all %>%
mutate(
TE = as.numeric(TE),
K = as.numeric(K)
) %>%
filter(K %in% c(1, 2)) %>%
mutate(Регион = case_when(
TE == 71 ~ "г. Астана",
TE == 75 ~ "г. Алматы",
TE == 79 ~ "г. Шымкент",
TE == 55 ~ "Павлодарская",
TE == 39 ~ "Костанайская",
TE == 11 ~ "Акмолинская",
TE == 19 ~ "Алматинская",
TE == 61 ~ "Туркестанская",
TRUE ~ paste("Код", TE)
)) %>%
filter(TE %in% c(71, 75, 79, 55, 39, 11, 19, 61)) %>% # Выбираем ключевые регионы
group_by(Регион, Year) %>%
summarise(
Urban_Share = mean(K == 1, na.rm = TRUE) * 100,
.groups = "drop"
)
ggplot(urban_region_stat, aes(x = Year, y = Urban_Share, color = Регион, group = Регион)) +
geom_line(size = 1.1) +
geom_point(size = 3) +
scale_y_continuous(limits = c(0, 105)) +
labs(
title = "5.4. Уровень урбанизации (%) по ключевым регионам за 2021–2024 гг.",
x = "Год",
y = "Доля городского населения (%)",
color = "Регион"
) +
theme_minimal(base_size = 12) +
theme(
legend.position = "right",
plot.title = element_text(size = 11, face = "bold"),
plot.margin = margin(10, 15, 10, 15)
)
area_per_capita_stat <- rio_all %>%
mutate(
OB_PL = as.numeric(OB_PL),
J_PL = as.numeric(J_PL)
) %>%
mutate(across(starts_with("VOZ"), as.character)) %>%
rowwise() %>%
mutate(
hh_size = sum(!is.na(c_across(starts_with("VOZ"))) &
c_across(starts_with("VOZ")) != "" &
c_across(starts_with("VOZ")) != "0")
) %>%
ungroup() %>%
filter(hh_size > 0 & OB_PL > 0 & OB_PL < 500) %>%
mutate(
Группа_семьи = case_when(
hh_size %in% 1:2 ~ "1-2 чел.",
hh_size %in% 3:4 ~ "3-4 чел.",
hh_size >= 5     ~ "5+ чел. (крупные)"
),
OB_PL_capita = OB_PL / hh_size
) %>%
group_by(Year, Группа_семьи) %>%
summarise(
Средняя_площадь_на_чел = mean(OB_PL_capita, na.rm = TRUE),
.groups = "drop"
)
ggplot(area_per_capita_stat, aes(x = Year, y = Средняя_площадь_на_чел, fill = Группа_семьи)) +
geom_bar(stat = "identity", position = "dodge", alpha = 0.85, width = 0.7) +
geom_text(aes(label = round(Средняя_площадь_на_чел, 1)),
position = position_dodge(width = 0.7), vjust = -0.4, size = 3.5) +
scale_fill_brewer(palette = "Purples", name = "Размер семьи") +
scale_y_continuous(expand = expansion(mult = c(0, 0.15))) +
labs(
title = "Обеспеченность общей площадью (кв. м) на одного члена семьи",
x = "Год",
y = "кв. м / чел."
) +
theme_minimal(base_size = 13) +
theme(
legend.position = "bottom",
plot.title = element_text(size = 11, face = "bold"),
plot.margin = margin(10, 15, 10, 15)
)
evolution_stat <- rio_all %>%
mutate(
TIP_J = as.numeric(TIP_J),
U2 = as.numeric(U2),
U5 = as.numeric(U5)
) %>%
filter(TIP_J %in% c(1, 3)) %>%
mutate(
Тип_жилья = ifelse(TIP_J == 1, "Многоквартирный дом", "Частный дом"),
Оснащено = ifelse(U2 == 1 & U5 == 1, 1, 0)
) %>%
group_by(Year, Тип_жилья) %>%
summarise(
Доля = mean(Оснащено, na.rm = TRUE) * 100,
.groups = "drop"
)
ggplot(evolution_stat, aes(x = Year, y = Доля, color = Тип_жилья, group = Тип_жилья)) +
geom_line(size = 1.3) +
geom_point(size = 3.5) +
geom_text(aes(label = paste0(round(Доля, 1), "%")), vjust = -0.7, size = 3.8, show.legend = FALSE) +
scale_color_manual(values = c("#3182bd", "#31a354")) +
scale_y_continuous(expand = expansion(mult = c(0.1, 0.15))) +
labs(
title = "Динамика доли жилья с водопроводом и газом (2021–2024 гг.)",
x = "Год",
y = "Доля (%)",
color = "Тип жилья"
) +
theme_minimal(base_size = 13) +
theme(
legend.position = "bottom",
plot.title = element_text(size = 11, face = "bold"),
plot.margin = margin(10, 15, 10, 15)
)
