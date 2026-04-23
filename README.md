# E-Commerce Sales & Customer Behaviour Analysis

![SQL](https://img.shields.io/badge/SQL-Intermediate-blue)
![MySQL](https://img.shields.io/badge/MySQL-8.0-orange)
![Dataset](https://img.shields.io/badge/Dataset-541K%20Rows-green)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen)

---

## 📌 Project Overview

An online retail company is experiencing declining repeat purchases and wants to understand customer behaviour, product performance, and revenue trends to improve retention and increase profitability.

As a Data Analyst, I analysed 500,000+ real transactional records using SQL to uncover purchasing patterns, segment customers, and deliver insights that help the business take targeted action.

> **Dataset:** UCI Online Retail Dataset — Real transactions from a UK-based online retailer (2010–2011)
> **Source:** [UCI Machine Learning Repository](https://archive.ics.uci.edu/dataset/352/online+retail)
> **Records:** 541,909 rows across 8 columns

---

## 🔑 Key Findings

> **Top 10% of customers (438 customers) drive 56% of total revenue — £9.97M out of £63.87M**

| # | Business Question | Key Finding |
|---|---|---|
| 1 | Which months had highest revenue? | November 2011 generated the highest revenue |
| 2 | Who are the top 10% customers? | 438 customers generate 56% of all revenue |
| 3 | Which products are most cancelled? | REGENCY CAKESTAND 3 TIER — 543 cancellations |
| 4 | Which countries order most outside UK? | Germany, France and EIRE are top 3 |
| 5 | How do customers segment by RFM? | 5 Champion customers scored perfect 555 |

---

## ❓ Business Questions & Insights

### Q1 — Monthly Revenue Trends
- November 2011 generated the highest revenue in the dataset
- A visible dip in December 2011 is attributed to **incomplete data** — the dataset ends mid-December, not a real business decline
- Revenue shows a strong upward trend from Q1 to Q4 2011 — consistent with typical retail seasonality

### Q2 — Top 10% Customer Analysis
- **438 customers** qualify as top 10% with a minimum revenue threshold of **£7,013**
- These 438 customers collectively generate **£9,968,242 — 56% of total revenue**
- Top customer `14646` alone generated **£558,978** purchasing children's giftware in bulk — almost certainly a wholesale reseller
- **49.8% of transactions (270,160 rows) had no CustomerID** — representing guest purchases excluded from customer-level analysis
- Several customers showed **negative lifetime revenue** — meaning returns exceeded purchases, flagged as high-risk accounts

### Q3 — Product Cancellation Analysis
- Top cancelled items initially included `Manual`, `Postage` and `Discount` — identified as **system entries, not real products**, and excluded from analysis
- After cleaning, **REGENCY CAKESTAND 3 TIER** has the highest real cancellation rate with **543 cancellations**
- `JUMBO BAG RED RETROSPOT` shows only 132 cancellations but **3,345 units returned** — indicating bulk return behaviour by wholesale buyers
- High cancellations on top-selling products suggest potential quality, packaging or shipping issues worth investigating

### Q4 — Geographic Analysis
- **Germany (37,980), France (34,228) and EIRE (32,784)** are the top 3 international markets
- **8 out of top 10** international markets are European — indicating strong regional concentration
- Australia appears at position 8 with only 5,036 orders despite being English-speaking — geographic proximity outweighs language similarity

### Q5 — RFM Customer Segmentation
- **5 Champion customers** scored a perfect 555 (Recent, Frequent, High Spend)
- `CustomerID 17850` is the most loyal customer with **34 purchases** — highest frequency in the entire dataset
- RFM segmentation enables targeted marketing: Champions → loyalty rewards, At-Risk customers → win-back campaigns

---

## 🛠️ Tools & Technologies

- **MySQL 8.0** — Database setup, data ingestion, transformation and analysis
- **GitHub** — Version control and project documentation

---

## 💡 Data Quality Issues Found & Resolved

| Issue | Resolution |
|---|---|
| InvoiceDate stored as text in CSV | Used STR_TO_DATE() to convert to DATETIME |
| BOM character in CSV header | Re-saved CSV as UTF-8 without BOM in Notepad |
| 49.8% missing CustomerIDs | Excluded from customer-level analysis, flagged as guest purchases |
| Hidden character in United Kingdom | Used LIKE instead of = for country filtering |
| System entries in cancellation data | Excluded Manual, Postage, Discount using NOT IN |
| Negative revenue customers | Identified as customers where returns exceeded purchases |
| Date format mismatch | CSV format DD-MM-YYYY converted using STR_TO_DATE() |
| Large file import 541K rows | Used LOAD DATA INFILE instead of wizard — 54 seconds vs 100+ hours |

---

## 📂 Project Structure

```
E-commerce_SQL_Analysis/
│
├── data/
│   └── online_retail.csv          # Raw dataset (download from UCI link above)
│
├── sql/
│   └── ecommerce_analysis.sql     # All SQL scripts (setup to analysis)
│
└── README.md
```

---

## 📊 SQL Concepts Used

- `CTEs` — Multi-step customer revenue and RFM analysis
- `Window Functions` — NTILE(5) for RFM scoring, NTILE(10) for top 10% segmentation
- `Subqueries` — Nested filtering for percentile analysis
- `GROUP BY` — Aggregation across customers, products and countries
- `Date Functions` — DATE_FORMAT(), STR_TO_DATE() for monthly trends
- `String Functions` — LIKE, NOT IN, TRIM() for data cleaning
- `CASE WHEN` — Customer segment classification
- `ABS()` — Handling negative quantities from cancellations
- `LOAD DATA INFILE` — High performance bulk data ingestion

---

## 🚀 How to Run This Project

1. Download the dataset from [UCI Repository](https://archive.ics.uci.edu/dataset/352/online+retail)
2. Save as `online_retail.csv` with UTF-8 encoding and no BOM
3. Copy CSV to `C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/`
4. Open MySQL Workbench and run `ecommerce_analysis.sql` top to bottom
5. Each section is clearly commented — run section by section for best results

---

## 👤 About Me

**Jayesh Chaudhari** — Data Analyst with 2+ years of international experience at Enbridge Canada, managing data validation across $600M+ CAD in DSM program value. Currently seeking Data Analyst opportunities in Pune, Maharashtra.

📧 chaudharij1503@gmail.com
🔗 [LinkedIn](https://linkedin.com/in/jchau1503)

---

*Feedback and suggestions are welcome! Feel free to raise an issue or connect on LinkedIn.*
