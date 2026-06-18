-- 1.Total Revenue by Movie
select m.title, sum(p.amount) as total_revenue
from movies as m
inner join shows as s
on m.movie_id=s.movie_id
inner join bookings as b
on s.show_id=b.show_id
inner join payments as p
on b.booking_id=p.booking_id
group by m.title
order by total_revenue desc;

-- 2.Top 5 movies by bookings
select m.title, count(b.booking_id) as Total_bookings
from movies as m
inner join shows as s
on s.movie_id=m.movie_id
inner join bookings as b
on s.show_id = b.show_id
group by m.title
order by Total_bookings desc
limit 5;

-- 3.Available seats per show 
select show_id, count(*) as Available_seats
from seats 
where status = "Available"
group by show_id ;

-- 4.customers with more than one bookings
select u.name,count(b.booking_id) as Total_bookings
from users as u
inner join bookings as b
on u.user_id=b.user_id
group by u.user_id,u.name 
having (Total_bookings)>1;

-- 5.top 3 highest revenue movies
select m.title, sum(p.amount) as revenue
from movies as m
inner join shows as s
on m.movie_id=s.movie_id
inner join bookings as b
on s.show_id=b.show_id
inner join payments as p
on b.booking_id=p.booking_id
where payment_status = "success" 
group by m.title
order by revenue desc
limit 3;

-- 6.most active customers
select u.name, count(b.booking_id) as Active_customers
from users as u
inner join bookings as b
on u.user_id=b.user_id
group by u.name
order by Active_customers;

-- 7.movies with average review rating
select m.title,round(avg(r.rating),2) as average_review
from movies as m
inner join reviews as r
on m.movie_id = r.movie_id
group by m.movie_id,m.title
order by average_review desc;

-- 8.revenue by payment method
	select payment_method,sum(amount) as revenue
    from payments
    where payment_status="success"
    group by payment_method;
    
    -- 9.rank movies by revenue
    select m.title, sum(p.amount) as revenue,
    rank() over( order by sum(p.amount) desc) as movie_rank
    from movies as m
    inner join shows as s
    on m.movie_id=s.movie_id
    inner join bookings as b
    on s.show_id=b.show_id
    inner join payments as p
    on b.booking_id=p.booking_id
    where payment_status="success"
    group by m.title;
    
    -- 10.dense rank customers
    select u.name, count(*) as bookings,
    dense_rank() over (order by count(*)desc ) as coustomer_rank
    from users as u
    inner join bookings as b
    on u.user_id=b.user_id
    group by u.name,u.user_id;

-- 11.above avg revenue movies
with movie_revenue as (
 SELECT m.title,SUM(p.amount) revenue
    FROM movies m
    JOIN shows as s ON m.movie_id=s.movie_id
    JOIN bookings as b ON s.show_id=b.show_id
    JOIN payments as p ON b.booking_id=p.booking_id
    WHERE p.payment_status='Success'
    GROUP BY m.title)
    
    select * from movie_revenue
    where revenue>(
    select avg(revenue)
    from movie_revenue);

-- 12.create view
create view movie_booking_summary as 
select m.title,count(b.booking_id) as Total_bookings,sum(p.amount) as Total_amount
from movies as m
join shows as s
on m.movie_id=s.movie_id
join bookings as b 
on s.show_id=b.show_id
join payments as p
on b.booking_id=p.booking_id
group by m.title

select * from movie_booking_summary

-- 13.stored procedure
DELIMITER $$
CREATE PROCEDURE GetCustomerBookings
(
    IN p_user_id INT
)
BEGIN
SELECT
u.name,
m.title,
b.seat_no,
b.booking_date
FROM users u
JOIN bookings b
ON u.user_id=b.user_id
JOIN shows s
ON b.show_id=s.show_id
JOIN movies m
ON s.movie_id=m.movie_id
WHERE u.user_id=p_user_id;
END $$
DELIMITER ;
    CALL GetCustomerBookings(5);
    call GetAvailableSeats();
    
    -- 14.triger(automatically update seat status after booking)
    delimiter &&
    create trigger seat_booked
    after insert on bookings 
    for each row
    begin
    update seats set status='Booked'
    where show_id =new.show_id
    and seat_no=new.seat_no;
    end &&
    delimiter ;
    
    -- 15.view:Movie ticketbooking summary
    CREATE VIEW movie_ticketbooking_summary AS
