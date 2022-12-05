USE sakila;

-- 1) Write a query to display for each store its store ID, city, and country.
SELECT * FROM store; -- store_id, address_id
SELECT * FROM address; -- address_id, city_id
SELECT * FROM city; -- city_id, city, country_id
SELECT * FROM country; -- country_id, country

SELECT store_id, city, country
FROM sakila.store s
JOIN sakila.address a
USING (address_id)
JOIN sakila.city c
USING (city_id)
JOIN sakila.country co
USING (country_id);

-- 2) Write a query to display how much business, in dollars, each store brought in.

SELECT * FROM store; -- store_id
SELECT * FROM customer; -- store_id, customer_id
SELECT * FROM rental; -- customer_id, rental_id
SELECT * FROM payment; -- rental_id, amount  

SELECT store_id, CONCAT('$', FORMAT(SUM(amount),2)) AS business_in_dollars
FROM sakila.store s
JOIN sakila.customer c
USING (store_id)
JOIN sakila.rental r
USING (customer_id)
JOIN sakila.payment p
USING (rental_id)
GROUP BY store_id;

-- 3) Which film categories are longest?
SELECT * FROM category; -- name, category_id
SELECT * FROM film_category; -- category_id id, film_id
SELECT * FROM film; -- film_id, length

SELECT name, sec_to_time(ROUND(AVG(length)*60,0)) AS film_duration
FROM sakila.category c
JOIN sakila.film_category fc
USING (category_id)
JOIN sakila.film f
USING (film_id)
GROUP BY name
ORDER BY film_duration DESC;

-- 4) Display the most frequently rented movies in descending order.
SELECT * FROM rental; -- rental_id, inventory_id
SELECT * FROM inventory; -- inventory_id, film_id
SELECT * FROM film; -- film_id, title

SELECT 
    title, COUNT(rental_id) AS number_of_rentals
FROM
    sakila.rental r
        JOIN
    sakila.inventory i USING (inventory_id)
        JOIN
    sakila.film f USING (film_id)
GROUP BY title
ORDER BY number_of_rentals DESC;

-- 5) List the top five genres in gross revenue in descending order.
SELECT * FROM category; -- name, category_id
SELECT * FROM film_category; -- category_id, film_id
SELECT * FROM inventory; -- film_id, inventory_id
SELECT * FROM rental; -- inventory_id, rental_id
SELECT * FROM payment; -- rental_id, amount

SELECT 
    c.name, CONCAT('$', FORMAT(SUM(amount),2)) AS gross_revenue
FROM
    sakila.category c
        JOIN
    sakila.film_category fc USING (category_id)
        JOIN
    sakila.inventory i USING (film_id)
        JOIN
    sakila.rental r USING (inventory_id)
        JOIN
    sakila.payment p USING (rental_id)
GROUP BY c.name
ORDER BY gross_revenue DESC
LIMIT 5;

-- 6) Is "Academy Dinosaur" available for rent from Store 1?
SELECT * FROM film; -- title, film_id
SELECT * FROM inventory; -- film_id, store_id, inventory_id
SELECT * FROM rental; -- inventory_id

SELECT 
    inventory_id, title, MAX(return_date) AS available_from
FROM
    sakila.film f
        JOIN
    sakila.inventory i USING (film_id)
        JOIN
    sakila.rental r USING (inventory_id)
WHERE
    title = 'ACADEMY DINOSAUR'
        AND store_id = 1
        AND return_date IS NOT NULL
GROUP BY inventory_id , title;

-- 7) Get all pairs of actors that worked together.
SELECT * FROM actor; -- actor_id, first_name, last_name
SELECT * FROM film_actor; -- actor_id, film_id

SELECT 
    fa1.actor_id,
    a1.first_name,
    a1.last_name,
    fa2.actor_id,
    a2.first_name,
    a2.last_name
FROM
    sakila.film_actor fa1
        JOIN
    sakila.film_actor fa2 ON (fa1.actor_id < fa2.actor_id)
        AND (fa1.film_id = fa2.film_id)
        JOIN
    sakila.actor a1 ON (fa1.actor_id = a1.actor_id)
        JOIN
    sakila.actor a2 ON (fa2.actor_id = a2.actor_id);

-- 8) Get all pairs of customers that have rented the same film more than 3 times.
SELECT * FROM customer; -- customer_id
SELECT * FROM rental; -- customer_id, rental_id, inventory_id
SELECT * FROM inventory; -- inventory_id, film_id
SELECT * FROM film; -- film_id

DROP TABLE IF EXISTS t1;
CREATE TEMPORARY TABLE t1 AS (
SELECT i.film_id, r.rental_id, r.customer_id, r.inventory_id
FROM rental r
JOIN inventory i
USING(inventory_id));

SELECT * FROM t1;

DROP TABLE IF EXISTS t2;
CREATE TEMPORARY TABLE t2 AS (
SELECT i.film_id, r.rental_id, r.customer_id, r.inventory_id
FROM rental r
JOIN inventory i
USING(inventory_id));

SELECT * FROM t2;

SELECT 
    COUNT(t1.film_id),
    t1.customer_id,
    t2.customer_id
FROM
    t1
        JOIN
    t2 ON t1.inventory_id = t2.inventory_id
        AND t1.customer_id > t2.customer_id
GROUP BY t1.customer_id , t2.customer_id
HAVING COUNT(t1.film_id) > 3;

-- 9) For each film, list actor that has acted in more films.

SELECT * FROM film; -- film_id
SELECT * FROM film_actor; -- film_id, actor_id
SELECT * FROM actor; -- actor_id

-- --------- CREATE TEMPORARY TABLE
DROP TABLE IF EXISTS numbers_of_films_for_actors;

CREATE TEMPORARY TABLE numbers_of_films_for_actors
SELECT 
    fa.actor_id,
    COUNT(DISTINCT film_id) AS numbers_of_films,
    a.first_name,
    a.last_name -- doesn't work as expected: , ROW_NUMBER() OVER() AS 'row'
FROM
    sakila.film_actor fa
        JOIN
    sakila.actor a USING (actor_id)
GROUP BY fa.actor_id , a.first_name , a.last_name
ORDER BY numbers_of_films DESC;

-- add column with "rank" to temp table
SELECT *, ROW_NUMBER() OVER() AS 'rank' from numbers_of_films_for_actors;

-- JOIN film, film_actor and actor
SELECT film_id, title, actor_id, first_name, last_name 
FROM
    sakila.film f
        JOIN
    sakila.film_actor fa USING (film_id)
        JOIN 
        sakila.actor a USING (actor_id) WHERE actor_id = (SELECT actor_id WHERE 
        ORDER BY film_id ASC;
        
        
        WHERE actor_id = (SELECT actor_id FROM
                    actor
                WHERE
                    actor_id = (SELECT 
                            actor_id
                        FROM
                            (SELECT 
                                actor_id, COUNT(DISTINCT film_id) AS count_of_films
                            FROM
                                film_actor
                            GROUP BY actor_id
                            ORDER BY count_of_films DESC
                            LIMIT 1) sub1)) ORDER BY film_id ASC;