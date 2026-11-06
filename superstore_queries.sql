-- =====================================================================
-- Superstore Sales Analysis - SQL queries (SQLite)
-- Dataset : Sample - Superstore.csv (9,994 rows, 21 columns)
-- Author : Suhail
--
-- HOW TO RUN (sqlite3 command-line shell, version 3.32 or newer):
-- 1. Put this file and "Sample - Superstore.csv" in the same folder.
-- 2. Open a terminal in that folder and run:
-- sqlite3 superstore.db
-- 3. Inside the shell run:
-- .read superstore_queries.sql
-- The lines starting with a dot (.headers, .mode, .import) are sqlite3 shell
-- commands, not SQL. If you use DB Browser for SQLite instead, create the
-- table from the SETUP section, import the CSV with File > Import > Table
-- from CSV file (skip the header row), create the view, and then run the
-- queries one by one.
--
-- NOTES
-- * Dates in the CSV are text in M/D/YYYY format (e.g. 11/8/2016).
-- The view sales_data converts them to ISO format (YYYY-MM-DD) so that
-- sorting and strftime() work correctly. The CSV itself is never changed.
-- * Profit margin % = SUM(profit) / SUM(sales) * 100, calculated on totals,
-- not as an average of row-level margins.
-- * Totals are rounded to 2 decimals BEFORE testing "< 0" (HAVING ROUND(SUM(profit), 2) < 0).
-- Some products add up to a true zero but floating-point noise gives
-- values like -1.7e-15, which would wrongly count as a loss.
-- * Product ID is not a reliable unique key in this file (see
-- data_quality_check.md), so product analysis groups by product_name.
-- * Every query is marked [Qnn] so query_results.md can refer to it.
-- =====================================================================


-- =====================================================================
-- 0. SETUP
-- =====================================================================

DROP VIEW  IF EXISTS sales_data;
DROP TABLE IF EXISTS superstore;

CREATE TABLE superstore (
    row_id          INTEGER,
    order_id        TEXT,
    order_date_raw  TEXT,      -- M/D/YYYY as in the CSV
    ship_date_raw   TEXT,      -- M/D/YYYY as in the CSV
    ship_mode       TEXT,
    customer_id     TEXT,
    customer_name   TEXT,
    segment         TEXT,
    country         TEXT,
    city            TEXT,
    state           TEXT,
    postal_code     TEXT,
    region          TEXT,
    product_id      TEXT,
    category        TEXT,
    sub_category    TEXT,
    product_name    TEXT,
    sales           REAL,
    quantity        INTEGER,
    discount        REAL,
    profit          REAL
);

-- Load the CSV (sqlite3 shell commands). The header row is skipped because the
-- table above already has its own column names.
.headers on
.mode column
.import --csv --skip 1 "Sample - Superstore.csv" superstore

CREATE VIEW sales_data AS
SELECT
    s.*,
    date(
        substr(order_date_raw, -4) || '-' ||
        printf('%02d', CAST(substr(order_date_raw, 1, instr(order_date_raw, '/') - 1) AS INTEGER)) || '-' ||
        printf('%02d', CAST(substr(order_date_raw, instr(order_date_raw, '/') + 1,
               instr(substr(order_date_raw, instr(order_date_raw, '/') + 1), '/') - 1) AS INTEGER))
    ) AS order_date,
    date(
        substr(ship_date_raw, -4) || '-' ||
        printf('%02d', CAST(substr(ship_date_raw, 1, instr(ship_date_raw, '/') - 1) AS INTEGER)) || '-' ||
        printf('%02d', CAST(substr(ship_date_raw, instr(ship_date_raw, '/') + 1,
               instr(substr(ship_date_raw, instr(ship_date_raw, '/') + 1), '/') - 1) AS INTEGER))
    ) AS ship_date
FROM superstore AS s;


-- =====================================================================
-- 1. BASIC EXPLORATION
-- =====================================================================

-- [Q01] Dataset size and coverage
-- Business question: How big is the dataset and what period does it cover?
SELECT
    COUNT(*)                     AS total_rows,
    COUNT(DISTINCT order_id)     AS unique_orders,
    COUNT(DISTINCT customer_id)  AS unique_customers,
    COUNT(DISTINCT product_name) AS unique_products,
    COUNT(DISTINCT category)     AS categories,
    COUNT(DISTINCT sub_category) AS sub_categories,
    MIN(order_date)              AS first_order_date,
    MAX(order_date)              AS last_order_date
