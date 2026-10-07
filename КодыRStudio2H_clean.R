library(tidyverse)
df_g1 <- df_all %>%
  mutate(
    missing_tdp_count = rowSums(across(starts_with("TDP"), ~ is.na(.x) | .x == "2"), na.rm = TRUE),
    fin_vulnerable = if_else(missing_tdp_count > median(missing_tdp_count, na.rm = TRUE), 1, 0),
    family_type = case_when(
      n_children == 0 ~ "Без детей",
      n_children %in% c(1, 2) ~ "1–2 ребенка",
      n_children >= 3 ~ "Многодетные (3+)",
      TRUE ~ "Другое"
    )
  )
g1_data <- df_g1 %>%
  group_by(family_type) %>%
  summarise(
    vulnerability_rate = round(mean(fin_vulnerable == 1, na.rm = TRUE) * 100, 1),
    .groups = "drop"
  )
ggplot(g1_data, aes(x = family_type, y = vulnerability_rate, fill = family_type)) +
  geom_col(width = 0.5, show.legend = FALSE) +
  geom_text(aes(label = paste0(vulnerability_rate, "%")), vjust = -0.5, fontface = "bold", size = 4.5) +
  scale_y_continuous(limits = c(0, 60)) +
  scale_fill_brewer(palette = "Set2") +
  labs(
    title = "Доля финансово уязвимых семей по типам семей",
    subtitle = "Сравнение домохозяйств без детей, с 1–2 детьми и многодетных",
    x = "Состав / тип семьи",
    y = "Процент уязвимых семей (%)"
  ) +
  theme_minimal(base_size = 13)
df_g2 <- df_all %>%
  mutate(
    missing_tdp_count = rowSums(across(starts_with("TDP"), ~ is.na(.x) | .x == "2"), na.rm = TRUE),
    fin_vulnerable = if_else(missing_tdp_count > median(missing_tdp_count, na.rm = TRUE), 1, 0),
    edu_level = case_when(
      head_edu %in% c(1, 2) ~ "Высшее / Послевузовское",
      head_edu %in% c(3, 4) ~ "Среднее специальное",
      head_edu >= 5 ~ "Среднее и ниже",
      TRUE ~ "Не указано"
    )
  )
g2_data <- df_g2 %>%
  filter(edu_level != "Не указано") %>%
  group_by(edu_level) %>%
  summarise(
    vulnerability_rate = round(mean(fin_vulnerable == 1, na.rm = TRUE) * 100, 1),
    .groups = "drop"
  )
ggplot(g2_data, aes(x = edu_level, y = vulnerability_rate, fill = edu_level)) +
  geom_col(width = 0.5, show.legend = FALSE) +
  geom_text(aes(label = paste0(vulnerability_rate, "%")), vjust = -0.5, fontface = "bold", size = 4.5) +
  scale_y_continuous(limits = c(0, 60)) +
  scale_fill_brewer(palette = "Pastel1") +
  labs(
    title = "Доля уязвимых семей по уровню образования главы семьи",
    subtitle = "Человеческий капитал главы семьи и финансовая устойчивость",
    x = "Образование главы семьи",
    y = "Процент уязвимых семей (%)"
  ) +
  theme_minimal(base_size = 13)
df_g3 <- df_all %>%
  mutate(
    missing_tdp_count = rowSums(across(starts_with("TDP"), ~ is.na(.x) | .x == "2"), na.rm = TRUE),
    fin_vulnerable = if_else(missing_tdp_count > median(missing_tdp_count, na.rm = TRUE), 1, 0),
    sq_m_category = case_when(
      sq_m_per_cap < 15 ~ "1. До 15 м² (Тесно)",
      sq_m_per_cap >= 15 & sq_m_per_cap <= 25 ~ "2. 15–25 м² (Норма)",
      sq_m_per_cap > 25 ~ "3. Свыше 25 м² (Просторное)",
      TRUE ~ "Не указано"
    )
  )
g3_data <- df_g3 %>%
  filter(sq_m_category != "Не указано") %>%
  group_by(sq_m_category) %>%
  summarise(
    vulnerability_rate = round(mean(fin_vulnerable == 1, na.rm = TRUE) * 100, 1),
    .groups = "drop"
  )
