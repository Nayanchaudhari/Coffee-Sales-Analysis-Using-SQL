-- 1 Coffee Consumers Count
-- How many people in each city are estimated to consume coffee, given that 25% of the population does?
SELECT city_name,
ROUND((population * 0.25)/1000000,2) AS coffee_consumer_in_million,
city_rank
FROM city
ORDER BY population DESC;

-- 2 Total Revenue from Coffee Sales
-- What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?

SELECT sum(total) AS total_revenue
FROM sales
WHERE year(sale_date) = 2023 AND
quarter(sale_date) = 4;

SELECT A.city_name,sum(total) AS total_reveneu
FROM city AS A
JOIN customers AS B
ON A.city_id = B.city_id
JOIN sales AS C
ON C.customer_id = B.customer_id
WHERE year(C.sale_date) = 2023 AND
quarter(C.sale_date) = 4
GROUP BY A.city_name
ORDER BY total_reveneu DESC;


-- 3 Sales Count for Each Product
-- How many units of each coffee product have been sold?
SELECT A.product_name,COUNT(B.sale_id) AS sold
FROM products AS A
JOIN sales AS B
ON A.product_id = B.product_id
GROUP BY A.product_name
ORDER BY sold DESC;

-- 4 Average Sales Amount per City
-- What is the average sales amount per customer in each city?

SELECT C.city_name,sum(total) AS total_reveneu,
COUNT( DISTINCT A.customer_id) AS total_customer,
ROUND(sum(total)/COUNT( DISTINCT A.customer_id),2) AS avg_sale_per_cus
FROM customers AS A
JOIN sales AS B
ON A.customer_id = B.customer_id
JOIN city AS C
ON C.city_id = A.city_id
GROUP BY C.city_name
ORDER BY total_reveneu DESC;

-- 5 City Population and Coffee Consumers
-- Provide a list of cities along with their populations and estimated coffee consumers.

WITH city_table AS
(SELECT city_name,
ROUND((population * 0.25)/1000000,2) AS coffee_consumer_in_million
FROM city),
customer_table AS
(SELECT A.city_name,count(DISTINCT B.customer_id) AS unique_customer
FROM city AS A
JOIN customers AS B
ON A.city_id = B.city_id
JOIN sales AS C
ON C.customer_id = B.customer_id
GROUP BY A.city_name)

SELECT city_table.city_name,city_table.coffee_consumer_in_million AS coffee_consumer,
customer_table.unique_customer
FROM city_table
JOIN customer_table
ON city_table.city_name = customer_table.city_name
ORDER BY coffee_consumer DESC;


-- 6 Top Selling Products by City
-- What are the top 3 selling products in each city based on sales volume?

WITH TOP_selling AS
(SELECT D.city_name , A.product_name,count(B.sale_id) AS sales_volume,
dense_rank() OVER(PARTITION BY  D.city_name ORDER BY count(B.sale_id) DESC) AS rank_city
FROM products AS A
JOIN sales AS B
ON A.product_id = B.product_id
JOIN customers AS C
ON C.customer_id = B.customer_id
JOIN city AS D
ON D.city_id = C.city_id
GROUP BY D.city_name, A.product_name)

SELECT *
FROM top_selling
WHERE rank_city <= 3;


-- 7 Customer Segmentation by City
-- How many unique customers are there in each city who have purchased coffee products?

SELECT B.city_name,count(DISTINCT A.customer_id) AS unique_customer
FROM customers AS A
JOIN city AS B
ON A.city_id = B.city_id
JOIN sales AS C
ON C.customer_id = A.customer_id
WHERE C.product_id between 1 AND 14
GROUP BY B.city_name
ORDER BY unique_customer DESC;


-- 8 Average Sale vs Rent
-- Find each city and their average sale per customer and avg rent per customer

WITH city_table AS
(SELECT A.city_name,sum(C.total) AS total,count(DISTINCT B.customer_id) AS unique_customer,
ROUND((sum(C.total)/count(DISTINCT B.customer_id)),2) AS averager_per_customer
FROM city AS A
JOIN customers AS B
ON A.city_id =  B.city_id
JOIN sales AS C
ON C.customer_id = B.customer_id
GROUP BY A.city_name),

city_rent As
(SELECT city_name,estimated_rent
FROM city)

SELECT CR.city_name,CR.estimated_rent,CT.averager_per_customer,CT.unique_customer,
ROUND((estimated_rent/(CT.unique_customer)),2) AS rent_per_customer
FROM city_table AS CT
JOIN city_rent AS CR
ON CT.city_name = CR.city_name;


-- 9 Monthly Sales Growth
-- Sales growth rate: Calculate the percentage growth (or decline) in 
-- sales over different time periods (monthly) by each city

WITH growth_rate AS
(SELECT C.city_name,month(A.sale_date) AS month_sales,year(A.sale_date) AS year_sales,sum(A.total) AS current_month_sales
FROM sales AS A
JOIN customers AS B
ON A.customer_id = B.customer_id
JOIN city AS C
ON C.city_id = B.city_id
GROUP BY C.city_name,month_sales,year_sales
ORDER BY C.city_name,year_sales,month_sales),

growth_ratio AS

(SELECT city_name,month_sales,year_sales,current_month_sales,
LAG(current_month_sales,1) OVER(PARTITION BY city_name ) AS last_month_sales
FROM growth_rate)

SELECT city_name,month_sales,year_sales,current_month_sales,last_month_sales,
ROUND(((current_month_sales - last_month_sales)/last_month_sales * 100),2) AS growth_percentage
FROM growth_ratio
WHERE last_month_sales IS NOT NULL;


-- 10 Market Potential Analysis
-- Identify top 3 city based on highest sales, return city name, total sale, total rent,
--  total customers, estimated coffee consumer

WITH city_table AS
(SELECT A.city_name,sum(total) AS total,count(DISTINCT B.customer_id) AS unique_customer,
ROUND((sum(total)/count(DISTINCT B.customer_id)),2) avg_per_customer
FROM city AS A
JOIN customers AS B
ON A.city_id = B.city_id
JOIN sales AS C
ON C.customer_id = B.customer_id
GROUP BY A.city_name),
city_rent AS 

(SELECT city_name,estimated_rent,ROUND((population * 0.25)/1000000,2) AS estimated_coffee_consumer_million
FROM city)

SELECT CT.city_name,CT.total,CT.unique_customer,CT.avg_per_customer,CR.estimated_rent,
ROUND((CR.estimated_rent/CT.unique_customer),2) AS avg_est_per_customer,CR.estimated_coffee_consumer_million
FROM city_table AS CT
JOIN city_rent AS CR
ON CT.city_name = CR.city_name
ORDER BY total DESC;


-- Recomendation
-- City 1: Pune
	-- 1.Average rent per customer is very low.
	-- 2.Highest total revenue.
	-- 3.Average sales per customer is also high.

-- City 2: Delhi
	-- 1.Highest estimated coffee consumers at 7.7 million.
	-- 2.Highest total number of customers, which is 68.
	-- 3.Average rent per customer is 330 (still under 500).

-- City 3: Jaipur
	-- 1.Highest number of customers, which is 69.
	-- 2.Average rent per customer is very low at 156.
	-- 3.Average sales per customer is better at 11.6k.