SELECT m.title,COUNT(b.booking_id) AS total_bookings,SUM(p.amount) AS total_revenue
FROM movies m
JOIN shows sh
ON m.movie_id = sh.movie_id
JOIN bookings b
ON sh.show_id = b.show_id
JOIN payments p
ON b.booking_id = p.booking_id
WHERE p.payment_status = 'Success'
GROUP BY m.movie_id, m.title;

select * from movie_ticketbooking_summary;

-- 16.available seats
CREATE VIEW available_seats_view AS
SELECT m.title,sh.show_id,COUNT(st.seat_id) AS available_seats
FROM movies m
JOIN shows sh
ON m.movie_id = sh.movie_id
JOIN seats st
ON sh.show_id = st.show_id
WHERE st.status = 'Available'
GROUP BY m.title, sh.show_id;
    
    -- AGGREGATE AND JOINS
-- 17. Highest revenue theater
select t.name,sum(amount) as revenue
from payments as p 
join bookings as b
on p.booking_id=b.booking_id
join shows as s
on s.show_id=b.show_id
join screens as sc
on sc.screen_id=s.screen_id
join theaters as t
on t.theater_id=sc.theater_id
group by t.name 
order by revenue desc
limit 1;
    
 -- 18. Average ticket price per movie
 select m.title,avg(s.ticket_price) as avg_ticket_price
 from movies as m
 join shows as s
 on s.movie_id=m.movie_id
 group by m.title
 order by avg_ticket_price desc;
 
 -- 19. Total bookings per theater
 select t.name,count(b.booking_id) as total_bookings
from bookings as b
join shows as s
on s.show_id=b.show_id
join screens as sc
on sc.screen_id=s.screen_id
join theaters as t
on t.theater_id=sc.theater_id
group by t.name
order by total_bookings desc;

-- 20. Count movies by language
select language,count(movie_id) total_movies
from movies
group by language;

-- 21. Count movies by genre
    select genre,count(movie_id) as total_movies
    from movies
    group by genre;
    
-- 22. Average movie rating by genre
select genre,avg(r.rating) as avg_movie_rating
from movies as m
join reviews as r
on m.movie_id=r.movie_id
group by genre;

-- 23. Total revenue per city
select t.city,sum(p.amount) as revenue
from payments as p
join bookings as b
on p.booking_id=b.booking_id
join shows as s
on s.show_id=b.show_id
join screens as sc
on sc.screen_id=s.screen_id
join theaters as t
on t.theater_id=sc.theater_id
group by t.city
order by revenue desc;

-- 24. Total cancelled bookings
select status,count(booking_id) as total_bookings
from bookings
where status = "cancelled"
group by status;

-- 25. Revenue generated by each payment method
select payment_method,sum(amount) as revenue
from payments 
group by payment_method;

-- SUBQUERIES
-- 26. Movies with rating above average
select title,rating
from movies 
where rating >
(
select avg(rating) 
from movies
);

-- 27. Users with bookings above average
select user_id ,count(booking_id) as total_booking
from bookings
group by user_id
having count(booking_id) >
(
select avg(booking_id) 
from bookings 
);

-- 28. Movie with highest bookings
    SELECT 
    m.title, 
    COUNT(b.booking_id) AS total_booking
FROM movies AS m
JOIN shows AS s ON s.movie_id = m.movie_id
JOIN bookings AS b ON s.show_id = b.show_id
GROUP BY m.movie_id, m.title
HAVING COUNT(b.booking_id) = (
    SELECT MAX(mhb.booking_count) 
    FROM (
        SELECT COUNT(b2.booking_id) AS booking_count 
        FROM bookings AS b2
        JOIN shows AS s2 ON b2.show_id = s2.show_id
        GROUP BY s2.movie_id
    ) AS mhb
);

-- 29. Theater with highest revenue
select t.name,sum(p.amount) as revenue
from payments as p
join bookings as b
on p.booking_id=b.booking_id
join shows as s
on s.show_id=b.show_id
join screens as sc
on sc.screen_id=s.screen_id
join theaters as t
on t.theater_id=sc.theater_id
group by t.name
having sum(p.amount) = (
select max(mt.total_amount)
 from(
SELECT SUM(p2.amount) AS total_amount
        FROM payments AS p2
        JOIN bookings AS b2 ON p2.booking_id = b2.booking_id
        JOIN shows AS s2 ON s2.show_id = b2.show_id
        JOIN screens AS sc2 ON sc2.screen_id = s2.screen_id
        GROUP BY sc2.theater_id
    ) AS mt
);

-- 30. Show with maximum bookings
SELECT 
    show_id, 
    COUNT(booking_id) AS total_bookings