ggplot(g3_data, aes(x = sq_m_category, y = vulnerability_rate, fill = sq_m_category)) +
  geom_col(width = 0.5, show.legend = FALSE) +
  geom_text(aes(label = paste0(vulnerability_rate, "%")), vjust = -0.5, fontface = "bold", size = 4.5) +
  scale_y_continuous(limits = c(0, 60)) +
  scale_fill_manual(values = c("#E53935", "#FFB300", "#4CAF50")) +
  labs(
    title = "Доля уязвимых семей по обеспеченности жилой площадью",
    subtitle = "Условия проживания: квадратные метры на 1 человека",
    x = "Категория площади на 1 человека",
    y = "Процент уязвимых семей (%)"
  ) +
  theme_minimal(base_size = 13)
df_g4 <- df_all %>%
  mutate(
    missing_tdp_count = rowSums(across(starts_with("TDP"), ~ is.na(.x) | .x == "2"), na.rm = TRUE),
    fin_vulnerable = if_else(missing_tdp_count > median(missing_tdp_count, na.rm = TRUE), 1, 0),
    family_type = case_when(
      n_children == 0 ~ "Без детей",
      n_children %in% c(1, 2) ~ "1–2 ребенка",
      n_children >= 3 ~ "Многодетные (3+)",
      TRUE ~ "Другое"
    )
  )
g4_data <- df_g4 %>%
  group_by(year, family_type) %>%
  summarise(
    vulnerability_rate = round(mean(fin_vulnerable == 1, na.rm = TRUE) * 100, 1),
    .groups = "drop"
  )
ggplot(g4_data, aes(x = factor(year), y = vulnerability_rate, color = family_type, group = family_type)) +
  geom_line(size = 1.2) +
  geom_point(size = 3) +
  geom_text(aes(label = paste0(vulnerability_rate, "%")), vjust = -0.8, fontface = "bold", show.legend = FALSE) +
  scale_y_continuous(limits = c(0, 60)) +
  scale_color_manual(values = c("Без детей" = "#2B5C8F", "1–2 ребенка" = "#E67E22", "Многодетные (3+)" = "#D9534F")) +
  labs(
    title = "Динамика финансовой уязвимости по типам семей (2021–2024)",
    subtitle = "Проверка устойчивости различий между группами во времени",
    x = "Год опроса",
    y = "Процент уязвимых семей (%)",
    color = "Тип семьи"
  ) +
  theme_minimal(base_size = 13) +
  theme(legend.position = "bottom")
df_g5 <- df_all %>%
  mutate(
    missing_tdp_count = rowSums(across(starts_with("TDP"), ~ is.na(.x) | .x == "2"), na.rm = TRUE),
    fin_vulnerable = if_else(missing_tdp_count > median(missing_tdp_count, na.rm = TRUE), 1, 0),
    head_gender = if_else(head_pol == 1, "Мужчина", "Женщина"),
    age_group = case_when(
      head_age < 35 ~ "Молодые (до 35 лет)",
      head_age >= 35 & head_age <= 60 ~ "Средний возраст (35–60)",
      head_age > 60 ~ "Пожилые (старше 60)",
      TRUE ~ "Не указано"
    )
  )
g5_data <- df_g5 %>%
  filter(!is.na(head_pol), age_group != "Не указано") %>%
  group_by(age_group, head_gender) %>%
  summarise(
    vulnerability_rate = round(mean(fin_vulnerable == 1, na.rm = TRUE) * 100, 1),
    .groups = "drop"
  )
ggplot(g5_data, aes(x = age_group, y = vulnerability_rate, fill = head_gender)) +
  geom_col(position = position_dodge(width = 0.8), width = 0.7) +
  geom_text(
    aes(label = paste0(vulnerability_rate, "%")),
    position = position_dodge(width = 0.8),
    vjust = -0.5,
    fontface = "bold",
    size = 3.8
  ) +
  scale_y_continuous(limits = c(0, 60)) +
  scale_fill_manual(values = c("Мужчина" = "#3498DB", "Женщина" = "#E74C3C"), name = "Пол главы семьи") +
  labs(
    title = "Уязвимость по полу и возрасту главы домохозяйства",
    subtitle = "Социально-демографический профиль главы семьи",
    x = "Возрастная группа главы семьи",
    y = "Процент уязвимых семей (%)"
  ) +
  theme_minimal(base_size = 13) +
  theme(legend.position = "bottom")
