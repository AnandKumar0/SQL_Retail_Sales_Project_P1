# Retail Sales Analysis using PostgreSQL

## Project Overview

**Project Title:** Retail Sales Analysis

**Database:** sql_project_p1

**Tools Used:** PostgreSQL, SQL, GitHub

This project demonstrates SQL skills and techniques commonly used by Data Analysts to clean, explore, and analyze retail sales data.

The project covers the complete analytical workflow, including database setup, data cleaning, exploratory data analysis (EDA), and business-driven SQL analysis.

---

# Objectives

### Database Setup

Create and structure a retail sales database for analysis.

### Data Cleaning

Identify missing values, duplicates, and invalid records and prepare a clean dataset for analysis.

### Exploratory Data Analysis (EDA)

Understand customer behavior, sales distribution, and product categories.

### Business Analysis

Answer business questions using SQL queries and generate actionable insights.

---

# Project Structure

## 1. Database Setup

### Table Creation

The project starts by creating a raw sales table.

```sql
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
```

### Rename Incorrect Column

```sql
ALTER TABLE retail_sales_raw
RENAME COLUMN quantiy TO quantity;
```

---

## 2. Data Cleaning

A separate cleaned table was created to preserve raw data.

```sql
CREATE TABLE retail_sales_clean AS
SELECT *
FROM retail_sales_raw;
```

### Duplicate Detection

```sql
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
```

### Missing Values Check

```sql
SELECT *
FROM retail_sales_clean
WHERE
  transactions_id IS NULL
  OR sale_date IS NULL
  OR sale_time IS NULL
  OR customer_id IS NULL
  OR gender IS NULL
  OR age IS NULL
  OR category IS NULL
  OR quantity IS NULL
  OR price_per_unit IS NULL
  OR cogs IS NULL
  OR total_sale IS NULL;
```

### Remove Records with Missing Data

```sql
DELETE FROM retail_sales_clean
WHERE
  quantity IS NULL
  OR price_per_unit IS NULL
  OR cogs IS NULL
  OR total_sale IS NULL;
```

### Fill Missing Age Values

```sql
  UPDATE retail_sales_clean
  SET age =
  (
  SELECT ROUND(AVG(age))
  FROM retail_sales_clean
  )
  WHERE age IS NULL;
```

### Invalid Data Validation

Checks performed:

* Quantity ≤ 0
* Price ≤ 0
* COGS ≤ 0
* Total Sale ≤ 0
* Total Sale < COGS

Example:

```sql
SELECT *
FROM retail_sales_clean
WHERE quantity <= 0;
```

---

# 3. Data Exploration

### Total Sales

```sql
SELECT COUNT(*) AS total_sales
FROM retail_sales_clean;
```

### Unique Customers

```sql
SELECT COUNT(DISTINCT customer_id)
FROM retail_sales_clean;
```

### Product Categories

```sql
SELECT DISTINCT category
FROM retail_sales_clean;
```

---

# 4. Data Analysis & Business Questions

The following SQL queries were developed to answer key business questions.

---

### Q1. Sales made on 2022-11-05

```sql
SELECT *
FROM retail_sales_clean
WHERE sale_date='2022-11-05';
```

---

### Q2. Clothing sales with quantity greater than 4 during November 2022

```sql
SELECT *
FROM retail_sales_clean
WHERE category='Clothing'
  AND quantity >= 4
  AND sale_date >= '2022-11-01'
  AND sale_date < '2022-12-01';
```

---

### Q3. Total sales by category

```sql
SELECT
  category,
  SUM(total_sale) AS total_sales,
  COUNT(*) AS total_orders
FROM retail_sales_clean
GROUP BY category
ORDER BY total_sales DESC;
```

---

### Q4. Average age of Beauty customers

```sql
SELECT
  ROUND(AVG(age),2) AS avg_age
FROM retail_sales_clean
WHERE category='Beauty';
```

---

### Q5. Transactions greater than 1000

```sql
SELECT
  transactions_id,
  total_sale
FROM retail_sales_clean
WHERE total_sale > 1000
ORDER BY total_sale DESC;
```

---

### Q6. Transactions by Gender and Category