FROM bookings
GROUP BY show_id
HAVING COUNT(booking_id) = (
    SELECT MAX(sb.booking_count)
    FROM (
        SELECT COUNT(booking_id) AS booking_count
        FROM bookings
        GROUP BY show_id
    ) AS sb
);

-- 31. Users who never booked tickets
SELECT 
    user_id, 
    name 
FROM users
WHERE user_id NOT IN (
    SELECT DISTINCT user_id 
    FROM bookings 
    WHERE user_id IS NOT NULL
);
-- 32. Movies with no reviews
SELECT 
    movie_id, 
    title 
FROM movies
WHERE movie_id NOT IN (
    SELECT movie_id 
    FROM reviews 
    WHERE movie_id IS NOT NULL
);
-- 33. Payment amount greater than average payment
SELECT 
    payment_id, 
    booking_id, 
    amount
FROM payments
WHERE amount > (
    SELECT AVG(amount) 
    FROM payments
);

-- 34. Movies whose revenue exceeds average revenue
SELECT 
    m.title,
    SUM(p.amount) AS movie_revenue
FROM movies AS m
JOIN shows AS s ON m.movie_id = s.movie_id
JOIN bookings AS b ON s.show_id = b.show_id
JOIN payments AS p ON b.booking_id = p.booking_id
GROUP BY m.movie_id, m.title
HAVING SUM(p.amount) > (
    SELECT AVG(sub.total_revenue)
    FROM (
        SELECT SUM(p2.amount) AS total_revenue
        FROM payments AS p2
        JOIN bookings AS b2 ON p2.booking_id = b2.booking_id
        JOIN shows AS s2 ON b2.show_id = s2.show_id
        GROUP BY s2.movie_id
    ) AS sub
);

-- 35. Second highest revenue movie
SELECT 
    m.title,
    SUM(p.amount) AS revenue
FROM movies AS m
JOIN shows AS s ON m.movie_id = s.movie_id
JOIN bookings AS b ON s.show_id = b.show_id
JOIN payments AS p ON b.booking_id = p.booking_id
GROUP BY m.movie_id, m.title
HAVING SUM(p.amount) = (
    SELECT MAX(sub.total_revenue)
    FROM (
        SELECT SUM(p2.amount) AS total_revenue
        FROM payments AS p2
        JOIN bookings AS b2 ON p2.booking_id = b2.booking_id
        JOIN shows AS s2 ON b2.show_id = s2.show_id
        GROUP BY s2.movie_id
    ) AS sub
    WHERE sub.total_revenue < (
        SELECT MAX(top.total_revenue)
        FROM (
            SELECT SUM(p3.amount) AS total_revenue
            FROM payments AS p3
            JOIN bookings AS b3 ON p3.booking_id = b3.booking_id
            JOIN shows AS s3 ON b3.show_id = s3.show_id
            GROUP BY s3.movie_id
        ) AS top
    )
);

-- CTE
-- 36. movies by revenue
with movie_rank as
(
select m.movie_id,m.title,sum(p.amount) as revenue
from movies as m
join shows as s
on s.movie_id=m.movie_id
join bookings as b
on b.show_id=s.show_id
join payments as p
on p.booking_id=b.booking_id
group by m.movie_id
)
select * from movie_rank;

-- 37. Top 5 users by booking count
with top_users as
(
select u.user_id,u.name,count(b.booking_id) as total_bookings
from users as u
join bookings as b
on u.user_id=b.user_id
join payments as p
on b.booking_id=p.booking_id
group by u.user_id,u.name
)
select * from top_users
order by total_bookings desc
limit 5;

-- 38. Top 3 theaters by revenue
with top_theater as
(
select t.theater_id,t.name,sum(p.amount) as revenue
from payments as p 
join bookings as b
on p.booking_id=b.booking_id
join shows as s
on s.show_id=b.show_id
join screens as sc
on sc.screen_id=s.screen_id
join theaters as t
on t.theater_id=sc.theater_id
group by t.theater_id,t.name
)
select * from top_theater
order by revenue desc
limit 3;

-- 39. Above average revenue movies
WITH movie_revenue AS
(
    SELECT m.movie_id,
           m.title,
           SUM(p.amount) AS revenue
    FROM movies m
    JOIN shows s
        ON m.movie_id = s.movie_id
    JOIN bookings b
        ON s.show_id = b.show_id
    JOIN payments p
        ON b.booking_id = p.booking_id
    GROUP BY m.movie_id,m.title
)
SELECT *
FROM movie_revenue
WHERE revenue >
(
    SELECT AVG(revenue)
    FROM movie_revenue
);

