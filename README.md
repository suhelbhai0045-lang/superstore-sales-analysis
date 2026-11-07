Superstore Sales Analysis | SQL + Power BI

An end-to-end retail sales analysis project using SQL (SQLite) and Power BI to explore sales performance, profitability, customer behavior, regional trends, product performance, and discount impact.

Project Overview

This project analyzes the Sample Superstore dataset containing 9,994 rows and 21 columns, covering sales transactions from 2014 to 2017.

The goal is to identify business trends, evaluate profitability, find loss-making areas, and present actionable insights through SQL analysis and an interactive Power BI dashboard.

Tools & Technologies

- SQL (SQLite): Data exploration, analysis, aggregations, subqueries, CTEs, and window functions.
- Power BI: Interactive dashboard and business performance visualization.
- CSV: Source dataset.
- GitHub: Project documentation and version control.

Dataset Information

Metric| Value
Total Records| 9,994
Total Columns| 21
Unique Orders| 5,009
Unique Customers| 793
Categories| 3
Sub-categories| 17
Date Range| 2014–2017

Key Business Metrics

KPI| Result
Total Sales| $2,297,200.86
Total Profit| $286,397.02
Profit Margin| 12.47%
Total Orders| 5,009
Total Quantity| 37,873

Power BI Dashboard

The interactive dashboard provides an overview of business performance and allows users to explore sales and profit trends.

Dashboard Preview

"Superstore Power BI Dashboard" (dashboard.png)

Dashboard Features

- KPI cards for Total Sales, Total Profit, Orders, and Quantity.
- Sales analysis by Region.
- Sales and profit analysis by Category and Sub-category.
- Customer Segment analysis.
- Shipping Mode analysis.
- Year-wise sales trends.
- Interactive slicers for Region, Category, and Year.

Power BI File: "Download Superstore Dashboard" (superstore_Dashboard.pbix)

SQL Analysis

The project contains 30 SQL queries organized into 8 analytical sections.

Section| Analysis
1| Basic Exploration
2| Sales Performance
3| Profitability Analysis
4| Product Analysis
5| Customer Analysis
6| Regional Analysis
7| Time-Based Analysis
8| Discount Analysis

SQL concepts used include:

- SELECT, WHERE, GROUP BY, ORDER BY
- Aggregate Functions
- CASE WHEN
- Subqueries
- Common Table Expressions (CTEs)
- Window Functions
- LAG()
- Date Functions

Key Business Insights

1. Regional Performance: The West region generated the highest sales and profit margin among the four regions.
2. Profitability: Overall profit margin was 12.47%.
3. Discount Impact: Discounted order lines generated a combined loss of $34,590.58, while non-discounted lines generated $320,987.60 in profit.
4. Loss-Making States: 10 states recorded negative overall profit.
5. Product Profitability: Tables and Bookcases were among the loss-making sub-categories.
6. Yearly Growth: Sales increased from $484,247.50 in 2014 to $733,215.26 in 2017.

Note: These are descriptive findings from the dataset. They show associations and patterns, not proof of causation.

Data Quality Checks

Data quality checks were performed to examine:

- Missing values in key columns.
- Duplicate transaction records.
- Date formatting and validity.
- Product ID uniqueness.
- Dataset consistency.

See "Data Quality Check" (data_quality_check.md).

Repository Structure

superstore-sales-analysis/
│
├── README.md
├── Sample - Superstore.csv
├── superstore_queries.sql
├── superstore_Dashboard.pbix
├── dashboard.png
├── data_quality_check.md
├── query_results.md
└── business_insights.md

How to Use This Project

1. Download or clone this repository.
2. Open the SQL file using SQLite or DB Browser for SQLite.
3. Import the CSV dataset as instructed in the SQL file.
4. Execute the SQL queries to explore the analysis.
5. Open the Power BI ".pbix" file using Power BI Desktop.
6. Explore the interactive dashboard using its slicers and visuals.

Project Limitations

- The analysis uses historical Sample Superstore data from 2014–2017.
- The dataset represents a sample retail business, not current market conditions.
- Discount and profitability relationships are observational and do not establish causation.

Author

Suhail Hussain

B.Sc. (Hons.) Mathematics Student | Aspiring Data Analyst

- GitHub: https://github.com/suhelbhai0045-lang
- Project Repository: https://github.com/suhelbhai0045-lang/superstore-sales-analysis

---

If you find this project useful, feel free to explore the SQL queries and Power BI dashboard.
