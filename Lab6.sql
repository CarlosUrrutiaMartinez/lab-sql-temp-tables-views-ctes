USE sakila;

SELECT * FROM actor;
SELECT * FROM film_category;
SELECT * FROM category;
SELECT * FROM customer;
SELECT * FROM address;
SELECT * FROM city;
SELECT * FROM country;
SELECT * FROM payment;
SELECT * FROM rental;
SELECT * FROM store;
SELECT * FROM film;
SELECT * FROM inventory;

CREATE VIEW customer_rental_summary AS
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    COUNT(r.rental_id) AS rental_count
FROM 
    customer c
LEFT JOIN rental r ON c.customer_id = r.customer_id
GROUP BY 
    c.customer_id, c.first_name, c.last_name, c.email;
    
CREATE TEMPORARY TABLE customer_payment_summary AS
SELECT 
    crs.customer_id,
    crs.customer_name,
    crs.email,
    crs.rental_count,
    IFNULL(SUM(p.amount), 0) AS total_paid
FROM 
    customer_rental_summary crs
LEFT JOIN rental r ON crs.customer_id = r.customer_id
LEFT JOIN payment p ON r.rental_id = p.rental_id
GROUP BY 
    crs.customer_id, crs.customer_name, crs.email, crs.rental_count;

-- Create the CTE
WITH customer_summary AS (
    SELECT 
        crs.customer_name,
        crs.email,
        crs.rental_count,
        cps.total_paid,
        cps.total_paid / crs.rental_count AS average_payment_per_rental
    FROM 
        customer_rental_summary crs
    LEFT JOIN customer_payment_summary cps ON crs.customer_id = cps.customer_id
)

-- Generate the final customer summary report
SELECT 
    customer_name,
    email,
    rental_count,
    total_paid,
    average_payment_per_rental
FROM 
    customer_summary;