-- 40. Users whose booking count is above average booking count
WITH user_bookings AS
(
    SELECT user_id,
           COUNT(*) AS total_bookings
    FROM bookings
    GROUP BY user_id
)
SELECT *
FROM user_bookings
WHERE total_bookings >
(
    SELECT AVG(total_bookings)
    FROM user_bookings
);

-- 41. Revenue contribution percentage of each movie
WITH movie_revenue AS
(
    SELECT m.movie_id,
           m.title,
           SUM(p.amount) AS revenue
    FROM movies m
    JOIN shows s
        ON m.movie_id = s.movie_id
    JOIN bookings b
        ON s.show_id = b.show_id
    JOIN payments p
        ON b.booking_id = p.booking_id
    GROUP BY m.movie_id,m.title
)
SELECT movie_id,
       title,
       revenue,
       ROUND(
           revenue * 100 /
           (SELECT SUM(revenue)
            FROM movie_revenue),
           2
       ) AS revenue_percentage
FROM movie_revenue;

-- 42. Monthly revenue summary
	WITH monthly_revenue AS
(
    SELECT DATE_FORMAT(payment_date,'%Y-%m') AS month,
           SUM(amount) AS revenue
    FROM payments
    WHERE payment_status='Success'
    GROUP BY DATE_FORMAT(payment_date,'%Y-%m')
)
SELECT *
FROM monthly_revenue
ORDER BY month;

-- 43. Payment method with highest revenue
WITH payment_revenue AS
(
    SELECT payment_method,
           SUM(amount) AS revenue
    FROM payments
    WHERE payment_status='Success'
    GROUP BY payment_method
)
SELECT *
FROM payment_revenue
ORDER BY revenue DESC
LIMIT 1;

-- 44. Highest rated movie
WITH movie_rank AS
(
    SELECT *,
           DENSE_RANK() OVER(
               ORDER BY rating DESC
           ) AS rnk
    FROM movies
)
SELECT *
FROM movie_rank
WHERE rnk = 1;

-- 45. Top 5 most reviewed movies
WITH review_count AS
(
    SELECT m.movie_id,
           m.title,
           COUNT(r.review_id) AS total_reviews
    FROM movies m
    JOIN reviews r
        ON m.movie_id = r.movie_id
    GROUP BY m.movie_id,m.title
)
SELECT *
FROM review_count
ORDER BY total_reviews DESC
LIMIT 5;

-- Window Functions
-- 46. Rank movies by revenue
WITH movie_revenue AS
(
SELECT m.title,
SUM(p.amount) revenue
FROM movies m
JOIN shows s ON m.movie_id=s.movie_id
JOIN bookings b ON s.show_id=b.show_id
JOIN payments p ON b.booking_id=p.booking_id
WHERE p.payment_status='Success'
GROUP BY m.title
)
SELECT *,
RANK() OVER(ORDER BY revenue DESC) rnk
FROM movie_revenue;

-- 47. Dense rank users by booking count
WITH user_bookings AS
(
    SELECT user_id,
           COUNT(booking_id) AS total_bookings
    FROM bookings
    GROUP BY user_id
)
SELECT *,
       DENSE_RANK() OVER(
           ORDER BY total_bookings DESC
       ) AS rnk
FROM user_bookings;

-- 48. Latest booking per user
WITH user_booking AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY user_id
ORDER BY booking_date DESC
) rnk
FROM bookings
)
SELECT *
FROM user_booking
WHERE rnk=1;

-- 49. Highest payment per user
WITH payment_rank AS
(
    SELECT *,
           DENSE_RANK() OVER(
               PARTITION BY user_id
               ORDER BY amount DESC
           ) AS rnk
    FROM payments
)
SELECT *
FROM payment_rank
WHERE rnk = 1;

-- 50. Highest revenue movie in each language
WITH movie_rev AS
(
SELECT m.language,
m.title,
SUM(p.amount) revenue
FROM movies m
JOIN shows s ON m.movie_id=s.movie_id
JOIN bookings b ON s.show_id=b.show_id
JOIN payments p ON b.booking_id=p.booking_id
GROUP BY m.language,m.title
)
SELECT *
FROM
(
SELECT *,
DENSE_RANK() OVER(
PARTITION BY language
ORDER BY revenue DESC
) rnk
FROM movie_rev
) x
WHERE rnk=1;
