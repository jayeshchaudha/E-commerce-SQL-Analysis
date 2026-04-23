-- =============================================================
-- E-Commerce Sales & Customer Behaviour Analysis
-- Author: Jayesh Chaudhari
-- Dataset: UCI Online Retail Dataset (541,909 rows)
-- Tool: MySQL 8.0
-- GitHub: github.com/jayeshchaudha/E-commerce_SQL_Analysis
-- =============================================================

-- =============================================================
-- SECTION 1 — SETUP ENVIRONMENT
-- =============================================================

CREATE DATABASE IF NOT EXISTS ecommerce_analysis;
USE ecommerce_analysis;

-- =============================================================
-- SECTION 2 — TABLE STRUCTURE
-- Note: InvoiceDate defined as VARCHAR to accommodate CSV format
--       InvoiceDateClean added as DATETIME after transformation
-- =============================================================

CREATE TABLE IF NOT EXISTS online_retail (
    InvoiceNo        VARCHAR(20),
    StockCode        VARCHAR(20),
    Description      TEXT,
    Quantity         INT,
    InvoiceDate      VARCHAR(50),
    UnitPrice        DECIMAL(10, 2),
    CustomerID       VARCHAR(20),
    Country          VARCHAR(50),
    InvoiceDateClean DATETIME
);

-- =============================================================
-- SECTION 3 — DATA INGESTION
-- Using LOAD DATA INFILE for performance
-- 541,909 rows imported in ~54 seconds
-- CSV must be placed in: C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/
-- =============================================================

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/online_retail.csv'
INTO TABLE online_retail
CHARACTER SET utf8
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(InvoiceNo, StockCode, Description, Quantity, InvoiceDate, UnitPrice, CustomerID, Country);

-- =============================================================
-- SECTION 4 — DATA TRANSFORMATION
-- Convert InvoiceDate VARCHAR to proper DATETIME format
-- CSV format: DD-MM-YYYY HH:MM
-- =============================================================

SET SQL_SAFE_UPDATES = 0;

UPDATE online_retail
SET InvoiceDateClean = STR_TO_DATE(InvoiceDate, '%d-%m-%Y %H:%i');

SET SQL_SAFE_UPDATES = 1;

-- =============================================================
-- SECTION 5 — VERIFICATION
-- =============================================================

SELECT COUNT(*) AS total_rows FROM online_retail;
-- Expected: 541,909 rows

SELECT * FROM online_retail LIMIT 10;

DESCRIBE online_retail;

-- =============================================================
-- BUSINESS QUESTION 1
-- Which months generated the highest revenue?
-- =============================================================

SELECT 
    DATE_FORMAT(InvoiceDateClean, '%Y-%m') AS Month, 
    ROUND(SUM(Quantity * UnitPrice), 2)    AS Revenue,
    COUNT(DISTINCT InvoiceNo)              AS Total_Orders
FROM online_retail
WHERE InvoiceNo NOT LIKE 'C%'
AND Quantity > 0
GROUP BY Month 
ORDER BY Revenue DESC;

-- FINDING: November 2011 generated highest revenue
-- NOTE: December 2011 dip is due to incomplete data

-- =============================================================
-- BUSINESS QUESTION 2
-- Who are the top 10% of customers by revenue and what do they buy?
-- =============================================================

-- Step 1: Check missing CustomerIDs
SELECT COUNT(*) AS missing_customers
FROM online_retail
WHERE CustomerID IS NULL OR CustomerID = '';
-- FINDING: 270,160 rows (49.8%) have no CustomerID

-- Step 2: Identify top 10% customers
WITH customer_revenue AS (
    SELECT 
        CustomerID, 
        ROUND(SUM(Quantity * UnitPrice), 2) AS Revenue
    FROM online_retail
    WHERE CustomerID IS NOT NULL 
    AND CustomerID != ''
    AND InvoiceNo NOT LIKE 'C%'
    GROUP BY CustomerID
),
ranked AS (
    SELECT *,
           NTILE(10) OVER (ORDER BY Revenue DESC) AS Percentile
    FROM customer_revenue
)
SELECT 
    COUNT(*)                   AS top_10_percent_customers,
    ROUND(MIN(Revenue), 2)     AS min_revenue,
    ROUND(MAX(Revenue), 2)     AS max_revenue,
    ROUND(SUM(Revenue), 2)     AS total_revenue
FROM ranked
WHERE Percentile = 1;
-- FINDING: 438 customers generate 56% of total revenue

-- Step 3: Total revenue for Pareto comparison
SELECT ROUND(SUM(Quantity * UnitPrice), 2) AS total_all_revenue
FROM online_retail
WHERE CustomerID IS NOT NULL
AND CustomerID != ''
AND Quantity > 0;
-- FINDING: £63,867,362 total revenue

-- Step 4: What does the top customer buy?
SELECT 
    Description, 
    ROUND(SUM(Quantity * UnitPrice), 2) AS Revenue
FROM online_retail
WHERE CustomerID = '14646'
AND InvoiceNo NOT LIKE 'C%'
GROUP BY Description
ORDER BY Revenue DESC
LIMIT 10;
-- FINDING: Customer 14646 buys children giftware in bulk — likely a wholesaler

