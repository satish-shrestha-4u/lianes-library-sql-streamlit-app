USE atlas;

-- 1. How many more Impressionism paitings are there than Rococo paintings?

-- CTEs method
	With  impressionism AS (
							select count(*) as num_imp 
                            from works 
							where style = 'Impressionism'),
		   rococo AS (
						select count(*) as num_roc 
                        from works 
                        where style = 'Rococo')
	SELECT (num_imp - num_roc) as difference from impressionism, rococo;

-- subqueries way
SELECT 
    (SELECT 
            COUNT(*)
        FROM
            works
        WHERE
            style = 'Impressionism'
	)
	- 
	(SELECT 
            COUNT(*)
        FROM
            works
        WHERE
            style = 'Rococo') as difference;


-- 2. How many canvases have a greater width than the average width?

-- subquery method
SELECT 
    COUNT(*) AS number_or_canvases
FROM
    canvas_sizes
WHERE
    width > (SELECT 
            AVG(width)
        FROM
            canvas_sizes);         
            
-- 3. What is the percentage of artists working in each style?

WITH style_counts AS (
    SELECT 
        style,
        COUNT(artist_id) AS number_of_artists
    FROM artists
    GROUP BY style
),
total_artists AS (
    SELECT 
        sum(number_of_artists) AS total_number_of_artists
    FROM style_counts
)
SELECT 
    sc.style,
    sc.number_of_artists,
    ROUND(100 * sc.number_of_artists / ta.total_number_of_artists, 2) AS percentage_of_artists
FROM style_counts sc
CROSS JOIN total_artists ta;

-- Subquery method

SELECT 
    style,
    COUNT(*) / (SELECT 
            COUNT(*)
        FROM
            artists) * 100 AS PercentageArtists
FROM
    artists
GROUP BY style;


-- 4. Can you check that the column of percentages adds up to 100%?

WITH style_counts AS (
    SELECT 
        style,
        COUNT(artist_id) AS number_of_artists
    FROM artists
    GROUP BY style
),
total_artists AS (
    SELECT 
        sum(number_of_artists) AS total_number_of_artists
    FROM style_counts
),
percentage as (SELECT 
    sc.style,
    sc.number_of_artists,
    ROUND(100 * sc.number_of_artists / ta.total_number_of_artists, 2) AS percentage_of_artists
FROM style_counts sc
CROSS JOIN total_artists ta
ORDER BY percentage_of_artists DESC)

select sum(percentage_of_artists) from percentage;

-- Another way

WITH TableOfPercentages AS (
	SELECT 
		style, 
		COUNT(*) / (SELECT COUNT(*) FROM artists) * 100 AS PercentageArtists
	FROM
		artists
	GROUP BY style
)
SELECT SUM(PercentageArtists)
FROM TableOfPercentages;

-- 5. What is the difference between the greatest number of artists in a style and the least?

-- CTEs way
WITH style_counts AS (
					select style, 
                    count(artist_id) as num_of_artists 
                    from artists 
                    group by style)
select 
Max(num_of_artists)-Min(num_of_artists) as difference 
from style_counts;

-- Subquery way
SELECT 
    MAX(num_of_artists) - MIN(num_of_artists) AS difference
FROM
    (SELECT 
        style, COUNT(artist_id) AS num_of_artists
    FROM
        artists
    GROUP BY style) AS style_counts;


-- 6. Assuming an artist works at a steady pace over their entire lifetime, what is the average number of paintings produced per year by an artist?

-- CTE way
with num_of_work as (
					select 
                    artist_id, 
                    count(work_id) as num_work 
                    from works group by artist_id),

	life as (
			select 
            artist_id, 
            full_name, 
            (death-birth) as life_span 
            from artists)
           -- WHERE birth IS NOT NULL AND death IS NOT NULL AND death > birth

select 
artist_id, 
full_name, 
(num_work/life_span) as paintings_per_year 
from num_of_work 
join life using (artist_id);

-- Alternative Normal Join Way

SELECT 
    a.artist_id,
    a.full_name,
    COUNT(w.work_id) AS number_of_paintings,
    a.death - a.birth AS years_lived,
    ROUND(COUNT(w.work_id) / (a.death - a.birth), 2) AS paintings_per_year
FROM artists AS a
JOIN works AS w
    ON a.artist_id = w.artist_id
