Superstore Sales Analysis

This project explores the Sample Superstore retail dataset using SQL and SQLite. I worked on understanding sales performance, profitability, customer segments, regional trends, discounts, and product performance.

Project Overview

- Dataset: Sample Superstore
- Source: Kaggle (Vivek Chowdhury)
- Total Records: 9,994 rows
- Total Columns: 21
- Time Period: 2014–2017
- SQL Tool: SQLite

Note: The 9,994 figure represents dataset rows, not the number of unique orders.

Business Questions

I used SQL to explore the following questions:

1. What are the total sales and total profit?
2. How many unique orders are recorded?
3. Which product categories have the most sales records?
4. Which products generate the highest sales?
5. Which region contributes the most revenue?
6. How does average order-level profit vary by category?
7. How have sales changed over the years?
8. Which customer segment generates the most orders?
9. Which states sell the highest quantities?
10. How many orders have negative overall profit?
11. How many orders include discounts above 30%?
12. Which states generate the highest profit?
13. Which shipping modes are used most frequently?
14. Which customers generate the highest sales?
15. How do products rank within their categories?
16. What does the cumulative sales trend look like?
17. Who is the highest-sales customer in each region?
18. Which sub-categories have the lowest profit?
19. How are sales distributed across categories and sub-categories?

SQL Concepts Used

- SELECT, WHERE and ORDER BY
- GROUP BY and aggregate functions
- COUNT and COUNT DISTINCT
- Common Table Expressions (CTEs)
- Subqueries
- CASE expressions
- Window functions: RANK() and ROW_NUMBER()
- Running totals
- Date handling in SQLite

Repository Files

File| Description
"superstore_queries.sql"| 20 commented SQL queries used for the analysis

How to Run This Project

1. Download the Sample Superstore dataset from Kaggle.
2. Import the dataset into an SQLite database.
3. Name the table "Superstore".
4. Make sure the column names match those used in the SQL file.
5. Open "superstore_queries.sql" in an SQLite-compatible SQL editor.
6. Execute the queries individually to explore the results.

Project Limitations

- This repository currently contains SQL analysis only.
- A Power BI dashboard and PBIX file are not included yet.
- The findings depend on the dataset version and correct data import.
- The analysis identifies patterns in the data; it does not prove the causes behind them.

About Me

Suhail Hussain
B.Sc. Mathematics Student | Aspiring Data Analyst

GitHub: "suhelbhai0045-lang" (https://github.com/suhelbhai0045-lang)
