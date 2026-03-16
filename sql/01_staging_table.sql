-- Create staging table to import CSV without type errors

DROP TABLE IF EXISTS auto_sales_staging;

CREATE TABLE auto_sales_staging (
    ordernumber TEXT,
    quantityordered TEXT,
    priceeach TEXT,
    orderlinenumber TEXT,
    sales TEXT,
    orderdate TEXT,
    days_since_lastorder TEXT,
    status TEXT,
    productline TEXT,
    msrp TEXT,
    productcode TEXT,
    customername TEXT,
    phone TEXT,
    addressline1 TEXT,
    city TEXT,
    postalcode TEXT,
    country TEXT,
    contactlastname TEXT,
    contactfirstname TEXT,
    dealsize TEXT
);