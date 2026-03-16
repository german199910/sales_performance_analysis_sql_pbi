-- RFM (Recency, Frecuency, Monetary) Analysis.
-- How recently did the customer buy?, How often does the customer buy?, How much money does the customer spend?

-- First -> Determine the Reference Date
SELECT MAX(orderdate)
	FROM sales_completed;

	-- Build the RFM Table
	SELECT
    customername,
    MAX(orderdate) AS last_purchase_date,
    (SELECT MAX(orderdate) FROM sales_completed) - MAX(orderdate) AS recency_days,
    COUNT(DISTINCT ordernumber) AS frequency,
    SUM(sales) AS monetary
	FROM sales_completed
	GROUP BY customername
	ORDER BY monetary DESC;
--The customer who bought yesterday is more engaged than one who bought 200 days ago.

-- Quick Data Quality Check -> Before scoring customers, it's useful to check
SELECT
		COUNT(DISTINCT customername)
	FROM sales_completed;

	-- NTILE() -> divides the rows into n groups 
	-- First create the base RFM table
	WITH rfm_base AS (
		SELECT
			customername,
			MAX(orderdate) AS last_purchase,
			(SELECT MAX(orderdate) FROM sales_completed) - MAX(orderdate) AS recency,
			COUNT(DISTINCT ordernumber) AS frequency,
			SUM(sales) AS monetary
		FROM sales_completed
		GROUP BY customername
	)
	SELECT *
	FROM rfm_base
	ORDER BY monetary DESC;
	
-- As this work, apply NTILE(5)
WITH rfm_base AS (
		SELECT
			customername,
			MAX(orderdate) AS last_purchase,
			(SELECT MAX(orderdate) FROM sales_completed) - MAX(orderdate) AS recency,
			COUNT(DISTINCT ordernumber) AS frequency,
			SUM(sales) AS monetary
		FROM sales_completed
		GROUP BY customername
	)
SELECT
		customername,
		recency,
		frequency,
		monetary,
		NTILE(5) OVER (ORDER BY recency DESC) AS r_score,
		NTILE(5) OVER (ORDER BY frequency ASC) AS f_score,
		NTILE(5) OVER (ORDER BY monetary ASC) AS m_score
	FROM rfm_base;
-- Short explain -> 5 is the best in the category, 1 is the worst.
-- 5,5,5 -> Excellent customer. 1,1,1 -> Weak/inactive customer.
-- Now with this, let's ordenate and combine the three scores into one code.
WITH rfm_base AS (
	SELECT
			customername,
			MAX(orderdate) AS last_purchase,
			(SELECT MAX(orderdate) FROM sales_completed) - MAX(orderdate) AS recency,
			COUNT(DISTINCT ordernumber) AS frequency,
			SUM(sales) AS monetary
	FROM sales_completed
	GROUP BY customername
		),
		rfm_scores AS (
	SELECT
			customername,
			recency,
			frequency,
			monetary,
			NTILE(5) OVER (ORDER BY recency DESC) AS r_score,
			NTILE(5) OVER (ORDER BY frequency ASC) AS f_score,
			NTILE(5) OVER (ORDER BY monetary ASC) AS m_score
	FROM rfm_base
		)
	SELECT
			customername,
			recency,
			frequency,
			monetary,
			r_score,
			f_score,
			m_score,
			CONCAT(r_score, f_score, m_score) AS rfm_score
		FROM rfm_scores
		ORDER BY rfm_score DESC, monetary DESC;