FROM sales_data;

-- [Q02] Missing values check
-- Business question: Do any key columns contain NULL or empty values?
SELECT
    SUM(CASE WHEN order_id      IS NULL OR TRIM(order_id)      = '' THEN 1 ELSE 0 END) AS missing_order_id,
    SUM(CASE WHEN customer_id   IS NULL OR TRIM(customer_id)   = '' THEN 1 ELSE 0 END) AS missing_customer_id,
    SUM(CASE WHEN product_name  IS NULL OR TRIM(product_name)  = '' THEN 1 ELSE 0 END) AS missing_product_name,
    SUM(CASE WHEN order_date    IS NULL                            THEN 1 ELSE 0 END) AS missing_order_date,
    SUM(CASE WHEN sales         IS NULL                            THEN 1 ELSE 0 END) AS missing_sales,
    SUM(CASE WHEN profit        IS NULL                            THEN 1 ELSE 0 END) AS missing_profit
FROM sales_data;

-- [Q03] Duplicate rows (ignoring Row ID)
-- Business question: Are any rows repeated exactly, apart from their Row ID?
SELECT
    order_id, product_id, product_name, sales, quantity, discount, profit,
    COUNT(*) AS times_repeated
FROM sales_data
GROUP BY order_id, product_id, product_name, sales, quantity, discount, profit
HAVING COUNT(*) > 1;


-- =====================================================================
-- 2. SALES PERFORMANCE
-- =====================================================================

-- [Q04] Overall business performance
-- Business question: What are total sales, profit, quantity and profit margin?
SELECT
    ROUND(SUM(sales), 2)                    AS total_sales,
    ROUND(SUM(profit), 2)                   AS total_profit,
    ROUND(SUM(profit) * 100.0 / SUM(sales), 2) AS profit_margin_pct,
    SUM(quantity)                           AS total_quantity
FROM sales_data;

-- [Q05] Average order value
-- Business question: How much sales value does an average order carry?
-- (Order-level totals first, then the average, so each order counts once.)
SELECT
    COUNT(*)                       AS total_orders,
    ROUND(AVG(order_sales), 2)     AS avg_order_value,
    ROUND(MIN(order_sales), 2)     AS smallest_order,
    ROUND(MAX(order_sales), 2)     AS largest_order
FROM (
    SELECT order_id, SUM(sales) AS order_sales
    FROM sales_data
    GROUP BY order_id
);

-- [Q06] Sales and profit by customer segment
-- Business question: Which customer segment brings the most sales and profit?
SELECT
    segment,
    COUNT(DISTINCT order_id)                    AS orders,
    ROUND(SUM(sales), 2)                        AS total_sales,
    ROUND(SUM(profit), 2)                       AS total_profit,
    ROUND(SUM(profit) * 100.0 / SUM(sales), 2)  AS profit_margin_pct
FROM sales_data
GROUP BY segment
ORDER BY total_sales DESC;

-- [Q07] Shipping mode usage and shipping time
-- Business question: How are orders shipped and how long does each mode take?
SELECT
    ship_mode,
    COUNT(DISTINCT order_id)                                   AS orders,
    ROUND(AVG(julianday(ship_date) - julianday(order_date)), 2) AS avg_days_to_ship,
    ROUND(SUM(sales), 2)                                       AS total_sales,
    ROUND(SUM(profit), 2)                                      AS total_profit
FROM sales_data
GROUP BY ship_mode
ORDER BY orders DESC;


-- =====================================================================
-- 3. PROFITABILITY ANALYSIS
-- =====================================================================

-- [Q08] Profitability by category
-- Business question: Which category earns the best and worst profit margin?
SELECT
    category,
    ROUND(SUM(sales), 2)                        AS total_sales,
    ROUND(SUM(profit), 2)                       AS total_profit,
    ROUND(SUM(profit) * 100.0 / SUM(sales), 2)  AS profit_margin_pct
FROM sales_data
GROUP BY category
ORDER BY total_profit DESC;