WHERE a.birth IS NOT NULL
  AND a.death IS NOT NULL
  AND a.death > a.birth
GROUP BY 
    a.artist_id,
    a.full_name,
    a.birth,
    a.death
ORDER BY paintings_per_year DESC;


-- Alternative way

SELECT ROUND(AVG(WorksYearly), 2) AS AvgLifetimeRate
FROM (
    SELECT 
		artist_id,
		COUNT(*) / (death - birth) AS WorksYearly
    FROM 
		works
			JOIN 
		artists USING (artist_id)
    GROUP BY artist_id
) AS LifetimeRateArtists;

/* 7. Which days are the most museums open? We've answered this before, but there's no clear #1. 
Use a subquery or CTE to display *all* the days where the most museums are open. */

with daily_counts as (SELECT 
        day, COUNT(museum_id) AS num_of_open_museums
    FROM
        museum_hours
    GROUP BY day)
SELECT day, num_of_open_museums from daily_counts 
where num_of_open_museums = (select max(num_of_open_museums) from daily_counts);

-- Alternative way

SELECT 
	`day`, COUNT(*) AS open_museums
FROM
	museum_hours
GROUP BY `day`
HAVING COUNT(*) = (
		SELECT 
			COUNT(*) AS open_museums
		FROM
			museum_hours
		GROUP BY `day`
		ORDER BY open_museums DESC
        LIMIT 1
);


-- 8. Are there any artists with at least one painting in every museum? 

SELECT 
    artist_id, COUNT(DISTINCT w.museum_id) AS num_of_museums
FROM
    artists a
        JOIN
    works w USING (artist_id)
WHERE
    w.museum_id IS NOT NULL
GROUP BY artist_id
HAVING COUNT(DISTINCT w.museum_id) = (SELECT 
        COUNT(*)
    FROM
        museums);

-- Alternative way

SELECT 
	COUNT(*) AS artists_in_all_museums
FROM (
	SELECT artist_id, COUNT(DISTINCT museum_id) num_museums
	FROM works 
	GROUP BY artist_id
) AS ArtistMuseumCounts
WHERE 
	num_museums = (SELECT COUNT(*) FROM museums);


-- 9. What percentage of each artist's works are held in a museum? 

with artist_total as (
					SELECT 
                    artist_id, 
                    COUNT(*) as total_works
					FROM works
					GROUP BY artist_id),
                    
	artist_museum as (
					select artist_id, 
					count(*) as work_in_museum -- or use count(museum_id) and no need to use COALESCE
					from works 
					where museum_id is not Null 
					group by artist_id)
select 	artist_id,
		total_works, 
        COALESCE(work_in_museum, 0) AS work_in_museum, -- to replace null value with 0
        100 * (coalesce (work_in_museum, 0) / total_works) as percentage 
        from artist_total 
        left join 
        artist_museum using (artist_id);



-- 10. What percentage of artists have ALL of their works in a museum?


WITH artist_stats AS (
    SELECT 
        artist_id,
        COUNT(*) AS total_works,
        COUNT(museum_id) AS works_in_museum
    FROM works
    GROUP BY artist_id
),
artists_all_in_museum AS (
    SELECT artist_id
    FROM artist_stats
    WHERE total_works = works_in_museum
)
SELECT 
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM artist_stats), 2)
        AS pct_artists_all_works_in_museum
FROM artists_all_in_museum;

/* 11. Does length of life correlate with the number of paintings created? 
Try grouping artists into age brackets when solving this problem. */

WITH artist_work_counts AS (
    SELECT 
        a.artist_id,
        a.full_name,
        a.death - a.birth AS life_span,
        COUNT(w.work_id) AS number_of_paintings
    FROM artists AS a
    JOIN works AS w
        ON a.artist_id = w.artist_id
    GROUP BY 
        a.artist_id,
        a.full_name,
        a.birth,
        a.death
),
age_brackets AS (
    SELECT 
        artist_id,
        full_name,
        life_span,
        number_of_paintings,
        CASE
            WHEN life_span < 30 THEN 'Under 30'
            WHEN life_span BETWEEN 30 AND 39 THEN '30-39'
            WHEN life_span BETWEEN 40 AND 49 THEN '40-49'
            WHEN life_span BETWEEN 50 AND 59 THEN '50-59'
            WHEN life_span BETWEEN 60 AND 69 THEN '60-69'
            WHEN life_span BETWEEN 70 AND 79 THEN '70-79'
            ELSE '80+'
        END AS age_bracket
    FROM artist_work_counts
)
SELECT 
    age_bracket,
    COUNT(artist_id) AS number_of_artists,
    ROUND(AVG(number_of_paintings), 2) AS avg_paintings_per_artist,
    MIN(number_of_paintings) AS min_paintings,
    MAX(number_of_paintings) AS max_paintings