```sql
SELECT
  category,
  gender,
  COUNT(transactions_id) AS total_transactions
FROM retail_sales_clean
GROUP BY
  category,
  gender
ORDER BY category;
```

---

### Q7. Best Selling Month in Each Year

Using CTEs and Window Functions.

```sql
WITH monthly_sales AS
(
  SELECT
  EXTRACT(YEAR FROM sale_date) AS year,
  EXTRACT(MONTH FROM sale_date) AS month,
  AVG(total_sale) AS avg_sale
  FROM retail_sales_clean
  GROUP BY year,month
),

ranked_months AS
(
  SELECT *,
  ROW_NUMBER() OVER(PARTITION BY year ORDER BY avg_sale DESC) AS rn
  FROM monthly_sales
)

SELECT
  year,
  month,
  avg_sale
FROM ranked_months
WHERE rn=1;
```

---

### Q8. Top 5 Customers by Sales

```sql
SELECT
  customer_id,
  SUM(total_sale) AS total_sales
FROM retail_sales_clean
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 5;
```

---

### Q9. Unique Customers by Category

```sql
SELECT
  category,
  COUNT(DISTINCT customer_id) AS unique_customers
FROM retail_sales_clean
GROUP BY category;
```

---

### Q10. Shift-wise Order Analysis

Morning → Before 12 PM

Afternoon → Between 12 PM and 5 PM

Evening → After 5 PM

```sql
WITH shift_wise_orders AS
(
SELECT *,
  CASE
    WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
    WHEN EXTRACT(HOUR FROM sale_time)  BETWEEN 12 AND 17 THEN 'Afternoon'    
    ELSE 'Evening'
  END AS shift

FROM retail_sales_clean
)
SELECT
  shift,
  COUNT(*) AS total_orders
FROM shift_wise_orders
GROUP BY shift;
```

---

# Findings

### Customer Demographics

The dataset includes customers across multiple age groups and purchasing behaviors.

### High Value Transactions

Several transactions exceeded 1000 in total sales, indicating premium purchases.

### Sales Trends

Monthly analysis reveals seasonal fluctuations and identifies top-performing periods.

### Customer Insights

Top customers contribute significantly to overall revenue.

### Category Performance

Certain categories attract a larger number of unique customers.

### Shift Analysis

Order distribution varies significantly across Morning, Afternoon, and Evening periods.

---

# Reports Generated

### Sales Summary

* Total Sales
* Order Volume
* Category Performance

### Customer Insights

* Top Customers
* Unique Customer Counts
* Demographic Analysis

### Trend Analysis

* Monthly Sales Trends
* Best Performing Months
* Shift Analysis

---

# SQL Concepts Used

✔ CREATE TABLE

✔ ALTER TABLE

✔ Data Cleaning

✔ Data Validation

✔ DELETE

✔ UPDATE

✔ Aggregate Functions

✔ GROUP BY

✔ DISTINCT

✔ CASE WHEN

✔ CTEs

✔ Window Functions

✔ ROW_NUMBER()

✔ EXTRACT()

✔ Business Analysis

✔ Exploratory Data Analysis

---

# Conclusion

This project helped strengthen my practical SQL and PostgreSQL skills for data analytics.

It demonstrates practical experience in:

* Data Cleaning
* Data Validation
* Exploratory Data Analysis
* Business Problem Solving
* SQL Reporting
* Window Functions
* Customer Analytics
* Sales Analytics

The insights generated from this project can support decision-making related to customer behavior, product performance, and sales optimization.

---

# How To Use

1. Download or clone this repository.

2. Open PostgreSQL or pgAdmin.

3. Create a database named:

```sql
CREATE DATABASE sql_project_p1;
```

4. Execute the SQL script in sequence:

* Database Setup
* Data Cleaning
* Data Exploration
* Business Analysis

5. Review the query outputs and findings.

---

# Author

**Anand Kumar**

Aspiring Data Analyst

PostgreSQL | SQL | Power BI | Data Analytics

This project is part of my Data Analytics portfolio showcasing SQL skills required for Data Analyst roles.

Feel free to connect, provide feedback, or collaborate on future projects.
