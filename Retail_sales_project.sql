-- Create table
DROP TABLE IF EXISTS retail_sales_raw;
CREATE TABLE retail_sales_raw (
	transactions_id INT PRIMARY KEY,
	sale_date DATE,
	sale_time TIME,
	customer_id INT,
	gender VARCHAR(10),
	age INT,
	category VARCHAR(20),
	quantiy INT,
	price_per_unit FLOAT,
	cogs FLOAT,
	total_sale FLOAT
);

SELECT * FROM retail_sales_raw;

-- RENAME COLUMN

ALTER TABLE retail_sales_raw
RENAME COLUMN quantiy TO quantity;

SELECT * FROM retail_sales_raw;

-- INSERT DATA ---- ====

-- NOW CREATE OTHER TABLE FOR CLEAN DATA -- ===

CREATE TABLE retail_sales_clean AS
SELECT *
FROM retail_sales_raw;

-- CHECK DUPLICATE ROWS

SELECT *,
COUNT(*)
FROM retail_sales_clean
GROUP BY
	transactions_id,
	sale_date,
	sale_time,
	customer_id,
	gender,
	age,
	category,
	quantity,
	price_per_unit,
	cogs,
	total_sale
	HAVING COUNT(*) > 1;


-- CHECK DATA STRUCTURE

SELECT *
FROM retail_sales_clean
WHERE 
	transactions_id IS NULL
	OR
	sale_date IS NULL
	OR
	sale_time IS NULL
	OR
	customer_id IS NULL
	OR 
	gender IS NULL
	OR
	age IS NULL
	OR
	category IS NULL
	OR 
	quantity IS NULL
	OR
	price_per_unit IS NULL
	OR 
	cogs IS NULL
	OR
	total_sale IS NULL;


-- DATA CLEANING

DELETE FROM retail_sales_clean
WHERE
	quantity IS NULL
	OR
	price_per_unit IS NULL
	OR 
	cogs IS NULL
	OR
	total_sale IS NULL;


SELECT * FROM retail_sales_clean;



-- FILL MISSING VALUES WITH IN AGE Column with AVG(age)

UPDATE retail_sales_clean
SET age = 
(
	SELECT
		ROUND(AVG(age))
	FROM retail_sales_clean
)
WHERE age IS NULL;


SELECT * FROM retail_sales_clean;


-- CHECK INVALID VALUE --===

SELECT *
FROM retail_sales_clean
WHERE quantity <= 0;

SELECT *
FROM retail_sales_clean
WHERE price_per_unit <= 0;

SELECT *
FROM retail_sales_clean
WHERE cogs <= 0;

SELECT *
FROM retail_sales_clean
WHERE total_sale < cogs;

SELECT *
FROM retail_sales_clean
WHERE total_sale <= 0;

-- CHECK CATEGORY VALUES

SELECT DISTINCT category
FROM retail_sales_clean;


-- CHECK GENDER VALUES

SELECT DISTINCT gender
FROM retail_sales_clean;



-- DATA Exploration


-- How many sales we have?

SELECT COUNT(*) AS total_sales FROM retail_sales_clean;

-- How many UNIQUE customers we have?

SELECT COUNT(DISTINCT(customer_id)) AS total_customers FROM retail_sales_clean;

-- How many category we have?
SELECT DISTINCT(category) AS total_category FROM retail_sales_clean;



-- DATA ANALYSIS & BUSINESS KEY PROBLEMS & ANSWERS

-- My Analysis & Findings

-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05
-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022
-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.
-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.
-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 
-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.
-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)



-- Solve Above questions --====


-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05.
select * from retail_sales_clean

SELECT * FROM retail_sales_clean
WHERE sale_date = '2022-11-05';


-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022
select * from retail_sales_clean

SELECT *
FROM retail_sales_clean
WHERE category = 'Clothing'
	AND sale_date >= '2022-11-01'
	AND sale_date < '2022-12-01'
	AND quantity >= 4;


-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.
select * from retail_sales_clean;

SELECT
	category,
	SUM(total_sale) AS total_sales,
	COUNT(*) AS total_orders
FROM retail_sales_clean
GROUP BY category
ORDER BY total_sales DESC;


-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
select * from retail_sales_clean

SELECT
	
	ROUND(AVG(age), 2) AS avg_age
FROM retail_sales_clean
WHERE category = 'Beauty'
GROUP BY category


-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.
select * from retail_sales_clean

SELECT
	transactions_id,
	total_sale
FROM retail_sales_clean
WHERE total_sale > 1000
ORDER BY total_sale DESC;

-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
select * from retail_sales_clean

SELECT
	category,
	gender,
	COUNT(transactions_id) AS total_transactions
FROM retail_sales_clean
GROUP BY
	category,
	gender
ORDER BY category;


-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
select * from retail_sales_clean


SELECT
	EXTRACT(YEAR FROM sale_date) AS year,
	EXTRACT(MONTH FROM sale_date) AS month,
	AVG(total_sale) AS avg_sale
FROM retail_sales_clean
GROUP BY
	year,
	month
ORDER BY 
	year,
	avg_sale DESC;

-- OR with window function -- this is BEST Appproach

WITH monthly_sales AS
(
	SELECT
		EXTRACT(YEAR FROM sale_date) AS year,
		EXTRACT(MONTH FROM sale_date) AS month,
		AVG(total_sale) AS avg_sale
	FROM retail_sales_clean
	GROUP BY
		year,
		month
),
ranked_months AS
(
	SELECT *,
		ROW_NUMBER() OVER (PARTITION BY year ORDER BY avg_sale DESC) AS rn
	FROM monthly_sales
		
)
SELECT
	year,
	month,
	avg_sale
FROM ranked_months
WHERE rn = 1;

	
-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 
select * from retail_sales_clean

SELECT
	customer_id,
	SUM(total_sale) AS total_sales
FROM retail_sales_clean
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 5;

-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.
select * from retail_sales_clean

SELECT
	category,
	COUNT(DISTINCT(customer_id)) AS unique_customers
FROM retail_sales_clean
GROUP BY
	category;


-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)
select * from retail_sales_clean

WITH shift_wise_orders AS
(
	SELECT *,
		CASE
			WHEN EXTRACT (HOUR FROM sale_time) < 12 THEN 'Morning'
			WHEN EXTRACT (HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'After Noon'
			ELSE 'Evening'
		END AS shift
	FROM retail_sales_clean
)
SELECT
	shift,
	COUNT(*) AS total_orders
FROM shift_wise_orders
GROUP BY shift;


--->>>	 END THE PROJECT	 --->>>




