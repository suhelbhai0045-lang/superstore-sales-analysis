-- ============================================
-- SUPERSTORE SALES ANALYSIS - SQL QUERIES
-- Dataset: Sample Superstore (Kaggle - Vivek Chowdhury)
-- Tool: SQLite
-- ============================================

-- ===== BASIC QUERIES =====

-- Q1: Total Sales
SELECT ROUND(SUM(sales), 2) as Total_Sales FROM Superstore;

-- Q2: Total Profit
SELECT ROUND(SUM(profit), 2) as Total_Profit FROM Superstore;

-- Q3: Total number of distinct orders
SELECT COUNT(DISTINCT order_id) as Total_Orders FROM Superstore;

-- Q4: Item count by category
SELECT category, COUNT(*) as Total_Items FROM Superstore GROUP BY category;

-- Q5: Top 10 products by sales
SELECT product_name, ROUND(SUM(sales), 2) as Total_Sales 
FROM Superstore 
GROUP BY product_name 
ORDER BY Total_Sales DESC 
LIMIT 10;

-- ===== AGGREGATION QUERIES =====

-- Q6: Region-wise total sales
SELECT region, ROUND(SUM(sales), 2) as Total_Sales 
FROM Superstore 
GROUP BY region 
ORDER BY Total_Sales DESC;

-- Q7: Category-wise average profit
SELECT category, ROUND(AVG(profit), 2) as Avg_Profit 
FROM Superstore 
GROUP BY category 
ORDER BY Avg_Profit DESC;

-- Q8: Year-wise sales trend
SELECT substr(order_date, -4) as Year, ROUND(SUM(sales), 2) as Yearly_Sales
FROM Superstore
GROUP BY Year
ORDER BY Year;

-- Q9: Customer segment-wise order count
SELECT segment, COUNT(DISTINCT order_id) as Order_Count 
FROM Superstore 
GROUP BY segment 
ORDER BY Order_Count DESC;

-- Q10: State-wise total quantity sold (Top 10)
SELECT state, ROUND(SUM(quantity), 0) as Total_Quantity 
FROM Superstore 
GROUP BY state 
ORDER BY Total_Quantity DESC 
LIMIT 10;

-- ===== FILTERING QUERIES =====

-- Q11: Loss-making orders
SELECT COUNT(*) as Loss_Orders, ROUND(SUM(profit), 2) as Total_Loss
FROM Superstore 
WHERE profit < 0;

-- Q12: High discount orders (>30%)
SELECT COUNT(*) as High_Discount_Orders 
FROM Superstore 
WHERE discount > 0.3;

-- Q13: Top 5 states by profit
SELECT state, ROUND(SUM(profit), 2) as Total_Profit 
FROM Superstore 
GROUP BY state 
ORDER BY Total_Profit DESC 
LIMIT 5;

-- Q14: Order count by ship mode
SELECT ship_mode, COUNT(*) as Order_Count
FROM Superstore
GROUP BY ship_mode
ORDER BY Order_Count DESC;

-- Q15: Top 10 customers by total spending
SELECT customer_name, ROUND(SUM(sales), 2) as Total_Spent
FROM Superstore
GROUP BY customer_name
ORDER BY Total_Spent DESC
LIMIT 10;

-- ===== WINDOW FUNCTIONS =====

-- Q16: Rank products by sales within each category
SELECT product_name, category, sales,
RANK() OVER (PARTITION BY category ORDER BY sales DESC) as Sales_Rank
FROM Superstore
LIMIT 15;

-- Q17: Running total of sales by order date
SELECT order_id, order_date, sales,
SUM(sales) OVER (ORDER BY order_date) as Running_Total
FROM Superstore
LIMIT 15;

-- Q18: Row number for top customer per region
SELECT region, customer_name, sales,
ROW_NUMBER() OVER (PARTITION BY region ORDER BY sales DESC) as Row_Num
FROM Superstore
LIMIT 20;

-- Q19: Sub-categories with lowest profit (loss-making sub-categories)
SELECT sub_category, ROUND(SUM(sales), 2) as Total_Sales, ROUND(SUM(profit), 2) as Total_Profit
FROM Superstore
GROUP BY sub_category
ORDER BY Total_Profit ASC
LIMIT 5;

-- Q20: Category and Sub-category sales breakdown
SELECT category, sub_category, ROUND(SUM(sales), 2) as Total_Sales
FROM Superstore
GROUP BY category, sub_category
ORDER BY category, Total_Sales DESC;
