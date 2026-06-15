USE atlas;

-- 1. Rank museums by the number of paitings they have.

select
	m.name,
	m.museum_id, 
	count(w.work_id) as num_of_paintings,
	rank() over(order by count(w.work_id) desc) as museum_rank
 
from museums m
join works w
using (museum_id)
group by m.museum_id, m.name
order by museum_rank;


-- 2. Select only the top 10 ranked museums from the previous question.

with museum_ranks as(
					select
					m.name,
					m.museum_id, 
					count(w.work_id) as num_paintings,
					dense_rank() over(order by count(w.work_id) desc) as museum_rank
					from museums m
					join works w
					using (museum_id)
                    group by m.museum_id,m.name)
select 				name,
					museum_id, 
					num_paintings,
					museum_rank
                    from museum_ranks
                    where museum_rank <= 10
                    order by museum_rank;
                    
                    
-- 3. Rank artists in each style based on the total number of paintings made.

SELECT 
    a.artist_id, a.full_name, a.style, COUNT(work_id) AS num_of_works,
    rank() over(partition by a.style order by count(work_id) desc) as artist_rank
FROM
    works w
    join artists a using (artist_id)
WHERE a.style is not null
GROUP BY a.style , a.artist_id;



/* 4. Do the styles museums collections vary by country? What are the top 3 styles for each country?
Ignore countries with fewer than three paintings. */

select * 
from (
	SELECT 
	m.country,
    w.style,
    count(w.style) as num_of_styles, 
    dense_rank() over(partition by m.country order by count(w.style) desc) as country_rank_by_styles
FROM
    works w
        JOIN
    museums m USING (museum_id)
WHERE
    w.style IS NOT NULL
Group by m.country,w.style
) as alias

Where country_rank_by_styles <4 and num_of_styles>=3
order by num_of_styles desc;


--  alternative CTE way

WITH StyleRanks AS (
SELECT 
	country, 
    style, 
    COUNT(*) AS WorkCount,
	RANK() OVER (PARTITION BY country ORDER BY COUNT(*) DESC) AS StyleRank
FROM 
	works
		JOIN
    museums USING (museum_id)
WHERE 
	style IS NOT NULL 
GROUP BY country, style
HAVING COUNT(*) > 2
)
SELECT *
FROM StyleRanks 
WHERE StyleRank <= 3;

  
    
-- 5. We know already on which days the most museums are open. What about the SECOND most?

with day_ranks as (SELECT 
    day, COUNT(day),
    dense_rank() over(order by count(day) desc) as day_rank
FROM
    museum_hours
GROUP BY day)

select * from day_ranks where day_rank =2;

-- 6. How many years between the birth of one artist and another?

SELECT 
    artist_id, 
    full_name, 
    birth,
    lag(birth) over(order by birth) as previous_artist_birth,
    birth - lag(birth,1,birth) over(order by birth) as difference -- lag format is LAG(column, offset, default)
FROM
    artists; 
    
/* 7. Arrange canvas sizes by total area. Ignore canvases with only one measurement. 
If two canvases have the same area, display the one with the lower width first.
How much bigger (in area) is each canvas size than the previous? */

SELECT 
    size_id, width, height,
    (width * height) AS area,
   (width * height) - lag(width * height) over(order by (width * height),width) as bigger_by
FROM
    canvas_sizes
WHERE
    width IS NOT NULL
    AND height is not null
    order by area, width;
    
    
-- 8. How do the number of paintings created vary century-to-century? Use the artist's death to determine the century.

with num_of_works as (
					SELECT 
						a.artist_id, COUNT(work_id) AS num_of_paintings, a.death
					FROM
						artists a
							JOIN
						works w USING (artist_id)
                        WHERE death IS NOT NULL
					GROUP BY a.artist_id, a.death),
	century_total as (
					select 
                    floor(death/100)*100 as century,
					sum(num_of_paintings) as total_paintings_in_century
                    from num_of_works
                    group by floor(death/100)*100)
