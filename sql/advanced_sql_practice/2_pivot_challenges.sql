USE atlas;


-- 1. How many works come from each century? Use the artist's death year to determine the century.

SELECT 
    CASE
        WHEN death BETWEEN 1800 AND 1899 THEN '1800s (19th centyry)'
        WHEN death BETWEEN 1900 AND 1999 THEN '1900s (20th centyry)'
        WHEN death BETWEEN 2000 AND 2099 THEN '2000s (21th centyry)'
        ELSE 'before 1800'
    END AS century_label,
    COUNT(*) AS num_works
FROM
    works
        JOIN
    artists USING (artist_id)
GROUP BY century_label;

    
-- 2. How many paintings in each museum?

SELECT 
    m.name, COUNT(*) as num_paintings
FROM
    works w
        JOIN
    museums m USING (museum_id)
GROUP BY museum_id;


-- 3. Show the number of paintings from each century held by each museum.

SELECT 
    m.name,
    SUM(CASE
        WHEN death BETWEEN 1400 AND 1499 THEN 1
        ELSE 0
    END) AS '15th centyry',
    SUM(CASE
        WHEN death BETWEEN 1500 AND 1599 THEN 1
        ELSE 0
    END) AS '16th centyry',
    SUM(CASE
        WHEN death BETWEEN 1600 AND 1699 THEN 1
        ELSE 0
    END) AS '17th centyry',
    SUM(CASE
        WHEN death BETWEEN 1700 AND 1799 THEN 1
        ELSE 0
    END) AS '18th centyry',
    SUM(CASE
        WHEN death BETWEEN 1800 AND 1899 THEN 1
        ELSE 0
    END) AS '19th centyry',
    SUM(CASE
        WHEN death BETWEEN 1900 AND 1999 THEN 1
        ELSE 0
    END) AS '20th centyry',
    SUM(CASE
        WHEN death BETWEEN 2000 AND 2099 THEN 1
        ELSE 0
    END) AS '21th centyry'
FROM
    works w
        JOIN
    artists a USING (artist_id)
        JOIN
    museums m USING (museum_id)
GROUP BY museum_id;


-- 4. How many paintings from each artist nationalities are held by each museum?

SELECT 
    m.name,
    SUM(CASE
        WHEN nationality = 'French' THEN 1
        ELSE 0
    END) AS 'French',
    SUM(CASE
        WHEN nationality = 'Belgian' THEN 1
        ELSE 0
    END) AS 'Belgian',
    SUM(CASE
        WHEN nationality = 'German' THEN 1
        ELSE 0
    END) AS 'German',
    SUM(CASE
        WHEN nationality = 'English' THEN 1
        ELSE 0
    END) AS 'English',
    SUM(CASE
        WHEN nationality = 'American' THEN 1
        ELSE 0
    END) AS 'American',
    SUM(CASE
        WHEN nationality = 'Italian' THEN 1
        ELSE 0
    END) AS 'Italian',
    SUM(CASE
        WHEN nationality = 'Dutch' THEN 1
        ELSE 0
    END) AS 'Dutch',
    SUM(CASE
        WHEN nationality = 'Swiss' THEN 1
        ELSE 0
    END) AS 'Swiss',
    SUM(CASE
        WHEN nationality = 'Flemish' THEN 1
        ELSE 0
    END) AS 'Flemish',
    SUM(CASE
        WHEN nationality = 'Danish' THEN 1
        ELSE 0
    END) AS 'Danish',
    SUM(CASE
        WHEN nationality = 'Spanish' THEN 1
        ELSE 0
    END) AS 'Spanish',
    SUM(CASE
        WHEN nationality = 'Mexican' THEN 1
        ELSE 0
    END) AS 'Mexican',
    SUM(CASE
        WHEN nationality = 'Russian' THEN 1
        ELSE 0
    END) AS 'Russian',
    SUM(CASE
        WHEN nationality = 'Japanese' THEN 1
        ELSE 0
    END) AS 'Japanese',
    SUM(CASE
        WHEN nationality = 'Norwegian' THEN 1
        ELSE 0
    END) AS 'Norwegian',
    SUM(CASE
        WHEN nationality = 'Austrian' THEN 1
        ELSE 0
    END) AS 'Austrian',
    SUM(CASE
        WHEN nationality = 'Canadian' THEN 1
        ELSE 0
    END) AS 'Canadian',
    SUM(CASE
        WHEN nationality = 'Irish' THEN 1
        ELSE 0
    END) AS 'Irish'
