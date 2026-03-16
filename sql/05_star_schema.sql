-- FIRST CREATE THE SCHEMA

CREATE SCHEMA IF NOT EXISTS warehouse;

-- NEXT CREATE DIM CUSTOMER TABLE
DROP TABLE IF EXISTS warehouse.dim_customer;

CREATE TABLE warehouse.dim_customer AS
SELECT
	ROW_NUMBER() OVER (ORDER BY customername) AS customer_id,
	customername,
	contactfirstname,
	contactlastname,
	phone,
	addressline1,
	city,
	postalcode,
	country
FROM(
	SELECT DISTINCT
		customername,
		contactfirstname,
		contactlastname,
		phone,
		addressline1,
		city,
		postalcode,
		country
	FROM sales_completed
)t;
)

-- NOW CREATE DIM PRODUCT TABLE
DROP TABLE IF EXISTS warehouse.dim_product;

CREATE TABLE warehouse.dim_product AS
SELECT
	ROW_NUMBER() OVER (ORDER BY productcode) AS product_id,
	productcode,
	productline,
	msrp
FROM (
	SELECT DISTINCT 
		productcode,
		productline,
		msrp
	FROM sales_completed
) t;

-- CREATE THE DIM DATE TABLE

DROP TABLE IF EXISTS warehouse.dim_date;

CREATE TABLE warehouse.dim_date AS
SELECT
    ROW_NUMBER() OVER (ORDER BY orderdate) AS date_id,
    orderdate AS full_date,
    EXTRACT(YEAR FROM orderdate) AS year,
    EXTRACT(MONTH FROM orderdate) AS month,
    EXTRACT(DAY FROM orderdate) AS day,
    EXTRACT(QUARTER FROM orderdate) AS quarter,
    TO_CHAR(orderdate, 'Month') AS month_name,
    TO_CHAR(orderdate, 'Day') AS day_name
FROM (
    SELECT DISTINCT orderdate
    FROM sales_completed
) t;

-- Create Fact sales Table
DROP TABLE IF EXISTS warehouse.fact_sales;

CREATE TABLE warehouse.fact_sales AS
SELECT
    s.ordernumber,
    s.orderlinenumber,
    c.customer_id,
    p.product_id,
    d.date_id,
    s.quantityordered,
    s.priceeach,
    s.sales,
    s.days_since_lastorder,
    s.dealsize,
    s.status
FROM sales_completed s
JOIN warehouse.dim_customer c
    ON s.customername = c.customername
JOIN warehouse.dim_product p
    ON s.productcode = p.productcode
JOIN warehouse.dim_date d
    ON s.orderdate = d.full_date;

-- Now we can check all the tables

SELECT * FROM warehouse.dim_customer
LIMIT 5;

SELECT * FROM warehouse.dim_date
LIMIT 5;

SELECT * FROM warehouse.dim_product
LIMIT 5;

SELECT * FROM warehouse.fact_sales
LIMIT 5;

-- Now let's make a row counts
SELECT COUNT(*) AS customers FROM warehouse.dim_customer; --89 rows
SELECT COUNT(*) AS products FROM warehouse.dim_product; --109 rows
SELECT COUNT(*) AS dates FROM warehouse.dim_date; -- 234 rows
SELECT COUNT(*) AS fact_rows FROM warehouse.fact_sales; --2588 rows