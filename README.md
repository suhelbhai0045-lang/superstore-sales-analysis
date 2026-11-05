Superstore Sales Analysis | SQL

About the Project

I worked on this project to practise SQL using a retail sales dataset. Instead of only writing basic queries, I tried to explore different business questions related to sales, profit, customers, regions, discounts and products.

The analysis is written in SQLite. Each query focuses on a specific question, and I have added comments to make the purpose of the query easier to understand.

Project Details

Detail| Information
Project| Superstore Sales Analysis
Dataset| Sample Superstore
Database| SQLite
Language| SQL
Queries| 20
Analysis Focus| Sales, Profit, Customers and Products

Questions I Explored

Sales Analysis

1. What are the overall sales and profit?
2. How many unique orders are in the dataset?
3. How many sales line items belong to each category?
4. Which products have the highest sales?
5. Which region generates the highest sales?
6. How do yearly sales compare?
7. Which customer segment has the most orders?

Customer and Regional Analysis

8. Which states have the highest quantity sold?
9. Which customers generate the highest sales?
10. Who is the highest-sales customer in each region?
11. How are orders distributed across shipping modes?

Profit and Discount Analysis

12. What is the average profit per order within each category?
13. How many orders have an overall loss?
14. How many orders contain discounts above 30%?
15. Which states generate the highest profit?
16. Which sub-categories have the lowest profit?

Product and Trend Analysis

17. How do products rank within their categories?
18. What does the running total of daily sales look like?
19. How are sales distributed across categories and sub-categories?
20. Which 10 products generate the highest sales?

SQL Skills Practised

- Filtering and sorting data
- GROUP BY and aggregate functions
- COUNT and COUNT DISTINCT
- Common Table Expressions (CTEs)
- Window functions
- RANK() and ROW_NUMBER()
- PARTITION BY
- Running totals
- Date conversion and date-based analysis

Repository Files

File| Purpose
"README.md"| Project details and instructions
"superstore_queries.sql"| SQL queries with comments

How to Run

1. Download the Sample Superstore dataset.
2. Create an SQLite database.
3. Import the dataset into a table named "Superstore".
4. Make sure the column names match those used in the SQL file.
5. Open "superstore_queries.sql" in an SQLite-compatible editor.
6. Run the queries individually.

Expected Column Names

The queries use these column names:

"order_id", "order_date", "ship_date", "ship_mode", "customer_id", "customer_name", "segment", "country", "city", "state", "postal_code", "region", "product_id", "category", "sub_category", "product_name", "sales", "quantity", "discount", "profit".

The original CSV may use spaces or different capitalization. Rename the columns during import if required.

Date format: The yearly sales and daily running-total queries currently expect dates in "M/D/YYYY" or "MM/DD/YYYY" format. Other date formats may require changes to those queries.

Current Limitations

- The repository currently contains SQL analysis only.
- A Power BI dashboard and its PBIX file have not been added.
- Query outputs and business findings will be added after testing the queries against the actual dataset.
- Results may vary depending on the dataset version and data preparation.

About Me

Suhail Hussain
B.Sc. Mathematics Student | Aspiring Data Analyst

GitHub: https://github.com/suhelbhai0045-lang
