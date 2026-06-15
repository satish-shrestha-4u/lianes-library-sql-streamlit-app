USE atlas;

-- 1. Create a view help track of museum rankings by number of paintings they have.
	
    CREATE VIEW museum_ranking AS
    SELECT 
        museum_id, 
        m.name, 
        COUNT(work_id) AS num_of_paintings,
        rank() over (order by count(work_id) desc) as museum_rank
    FROM
        museums m
            JOIN
        works w USING (museum_id)
    GROUP BY museum_id, m.name
    ORDER BY COUNT(work_id) Desc;
     
     -- view the table
     select * from museum_ranking;
     
-- 2. Create a view help your colleagues see how many museums are open every day.

CREATE VIEW open_museum_everyday AS
    SELECT 
        day,
        COUNT(day) AS open_num_days,
        DAYNAME_TO_INTEGER(day) AS day_num -- to make the week start from Monday
    FROM
        museum_hours
    GROUP BY day
    ORDER BY day_num ASC;
    

/* 3. Create a view showing the most popular (most paintings in museums) artist 
in each country. Order the results from highest number of paintings to lowest. 
Ignore results where fewer than three paintings have been collected. */

create view popular_artist_by_country as 
with country_ranks as (SELECT 
    a.full_name,
    m.country,COUNT(w.work_id) AS num_of_works,
    dense_rank() over(partition by country order by COUNT(w.work_id)desc) as country_rank_by_works
FROM
    museums m
        JOIN
    works w USING (museum_id)
    join artists a using (artist_id)
GROUP BY  m.country, w.artist_id
HAVING COUNT(w.work_id) > 2)

SELECT 
    full_name,
    country,
    num_of_works,
    country_rank_by_works    
FROM
    country_ranks
WHERE
    country_rank_by_works = 1
ORDER BY num_of_works DESC;

-- let's view the table
select * from popular_artist_by_country;

/* 4. Create a stored procedure that, when provided with a style, 
retrieves all artists and their works associated with the style */


delimiter $$

create procedure style_artist (In input_style varchar(20))
begin
select
a.artist_id,
a.full_name as artist_name,
w.name as work_name,
w.style as work_style,
a.style as artist_style
from artists a 
join works w using (artist_id)
where input_style In (a.style, w.style) 
;
end $$

delimiter ;

call style_artist('Impressionism'); -- eg; to search artist with style Impressionism



-- 5. Create a stored procedure to look up all of the works held by a museum.

delimiter $$

create procedure museum_work (In input_name Varchar (50))
begin
select a.full_name as artist_name, 
	   m.museum_id,
	   w.name AS work_name,
	   w.style,
       m.name AS museum_name,
       m.country
from works w
join museums m using (museum_id)
join artists a using (artist_id)
where m.name RLike input_name;
end $$

delimiter ;

call museum_work('National Gallery'); -- eg; to look for museum with name national gallery

-- 6. Create a stored procedure to fetch museums open on given a day and time
/***** 
HINT: You can use STR_TO_DATE to easily convert opening and closing times to a proper TIME format.
This should help when checking if the given time falls within the opening hours of a museum. 
https://www.w3schools.com/sql/func_mysql_str_to_date.asp 
*****/

delimiter $$

create procedure opened_museums (IN input_day varchar(10), input_time varchar(8))
begin
select mh.museum_id,
	   mh.day,
       m.name,
       m.address,
       str_to_date (mh.open, '%h:%i %p') as open_time,
       str_to_date (mh.close, '%h:%i %p') as close_time
from museum_hours mh join museums m using (museum_id)
where mh.day = input_day 
and str_to_date(input_time,'%h:%i %p') between str_to_date (mh.open, '%h:%i %p') and str_to_date (mh.close, '%h:%i %p')
;
end $$

delimiter ;

-- test the procedure

CALL opened_museums('Monday', '12:00 PM');



-- 7. Create a stored function to calculate the maximum price for a work by a given artist.

delimiter $$

create function max_price_work (input_artist_name varchar(30))
returns Decimal(10,2)

DETERMINISTIC
READS SQL DATA

begin
declare HighestPrice Decimal(10,2);

SELECT 
    MAX(regular_price)
INTO HighestPrice 
FROM
    product_prices
        JOIN
    works USING (work_id)
        JOIN
    artists USING (artist_id)
WHERE
    full_name RLIKE input_artist_name;
return HighestPrice;

end $$

delimiter ;

-- test the function

SELECT *, 
max_price_work(full_name) AS max_price 
FROM artists 
LIMIT 10;

SELECT max_price_work('\\bjames\\b');   

SELECT max_price_work('^Vincent');


-- 8. Create a stored function that returns the most popular (most paintings in museums) artist in a given style

delimiter $$

create function popular_artist_style (InputStyle Varchar(100))
returns Varchar(100)

DETERMINISTIC
READS SQL DATA
begin
declare PopularArtist Varchar(1000);
WITH top_artists AS (
	SELECT 
		a.full_name, 
        a.birth, 
		RANK() OVER (ORDER BY count(museum_id) DESC) AS artist_rank
	FROM 
		artists AS a
			JOIN 
        works USING (artist_id)
	WHERE 
		a.style = InputStyle
	GROUP BY a.artist_id, a.full_name, a.birth
)
SELECT 
	GROUP_CONCAT(
		CONCAT(full_name, ' (', birth, ')') 
		SEPARATOR ', '
    )INTO PopularArtist 
FROM 
	top_artists
WHERE 
	artist_rank = 1;

RETURN PopularArtist;
END$$

DELIMITER ;

-- test the function
SELECT 
	style, popular_artist_style(style) AS MostPopularArtist
FROM (
	SELECT DISTINCT style FROM artists
) AS styles;
-- 9. Create a middle-name finder. Enter an artist's last name (or first and last) to find their middle name.
-- If the artist has no middle name, return 'nameless'

DELIMITER $$

CREATE FUNCTION middle_name_finder(InputName VARCHAR(80))
RETURNS VARCHAR(20)

NOT DETERMINISTIC 
READS SQL DATA

BEGIN
DECLARE SearchTerm VARCHAR(80);
DECLARE MiddleName VARCHAR(20);

SELECT CONCAT('%', InputName, '%') INTO SearchTerm;	-- %james%
SELECT 
	CASE
		WHEN middle_names IS NOT NULL THEN middle_names
		ELSE 'nameless'
	END INTO MiddleName
FROM artists 
WHERE CONCAT(first_name, ' ', last_name) LIKE SearchTerm;		

RETURN MiddleName;
END$$

DELIMITER ;

SELECT middle_name_finder('Sargent');

SELECT middle_name_finder('vincent');
