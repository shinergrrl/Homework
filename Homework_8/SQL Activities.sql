use sakila;
set sql_safe_updates = 0;

-- 1a. Display the first and last names of all actors from the table `actor`.
select first_name, last_name from actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
select concat(first_name, ' ', last_name) as 'Actor Name'
from actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
select actor_id, first_name, last_name
from actor
where first_name = "Joe";

-- 2b. Find all actors whose last name contain the letters `GEN`:
select concat(first_name, ' ', last_name) as 'Actor Name'
from actor
where last_name like '%GEN%';

-- 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order
select concat(first_name, ' ', last_name) as 'Actor Name'
from actor
where last_name like '%LI%'
order by last_name, first_name;

-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China
select country_id, country
from country
where country in ('Afghanistan', 'Bangladesh', 'China');

-- 3a. Add a `middle_name` column to the table `actor`. Position it between `first_name` and `last_name`. Hint: you will need to specify the data type.
ALTER TABLE actor
ADD COLUMN middle_name VARCHAR(45) NULL AFTER first_name;

-- 3b. You realize that some of these actors have tremendously long last names. Change the data type of the `middle_name` column to `blobs`.
ALTER TABLE actor
CHANGE COLUMN middle_name middle_name BLOB NULL DEFAULT NULL ;

-- 3c. Now delete the `middle_name` column.
ALTER TABLE `sakila`.`actor` 
DROP COLUMN `middle_name`;

-- 4a. List the last names of actors, as well as how many actors have that last name.
select last_name as 'Actor\'s Last Name', count(*) as 'Count'
from actor
group by last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
select last_name as 'Actor\'s Last Name', count(*) as Count 
from actor
group by last_name
having Count >= 2;

-- 4c. Oh, no! The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`, the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.
UPDATE actor
SET first_name = 'HARPO'
WHERE actor_id in
( select * from 
(
select actor_id
from actor
where first_name = 'GROUCHO' and last_name = 'WILLIAMS'
) as id
);

-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`. Otherwise, change the first name to `MUCHO GROUCHO`, as that is exactly what the actor will be with the grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO `MUCHO GROUCHO`, HOWEVER! (Hint: update the record using a unique identifier.)
UPDATE actor
SET first_name = 'GROUCHO'
WHERE actor_id in
( select * from 
(
select actor_id
from actor
where first_name = 'HARPO' and last_name = 'WILLIAMS'
) as id
);

-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it? Hint: <https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html>
SHOW CREATE TABLE address;

-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`
select s.first_name AS 'First Name', s.last_name as 'Last Name', a.address as 'Home Address'
from staff s
join address a on 
s.address_id = a.address_id;

-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
select s.first_name as 'First Name', s.last_name as 'Last Name', sum(p.amount) as 'Total for August 2005'
from payment p
join staff s on
s.staff_id = p.staff_id
where p.payment_date between '2005-08-01' and '2005-08-31'
group by s.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
select f.title as 'Movie Title', count(*) as 'Number of Actors'
from film f
join film_actor a on
a.film_id = f.film_id
group by f.title; 

-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
select f.title as 'Movie Title', count(*) as 'Copies in Inventory'
from film f
join inventory i on
f.film_id = i.film_id
where f.title = 'Hunchback Impossible';

-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name
select c.first_name as 'Customer First Name', c.last_name as 'Customer Last Name', sum(p.amount) as 'Total Paid'
from payment p
join customer c on
c.customer_id = p.customer_id
group by c.last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. 
--     Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.

select title as 'Movie Title'
from film
where (title like 'K%' or title like 'Q%') and language_id in
(
select language_id
from language
where name = 'English'
);

-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
select concat(first_name, ' ', last_name) as 'Actors Starring in Alone Trip'
from actor
where actor_id in 
(
select actor_id
from film_actor
where film_id in
(
select film_id
from film
where title = 'Alone Trip'
)
)
order by first_name;

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
select concat(c.first_name, ' ', c.last_name) as 'Customer Name', c.email as 'Customer Email Address'
from customer c
join address a on a.address_id = c.address_id
join city y on y.city_id = a.city_id
join country u on u.country_id = y.country_id
where u.country = 'Canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as famiy films.
select f.title as 'Movie Title', t.name as 'Movie Type'
from film f
join film_category c on c.film_id = f.film_id
join category t on t.category_id = c.category_id
where t.name = 'Family';

-- 7e. Display the most frequently rented movies in descending order.
select f.title as 'Movie Title', count(*) as 'Rentals'
from film f
join inventory i on i.film_id = f.film_id
join rental r on r.inventory_id = i.inventory_id
group by f.title
order by count(*) desc;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
select s.store_id as 'Store ID', sum(p.amount) as 'Sales in $'
from store s
join inventory i on i.store_id = s.store_id
join rental r on r.inventory_id = i.inventory_id
join payment p on p.rental_id = r.rental_id
group by s.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
select s.store_id as 'Store ID', c.city as 'City', r.country as 'Country'
from store s
join address a on a.address_id = s.address_id
join city c on c.city_id = a.city_id
join country r on r.country_id = c.country_id;

-- 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select c.name as 'Genre', sum(p.amount) as 'Gross Revenue $'
from category c 
join film_category f on f.category_id = c.category_id
join inventory i on i.film_id = f.film_id
join rental r on r.inventory_id = i.inventory_id
join payment p on p.rental_id = r.rental_id
group by c.name
order by sum(p.amount) desc limit 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
create view `top_5_grossing_genres` as select c.name as 'Genre', sum(p.amount) as 'Gross Revenue $'
from category c 
join film_category f on f.category_id = c.category_id
join inventory i on i.film_id = f.film_id
join rental r on r.inventory_id = i.inventory_id
join payment p on p.rental_id = r.rental_id
group by c.name
order by sum(p.amount) desc limit 5;

-- 8b. How would you display the view that you created in 8a?
show create view top_5_grossing_genres;

-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
drop view top_5_grossing_genres;