-- Stop one second. Let's explain this
-- Loyal customers -> High frequency, good monetary but not perfect recency (355) 
-- Big spenders -> High monetary but maybe lower frequency or recency (445)
-- At risk -> Use to buy, now inactive (155)
-- Lost/weak customers -> 111, 112, 121
-- A better version: create segment labels directly
WITH rfm_base AS (
	SELECT
			customername,
			MAX(orderdate) AS last_purchase,
			(SELECT MAX(orderdate) FROM sales_completed) - MAX(orderdate) AS recency,
			COUNT(DISTINCT ordernumber) AS frequency,
			SUM(sales) AS monetary
		FROM sales_completed
		GROUP BY customername
		),
		rfm_scores AS (
		SELECT
			customername,
			recency,
			frequency,
			monetary,
			NTILE(5) OVER (ORDER BY recency DESC) AS r_score,
			NTILE(5) OVER (ORDER BY frequency ASC) AS f_score,
			NTILE(5) OVER (ORDER BY monetary ASC) AS m_score
		FROM rfm_base
		)
		SELECT
			customername,
			recency,
			frequency,
			monetary,
			r_score,
			f_score,
			m_score,
			CONCAT(r_score, f_score, m_score) AS rfm_score,
			CASE
				WHEN r_score >= 4 AND f_score >=4 AND m_score >= 4 THEN 'Champions'
				WHEN r_score >= 3 AND f_score >=3 THEN 'Loyal Customers'
				WHEN r_score >= 4 AND f_score <= 2 THEN 'Recent Customers'
				WHEN r_score <= 2 AND f_score >= 3 AND m_score >= 3 THEN 'At Risk'
				WHEN r_score <= 2 AND f_score <= 2 AND m_score <=2 THEN 'Lost Customer'
				ELSE 'Potential Loyalists'
			END AS segment
		FROM rfm_scores
		ORDER BY monetary DESC;
		
-- Count Customers per Segment -> How many customers fall into each segment
WITH rfm_base AS (
    SELECT
        customername,
        MAX(orderdate) AS last_purchase,
        (SELECT MAX(orderdate) FROM sales_completed) - MAX(orderdate) AS recency,
        COUNT(DISTINCT ordernumber) AS frequency,
        SUM(sales) AS monetary
    FROM sales_completed
    GROUP BY customername
),
rfm_scores AS (
    SELECT
        customername,
        recency,
        frequency,
        monetary,
        NTILE(5) OVER (ORDER BY recency DESC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency ASC) AS f_score,
        NTILE(5) OVER (ORDER BY monetary ASC) AS m_score
    FROM rfm_base
),
rfm_segments AS (
    SELECT
        customername,
        recency,
        frequency,
        monetary,
        r_score,
        f_score,
        m_score,
        CONCAT(r_score,f_score,m_score) AS rfm_score,
        CASE
            WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
            WHEN r_score >= 3 AND f_score >= 4 THEN 'Loyal Customers'
            WHEN r_score >= 4 AND f_score <= 2 THEN 'Recent Customers'
            WHEN r_score <= 2 AND f_score >= 3 AND m_score >= 3 THEN 'At Risk'
            WHEN r_score <= 2 AND f_score <= 2 AND m_score <= 2 THEN 'Lost Customers'
            ELSE 'Potential Loyalists'
        END AS segment
    FROM rfm_scores
)
SELECT
    segment,
    COUNT(*) AS customers
FROM rfm_segments
GROUP BY segment
ORDER BY customers DESC;

-- Create a View of the rfm_base
 CREATE VIEW rfm_segments AS
WITH rfm_base AS (
    SELECT
        customername,
        MAX(orderdate) AS last_purchase,
        (SELECT MAX(orderdate) FROM sales_completed) - MAX(orderdate) AS recency,
        COUNT(DISTINCT ordernumber) AS frequency,
        SUM(sales) AS monetary
    FROM sales_completed
    GROUP BY customername
),
rfm_scores AS (
    SELECT
        customername,
        recency,
        frequency,
        monetary,
        NTILE(5) OVER (ORDER BY recency DESC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency ASC) AS f_score,
        NTILE(5) OVER (ORDER BY monetary ASC) AS m_score
    FROM rfm_base
)
SELECT
    customername,
    recency,
    frequency,
    monetary,
    CASE
        WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
        WHEN r_score >= 3 AND f_score >= 4 THEN 'Loyal Customers'
        WHEN r_score >= 4 AND f_score <= 2 THEN 'Recent Customers'
        WHEN r_score <= 2 AND f_score >= 3 AND m_score >= 3 THEN 'At Risk'
        WHEN r_score <= 2 AND f_score <= 2 AND m_score <= 2 THEN 'Lost Customers'
        ELSE 'Potential Loyalists'
    END AS segment
FROM rfm_scores;

-- Revenue by Segment -> Which segments generate the most revenue
SELECT
	segment,
	COUNT(*) AS customers,
	SUM(monetary) AS revenue
FROM rfm_segments
GROUP BY segment
ORDER BY revenue DESC;

-- Average Customer Value per Segment -> How valuable is each segment?
SELECT 
	segment,
	COUNT(*) AS customers,
	AVG(monetary) AS avg_customer_value
FROM rfm_segments
GROUP BY segment
ORDER BY avg_customer_value DESC;