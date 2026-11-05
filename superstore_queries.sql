-- Superstore Sales Analysis
-- Database: SQLite
-- Table: Superstore


-- 1. Total Sales
SELECT ROUND(SUM(sales), 2) AS total_sales
FROM Superstore;


-- 2. Total Profit
SELECT ROUND(SUM(profit), 2) AS total_profit
FROM Superstore;


-- 3. Total Unique Orders
SELECT COUNT(DISTINCT order_id) AS total_orders
FROM Superstore;


-- 4. Sales Line Items by Category
SELECT
    category,
    COUNT(*) AS line_item_count
FROM Superstore
GROUP BY category
ORDER BY line_item_count DESC;


-- 5. Top 10 Products by Sales
SELECT
    product_name,
    ROUND(SUM(sales), 2) AS total_sales
FROM Superstore
GROUP BY product_name
ORDER BY total_sales DESC
LIMIT 10;


-- 6. Region-wise Sales
SELECT
    region,
    ROUND(SUM(sales), 2) AS total_sales
FROM Superstore
GROUP BY region
ORDER BY total_sales DESC;


-- 7. Average Profit per Order within Each Category
WITH order_category_profit AS (
    SELECT
        category,
        order_id,
        SUM(profit) AS order_profit
    FROM Superstore
    GROUP BY category, order_id
)
SELECT
    category,
    ROUND(AVG(order_profit), 2) AS avg_profit_per_order
FROM order_category_profit
GROUP BY category
ORDER BY avg_profit_per_order DESC;


-- 8. Year-wise Sales
SELECT
    CAST(substr(order_date, -4) AS INTEGER) AS order_year,
    ROUND(SUM(sales), 2) AS yearly_sales
FROM Superstore
GROUP BY order_year
ORDER BY order_year;


-- 9. Orders by Customer Segment
SELECT
    segment,
    COUNT(DISTINCT order_id) AS order_count
FROM Superstore
GROUP BY segment
ORDER BY order_count DESC;


-- 10. Top 10 States by Quantity Sold
SELECT
    state,
    SUM(quantity) AS total_quantity
FROM Superstore
GROUP BY state
ORDER BY total_quantity DESC
LIMIT 10;


-- 11. Loss-making Orders
WITH order_profit AS (
    SELECT
        order_id,
        SUM(profit) AS total_order_profit
    FROM Superstore
    GROUP BY order_id
)
SELECT
    COUNT(*) AS loss_making_orders,
    ROUND(SUM(total_order_profit), 2)
        AS total_profit_from_loss_orders
FROM order_profit
WHERE total_order_profit < 0;


-- 12. Orders with Discount Above 30%
SELECT
    COUNT(DISTINCT order_id) AS high_discount_orders
FROM Superstore
WHERE discount > 0.30;


-- 13. Top 5 States by Profit
SELECT
    state,
    ROUND(SUM(profit), 2) AS total_profit
FROM Superstore
GROUP BY state
ORDER BY total_profit DESC
LIMIT 5;


-- 14. Orders by Shipping Mode
SELECT
    ship_mode,
    COUNT(DISTINCT order_id) AS order_count
FROM Superstore
GROUP BY ship_mode
ORDER BY order_count DESC;


-- 15. Top 10 Customers by Sales
SELECT
    customer_name,
    ROUND(SUM(sales), 2) AS total_sales
FROM Superstore
GROUP BY customer_name
ORDER BY total_sales DESC
LIMIT 10;


-- 16. Product Ranking within Each Category
WITH product_sales AS (
    SELECT
        category,
        product_name,
        SUM(sales) AS total_sales
    FROM Superstore
    GROUP BY category, product_name
)
SELECT
    category,
    product_name,
    ROUND(total_sales, 2) AS total_sales,
    RANK() OVER (
        PARTITION BY category
        ORDER BY total_sales DESC
    ) AS sales_rank
FROM product_sales
ORDER BY category, sales_rank;


-- 17. Running Total of Daily Sales
WITH daily_sales AS (
    SELECT
        date(
            substr(order_date, -4) || '-' ||
            printf(
                '%02d',
                CAST(
                    substr(
                        order_date, 1,
                        instr(order_date, '/') - 1
                    ) AS INTEGER
                )
            ) || '-' ||
            printf(
                '%02d',
                CAST(
                    substr(
                        order_date,
                        instr(order_date, '/') + 1,
                        instr(
                            substr(
                                order_date,
                                instr(order_date, '/') + 1
                            ),
                            '/'
                        ) - 1
                    ) AS INTEGER
                )
            )
        ) AS sales_date,
        SUM(sales) AS daily_sales
    FROM Superstore
    GROUP BY sales_date
)
SELECT
    sales_date,
    ROUND(daily_sales, 2) AS daily_sales,
    ROUND(
        SUM(daily_sales) OVER (
            ORDER BY sales_date
            ROWS BETWEEN UNBOUNDED PRECEDING
            AND CURRENT ROW
        ),
        2
    ) AS running_total_sales
FROM daily_sales
WHERE sales_date IS NOT NULL
ORDER BY sales_date;


-- 18. Highest-Sales Customer in Each Region
WITH customer_sales AS (
    SELECT
        region,
        customer_name,
        SUM(sales) AS total_sales
    FROM Superstore
    GROUP BY region, customer_name
),
ranked_customers AS (
    SELECT
        region,
        customer_name,
        total_sales,
        ROW_NUMBER() OVER (
            PARTITION BY region
            ORDER BY total_sales DESC, customer_name
        ) AS customer_rank
    FROM customer_sales
)
SELECT
    region,
    customer_name,
    ROUND(total_sales, 2) AS total_sales
FROM ranked_customers
WHERE customer_rank = 1
ORDER BY region;


-- 19. Five Lowest-Profit Sub-categories
SELECT
    sub_category,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit
FROM Superstore
GROUP BY sub_category
ORDER BY total_profit ASC
LIMIT 5;


-- 20. Category and Sub-category Sales
SELECT
    category,
    sub_category,
    ROUND(SUM(sales), 2) AS total_sales
FROM Superstore
GROUP BY category, sub_category
ORDER BY category, total_sales DESC;