df_g6 <- df_all %>%
  mutate(
    missing_tdp_count = rowSums(across(starts_with("TDP"), ~ is.na(.x) | .x == "2"), na.rm = TRUE),
    fin_vulnerable = if_else(missing_tdp_count > median(missing_tdp_count, na.rm = TRUE), 1, 0),
    dep_category = case_when(
      dep_ratio == 0 ~ "1. Без иждивенцев (0%)",
      dep_ratio > 0 & dep_ratio <= 0.5 ~ "2. Умеренная нагрузка (до 50%)",
      dep_ratio > 0.5 ~ "3. Высокая нагрузка (> 50%)",
      TRUE ~ "Не указано"
    )
  )
g6_data <- df_g6 %>%
  filter(dep_category != "Не указано") %>%
  group_by(dep_category) %>%
  summarise(
    vulnerability_rate = round(mean(fin_vulnerable == 1, na.rm = TRUE) * 100, 1),
    .groups = "drop"
  )
ggplot(g6_data, aes(x = dep_category, y = vulnerability_rate, fill = dep_category)) +
  geom_col(width = 0.5, show.legend = FALSE) +
  geom_text(aes(label = paste0(vulnerability_rate, "%")), vjust = -0.5, fontface = "bold", size = 4.5) +
  scale_y_continuous(limits = c(0, 60)) +
  scale_fill_manual(values = c("1. Без иждивенцев (0%)" = "#2ECC71", "2. Умеренная нагрузка (до 50%)" = "#F39C12", "3. Высокая нагрузка (> 50%)" = "#E74C3C")) +
  labs(
    title = "Уязвимость по уровню демографической нагрузки",
    subtitle = "Соотношение иждивенцев (детей и пожилых) к общему размеру семьи",
    x = "Категория демографической нагрузки",
    y = "Процент уязвимых семей (%)"
  ) +
  theme_minimal(base_size = 13)
df_g7 <- df_all %>%
  mutate(
    missing_tdp_count = rowSums(across(starts_with("TDP"), ~ is.na(.x) | .x == "2"), na.rm = TRUE),
    fin_vulnerable = if_else(missing_tdp_count > median(missing_tdp_count, na.rm = TRUE), 1, 0),
    has_full_utilities = if_else(U1 == "1" & U2 == "1" & U3 == "1", "Полное благоустройство", "Частичное / Отсутствует", missing = "Частичное / Отсутствует")
  )
g7_data <- df_g7 %>%
  group_by(has_full_utilities) %>%
  summarise(
    vulnerability_rate = round(mean(fin_vulnerable == 1, na.rm = TRUE) * 100, 1),
    .groups = "drop"
  )
ggplot(g7_data, aes(x = has_full_utilities, y = vulnerability_rate, fill = has_full_utilities)) +
  geom_col(width = 0.4, show.legend = FALSE) +
  geom_text(aes(label = paste0(vulnerability_rate, "%")), vjust = -0.5, fontface = "bold", size = 4.5) +
  scale_y_continuous(limits = c(0, 60)) +
  scale_fill_manual(values = c("Полное благоустройство" = "#27AE60", "Частичное / Отсутствует" = "#C0392B")) +
  labs(
    title = "Уязвимость по благоустройству жилья",
    subtitle = "Условия проживания: наличие центрального водопровода, канализации и отопления",
    x = "Уровень благоустройства жилья",
    y = "Процент уязвимых семей (%)"
  ) +
  theme_minimal(base_size = 13)