FROM
    artists a
        JOIN
    works w USING (artist_id)
        JOIN
    museums m USING (museum_id)
GROUP BY museum_id;


-- 5. For each style, display the average regular price of paintings with a width of 10-19 inches, 20-29 inches, etc.

SELECT 
    w.style,
    AVG(CASE
        WHEN width BETWEEN 10 AND 19 THEN regular_price
        ELSE Null -- we can exclude Else Null because by default it is Null if exclude
    END) AS '10-19 inch',
    AVG(CASE
        WHEN width BETWEEN 20 AND 29 THEN regular_price
        ELSE Null
    END) AS '20-29 inch',
    AVG(CASE
        WHEN width BETWEEN 30 AND 39 THEN regular_price
        ELSE Null
    END) AS '30-39 inch',
    AVG(CASE
        WHEN width BETWEEN 40 AND 49 THEN regular_price
        ELSE Null
    END) AS '40-49 inch',
    AVG(CASE
        WHEN width BETWEEN 50 AND 59 THEN regular_price
        ELSE Null
    END) AS '50-59 inch',
    AVG(CASE
        WHEN width BETWEEN 60 AND 69 THEN regular_price
        ELSE Null
    END) AS '60-69 inch',
    AVG(CASE
        WHEN width BETWEEN 70 AND 79 THEN regular_price
        ELSE Null
    END) AS '70-79 inch',
    AVG(CASE
        WHEN width BETWEEN 80 AND 89 THEN regular_price
        ELSE NULL
    END) AS '80-89 in',
    AVG(CASE
        WHEN width BETWEEN 90 AND 99 THEN regular_price
        ELSE NULL
    END) AS '90-99 in'
FROM
    works w
        JOIN
    product_prices pp USING (work_id)
        JOIN
    canvas_sizes cs USING (size_id)
WHERE
    style IS NOT NULL
GROUP BY w.style;

/* 6. Unpivot the following data, which displays the price of all paintings at various sizes. 
Exclude rows without prices in result. */

select * from pivoted_data; -- to see the pivoted_data


SELECT 
    work_id, '16 inch' AS width, `16" Long Edge` AS price
FROM
    pivoted_data
WHERE
    `16" Long Edge` IS NOT NULL 
UNION ALL SELECT 
    work_id, '19 inch' AS width, `19" Long Edge` AS price
FROM
    pivoted_data
WHERE
    `19" Long Edge` IS NOT NULL 
UNION ALL SELECT 
    work_id, 20 AS width, `20" Long Edge` AS price
FROM
    pivoted_data
WHERE
    `20" Long Edge` IS NOT NULL 
UNION ALL SELECT 
    work_id, 22 AS width, `22" Long Edge` AS price
FROM
    pivoted_data
WHERE
    `22" Long Edge` IS NOT NULL 
UNION ALL SELECT 
    work_id, 23 AS width, `23" Long Edge` AS price
FROM
    pivoted_data
WHERE
    `23" Long Edge` IS NOT NULL 
UNION ALL SELECT 
    work_id, 24 AS width, `24" Long Edge` AS price
FROM
    pivoted_data
WHERE
    `24" Long Edge` IS NOT NULL 
UNION ALL SELECT 
    work_id, 25 AS width, `25" Long Edge` AS price
FROM
    pivoted_data
WHERE
    `25" Long Edge` IS NOT NULL 
UNION ALL SELECT 
    work_id, 26 AS width, `26" Long Edge` AS price
FROM
    pivoted_data
WHERE
    `26" Long Edge` IS NOT NULL 
UNION ALL SELECT 
    work_id, 27 AS width, `27" Long Edge` AS price
FROM
    pivoted_data
WHERE
    `27" Long Edge` IS NOT NULL 
UNION ALL SELECT 
    work_id, 28 AS width, `28" Long Edge` AS price
FROM
    pivoted_data
WHERE
    `28" Long Edge` IS NOT NULL 
UNION ALL SELECT 
    work_id, 29 AS width, `29" Long Edge` AS price
FROM
    pivoted_data
WHERE
    `29" Long Edge` IS NOT NULL 
UNION ALL SELECT 
    work_id, 30 AS width, `30" Long Edge` AS price
FROM
    pivoted_data
WHERE
    `30" Long Edge` IS NOT NULL;
