Superstore Sales Analysis (SQL)
A SQL analysis of the Superstore sample dataset: 9,994 order lines from 2014 to 2017. I checked the data quality first, wrote the queries in SQLite, tested every query, and then wrote down what the results show.
Project objective
To answer basic business questions from sales data using SQL: how much the business sells and earns, which categories, regions and customers matter, where it loses money, and how discounts relate to profit. I also wanted to check the data and the queries carefully instead of trusting the first result.
Dataset
File: Sample - Superstore.csv (included, unchanged)
Content: 9,994 rows and 21 columns. Each row is one product line inside an order (order, customer, product, region, sales, quantity, discount, profit).
Period: orders from 2014-01-03 to 2017-12-30
Source: the Superstore sample dataset, widely used for practice. It is sample data, not data from a real company, and the file itself has no documentation or currency.
Tools used
SQLite (SQL queries, including window functions, subqueries and CASE)
Python (pandas) only to cross-check the SQL results independently
Markdown for documentation
No dashboard or Power BI file is part of this repository.
Data validation
Full details are in data_quality_check.md. In short:
No missing or blank values.
No fully duplicated rows, but 1 pair of rows is identical except for Row ID (kept, impact very small).
Dates are stored as text (M/D/YYYY) and were converted to YYYY-MM-DD in a SQL view.
Product ID is not a clean unique key (32 IDs are used for more than one product name), so products are analysed by name.
449 postal codes lost their leading zero (New England states and New Jersey).
1,871 rows (18.72%) have negative profit. They were kept, because losses are part of the analysis.
Analysis questions
The 30 queries in superstore_queries.sql are grouped into eight sections:
Basic exploration: dataset size, missing values, duplicates
Sales performance: totals, average order value, segments, shipping modes
Profitability: category and sub-category margins, loss-making order lines
Product analysis: top products by sales and profit, loss-making products
Customer analysis: top customers, loss-making customers, repeat customers
Regional analysis: regions, states, loss-making states, region x category
Time-based analysis: yearly growth, monthly pattern
Discount analysis: profit at each discount level, discounted vs non-discounted sales
Key verified findings
All numbers come from the query outputs in query_results.md.
Total sales 2,297,200.86, total profit 286,397.02, profit margin 12.47%.
Furniture has about the same sales as Office Supplies but a margin of only 2.49% (Technology 17.40%, Office Supplies 17.04%).
Tables (-17,725.48), Bookcases (-3,472.56) and Supplies (-1,189.10) lose money overall.
Order lines with no discount have a 29.51% margin. Lines with a discount have a combined profit of -34,590.58. At a discount of 0.30 or more, every discount level has a negative margin.
The Central region has the lowest margin (7.92%) and the highest average discount (0.24). 10 of 49 states lose money; Texas has the largest loss (-25,729.36).
Sales grew 29.47% in 2016 and 20.36% in 2017. September, November and December are the biggest months in every year.
The top customer by sales (Sean Miller, 25,043.05) has a negative total profit (-1,980.74). 155 of 793 customers (19.55%) have negative total profit.
These findings describe patterns in the data. For example, high discounts and low profit appear together, but the dataset cannot prove that discounts caused the losses. See business_insights.md for the explanation and limits of each finding.
Repository structure
superstore-sales-analysis/
├── README.md
├── Sample - Superstore.csv     # original dataset, unchanged
├── superstore_queries.sql      # 30 queries in 8 sections, with comments
├── data_quality_check.md       # validation results and issues found
├── query_results.md            # each query with its real SQLite output
└── business_insights.md        # findings, with figures and limitations
How to run the SQL analysis
You need SQLite 3.32 or newer (for .import --skip).
Download this repository and open a terminal in the folder.
Start SQLite:
sqlite3 superstore.db
Run the whole file (it creates the table, imports the CSV, creates the sales_data view and runs all queries):
.read superstore_queries.sql
You can also copy a single query from the file and run it after the setup. If you use DB Browser for SQLite, follow the note at the top of the SQL file.
The queries were tested by loading the CSV into SQLite 3.53.1 through Python's sqlite3 module. The .import shell command in the file was not run in this check, because the sqlite3 command-line program was not available in my testing environment.
Project limitations
Sample dataset: no cost, list price, returns or reason-for-discount columns, so causes cannot be proven.
Only four years (2014-2017) and 48 states plus DC (no Alaska or Hawaii).
Product-level results are by product name because Product ID is unreliable in this file.
One possible duplicate line was kept.
All findings are descriptive; no statistical tests were done.
No dashboard is included in this project.
Author
Suhail, B.Sc. Mathematics student (2024-2028), aiming for an entry-level Data Analyst role. GitHub: suhelbhai0045-lang
