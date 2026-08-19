
# Superstore Sales Analysis

SQL-based analysis of the Sample Superstore dataset — 9,994 orders across 4 regions and 3 product categories (2014–2017).

## Dataset
- Source: Superstore Dataset on Kaggle (Vivek Chowdhury)
- Rows: 9,994 | Columns: 21
- Tool used: SQLite (via sqliteonline.com)

## Key Insights

- **Total Sales:** $2.30M | **Total Profit:** $286.4K
- **West region** is the top performer ($725,457.82 in sales), while **South** lags behind ($391,721.91)
- **Technology** category has the highest average profit per order ($78.75), while **Furniture** is the weakest ($8.7)
- **1,871 orders (out of 9,994) resulted in a loss**, totaling $156,131.29 — largely tied to high discounting
- **1,166 orders had discounts above 30%**, a likely driver of the loss orders above
- **Tables and Bookcases sub-categories are loss-making** overall (-$17,725.48 and -$3,472.56 respectively) despite generating significant sales — a pricing/discount problem, not a demand problem
- Sales have grown steadily year over year: $484K (2014) → $733K (2017)
- **Sean Miller** is the top customer by total spend ($25,043.05)
- **Consumer segment** drives the most orders (2,586), followed by Corporate (1,514) and Home Office (909)

## Files
- `superstore_queries.sql` — 20 SQL queries covering aggregation, filtering, and window functions

## Tools Used
- SQL (SQLite)
- Power BI (interactive dashboard)

## Author
Suhail Hussain | B.Sc Mathematics | Aspiring Data Analyst
GitHub: suhelbhai0045-lang
Email: hussainsuhail749@gmail.com