select 
century,
total_paintings_in_century,
total_paintings_in_century - lag(total_paintings_in_century) over(order by century asc) as vary_by
from century_total
order by century;

-- 9. Display the above as a percentage change.


with num_of_works as (
					SELECT 
						a.artist_id, COUNT(work_id) AS num_of_paintings, a.death
					FROM
						artists a
							JOIN
						works w USING (artist_id)
                        WHERE death IS NOT NULL
					GROUP BY a.artist_id, a.death),
	century_total as (
					select 
                    floor(death/100)*100 as century,
					sum(num_of_paintings) as total_paintings_in_century
                    from num_of_works
                    group by floor(death/100)*100)
select 
century,
total_paintings_in_century,
Round(
(total_paintings_in_century - lag(total_paintings_in_century)over(order by century asc)) 
/ 
lag(total_paintings_in_century) over(order by century asc)*100,1) as vary_by_pct
from century_total
order by century;




-- 10. Categorise the century-by-century variation by whether it was an increase or decrease compared to the previous century.

with num_of_works as (SELECT 
    a.artist_id, COUNT(work_id) AS num_of_paintings, a.death
FROM
    artists a
        JOIN
    works w USING (artist_id)
WHERE
    death IS NOT NULL
GROUP BY a.artist_id , a.death),

century_total as ( select 
                    floor(death/100)*100 as century,
					sum(num_of_paintings) as total_paintings_in_century
                    from num_of_works
                    group by floor(death/100)*100),

century_variation as (select 
						century,
						total_paintings_in_century,
						total_paintings_in_century - lag(total_paintings_in_century) over(order by century asc) as vary_by
						from century_total)
select century,
	   total_paintings_in_century,
       vary_by,
       case 
       when vary_by > 0 then 'Increase'
       when vary_by < 0 then 'Decrease'
       when vary_by = 0 then 'No Change'
       else 'N/A'
       end as var_category
from century_variation
order by century;


-- 11. How many centuries in the data showed an increase in paintings created compared to the previous century?


with num_of_works as (SELECT 
    a.artist_id, COUNT(work_id) AS num_of_paintings, a.death
FROM
    artists a
        JOIN
    works w USING (artist_id)
WHERE
    death IS NOT NULL
GROUP BY a.artist_id , a.death),

century_total as ( select 
                    floor(death/100)*100 as century,
					sum(num_of_paintings) as total_paintings_in_century
                    from num_of_works
                    group by floor(death/100)*100),

century_variation as (select 
						century,
						total_paintings_in_century,
						total_paintings_in_century - lag(total_paintings_in_century) over(order by century asc) as vary_by
						from century_total)
SELECT 
    COUNT(*) AS total_increase_centuries
FROM
    century_variation
WHERE
    vary_by > 0;

-- 12. Display the above as a percentage of all centuries except the first in the dataset.

with num_of_works as (SELECT 
    a.artist_id, COUNT(work_id) AS num_of_paintings, a.death
FROM
    artists a
        JOIN
    works w USING (artist_id)
WHERE
    death IS NOT NULL
GROUP BY a.artist_id , a.death),

century_total as ( select 
                    floor(death/100)*100 as century,
					sum(num_of_paintings) as total_paintings_in_century
                    from num_of_works
                    group by floor(death/100)*100),

century_variation as (select 
						century,
						total_paintings_in_century,
						total_paintings_in_century - lag(total_paintings_in_century) over(order by century asc) as vary_by
						from century_total)
SELECT 
    ROUND(
        sum(CASE WHEN vary_by > 0 THEN 1 else 0 END) 
        / 
        COUNT(vary_by) * 100, 
        2) AS pct_increase_centuries -- count(vary_by) does not count null value but count(*) count all
FROM century_variation;

-- Alternative way

