-- Use Sakila

USE sakila
;

-- 1a. Display the first and last names of all actors from the table actor . 
SELECT first_name, last_name
FROM actor
;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. 
-- Name the column Actor Name.

SELECT CONCAT(UPPER(first_name), ' ', UPPER(last_name)) AS 'Actor Name'
FROM actor
;

-- 2a. You need to find the ID number, first name, and last name of an actor, 
-- of whom you know only the first name, 'Joe.' 

SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = 'Joe'
;

-- 2b. Find all actors whose last name contain the letters GEN

SELECT first_name, last_name
FROM actor
WHERE last_name LIKE '%GEN%'
;

-- 2c. Find all actors whose last names contain the letters LI.
-- This time, order the rows by last name and first name, in that order

SELECT first_name, last_name
FROM actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name, first_name
;

-- 2d. Using IN, display the country_id and country columns of the following countries: 
-- Afghanistan, Bangladesh, and China:

SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China')
;

-- 3a. Add a middle_name column to the table actor.
-- Position it between first_name and last_name. Hint: you will need to specify the data type.

ALTER TABLE actor 
ADD COLUMN middle_name VARCHAR(16) AFTER first_name
;

-- 3b. You realize that some of these actors have tremendously long last names. 
-- Change the data type of the middle_name column to blobs.

ALTER TABLE actor 
MODIFY middle_name BLOB
;

-- 3c. Now delete the middle_name column

ALTER TABLE actor 
DROP COLUMN middle_name
;

-- 4a. List the last names of actors, as well as how many actors have that last name.

SELECT last_name, COUNT(last_name)
FROM actor
GROUP BY last_name
;

-- 4b. List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors

SELECT last_name, COUNT(last_name)
FROM actor
GROUP BY last_name
HAVING COUNT(last_name) > 1
;

-- 4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS,
-- the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.

UPDATE actor
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS'
;

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO.
-- It turns out that GROUCHO was the correct name after all! 
-- In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
-- Otherwise, change the first name to MUCHO GROUCHO 

UPDATE actor
SET first_name =
	CASE
		WHEN (first_name = 'HARPO') THEN 'GROUCHO'
		WHEN (first_name = 'GROUCHO') THEN 'MUCHO GROUCHO'
		ELSE first_name
	END
WHERE actor_id > 0
;

--  5a. You cannot locate the schema of the address table. Which query would you use to recreate it? 

DESCRIBE address
;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. 
-- Use the tables staff and address.

SELECT first_name, last_name, address
FROM staff
JOIN address ON staff.staff_id = address.address_id
;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. 
-- Use tables staff and payment.

SELECT payment.staff_id, first_name, last_name, SUM(amount)
FROM payment
JOIN staff ON staff.staff_id = payment.staff_id
WHERE MONTH(payment_date) = 8 AND YEAR(payment_date) = 2005
GROUP BY staff_id
;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film.
-- Use inner join.

SELECT title, COUNT(actor_id)
FROM film
JOIN film_actor ON film.film_id = film_actor.film_id
GROUP BY title
;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?

SELECT title, COUNT(title) 
FROM inventory 
JOIN film ON inventory.film_id = film.film_id 
WHERE title = 'Hunchback Impossible'
;

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
-- List the customers alphabetically by last name.

SELECT payment.customer_id, first_name, last_name, SUM(amount)
FROM payment
JOIN customer ON payment.customer_id = customer.customer_id
GROUP BY customer_id
ORDER BY last_name
;

--  7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.

SELECT title, name
FROM film
JOIN language ON language.language_id = film.language_id
WHERE (title LIKE 'K%' OR title LIKE 'Q%') AND language.name = 'English'
;

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.

SELECT title, first_name, last_name
FROM film_actor
JOIN film ON film.film_id = film_actor.film_id
JOIN actor ON actor.actor_id = film_actor.actor_id
WHERE title = 'Alone Trip'
;

-- 7c. You want to run an email marketing campaign in Canada, 
-- for which you will need the names and email addresses of all Canadian customers.
-- Use joins to retrieve this information.

SELECT country, first_name, last_name, email
FROM customer
JOIN address ON customer.address_id = address.address_id
JOIN city ON city.city_id = address.city_id
JOIN country ON city.country_id = country.country_id
WHERE country = 'Canada'
;

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion.
-- Identify all movies categorized as famiy films.

SELECT film.title, category.name
FROM film
JOIN film_category ON film.film_id = film_category.film_id
JOIN category ON film_category.category_id = category.category_id
WHERE category.name = 'Family'
;

-- 7e. Display the most frequently rented movies in descending order.

SELECT title, COUNT(rental_date) 
FROM rental
JOIN inventory ON rental.inventory_id = inventory.inventory_id
JOIN film ON inventory.film_id = film.film_id
GROUP BY title
ORDER BY COUNT(rental_date) DESC, title
;

-- 7f. Write a query to display how much business, in dollars, each store brought in.

SELECT store_id, SUM(amount)
FROM rental
JOIN inventory ON rental.inventory_id = inventory.inventory_id
JOIN payment ON rental.rental_id = payment.rental_id
GROUP BY store_id
;

-- 7g. Write a query to display for each store its store ID, city, and country. 

SELECT store_id, city, country
FROM store
JOIN address ON address.address_id = store.address_id
JOIN city ON city.city_id = address.city_id
JOIN country ON country.country_id = city.country_id
;

-- 7h. List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

SELECT category.name, SUM(payment.amount)
FROM rental
JOIN inventory ON rental.inventory_id = inventory.inventory_id
JOIN payment ON rental.rental_id = payment.rental_id
JOIN film_category ON inventory.film_id = film_category.film_id
JOIN category ON film_category.category_id = category.category_id
GROUP BY category.name
ORDER BY SUM(payment.amount) DESC
LIMIT 5
;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres
-- by gross revenue. Use the solution from the problem above to create a view. 

CREATE VIEW top_five_genres AS
SELECT category.name, SUM(payment.amount)
FROM rental
JOIN inventory ON rental.inventory_id = inventory.inventory_id
JOIN payment ON rental.rental_id = payment.rental_id
JOIN film_category ON inventory.film_id = film_category.film_id
JOIN category ON film_category.category_id = category.category_id
GROUP BY category.name
ORDER BY SUM(payment.amount) DESC
LIMIT 5
;

-- 8b. How would you display the view that you created in 8a?

SELECT * FROM top_five_genres
;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.

DROP VIEW top_five_genres
;