library(broom)
df_model <- df_all %>%
  mutate(
    missing_tdp_count = rowSums(across(starts_with("TDP"), ~ is.na(.x) | .x == "2"), na.rm = TRUE),
    fin_vulnerable = if_else(missing_tdp_count > median(missing_tdp_count, na.rm = TRUE), 1, 0),
    family_type = factor(case_when(
      n_children == 0 ~ "1. Без детей",
      n_children %in% c(1, 2) ~ "2. 1-2 ребенка",
      n_children >= 3 ~ "3. Многодетные (3+)"
    )),
    edu_level = factor(case_when(
      head_edu %in% c(1, 2) ~ "1. Высшее",
      head_edu %in% c(3, 4) ~ "2. Среднее специальное",
      head_edu >= 5 ~ "3. Среднее и ниже"
    )),
    gender = factor(if_else(head_pol == 1, "Мужчина", "Женщина")),
    year_factor = factor(year)
  )
model_logit <- glm(
  fin_vulnerable ~ family_type + edu_level + sq_m_per_cap + head_age + gender + dep_ratio + year_factor,
  data = df_model,
  family = binomial(link = "logit")
)
or_clean <- tidy(model_logit, exponentiate = TRUE, conf.int = TRUE) %>%
  filter(!term %in% c("(Intercept)", "year_factor2022", "year_factor2023", "year_factor2024")) %>%
  mutate(
    term_ru = case_when(
      term == "dep_ratio" ~ "Высокая доля иждивенцев в семье",
      term == "edu_level3. Среднее и ниже" ~ "Образование главы: Среднее и ниже",
      term == "edu_level2. Среднее специальное" ~ "Образование главы: Среднее специальное",
      term == "head_age" ~ "Возраст главы семьи",
      term == "sq_m_per_cap" ~ "Площадь жилья на 1 человека (кв. м)",
      term == "genderМужчина" ~ "Глава семьи — мужчина",
      term == "family_type2. 1-2 ребенка" ~ "Семья с 1–2 детьми",
      term == "family_type3. Многодетные (3+)" ~ "Многодетная семья (3+ детей)",
      TRUE ~ term
    )
  )
p_clean <- ggplot(or_clean, aes(x = reorder(term_ru, estimate), y = estimate, ymin = conf.low, ymax = conf.high)) +
  geom_hline(yintercept = 1, linetype = "dashed", color = "#E53935", size = 0.9) +
  geom_pointrange(color = "#1976D2", size = 0.8) +
  geom_text(aes(label = round(estimate, 2)), vjust = -0.7, size = 3.8, fontface = "bold") +
  coord_flip() +
  labs(
    title = "Влияние факторов на вероятность финансовой уязвимости",
    subtitle = "Значение > 1 повышает риск дефицита, значение < 1 снижает риск",
    x = "Факторы домохозяйства",
    y = "Отношение шансов (Odds Ratio)"
  ) +
  theme_minimal(base_size = 13)
df_g1_prob <- df_all %>%
  mutate(
    missing_tdp_count = rowSums(across(starts_with("TDP"), ~ is.na(.x) | .x == "2"), na.rm = TRUE),
    fin_vulnerable = if_else(missing_tdp_count > median(missing_tdp_count, na.rm = TRUE), 1, 0),
    family_type = factor(case_when(
      n_children == 0 ~ "Без детей",
      n_children %in% c(1, 2) ~ "1–2 ребенка",
      n_children >= 3 ~ "Многодетные (3+)"
    ))
  )
p1_prob <- ggplot(
  df_g1_prob %>% filter(sq_m_per_cap <= 60),
  aes(x = sq_m_per_cap, y = fin_vulnerable, color = family_type, fill = family_type)
) +
  geom_smooth(method = "glm", method.args = list(family = "binomial"), size = 1.2, alpha = 0.15) +
  scale_y_continuous(labels = scales::percent_format(), limits = c(0, 0.6)) +
  scale_color_manual(values = c("Без детей" = "#2E7D32", "1–2 ребенка" = "#F57C00", "Многодетные (3+)" = "#C62828")) +
  scale_fill_manual(values = c("Без детей" = "#2E7D32", "1–2 ребенка" = "#F57C00", "Многодетные (3+)" = "#C62828")) +
  labs(
    title = "Вероятность уязвимости в зависимости от площади жилья",
    subtitle = "Сравнение траекторий для семей разного состава (до 60 кв. м на чел.)",
    x = "Жилая площадь на 1 человека (кв. м)",
    y = "Вероятность финансовой уязвимости (%)",
    color = "Тип семьи",
    fill = "Тип семьи"
  ) +
  theme_minimal(base_size = 13) +
  theme(legend.position = "bottom")
