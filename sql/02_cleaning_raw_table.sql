-- =========================================
-- STEP 2: CREATE CLEAN RAW TABLE
-- Convert TEXT columns into correct data types
-- =========================================

DROP TABLE IF EXISTS auto_sales_raw;

CREATE TABLE auto_sales_raw AS
SELECT
  NULLIF(ordernumber,'')::INT AS ordernumber,
  NULLIF(quantityordered,'')::INT AS quantityordered,
  NULLIF(priceeach,'')::NUMERIC AS priceeach,
  NULLIF(orderlinenumber,'')::INT AS orderlinenumber,
  NULLIF(sales,'')::NUMERIC AS sales,
  CASE
    WHEN NULLIF(orderdate,'') IS NULL THEN NULL
    ELSE TO_DATE(orderdate, 'DD/MM/YYYY')
  END AS orderdate,
  NULLIF(days_since_lastorder,'')::INT AS days_since_lastorder,
  NULLIF(status,'') AS status,
  NULLIF(productline,'') AS productline,
  NULLIF(msrp,'')::NUMERIC AS msrp,
  NULLIF(productcode,'') AS productcode,
  NULLIF(customername,'') AS customername,
  NULLIF(phone,'') AS phone,
  NULLIF(addressline1,'') AS addressline1,
  NULLIF(city,'') AS city,
  NULLIF(postalcode,'') AS postalcode,
  NULLIF(country,'') AS country,
  NULLIF(contactlastname,'') AS contactlastname,
  NULLIF(contactfirstname,'') AS contactfirstname,
  NULLIF(dealsize,'') AS dealsize
FROM auto_sales_staging;

-- Check Outs

SELECT COUNT(*) FROM auto_sales_raw;

SELECT COUNT(DISTINCT ordernumber) FROM auto_sales_raw;

SELECT COUNT(DISTINCT customername) FROM auto_sales_raw;