FROM age_brackets
GROUP BY age_bracket
ORDER BY 
    CASE age_bracket
        WHEN 'Under 30' THEN 1
        WHEN '30-39' THEN 2
        WHEN '40-49' THEN 3
        WHEN '50-59' THEN 4
        WHEN '60-69' THEN 5
        WHEN '70-79' THEN 6
        WHEN '80+' THEN 7
    END;

-- Alternative way

SELECT 
	FLOOR(age / 10) * 10 AS age, 
    AVG(TotalWorks) AS AvgWorks
FROM (
	SELECT artist_id, death - birth AS age, COUNT(*) AS TotalWorks
	FROM works
	JOIN artists USING (artist_id)
	GROUP BY artist_id
) AS ArtistWorksAges
GROUP BY FLOOR(age / 10) * 10
ORDER BY age;

/***** BONUS
Classify museum opening hours as 'Short', 'Medium', or 'Long' based on their length.
Long is 10 hours or more in a day. Short is less than 6 hours.
For each day of the week, count the number of museums open in each category.
e.g. On Monday, 2 museums are open for a short time, 27 are open for a medium time, and 0 are open for a long time.
*****/ 

with hours_opened as(
	SELECT 
    museum_id,
    day,
    open,
    close,
    round(
    TIMESTAMPDIFF(
    Minute,  
    str_to_date(open, '%h:%i %p'),
    str_to_date(close, '%h:%i %p')
    ) / 60,2) as hours_open
FROM
    museum_hours),
classified as(
select museum_id,
		day,
		open,
		close,
        hours_open,
		case 
        when hours_open >= 10 then 'Long'
		when hours_open < 6 then  'Short'
        else 'Medium'
        end as class_length
        from hours_opened)

select
    day,
	class_length, 
    count(museum_id) as num_of_museums 
    from classified 
    group by day, class_length
    order by day, class_length;
    
    
    -- Other way to show the tabel as Pivoted Table
   
   WITH hours_opened AS (
    SELECT 
        museum_id,
        day,
        ROUND(
            TIMESTAMPDIFF(
                MINUTE,
                STR_TO_DATE(open, '%h:%i %p'),
                STR_TO_DATE(close, '%h:%i %p')
            ) / 60, 2
        ) AS hours_open
    FROM museum_hours
),
classified AS (
    SELECT
        museum_id,
        day,
        CASE 
            WHEN hours_open >= 10 THEN 'Long'
            WHEN hours_open < 6 THEN 'Short'
            ELSE 'Medium'
        END AS class_length
    FROM hours_opened
)
SELECT
    day,
    SUM(class_length = 'Short')  AS short_count,
    SUM(class_length = 'Medium') AS medium_count,
    SUM(class_length = 'Long')   AS long_count
FROM classified
GROUP BY day
ORDER BY FIELD(day,'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday');


-- Alternative way

WITH opening_hours AS (
SELECT 
	museum_id, 
    `day`, 
    STR_TO_DATE(`open`, '%h:%i %p') AS `open`, 
    STR_TO_DATE(`close`, '%h:%i %p') AS `close`,
    TIMESTAMPDIFF(MINUTE, STR_TO_DATE(`open`, '%h:%i %p'), STR_TO_DATE(`close`, '%h:%i %p')) / 60 AS open_hours
FROM museum_hours
)
, labeled_openings AS (
SELECT
	*,
    CASE
		WHEN open_hours >= 10 THEN 'Long'
        WHEN open_hours < 6 THEN 'Short'
        ELSE 'Medium'
	END AS opening_category
FROM opening_hours
)
SELECT 
 `day`,
 sum(CASE when opening_category = 'Short' THEN 1 ELSE 0 END) AS short,
 sum(CASE when opening_category = 'Medium' THEN 1 ELSE 0 END) AS `medium`,
 sum(CASE when opening_category = 'Long' THEN 1 ELSE 0 END) AS `long`
 FROM labeled_openings
 group by `day`;