df_heatmap <- df_all %>%
  mutate(
    missing_tdp_count = rowSums(across(starts_with("TDP"), ~ is.na(.x) | .x == "2"), na.rm = TRUE),
    fin_vulnerable = if_else(missing_tdp_count > median(missing_tdp_count, na.rm = TRUE), 1, 0),
    family_type = factor(case_when(
      n_children == 0 ~ "Без детей",
      n_children %in% c(1, 2) ~ "1–2 ребенка",
      n_children >= 3 ~ "Многодетные (3+)"
    )),
    edu_level = factor(case_when(
      head_edu %in% c(1, 2) ~ "Высшее",
      head_edu %in% c(3, 4) ~ "Среднее спец.",
      head_edu >= 5 ~ "Среднее и ниже"
    ))
  )
heat_data <- df_heatmap %>%
  filter(!is.na(edu_level), !is.na(family_type)) %>%
  group_by(edu_level, family_type) %>%
  summarise(
    vulnerability_rate = round(mean(fin_vulnerable == 1, na.rm = TRUE) * 100, 1),
    .groups = "drop"
  )
p2_heat <- ggplot(heat_data, aes(x = family_type, y = edu_level, fill = vulnerability_rate)) +
  geom_tile(color = "white", size = 1) +
  geom_text(aes(label = paste0(vulnerability_rate, "%")), color = "black", fontface = "bold", size = 5) +
  scale_fill_gradient(low = "#C8E6C9", high = "#FF8A80", name = "% уязвимости") +
  labs(
    title = "Матрица финансовой уязвимости домохозяйств",
    subtitle = "Пересечение образования главы семьи и количества детей",
    x = "Тип семьи (состав)",
    y = "Образование главы семьи"
  ) +
  theme_minimal(base_size = 13) +
  theme(panel.grid = element_blank())
df_profiles <- df_all %>%
  mutate(
    missing_tdp_count = rowSums(across(starts_with("TDP"), ~ is.na(.x) | .x == "2"), na.rm = TRUE),
    fin_vulnerable = if_else(missing_tdp_count > median(missing_tdp_count, na.rm = TRUE), 1, 0),
    profile = case_when(
      head_edu %in% c(1, 2) & n_children == 0 & sq_m_per_cap > 25 ~ "1. Высшее обр. + Без детей + Просторное жилье",
      head_edu %in% c(1, 2) & n_children >= 1 & sq_m_per_cap >= 15 ~ "2. Высшее обр. + Дети + Среднее жилье",
      head_edu >= 3 & n_children >= 1 & sq_m_per_cap < 15 ~ "3. Среднее обр. + Дети + Тесное жилье (<15 м²)",
      head_edu >= 5 & n_children >= 3 & sq_m_per_cap < 15 ~ "4. Низкое обр. + Многодетные + Тесное жилье",
      TRUE ~ NA_character_
    )
  )
profile_data <- df_profiles %>%
  filter(!is.na(profile)) %>%
  group_by(profile) %>%
  summarise(
    vulnerability_rate = round(mean(fin_vulnerable == 1, na.rm = TRUE) * 100, 1),
    total_count = n(),
    .groups = "drop"
  )
p3_profiles <- ggplot(profile_data, aes(x = reorder(profile, vulnerability_rate), y = vulnerability_rate, fill = profile)) +
  geom_col(width = 0.6, show.legend = FALSE) +
  geom_text(aes(label = paste0(vulnerability_rate, "%")), hjust = -0.2, fontface = "bold", size = 4) +
  scale_y_continuous(limits = c(0, 70)) +
  scale_fill_manual(values = c("#2E7D32", "#81C784", "#FFB74D", "#D32F2F")) +
  coord_flip() +
  labs(
    title = "Уровень уязвимости для ключевых профилей домохозяйств",
    subtitle = "Сравнение комбинированного влияния образования, детей и жилья",
    x = "Типовой профиль домохозяйства",
    y = "Процент уязвимых семей (%)"
  ) +
  theme_minimal(base_size = 13)