-- [Q09] Profitability by sub-category
-- Business question: Which sub-categories make money and which lose money?
SELECT
    category,
    sub_category,
    ROUND(SUM(sales), 2)                        AS total_sales,
    ROUND(SUM(profit), 2)                       AS total_profit,
    ROUND(SUM(profit) * 100.0 / SUM(sales), 2)  AS profit_margin_pct
FROM sales_data
GROUP BY category, sub_category
ORDER BY total_profit DESC;

-- [Q10] Loss-making order lines
-- Business question: How many order lines lose money and how large is the loss?
SELECT
    COUNT(*)                                                       AS loss_making_rows,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM sales_data), 2) AS pct_of_all_rows,
    ROUND(SUM(profit), 2)                                          AS total_loss,
    ROUND(AVG(profit), 2)                                          AS avg_loss_per_row,
    ROUND(MIN(profit), 2)                                          AS biggest_single_loss
FROM sales_data
WHERE profit < 0;

-- [Q11] Loss-making rows by category
-- Business question: Where do the loss-making order lines come from?
SELECT
    category,
    COUNT(*)                   AS total_rows,
    SUM(CASE WHEN profit < 0 THEN 1 ELSE 0 END) AS loss_rows,
    ROUND(SUM(CASE WHEN profit < 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS loss_rows_pct,
    ROUND(SUM(CASE WHEN profit < 0 THEN profit ELSE 0 END), 2) AS total_loss
FROM sales_data
GROUP BY category
ORDER BY total_loss ASC;


-- =====================================================================
-- 4. PRODUCT ANALYSIS
-- =====================================================================

-- [Q12] Top 10 products by sales
-- Business question: Which products generate the most sales?
SELECT
    TRIM(product_name)                          AS product_name,
    ROUND(SUM(sales), 2)                        AS total_sales,
    ROUND(SUM(profit), 2)                       AS total_profit,
    ROUND(SUM(profit) * 100.0 / SUM(sales), 2)  AS profit_margin_pct
FROM sales_data
GROUP BY TRIM(product_name)
ORDER BY total_sales DESC
LIMIT 10;

-- [Q13] Top 10 products by profit
-- Business question: Which products contribute the most profit?
SELECT
    TRIM(product_name)                          AS product_name,
    ROUND(SUM(profit), 2)                       AS total_profit,
    ROUND(SUM(sales), 2)                        AS total_sales,
    ROUND(SUM(profit) * 100.0 / SUM(sales), 2)  AS profit_margin_pct
FROM sales_data
GROUP BY TRIM(product_name)
ORDER BY total_profit DESC
LIMIT 10;

-- [Q14] Top 10 loss-making products
-- Business question: Which products lose the most money overall?
SELECT
    TRIM(product_name)                          AS product_name,
    ROUND(SUM(profit), 2)                       AS total_profit,
    ROUND(SUM(sales), 2)                        AS total_sales,
    ROUND(AVG(discount), 2)                     AS avg_discount
FROM sales_data
GROUP BY TRIM(product_name)
HAVING ROUND(SUM(profit), 2) < 0
ORDER BY total_profit ASC
LIMIT 10;

-- [Q15] How many products lose money overall
-- Business question: What share of products has a negative total profit?
SELECT
    COUNT(*)                                                  AS total_products,
    SUM(CASE WHEN total_profit < 0 THEN 1 ELSE 0 END)         AS loss_making_products,
    ROUND(SUM(CASE WHEN total_profit < 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS loss_making_pct
FROM (
    SELECT TRIM(product_name) AS product_name, ROUND(SUM(profit), 2) AS total_profit
    FROM sales_data
    GROUP BY TRIM(product_name)
);


-- =====================================================================
-- 5. CUSTOMER ANALYSIS
-- =====================================================================

-- [Q16] Top 10 customers by sales
-- Business question: Who are the highest-spending customers, and are they profitable?
SELECT
    customer_id,
    customer_name,
    segment,
    COUNT(DISTINCT order_id)  AS orders,
    ROUND(SUM(sales), 2)      AS total_sales,
    ROUND(SUM(profit), 2)     AS total_profit
FROM sales_data
GROUP BY customer_id, customer_name, segment
ORDER BY total_sales DESC
LIMIT 10;

-- [Q17] Top 10 customers by profit
-- Business question: Which customers contribute the most profit?
SELECT
    customer_id,
    customer_name,
    COUNT(DISTINCT order_id)  AS orders,
    ROUND(SUM(profit), 2)     AS total_profit,
    ROUND(SUM(sales), 2)      AS total_sales
FROM sales_data
GROUP BY customer_id, customer_name
ORDER BY total_profit DESC
LIMIT 10;

-- [Q18] Customers with negative total profit
-- Business question: How many customers cost the business money overall?
SELECT
    COUNT(*)                                                     AS total_customers,
    SUM(CASE WHEN ROUND(total_profit, 2) < 0 THEN 1 ELSE 0 END)  AS loss_making_customers,
    ROUND(SUM(CASE WHEN ROUND(total_profit, 2) < 0 THEN total_profit ELSE 0 END), 2) AS combined_loss
FROM (
    SELECT customer_id, SUM(profit) AS total_profit
    FROM sales_data
    GROUP BY customer_id
);

-- [Q19] Repeat customers
-- Business question: How many customers ordered more than once?
SELECT
    COUNT(*)                                                    AS total_customers,
    SUM(CASE WHEN orders > 1 THEN 1 ELSE 0 END)                 AS repeat_customers,
    ROUND(SUM(CASE WHEN orders > 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS repeat_customer_pct,
    ROUND(AVG(orders), 2)                                       AS avg_orders_per_customer
FROM (
    SELECT customer_id, COUNT(DISTINCT order_id) AS orders
    FROM sales_data
    GROUP BY customer_id
);


-- =====================================================================
-- 6. REGIONAL ANALYSIS
-- =====================================================================

-- [Q20] Performance by region
-- Business question: Which region has the highest sales and the best profit margin?
SELECT
    region,
    COUNT(DISTINCT order_id)                    AS orders,
    ROUND(SUM(sales), 2)                        AS total_sales,
    ROUND(SUM(profit), 2)                       AS total_profit,
    ROUND(SUM(profit) * 100.0 / SUM(sales), 2)  AS profit_margin_pct,
    ROUND(AVG(discount), 3)                     AS avg_discount
FROM sales_data
GROUP BY region
ORDER BY total_sales DESC;

-- [Q21] Top 10 states by sales
-- Business question: Which states sell the most?
SELECT
    state,
    region,
    ROUND(SUM(sales), 2)                        AS total_sales,
    ROUND(SUM(profit), 2)                       AS total_profit,
    ROUND(SUM(profit) * 100.0 / SUM(sales), 2)  AS profit_margin_pct,
    ROUND(AVG(discount), 3)                     AS avg_discount
FROM sales_data
GROUP BY state, region
ORDER BY total_sales DESC
LIMIT 10;

-- [Q22] Loss-making states
-- Business question: Which states have a negative total profit?
SELECT
    state,
    region,
    ROUND(SUM(sales), 2)   AS total_sales,
    ROUND(SUM(profit), 2)  AS total_profit,
    ROUND(AVG(discount), 3) AS avg_discount
FROM sales_data
GROUP BY state, region
HAVING ROUND(SUM(profit), 2) < 0
ORDER BY total_profit ASC;

-- [Q23] Profit by region and category
-- Business question: Is any category losing money inside a particular region?
SELECT
    region,
    category,
    ROUND(SUM(sales), 2)                        AS total_sales,
    ROUND(SUM(profit), 2)                       AS total_profit,
    ROUND(SUM(profit) * 100.0 / SUM(sales), 2)  AS profit_margin_pct
FROM sales_data
GROUP BY region, category
ORDER BY region, total_profit DESC;


-- =====================================================================
-- 7. TIME-BASED ANALYSIS
-- =====================================================================

-- [Q24] Yearly sales and profit with year-over-year growth
-- Business question: How did sales and profit change from year to year?
SELECT
    year,
    total_sales,
    total_profit,
    profit_margin_pct,
    ROUND((total_sales - LAG(total_sales) OVER (ORDER BY year)) * 100.0
          / LAG(total_sales) OVER (ORDER BY year), 2) AS sales_growth_pct,
    ROUND((total_profit - LAG(total_profit) OVER (ORDER BY year)) * 100.0
          / LAG(total_profit) OVER (ORDER BY year), 2) AS profit_growth_pct
FROM (
    SELECT
        strftime('%Y', order_date)                  AS year,
        ROUND(SUM(sales), 2)                        AS total_sales,
        ROUND(SUM(profit), 2)                       AS total_profit,
        ROUND(SUM(profit) * 100.0 / SUM(sales), 2)  AS profit_margin_pct
    FROM sales_data
    GROUP BY strftime('%Y', order_date)
)
ORDER BY year;

-- [Q25] Sales by calendar month (all four years combined)
-- Business question: Is there a seasonal pattern across the months of the year?
SELECT
    strftime('%m', order_date)                  AS month_number,
    ROUND(SUM(sales), 2)                        AS total_sales,
    ROUND(SUM(profit), 2)                       AS total_profit,
    ROUND(SUM(profit) * 100.0 / SUM(sales), 2)  AS profit_margin_pct
FROM sales_data
GROUP BY strftime('%m', order_date)
ORDER BY month_number;

-- [Q26] Monthly sales for each year
-- Business question: Do the same months stay strong every year, or was it one unusual year?
SELECT
    strftime('%m', order_date) AS month_number,
    ROUND(SUM(CASE WHEN strftime('%Y', order_date) = '2014' THEN sales ELSE 0 END), 2) AS sales_2014,
    ROUND(SUM(CASE WHEN strftime('%Y', order_date) = '2015' THEN sales ELSE 0 END), 2) AS sales_2015,
    ROUND(SUM(CASE WHEN strftime('%Y', order_date) = '2016' THEN sales ELSE 0 END), 2) AS sales_2016,
    ROUND(SUM(CASE WHEN strftime('%Y', order_date) = '2017' THEN sales ELSE 0 END), 2) AS sales_2017
FROM sales_data
GROUP BY strftime('%m', order_date)
ORDER BY month_number;

-- [Q27] Yearly profit by category
-- Business question: Did the profit of each category move in the same direction every year?
SELECT
    strftime('%Y', order_date)  AS year,
    category,
    ROUND(SUM(sales), 2)        AS total_sales,
    ROUND(SUM(profit), 2)       AS total_profit
FROM sales_data
GROUP BY strftime('%Y', order_date), category
ORDER BY year, category;


-- =====================================================================
-- 8. DISCOUNT ANALYSIS
-- =====================================================================

-- [Q28] Profitability at each discount level
-- Business question: What happens to profit as the discount increases?
SELECT
    discount,
    COUNT(*)                                                    AS rows_count,
    ROUND(SUM(sales), 2)                                        AS total_sales,
    ROUND(SUM(profit), 2)                                       AS total_profit,
    ROUND(SUM(profit) * 100.0 / SUM(sales), 2)                  AS profit_margin_pct,
    SUM(CASE WHEN profit < 0 THEN 1 ELSE 0 END)                 AS loss_rows
FROM sales_data
GROUP BY discount
ORDER BY discount;

-- [Q29] Discounted vs non-discounted sales
-- Business question: How do discounted order lines compare with full-price lines?
SELECT
    CASE WHEN discount > 0 THEN 'Discounted' ELSE 'No discount' END AS discount_status,
    COUNT(*)                                    AS rows_count,
    ROUND(SUM(sales), 2)                        AS total_sales,
    ROUND(SUM(profit), 2)                       AS total_profit,
    ROUND(SUM(profit) * 100.0 / SUM(sales), 2)  AS profit_margin_pct
FROM sales_data
GROUP BY CASE WHEN discount > 0 THEN 'Discounted' ELSE 'No discount' END;

-- [Q30] Average discount and margin by sub-category
-- Business question: Do the sub-categories that lose money also receive heavier discounts?
SELECT
    sub_category,
    ROUND(AVG(discount), 3)                     AS avg_discount,
    ROUND(SUM(sales), 2)                        AS total_sales,
    ROUND(SUM(profit), 2)                       AS total_profit,
    ROUND(SUM(profit) * 100.0 / SUM(sales), 2)  AS profit_margin_pct
FROM sales_data
GROUP BY sub_category
ORDER BY avg_discount DESC;
