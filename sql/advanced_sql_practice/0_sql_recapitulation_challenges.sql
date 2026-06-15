USE atlas;

-- 1. How many artists are in the database?

SELECT 
    COUNT(DISTINCT artist_id)
FROM
    artists;


-- 2. Create an alphabetised list of the artists.

SELECT 
    *
FROM
    artists
ORDER BY last_name ASC;


-- 3. Show only the museums in the Netherlands.

SELECT 
    *
FROM
    museums
WHERE
    country = 'Netherlands'; -- use country like 'Netherlands' if the data may contain extra words eg. the Netherlands


-- 4. Get the full name, artist ID, and nationality of artists not from the US.

SELECT 
    full_name, artist_id, nationality
FROM
    artists
WHERE
    nationality <> 'American' -- <> is same as !=
        OR nationality IS NULL; -- to show artists with missing nationality 

-- 5. Find the work with the greatest regular price.

SELECT 
    w.work_id, w.name, pp.regular_price
FROM
    works AS w
        JOIN
    product_prices AS pp ON pp.work_id = w.work_id
ORDER BY pp.regular_price DESC
LIMIT 1;

-- 6. Which works have 'love' in their name?

SELECT 
    work_id, name
FROM
    works
WHERE
    LOWER(name) LIKE '%love%'; -- otherwise WHERE name RLIKE '\\blove\\b' This finds love as a whole word. Also in MySQL, RLIKE and REGEXP mean the same thing


-- 7. Which day are the most museums open?

SELECT 
    COUNT(museum_id) AS museum_open, day
FROM
    museum_hours
GROUP BY day
ORDER BY museum_open DESC;


-- 8. Which styles have more than 1000 works?

SELECT 
    style, COUNT(work_id) AS number_of_works
FROM
    works
-- WHERE style IS NOT NULL -- use this if you don't want to include style with null because NULL is not a real style. It means missing/unknown style
GROUP BY style
HAVING COUNT(work_id) > 1000;


-- 9. How many artists there are per nationality?

SELECT 
    nationality, COUNT(artist_id) AS number_of_artists
FROM
    artists
GROUP BY nationality
ORDER BY number_of_artists DESC;



-- 10. Find the name of the museum which hosts the most paintings.

SELECT 
    m.name, COUNT(w.work_id) AS number_of_paintings
FROM
    museums AS m
        JOIN
    works AS w ON m.museum_id = w.museum_id
GROUP BY m.museum_id
ORDER BY number_of_paintings DESC
LIMIT 1;


-- 11. Which artists have a first name that starts with 'A' and is 5 letters long?

SELECT 
    full_name
FROM
    artists
WHERE
    first_name LIKE 'A____'; -- can also use WHERE first_name LIKE 'A%' AND CHAR_LENGTH(first_name) = 5;


-- 12. Find the total number of works painted by each artist.

SELECT 
    COUNT(w.work_id) AS number_of_works,
    a.artist_id,
    a.full_name
FROM
    artists a
        LEFT JOIN
    works w ON w.artist_id = a.artist_id
GROUP BY a.artist_id , a.full_name
ORDER BY number_of_works DESC;


-- 13. Find the artist that appears in the most museums.

SELECT 
    a.artist_id,
    a.full_name,
    COUNT(DISTINCT w.museum_id) AS most_museums
FROM
    artists a
        JOIN
    works w ON a.artist_id = w.artist_id
GROUP BY a.artist_id , a.full_name
ORDER BY most_museums DESC
LIMIT 1;


-- 14. Find the style with the most works.

SELECT 
     style, COUNT(work_id) AS number_of_works
FROM
    works
WHERE
    style IS NOT NULL
GROUP BY style
ORDER BY COUNT(work_id) DESC
LIMIT 1;


-- 15. Which museums are open only in the afternoon? On which days?

SELECT 
    m.name, mh.open, mh.close, mh.day
FROM
    museum_hours mh
        JOIN
    museums m ON m.museum_id = mh.museum_id
WHERE
    mh.open LIKE '%PM%' --  use WHERE mh.open >= '12:00:00' If open is stored as a real TIME value
ORDER BY mh.day , m.name;


-- 16. Which artists have works in the 'Baroque' or 'Rococo' styles?

SELECT DISTINCT
    a.full_name, w.style
FROM
    artists a
        JOIN
    works w ON w.artist_id = a.artist_id
WHERE
    w.style IN ('Baroque' , 'Rococo');
    
    
-- 17. Which works are in the 'Baroque' or 'Rococo' style and have a name that is exactly 5 characters long?

SELECT DISTINCT
    style, name
FROM
    works 
WHERE
    style IN ('Baroque' , 'Rococo')
        AND name LIKE '_____'; -- also works AND CHAR_LENGTH(w.name) = 5


-- 18. Classify artists as 'Local' if they are Flemish, 'Nearby' if they are Dutch, and 'International' otherwise.

SELECT 
    full_name,
    nationality,
    CASE
        WHEN nationality = 'Flemish' THEN 'Local'
        WHEN nationality = 'Dutch' THEN 'Nearby'
        ELSE 'International'
    END AS artists_nationality_classify
FROM
    artists;


-- 19. Find the average price for each size of product.

SELECT 
    size_id,
    ROUND(AVG(sale_price),1) AS average_sale_price,
    ROUND(AVG(regular_price), 1) AS average_regular_price
FROM
    product_prices
GROUP BY size_id;


-- 20. Find the paiting (name and artist) with the most subjects.

SELECT 
    w.work_id,
    a.full_name,
    w.name,
    COUNT(DISTINCT s.subject) AS number_of_subjects
FROM
    artists a
        JOIN
    works w ON w.artist_id = a.artist_id
        JOIN
    subjects s ON w.work_id = s.work_id
GROUP BY w.work_id , a.full_name , w.name
ORDER BY number_of_subjects DESC;
        

-- 21. How many days a week is each museum open?

SELECT 
    m.museum_id, m.name, COUNT(mh.day) AS days_open
FROM
    museums m
        LEFT JOIN
    museum_hours mh USING (museum_id)
GROUP BY m.museum_id , m.name;


-- 22. Find the average sale price for each style of work. Only include styles with between 100 and 500 paintings.

SELECT 
    w.style,
    ROUND(AVG(pp.sale_price), 1) AS avg_sale_price,
    COUNT(DISTINCT w.work_id) AS number_of_paintings
FROM
    works AS w
        JOIN
    product_prices AS pp ON w.work_id = pp.work_id
WHERE
    w.style IS NOT NULL
GROUP BY w.style
HAVING COUNT(DISTINCT w.work_id) BETWEEN 100 AND 500;


/* 23. Find the average sale price of works by each artist. 
Add an extra column categorising the artists into 'High', 'Medium', 'Low' based on the average sale price.
High is more than 500, Low is less than 100. */

SELECT 
    artist_id,
    full_name,
    ROUND(AVG(sale_price), 2) AS avg_sale_price,
    CASE
        WHEN AVG(sale_price) > 500 THEN 'High'
        WHEN AVG(sale_price) < 100 THEN 'Low'
        ELSE 'Medium'
    END AS artist_category
FROM
    artists
        JOIN
    works USING (artist_id)
        JOIN
    product_prices USING (work_id)
GROUP BY artist_id , full_name;