WITH CenturyGrowthCategorised AS (
SELECT 
	FLOOR(death / 100) * 100 AS century, 
    COUNT(*) AS num_paintings,
	COUNT(*) - LAG(COUNT(*)) OVER (ORDER BY FLOOR(death / 100) * 100) AS growth,
    CASE
		WHEN COUNT(*) - LAG(COUNT(*)) OVER (ORDER BY FLOOR(death / 100) * 100) > 0 THEN 'Increase'
        WHEN COUNT(*) - LAG(COUNT(*)) OVER (ORDER BY FLOOR(death / 100) * 100) < 0 THEN 'Decrease'
	END cat_growth
FROM artists
JOIN works USING (artist_id)
GROUP BY FLOOR(death / 100) * 100
)
SELECT 
	100 * 
    (SELECT COUNT(*) FROM CenturyGrowthCategorised WHERE cat_growth = 'Increase') /
    (SELECT COUNT(*) FROM CenturyGrowthCategorised WHERE growth IS NOT NULL)
    AS PercentOfCenturiesWithIncrease;
    
    
/****** BONUS
Find the artists in the top 1% of works created in a lifetime. 
It may help to find an appropriate window function for this task https://dev.mysql.com/doc/refman/8.4/en/window-function-descriptions.html
******/

with pct_work as (SELECT 
    artist_id, full_name, COUNT(work_id) as total_work_by_artist,
    round(percent_rank() over (order by COUNT(work_id)desc),2) as pct
FROM
    artists a
        JOIN
    works w USING (artist_id)
GROUP BY artist_id, full_name)
select * from pct_work
where pct <=0.01;

-- Using NTILE() window function

with pct_work as (SELECT 
    artist_id, full_name, COUNT(work_id) as total_work_by_artist,
    NTILE(100) over (order by COUNT(work_id)desc) as percentile_bucket
FROM
    artists a
        JOIN
    works w USING (artist_id)
GROUP BY artist_id, full_name)
select * from pct_work
where percentile_bucket =1;

-- A Fun Data Quirky Fact on PERCENT_RANK() vs. NTILE()
-- If you run both queries on the exact same dataset, you might notice that the PERCENT_RANK() query sometimes returns slightly fewer or more rows than the NTILE() query.
-- NTILE(100) is strict about math. It divides your total number of artists into 100 perfectly equal groups. If you have 500 artists, it will put exactly 5 artists into Bucket 1.
-- PERCENT_RANK() is focused on ties. If multiple artists share the exact same number of paintings right at the 1% boundary line, PERCENT_RANK() will give them the exact same rank percentage.


/****** BONUS 2
If an employee works open to close every day of the week (starting Monday), 
what day do they need to work until to get a 40-hour week? How many days do they work?
Currently, museum hours are sorted with Sunday first. You can use the custom function 
dayname_to_integer() to help sort the days Monday-Sunday. e.g. dayname_to_integer('Monday') = 1, dayname_to_integer('Tuesday') = 2, etc.
******/

with daily_hours as (
				SELECT 
                museum_id,
				day,
				STR_TO_DATE(`open`, '%h:%i %p') AS open_time,
				STR_TO_DATE(`close`, '%h:%i %p') AS close_time,
                dayname_to_integer(day) as day_num,
				TIMESTAMPDIFF(MINUTE,
					STR_TO_DATE(open, '%h:%i %p'),
					STR_TO_DATE(close, '%h:%i %p')) / 60 AS hours_opened
				FROM
				museum_hours),
	worked_hours as ( 
				select 
                *,
                sum(hours_opened) over(partition by museum_id order by day_num asc) as total_hours,
                row_number() over(partition by museum_id order by day_num asc) as total_days
                from daily_hours),

over_40_hours as ( 
			select *,
            row_number() over(partition by museum_id ORDER BY total_days) as row_num
            from 
            worked_hours
            where total_hours >= 40)
select * 
from over_40_hours 
where row_num = 1;



