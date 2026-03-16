-- This file contains business metrics, exploratory data analysis and analytical views

--Create the main view

CREATE VIEW sales_completed AS
SELECT *
FROM auto_sales_raw
WHERE status IN ('Shipped','Resolved');

-- Cancellation rate

SELECT
SUM(CASE WHEN status = 'Cancelled' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS cancellation_rate
FROM auto_sales_raw;

-- Total revenue

SELECT
SUM(sales) AS total_revenue
FROM sales_completed;

-- Revenue by product line

CREATE VIEW sales_completed AS
SELECT *
FROM auto_sales_raw
WHERE status IN ('Shipped','Resolved');

-- Revenue share by product line

SELECT
productline,
SUM(sales) AS revenue
FROM sales_completed
GROUP BY productline
ORDER BY revenue DESC;

-- Revenue by country

SELECT
productline,
SUM(sales) AS revenue,
ROUND(100 * SUM(sales)/SUM(SUM(sales)) OVER(),2) AS revenue_share
FROM sales_completed
GROUP BY productline
ORDER BY revenue DESC;

-- Top customers

SELECT
customername,
SUM(sales) AS revenue
FROM sales_completed
GROUP BY customername
ORDER BY revenue DESC
LIMIT 10;

-- Monthly trend

SELECT
DATE_TRUNC('month', orderdate) AS month,
SUM(sales) AS revenue
FROM sales_completed
GROUP BY month
ORDER BY month;

-- Deal size distributioon

SELECT
dealsize,
COUNT(*) AS total_orders,
SUM(sales) AS revenue
FROM sales_completed
GROUP BY dealsize
ORDER BY revenue DESC;

-- Product performance

SELECT
productcode,
productline,
SUM(sales) AS revenue,
SUM(quantityordered) AS units_sold,
COUNT(DISTINCT ordernumber) AS orders_count,
AVG(priceeach) AS avg_price
FROM sales_completed
GROUP BY productcode, productline
ORDER BY revenue DESC;