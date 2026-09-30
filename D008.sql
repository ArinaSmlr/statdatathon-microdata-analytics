WITH unpivoted_demography AS (
    -- 1. Читаем все года, приводим коды к числам и разворачиваем колонки в строки за один проход
    UNPIVOT (
        SELECT 
            regexp_extract(filename, '.*\\([0-9]{4})\\', 1) AS yr,
            K::INTEGER AS local_k,
            rodstvo::INTEGER AS rodstvo,
            pol::INTEGER AS pol,
            sem_pol::INTEGER AS sem_pol,
            urov::INTEGER AS urov,
            status::INTEGER AS status
        FROM read_csv('C:/Users/smoly/Downloads/synthetic_microdata_2021-2024_20260921/synthetic_microdata_2021-2024_20260921/d008/**/*.csv', union_by_name=true, filename=true, ignore_errors=true)
    )
    ON rodstvo, pol, sem_pol, urov, status
    INTO NAME group_name VALUE kod
),
translated_data AS (
    -- 2. Переводим коды вопросов и ответов на человеческий язык по вашему справочнику
    SELECT 
        yr, local_k, kod,
        CASE group_name
            WHEN 'rodstvo' THEN '1. Отношение к главе хозяйства'
            WHEN 'pol' THEN '2. Пол'
            WHEN 'sem_pol' THEN '3. Семейное положение'
            WHEN 'urov' THEN '4. Уровень образования'
            WHEN 'status' THEN '5. Статус деятельности'
        END AS vopros,
        CASE group_name
            WHEN 'rodstvo' THEN 1 WHEN 'pol' THEN 2 WHEN 'sem_pol' THEN 3 WHEN 'urov' THEN 4 WHEN 'status' THEN 5
        END AS sort_order,
        CASE group_name
            WHEN 'rodstvo' THEN 
                CASE kod 
                    WHEN 1 THEN 'глава домашнего хозяйства' WHEN 2 THEN 'муж, жена' WHEN 3 THEN 'сын, дочь'
                    WHEN 4 THEN 'отец, мать' WHEN 5 THEN 'брат, сестра' WHEN 6 THEN 'дедушка, бабушка'
                    WHEN 7 THEN 'внук, внучка' WHEN 8 THEN 'другая степень родства' WHEN 9 THEN 'не родственник'
                END
            WHEN 'pol' THEN 
                CASE kod WHEN 1 THEN 'мужской' WHEN 2 THEN 'женский' END
            WHEN 'sem_pol' THEN 
                CASE kod 
                    WHEN 1 THEN 'никогда не состоял(а) в браке' WHEN 2 THEN 'состоит в браке'
                    WHEN 3 THEN 'вдовец, вдова' WHEN 4 THEN 'разведен(а)'
                END
            WHEN 'urov' THEN 
                CASE kod 
                    WHEN 1 THEN 'дошкольное' WHEN 2 THEN 'начальное' WHEN 3 THEN 'основное среднее'
                    WHEN 4 THEN 'среднее (общее, ТиПО)' WHEN 5 THEN 'высшее' WHEN 6 THEN 'послевузовское' WHEN 7 THEN 'никакого уровня'
                END
            WHEN 'status' THEN 
                CASE kod 
                    WHEN 1 THEN 'работает по найму' WHEN 2 THEN 'работает не по найму' WHEN 3 THEN 'безработный (ищет работу)'
                    WHEN 4 THEN 'пенсионер' WHEN 5 THEN 'учащийся, студент' WHEN 6 THEN 'домашнее хозяйство, уход за детьми'
                    WHEN 7 THEN 'нетрудоспособный' WHEN 8 THEN 'не работает и не ищет (др. причины)'
                END
        END AS otvet
    FROM unpivoted_demography
    WHERE kod IS NOT NULL AND yr IS NOT NULL AND yr != ''
),
aggregated AS (
    -- 3. Считаем количество человек для каждого ответа
    SELECT 
        yr, local_k, vopros, sort_order, otvet, kod,
        COUNT(*) AS chel
    FROM translated_data
    WHERE otvet IS NOT NULL
    GROUP BY yr, local_k, vopros, sort_order, otvet, kod
)
-- 4. Формируем финальную таблицу с расчетом процентов отдельно для Города и Села внутри каждого года
SELECT 
    yr AS "Год",
    CASE WHEN local_k = 1 THEN 'Город' ELSE 'Село' END AS "Местность",
    vopros AS "Категория",
    otvet AS "Вариант ответа",
    chel AS "Человек (абс.)",
    ROUND(100.0 * chel / SUM(chel) OVER (PARTITION BY yr, local_k, vopros), 1) AS "Процент (%)"
FROM aggregated
ORDER BY yr, local_k, sort_order, kod;