-- =============================================================
-- BUSINESS QUESTION 3
-- Which products have the highest return or cancellation rate?
-- =============================================================

SELECT 
    Description, 
    COUNT(*) AS cancel_count,
    ABS(SUM(Quantity)) AS total_qty_returned
FROM online_retail
WHERE InvoiceNo LIKE 'C%' 
AND Description NOT IN ('Manual', 'Postage', 'Discount', 'Samples')
AND Description IS NOT NULL
AND Description != ''
GROUP BY TRIM(Description)
ORDER BY cancel_count DESC
LIMIT 10;
-- FINDING: REGENCY CAKESTAND 3 TIER has 543 cancellations
-- FINDING: JUMBO BAG RED RETROSPOT — 132 cancellations but 3,345 units returned

-- =============================================================
-- BUSINESS QUESTION 4
-- Which countries drive the most orders outside the UK?
-- =============================================================

-- DATA QUALITY NOTE: United Kingdom has hidden character from CSV
-- Using LIKE instead of = to handle this

SELECT 
    Country, 
    COUNT(DISTINCT InvoiceNo)              AS total_orders,
    ROUND(SUM(Quantity * UnitPrice), 2)    AS revenue
FROM online_retail
WHERE Country NOT LIKE 'United Kingdom%'
AND InvoiceNo NOT LIKE 'C%'
AND Quantity > 0
GROUP BY Country
ORDER BY total_orders DESC
LIMIT 10;
-- FINDING: Germany, France, EIRE are top 3 international markets
-- FINDING: 8 out of top 10 markets are European

-- =============================================================
-- BUSINESS QUESTION 5
-- How do customers segment by RFM score?
-- R = Recency  (5 = most recent)
-- F = Frequency (5 = most frequent)
-- M = Monetary  (5 = highest spend)
-- =============================================================

WITH rfm_base AS (
    SELECT 
        CustomerID,
        MAX(InvoiceDateClean)               AS last_purchase_date,
        COUNT(DISTINCT InvoiceNo)           AS frequency,
        ROUND(SUM(Quantity * UnitPrice), 2) AS monetary
    FROM online_retail
    WHERE CustomerID != ''
    AND CustomerID IS NOT NULL
    AND InvoiceNo NOT LIKE 'C%'
    AND Quantity > 0
    GROUP BY CustomerID
),
rfm_scores AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY last_purchase_date ASC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency ASC)          AS f_score,
        NTILE(5) OVER (ORDER BY monetary ASC)           AS m_score
    FROM rfm_base
),
rfm_segments AS (
    SELECT *,
        CONCAT(r_score, f_score, m_score) AS rfm_segment,
        CASE
            WHEN CONCAT(r_score, f_score, m_score) = '555' THEN 'Champion'
            WHEN r_score >= 4 AND f_score >= 4               THEN 'Loyal'
            WHEN r_score >= 4 AND f_score <= 2               THEN 'New Customer'
            WHEN r_score <= 2 AND f_score >= 4               THEN 'At Risk'
            WHEN r_score <= 2 AND f_score <= 2               THEN 'Lost'
            ELSE 'Potential'
        END AS customer_segment
    FROM rfm_scores
)
SELECT *
FROM rfm_segments
ORDER BY rfm_segment DESC
LIMIT 20;
-- FINDING: 5 Champion customers scored perfect 555
-- FINDING: CustomerID 17850 most loyal with 34 purchases

-- =============================================================
-- BONUS — Customer segment summary
-- =============================================================

WITH rfm_base AS (
    SELECT 
        CustomerID,
        MAX(InvoiceDateClean)               AS last_purchase_date,
        COUNT(DISTINCT InvoiceNo)           AS frequency,
        ROUND(SUM(Quantity * UnitPrice), 2) AS monetary
    FROM online_retail
    WHERE CustomerID != ''
    AND CustomerID IS NOT NULL
    AND InvoiceNo NOT LIKE 'C%'
    AND Quantity > 0
    GROUP BY CustomerID
),
rfm_scores AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY last_purchase_date ASC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency ASC)          AS f_score,
        NTILE(5) OVER (ORDER BY monetary ASC)           AS m_score
    FROM rfm_base
),
rfm_segments AS (
    SELECT *,
        CASE
            WHEN CONCAT(r_score, f_score, m_score) = '555' THEN 'Champion'
            WHEN r_score >= 4 AND f_score >= 4               THEN 'Loyal'
            WHEN r_score >= 4 AND f_score <= 2               THEN 'New Customer'
            WHEN r_score <= 2 AND f_score >= 4               THEN 'At Risk'
            WHEN r_score <= 2 AND f_score <= 2               THEN 'Lost'
            ELSE 'Potential'
        END AS customer_segment
    FROM rfm_scores
)
SELECT 
    customer_segment,
    COUNT(*)                    AS customer_count,
    ROUND(AVG(monetary), 2)     AS avg_revenue
FROM rfm_segments
GROUP BY customer_segment
ORDER BY avg_revenue DESC;
-- Useful for business prioritisation and marketing campaign planning
