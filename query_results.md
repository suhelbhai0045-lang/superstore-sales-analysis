# Verified Query Results

All results below were produced by running the exact SQL shown against `Sample - Superstore.csv` (9,994 rows) in SQLite 3.53.1, through Python's `sqlite3` module. Nothing was typed in by hand: the output tables come directly from the query runs, and the short explanations were written from those outputs.

**Run summary:** 30 queries executed, 30 ran without error. The results were then compared against an independent calculation in pandas (a separate tool, not SQL) for the queries that return totals, rankings or counts; all of those matched. Q01-Q03 were checked against the data validation in `data_quality_check.md`.

**Audit notes**

- No earlier `superstore_queries.sql` was provided, so there was nothing to correct; the queries in this repository were written fresh and tested.
- One mistake was found in my own first draft and fixed: `HAVING SUM(profit) < 0` counted 302 loss-making products instead of 299, because some products add up to a true zero but floating-point noise gives values like -1.7e-15. All loss tests on grouped totals now use `ROUND(SUM(profit), 2) < 0`.
- Dates in the CSV are text in M/D/YYYY format. The view `sales_data` converts them to YYYY-MM-DD; the conversion was checked against pandas for all 9,994 rows (0 mismatches).
- Products are grouped by `TRIM(product_name)` because Product ID is not a reliable unique key in this file.

Money values are in the dataset's own units (it does not state a currency). Margin = total profit / total sales.

---

## Q01 - Dataset size and coverage

**Business question:** How big is the dataset and what period does it cover?

```sql
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
```

**Output:**

| total_rows | unique_orders | unique_customers | unique_products | categories | sub_categories | first_order_date | last_order_date |
|---|---|---|---|---|---|---|---|
| 9994 | 5009 | 793 | 1850 | 3 | 17 | 2014-01-03 | 2017-12-30 |

**Explanation:** The file has 9,994 order lines belonging to 5,009 orders and 793 customers, from 2014-01-03 to 2017-12-30. Products are counted by name (1,850); the Product ID column has 1,862 distinct values but is not a clean key (see data_quality_check.md).

---

## Q02 - Missing values check

**Business question:** Do any key columns contain NULL or empty values?

```sql
SELECT
    SUM(CASE WHEN order_id      IS NULL OR TRIM(order_id)      = '' THEN 1 ELSE 0 END) AS missing_order_id,
    SUM(CASE WHEN customer_id   IS NULL OR TRIM(customer_id)   = '' THEN 1 ELSE 0 END) AS missing_customer_id,
    SUM(CASE WHEN product_name  IS NULL OR TRIM(product_name)  = '' THEN 1 ELSE 0 END) AS missing_product_name,
    SUM(CASE WHEN order_date    IS NULL                            THEN 1 ELSE 0 END) AS missing_order_date,
    SUM(CASE WHEN sales         IS NULL                            THEN 1 ELSE 0 END) AS missing_sales,
    SUM(CASE WHEN profit        IS NULL                            THEN 1 ELSE 0 END) AS missing_profit
FROM sales_data;
```

**Output:**

| missing_order_id | missing_customer_id | missing_product_name | missing_order_date | missing_sales | missing_profit |
|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | 0 |

**Explanation:** No NULL or empty values in the key columns. (SQLite imported every column as text, so this check looks for NULL and empty strings.)

---

## Q03 - Duplicate rows (ignoring Row ID)

**Business question:** Are any rows repeated exactly, apart from their Row ID?

```sql
SELECT
    order_id, product_id, product_name, sales, quantity, discount, profit,
    COUNT(*) AS times_repeated
FROM sales_data
GROUP BY order_id, product_id, product_name, sales, quantity, discount, profit
HAVING COUNT(*) > 1;
```

**Output:**

| order_id | product_id | product_name | sales | quantity | discount | profit | times_repeated |
|---|---|---|---|---|---|---|---|
| US-2014-150119 | FUR-CH-10002965 | Global Leather Highback Executive Chair with Pneumatic Height Adjustment, Black | 281.372 | 2 | 0.3 | -12.0588 | 2 |

**Explanation:** One pair of rows is identical in every column except Row ID: order US-2014-150119, a Global Leather Highback Executive Chair, sales 281.372, profit -12.0588. It could be a duplicate entry or a genuine repeat line, and the file cannot tell which. It was kept in all analysis; its effect on totals is very small.

---

## Q04 - Overall business performance

**Business question:** What are total sales, profit, quantity and profit margin?

```sql
SELECT
    ROUND(SUM(sales), 2)                    AS total_sales,
    ROUND(SUM(profit), 2)                   AS total_profit,
    ROUND(SUM(profit) * 100.0 / SUM(sales), 2) AS profit_margin_pct,
    SUM(quantity)                           AS total_quantity
FROM sales_data;
```

**Output:**

| total_sales | total_profit | profit_margin_pct | total_quantity |
|---|---|---|---|
| 2297200.86 | 286397.02 | 12.47 | 37873 |

**Explanation:** Total sales are 2,297,200.86 and total profit is 286,397.02, which is a 12.47% profit margin on 37,873 units sold.

---

## Q05 - Average order value

**Business question:** How much sales value does an average order carry?

```sql
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
```

**Output:**

| total_orders | avg_order_value | smallest_order | largest_order |
|---|---|---|---|
| 5009 | 458.61 | 0.56 | 23661.23 |

**Explanation:** An average order is worth 458.61 in sales. The smallest order is 0.56 and the largest is 23,661.23, so a few very large orders pull the average up.

---

## Q06 - Sales and profit by customer segment

**Business question:** Which customer segment brings the most sales and profit?

```sql
SELECT
    segment,
    COUNT(DISTINCT order_id)                    AS orders,
    ROUND(SUM(sales), 2)                        AS total_sales,
    ROUND(SUM(profit), 2)                       AS total_profit,
    ROUND(SUM(profit) * 100.0 / SUM(sales), 2)  AS profit_margin_pct
FROM sales_data
GROUP BY segment
ORDER BY total_sales DESC;
```

**Output:**

| segment | orders | total_sales | total_profit | profit_margin_pct |
|---|---|---|---|---|
| Consumer | 2586 | 1161401.34 | 134119.21 | 11.55 |
| Corporate | 1514 | 706146.37 | 91979.13 | 13.03 |
| Home Office | 909 | 429653.15 | 60298.68 | 14.03 |

**Explanation:** Consumer is the largest segment by sales (1,161,401.34) and profit (134,119.21). Home Office is the smallest but has the best margin (14.03%); Consumer has the lowest (11.55%).

---

## Q07 - Shipping mode usage and shipping time

**Business question:** How are orders shipped and how long does each mode take?

```sql
SELECT
    ship_mode,
    COUNT(DISTINCT order_id)                                   AS orders,
    ROUND(AVG(julianday(ship_date) - julianday(order_date)), 2) AS avg_days_to_ship,
    ROUND(SUM(sales), 2)                                       AS total_sales,
    ROUND(SUM(profit), 2)                                      AS total_profit
FROM sales_data
GROUP BY ship_mode
ORDER BY orders DESC;
```

**Output:**

| ship_mode | orders | avg_days_to_ship | total_sales | total_profit |
|---|---|---|---|---|
| Standard Class | 2994 | 5.01 | 1358215.74 | 164088.79 |
| Second Class | 964 | 3.24 | 459193.57 | 57446.64 |
| First Class | 787 | 2.18 | 351428.42 | 48969.84 |
| Same Day | 264 | 0.04 | 128363.13 | 15891.76 |

**Explanation:** Standard Class is used for 2,994 of 5,009 orders (about 60%). Average shipping time is 5.01 days for Standard Class, 3.24 for Second Class, 2.18 for First Class and 0.04 for Same Day, which matches the mode names.

---

## Q08 - Profitability by category

**Business question:** Which category earns the best and worst profit margin?

```sql
SELECT
    category,
    ROUND(SUM(sales), 2)                        AS total_sales,
    ROUND(SUM(profit), 2)                       AS total_profit,
    ROUND(SUM(profit) * 100.0 / SUM(sales), 2)  AS profit_margin_pct
FROM sales_data
GROUP BY category
ORDER BY total_profit DESC;
```

**Output:**

| category | total_sales | total_profit | profit_margin_pct |
|---|---|---|---|
| Technology | 836154.03 | 145454.95 | 17.4 |
| Office Supplies | 719047.03 | 122490.8 | 17.04 |
| Furniture | 741999.8 | 18451.27 | 2.49 |

**Explanation:** Technology (145,454.95) and Office Supplies (122,490.80) earn most of the profit at margins of about 17%. Furniture has almost the same sales as Office Supplies but only 18,451.27 profit, a 2.49% margin.

---

## Q09 - Profitability by sub-category

**Business question:** Which sub-categories make money and which lose money?

```sql
SELECT
    category,
    sub_category,
    ROUND(SUM(sales), 2)                        AS total_sales,
    ROUND(SUM(profit), 2)                       AS total_profit,
    ROUND(SUM(profit) * 100.0 / SUM(sales), 2)  AS profit_margin_pct
FROM sales_data
GROUP BY category, sub_category
ORDER BY total_profit DESC;
```

**Output:**

| category | sub_category | total_sales | total_profit | profit_margin_pct |
|---|---|---|---|---|
| Technology | Copiers | 149528.03 | 55617.82 | 37.2 |
| Technology | Phones | 330007.05 | 44515.73 | 13.49 |
| Technology | Accessories | 167380.32 | 41936.64 | 25.05 |
| Office Supplies | Paper | 78479.21 | 34053.57 | 43.39 |
| Office Supplies | Binders | 203412.73 | 30221.76 | 14.86 |
| Furniture | Chairs | 328449.1 | 26590.17 | 8.1 |
| Office Supplies | Storage | 223843.61 | 21278.83 | 9.51 |
| Office Supplies | Appliances | 107532.16 | 18138.01 | 16.87 |
| Furniture | Furnishings | 91705.16 | 13059.14 | 14.24 |
| Office Supplies | Envelopes | 16476.4 | 6964.18 | 42.27 |
| Office Supplies | Art | 27118.79 | 6527.79 | 24.07 |
| Office Supplies | Labels | 12486.31 | 5546.25 | 44.42 |
| Technology | Machines | 189238.63 | 3384.76 | 1.79 |
| Office Supplies | Fasteners | 3024.28 | 949.52 | 31.4 |
| Office Supplies | Supplies | 46673.54 | -1189.1 | -2.55 |
| Furniture | Bookcases | 114880.0 | -3472.56 | -3.02 |
| Furniture | Tables | 206965.53 | -17725.48 | -8.56 |

**Explanation:** Three sub-categories lose money overall: Tables (-17,725.48), Bookcases (-3,472.56) and Supplies (-1,189.10). Copiers has the highest profit (55,617.82). Paper, Labels, Envelopes and Copiers all have margins above 37%. Machines has high sales (189,238.63) but only a 1.79% margin.

---

## Q10 - Loss-making order lines

**Business question:** How many order lines lose money and how large is the loss?

```sql
SELECT
    COUNT(*)                                                       AS loss_making_rows,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM sales_data), 2) AS pct_of_all_rows,
    ROUND(SUM(profit), 2)                                          AS total_loss,
    ROUND(AVG(profit), 2)                                          AS avg_loss_per_row,
    ROUND(MIN(profit), 2)                                          AS biggest_single_loss
FROM sales_data
WHERE profit < 0;
```

**Output:**

| loss_making_rows | pct_of_all_rows | total_loss | avg_loss_per_row | biggest_single_loss |
|---|---|---|---|---|
| 1871 | 18.72 | -156131.29 | -83.45 | -6599.98 |

**Explanation:** 1,871 order lines (18.72% of all rows) have negative profit, adding up to -156,131.29. This loss is equal to about 54.5% of the final net profit of 286,397.02. The single biggest loss is -6,599.98.

---

## Q11 - Loss-making rows by category

**Business question:** Where do the loss-making order lines come from?

```sql
SELECT
    category,
    COUNT(*)                   AS total_rows,
    SUM(CASE WHEN profit < 0 THEN 1 ELSE 0 END) AS loss_rows,
    ROUND(SUM(CASE WHEN profit < 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS loss_rows_pct,
    ROUND(SUM(CASE WHEN profit < 0 THEN profit ELSE 0 END), 2) AS total_loss
FROM sales_data
GROUP BY category
ORDER BY total_loss ASC;
```

**Output:**

| category | total_rows | loss_rows | loss_rows_pct | total_loss |
|---|---|---|---|---|
| Furniture | 2121 | 714 | 33.66 | -60936.11 |
| Office Supplies | 6026 | 886 | 14.7 | -56615.26 |
| Technology | 1847 | 271 | 14.67 | -38579.92 |

**Explanation:** Furniture has the highest share of loss-making lines: 714 of 2,121 (33.66%), against about 14.7% for both Office Supplies and Technology. In total money, Furniture lost -60,936.11, Office Supplies -56,615.26 and Technology -38,579.92 on their loss-making lines.

---

## Q12 - Top 10 products by sales

**Business question:** Which products generate the most sales?

```sql
SELECT
    TRIM(product_name)                          AS product_name,
    ROUND(SUM(sales), 2)                        AS total_sales,
    ROUND(SUM(profit), 2)                       AS total_profit,
    ROUND(SUM(profit) * 100.0 / SUM(sales), 2)  AS profit_margin_pct
FROM sales_data
GROUP BY TRIM(product_name)
ORDER BY total_sales DESC
LIMIT 10;
```

**Output:**

| product_name | total_sales | total_profit | profit_margin_pct |
|---|---|---|---|
| Canon imageCLASS 2200 Advanced Copier | 61599.82 | 25199.93 | 40.91 |
| Fellowes PB500 Electric Punch Plastic Comb Binding Machine with Manual Bind | 27453.38 | 7753.04 | 28.24 |
| Cisco TelePresence System EX90 Videoconferencing Unit | 22638.48 | -1811.08 | -8.0 |
| HON 5400 Series Task Chairs for Big and Tall | 21870.58 | 0.0 | 0.0 |
| GBC DocuBind TL300 Electric Binding System | 19823.48 | 2233.51 | 11.27 |
| GBC Ibimaster 500 Manual ProClick Binding System | 19024.5 | 760.98 | 4.0 |
| Hewlett Packard LaserJet 3310 Copier | 18839.69 | 6983.88 | 37.07 |
| HP Designjet T520 Inkjet Large Format Printer - 24" Color | 18374.9 | 4094.98 | 22.29 |
| GBC DocuBind P400 Electric Binding System | 17965.07 | -1878.17 | -10.45 |
| High Speed Automatic Electric Letter Opener | 17030.31 | -262.0 | -1.54 |

**Explanation:** The Canon imageCLASS 2200 Advanced Copier is the top product by sales (61,599.82) and also makes 25,199.93 profit. Three of the top 10 by sales lose money overall (Cisco TelePresence EX90, GBC DocuBind P400, High Speed Automatic Electric Letter Opener) and the HON 5400 chair breaks even (profit 0.0 after rounding). The top 10 together are only about 10.6% of total sales, so sales are spread across many products.

---

## Q13 - Top 10 products by profit

**Business question:** Which products contribute the most profit?

```sql
SELECT
    TRIM(product_name)                          AS product_name,
    ROUND(SUM(profit), 2)                       AS total_profit,
    ROUND(SUM(sales), 2)                        AS total_sales,
    ROUND(SUM(profit) * 100.0 / SUM(sales), 2)  AS profit_margin_pct
FROM sales_data
GROUP BY TRIM(product_name)
ORDER BY total_profit DESC
LIMIT 10;
```

**Output:**

| product_name | total_profit | total_sales | profit_margin_pct |
|---|---|---|---|
| Canon imageCLASS 2200 Advanced Copier | 25199.93 | 61599.82 | 40.91 |
| Fellowes PB500 Electric Punch Plastic Comb Binding Machine with Manual Bind | 7753.04 | 27453.38 | 28.24 |
| Hewlett Packard LaserJet 3310 Copier | 6983.88 | 18839.69 | 37.07 |
| Canon PC1060 Personal Laser Copier | 4570.93 | 11619.83 | 39.34 |
| HP Designjet T520 Inkjet Large Format Printer - 24" Color | 4094.98 | 18374.9 | 22.29 |
| Ativa V4110MDD Micro-Cut Shredder | 3772.95 | 7699.89 | 49.0 |
| 3D Systems Cube Printer, 2nd Generation, Magenta | 3717.97 | 14299.89 | 26.0 |
| Plantronics Savi W720 Multi-Device Wireless Headset System | 3696.28 | 9367.29 | 39.46 |
| Ibico EPK-21 Electric Binding System | 3345.28 | 15875.92 | 21.07 |
| Zebra ZM400 Thermal Label Printer | 3343.54 | 6965.7 | 48.0 |

**Explanation:** The Canon copier alone gives 25,199.93 profit, about 8.8% of total profit. Most of the top 10 are copiers, printers, binding machines or other Technology/Office products with margins from 21% to 49%.

---

## Q14 - Top 10 loss-making products

**Business question:** Which products lose the most money overall?

```sql
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
```

**Output:**

| product_name | total_profit | total_sales | avg_discount |
|---|---|---|---|
| Cubify CubeX 3D Printer Double Head Print | -8879.97 | 11099.96 | 0.53 |
| Lexmark MX611dhe Monochrome Laser Printer | -4589.97 | 16829.9 | 0.4 |
| Cubify CubeX 3D Printer Triple Head Print | -3839.99 | 7999.98 | 0.5 |
| Chromcraft Bull-Nose Wood Oval Conference Tables & Bases | -2876.12 | 9917.64 | 0.28 |
| Bush Advantage Collection Racetrack Conference Table | -1934.4 | 9544.73 | 0.35 |
| GBC DocuBind P400 Electric Binding System | -1878.17 | 17965.07 | 0.45 |
| Cisco TelePresence System EX90 Videoconferencing Unit | -1811.08 | 22638.48 | 0.5 |
| Martin Yale Chadless Opener Electric Letter Opener | -1299.18 | 16656.2 | 0.1 |
| Balt Solid Wood Round Tables | -1201.06 | 6518.75 | 0.2 |
| BoxOffice By Design Rectangular and Half-Moon Meeting Room Tables | -1148.44 | 1706.25 | 0.48 |

**Explanation:** The biggest loss-making product is the Cubify CubeX 3D Printer Double Head Print (-8,879.97), followed by the Lexmark MX611dhe laser printer (-4,589.97). Several have an average discount of 0.40 or more, but not all (for example the Martin Yale opener at 0.10), so discount is not the only reason.

---

## Q15 - How many products lose money overall

**Business question:** What share of products has a negative total profit?

```sql
SELECT
    COUNT(*)                                                  AS total_products,
    SUM(CASE WHEN total_profit < 0 THEN 1 ELSE 0 END)         AS loss_making_products,
    ROUND(SUM(CASE WHEN total_profit < 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS loss_making_pct
FROM (
    SELECT TRIM(product_name) AS product_name, ROUND(SUM(profit), 2) AS total_profit
    FROM sales_data
    GROUP BY TRIM(product_name)
);
```

**Output:**

| total_products | loss_making_products | loss_making_pct |
|---|---|---|
| 1850 | 299 | 16.16 |

**Explanation:** 299 of 1,850 products (16.16%) have a negative total profit. Totals are rounded to 2 decimals before the test, so products that add up to exactly zero are not counted as losses.

---

## Q16 - Top 10 customers by sales

**Business question:** Who are the highest-spending customers, and are they profitable?

```sql
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
```

**Output:**

| customer_id | customer_name | segment | orders | total_sales | total_profit |
|---|---|---|---|---|---|
| SM-20320 | Sean Miller | Home Office | 5 | 25043.05 | -1980.74 |
| TC-20980 | Tamara Chand | Corporate | 5 | 19052.22 | 8981.32 |
| RB-19360 | Raymond Buch | Consumer | 6 | 15117.34 | 6976.1 |
| TA-21385 | Tom Ashbrook | Home Office | 4 | 14595.62 | 4703.79 |
| AB-10105 | Adrian Barton | Consumer | 10 | 14473.57 | 5444.81 |
| KL-16645 | Ken Lonsdale | Consumer | 12 | 14175.23 | 806.85 |
| SC-20095 | Sanjit Chand | Consumer | 9 | 14142.33 | 5757.41 |
| HL-15040 | Hunter Lopez | Consumer | 6 | 12873.3 | 5622.43 |
| SE-20110 | Sanjit Engle | Consumer | 11 | 12209.44 | 2650.68 |
| CC-12370 | Christopher Conant | Consumer | 5 | 12129.07 | 2177.05 |

**Explanation:** Sean Miller has the highest sales (25,043.05) but a negative total profit (-1,980.74). The other nine customers in the top 10 are profitable, but their margins differ a lot: Tamara Chand earns 8,981.32 on 19,052.22 sales while Ken Lonsdale earns only 806.85 on 14,175.23.

---

## Q17 - Top 10 customers by profit

**Business question:** Which customers contribute the most profit?

```sql
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
```

**Output:**

| customer_id | customer_name | orders | total_profit | total_sales |
|---|---|---|---|---|
| TC-20980 | Tamara Chand | 5 | 8981.32 | 19052.22 |
| RB-19360 | Raymond Buch | 6 | 6976.1 | 15117.34 |
| SC-20095 | Sanjit Chand | 9 | 5757.41 | 14142.33 |
| HL-15040 | Hunter Lopez | 6 | 5622.43 | 12873.3 |
| AB-10105 | Adrian Barton | 10 | 5444.81 | 14473.57 |
| TA-21385 | Tom Ashbrook | 4 | 4703.79 | 14595.62 |
| CM-12385 | Christopher Martinez | 4 | 3899.89 | 8954.02 |
| KD-16495 | Keith Dawkins | 12 | 3038.63 | 8181.26 |
| AR-10540 | Andy Reiter | 6 | 2884.62 | 6608.45 |
| DR-12940 | Daniel Raglin | 8 | 2869.08 | 8350.87 |

**Explanation:** Tamara Chand is the most profitable customer (8,981.32), followed by Raymond Buch (6,976.10). Sales rank and profit rank are not the same: Keith Dawkins appears here with 3,038.63 profit on only 8,181.26 sales.

---

## Q18 - Customers with negative total profit

**Business question:** How many customers cost the business money overall?

```sql
SELECT
    COUNT(*)                                                     AS total_customers,
    SUM(CASE WHEN ROUND(total_profit, 2) < 0 THEN 1 ELSE 0 END)  AS loss_making_customers,
    ROUND(SUM(CASE WHEN ROUND(total_profit, 2) < 0 THEN total_profit ELSE 0 END), 2) AS combined_loss
FROM (
    SELECT customer_id, SUM(profit) AS total_profit
    FROM sales_data
    GROUP BY customer_id
);
```

**Output:**

| total_customers | loss_making_customers | combined_loss |
|---|---|---|
| 793 | 155 | -71224.47 |

**Explanation:** 155 of 793 customers (19.55%) have a negative total profit; together they account for -71,224.47.

---

## Q19 - Repeat customers

**Business question:** How many customers ordered more than once?

```sql
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
```

**Output:**

| total_customers | repeat_customers | repeat_customer_pct | avg_orders_per_customer |
|---|---|---|---|
| 793 | 781 | 98.49 | 6.32 |

**Explanation:** 781 of 793 customers (98.49%) placed more than one order, with 6.32 orders per customer on average. This is high because the file covers four years; it should not be read as a typical retail repeat rate.

---

## Q20 - Performance by region

**Business question:** Which region has the highest sales and the best profit margin?

```sql
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
```

**Output:**

| region | orders | total_sales | total_profit | profit_margin_pct | avg_discount |
|---|---|---|---|---|---|
| West | 1611 | 725457.82 | 108418.45 | 14.94 | 0.109 |
| East | 1401 | 678781.24 | 91522.78 | 13.48 | 0.145 |
| Central | 1175 | 501239.89 | 39706.36 | 7.92 | 0.24 |
| South | 822 | 391721.91 | 46749.43 | 11.93 | 0.147 |

**Explanation:** West has the highest sales (725,457.82) and margin (14.94%). Central has the lowest margin (7.92%) and also the highest average discount (0.24). South is the smallest region by sales but has a higher margin (11.93%) than Central.

---

## Q21 - Top 10 states by sales

**Business question:** Which states sell the most?

```sql
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
```

**Output:**

| state | region | total_sales | total_profit | profit_margin_pct | avg_discount |
|---|---|---|---|---|---|
| California | West | 457687.63 | 76381.39 | 16.69 | 0.073 |
| New York | East | 310876.27 | 74038.55 | 23.82 | 0.055 |
| Texas | Central | 170188.05 | -25729.36 | -15.12 | 0.37 |
| Washington | West | 138641.27 | 33402.65 | 24.09 | 0.064 |
| Pennsylvania | East | 116511.91 | -15559.96 | -13.35 | 0.329 |
| Florida | South | 89473.71 | -3399.3 | -3.8 | 0.299 |
| Illinois | Central | 80166.1 | -12607.89 | -15.73 | 0.39 |
| Ohio | East | 78258.14 | -16971.38 | -21.69 | 0.325 |
| Michigan | Central | 76269.61 | 24463.19 | 32.07 | 0.007 |
| Virginia | South | 70636.72 | 18597.95 | 26.33 | 0.0 |

**Explanation:** California (457,687.63) and New York (310,876.27) are the two biggest states and are both very profitable. Texas is third by sales but has a loss of -25,729.36 (margin -15.12%) with an average discount of 0.37. Pennsylvania, Illinois, Ohio and Florida also lose money in the top 10, while California and New York average discounts of only 0.073 and 0.055.

---

## Q22 - Loss-making states

**Business question:** Which states have a negative total profit?

```sql
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
```

**Output:**

| state | region | total_sales | total_profit | avg_discount |
|---|---|---|---|---|
| Texas | Central | 170188.05 | -25729.36 | 0.37 |
| Ohio | East | 78258.14 | -16971.38 | 0.325 |
| Pennsylvania | East | 116511.91 | -15559.96 | 0.329 |
| Illinois | Central | 80166.1 | -12607.89 | 0.39 |
| North Carolina | South | 55603.16 | -7490.91 | 0.284 |
| Colorado | West | 32108.12 | -6527.86 | 0.316 |
| Tennessee | South | 30661.87 | -5341.69 | 0.291 |
| Arizona | West | 35282.0 | -3427.92 | 0.304 |
| Florida | South | 89473.71 | -3399.3 | 0.299 |
| Oregon | West | 17431.15 | -1190.47 | 0.289 |

**Explanation:** Exactly 10 of the 49 states lose money overall. Texas (-25,729.36), Ohio (-16,971.38), Pennsylvania (-15,559.96) and Illinois (-12,607.89) are the largest losses. Average discount in these states is between 0.28 and 0.39.

---

## Q23 - Profit by region and category

**Business question:** Is any category losing money inside a particular region?

```sql
SELECT
    region,
    category,
    ROUND(SUM(sales), 2)                        AS total_sales,
    ROUND(SUM(profit), 2)                       AS total_profit,
    ROUND(SUM(profit) * 100.0 / SUM(sales), 2)  AS profit_margin_pct
FROM sales_data
GROUP BY region, category
ORDER BY region, total_profit DESC;
```

**Output:**

| region | category | total_sales | total_profit | profit_margin_pct |
|---|---|---|---|---|
| Central | Technology | 170416.31 | 33697.43 | 19.77 |
| Central | Office Supplies | 167026.42 | 8879.98 | 5.32 |
| Central | Furniture | 163797.16 | -2871.05 | -1.75 |
| East | Technology | 264973.98 | 47462.04 | 17.91 |
| East | Office Supplies | 205516.05 | 41014.58 | 19.96 |
| East | Furniture | 208291.2 | 3046.17 | 1.46 |
| South | Technology | 148771.91 | 19991.83 | 13.44 |
| South | Office Supplies | 125651.31 | 19986.39 | 15.91 |
| South | Furniture | 117298.68 | 6771.21 | 5.77 |
| West | Office Supplies | 220853.25 | 52609.85 | 23.82 |
| West | Technology | 251991.83 | 44303.65 | 17.58 |
| West | Furniture | 252612.74 | 11504.95 | 4.55 |

**Explanation:** Furniture loses money in the Central region (-2,871.05). Every other region/category combination is profitable. Central is weak in Office Supplies too (5.32% margin), compared with 23.82% for Office Supplies in the West.

---

## Q24 - Yearly sales and profit with year-over-year growth

**Business question:** How did sales and profit change from year to year?

```sql
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
```

**Output:**

| year | total_sales | total_profit | profit_margin_pct | sales_growth_pct | profit_growth_pct |
|---|---|---|---|---|---|
| 2014 | 484247.5 | 49543.97 | 10.23 | NULL | NULL |
| 2015 | 470532.51 | 61618.6 | 13.1 | -2.83 | 24.37 |
| 2016 | 609205.6 | 81795.17 | 13.43 | 29.47 | 32.74 |
| 2017 | 733215.26 | 93439.27 | 12.74 | 20.36 | 14.24 |

**Explanation:** Sales fell 2.83% in 2015, then grew 29.47% in 2016 and 20.36% in 2017. Profit grew every year (24.37%, 32.74%, 14.24%). Margin rose from 10.23% in 2014 to 13.43% in 2016, then fell to 12.74% in 2017 because profit grew slower than sales.

---

## Q25 - Sales by calendar month (all four years combined)

**Business question:** Is there a seasonal pattern across the months of the year?

```sql
SELECT
    strftime('%m', order_date)                  AS month_number,
    ROUND(SUM(sales), 2)                        AS total_sales,
    ROUND(SUM(profit), 2)                       AS total_profit,
    ROUND(SUM(profit) * 100.0 / SUM(sales), 2)  AS profit_margin_pct
FROM sales_data
GROUP BY strftime('%m', order_date)
ORDER BY month_number;
```

**Output:**

| month_number | total_sales | total_profit | profit_margin_pct |
|---|---|---|---|
| 01 | 94924.84 | 9134.45 | 9.62 |
| 02 | 59751.25 | 10294.61 | 17.23 |
| 03 | 205005.49 | 28594.69 | 13.95 |
| 04 | 137762.13 | 11587.44 | 8.41 |
| 05 | 155028.81 | 22411.31 | 14.46 |
| 06 | 152718.68 | 21285.8 | 13.94 |
| 07 | 147238.1 | 13832.66 | 9.39 |
| 08 | 159044.06 | 21776.94 | 13.69 |
| 09 | 307649.95 | 36857.48 | 11.98 |
| 10 | 200322.98 | 31784.04 | 15.87 |
| 11 | 352461.07 | 35468.43 | 10.06 |
| 12 | 325293.5 | 43369.19 | 13.33 |

**Explanation:** November (352,461.07), December (325,293.50) and September (307,649.95) are the strongest months when all years are combined. February (59,751.25) and January (94,924.84) are the weakest. Margin does not follow sales: November has one of the lower margins (10.06%).

---

## Q26 - Monthly sales for each year

**Business question:** Do the same months stay strong every year, or was it one unusual year?

```sql
SELECT
    strftime('%m', order_date) AS month_number,
    ROUND(SUM(CASE WHEN strftime('%Y', order_date) = '2014' THEN sales ELSE 0 END), 2) AS sales_2014,
    ROUND(SUM(CASE WHEN strftime('%Y', order_date) = '2015' THEN sales ELSE 0 END), 2) AS sales_2015,
    ROUND(SUM(CASE WHEN strftime('%Y', order_date) = '2016' THEN sales ELSE 0 END), 2) AS sales_2016,
    ROUND(SUM(CASE WHEN strftime('%Y', order_date) = '2017' THEN sales ELSE 0 END), 2) AS sales_2017
FROM sales_data
GROUP BY strftime('%m', order_date)
ORDER BY month_number;
```

**Output:**

| month_number | sales_2014 | sales_2015 | sales_2016 | sales_2017 |
|---|---|---|---|---|
| 01 | 14236.9 | 18174.08 | 18542.49 | 43971.37 |
| 02 | 4519.89 | 11951.41 | 22978.82 | 20301.13 |
| 03 | 55691.01 | 38726.25 | 51715.88 | 58872.35 |
| 04 | 28295.35 | 34195.21 | 38750.04 | 36521.54 |
| 05 | 23648.29 | 30131.69 | 56987.73 | 44261.11 |
| 06 | 34595.13 | 24797.29 | 40344.53 | 52981.73 |
| 07 | 33946.39 | 28765.33 | 39261.96 | 45264.42 |
| 08 | 27909.47 | 36898.33 | 31115.37 | 63120.89 |
| 09 | 81777.35 | 64595.92 | 73410.02 | 87866.65 |
| 10 | 31453.39 | 31404.92 | 59687.75 | 77776.92 |
| 11 | 78628.72 | 75972.56 | 79411.97 | 118447.82 |
| 12 | 69545.62 | 74919.52 | 96999.04 | 83829.32 |

**Explanation:** September, November and December are the three biggest months in each of the four years, and February is the lowest or second-lowest month in every year. So the pattern is not caused by one unusual year. 2017 is the highest year in 8 of the 12 months.

---

## Q27 - Yearly profit by category

**Business question:** Did the profit of each category move in the same direction every year?

```sql
SELECT
    strftime('%Y', order_date)  AS year,
    category,
    ROUND(SUM(sales), 2)        AS total_sales,
    ROUND(SUM(profit), 2)       AS total_profit
FROM sales_data
GROUP BY strftime('%Y', order_date), category
ORDER BY year, category;
```

**Output:**

| year | category | total_sales | total_profit |
|---|---|---|---|
| 2014 | Furniture | 157192.85 | 5457.73 |
| 2014 | Office Supplies | 151776.41 | 22593.42 |
| 2014 | Technology | 175278.23 | 21492.83 |
| 2015 | Furniture | 170518.24 | 3015.2 |
| 2015 | Office Supplies | 137233.46 | 25099.53 |
| 2015 | Technology | 162780.81 | 33503.87 |
| 2016 | Furniture | 198901.44 | 6959.95 |
| 2016 | Office Supplies | 183939.98 | 35061.23 |
| 2016 | Technology | 226364.18 | 39773.99 |
| 2017 | Furniture | 215387.27 | 3018.39 |
| 2017 | Office Supplies | 246097.17 | 39736.62 |
| 2017 | Technology | 271730.81 | 50684.26 |

**Explanation:** Technology and Office Supplies grew their profit every year. Furniture stayed small: 5,457.73 in 2014 and 3,018.39 in 2017, even though Furniture sales grew from 157,192.85 to 215,387.27.

---

## Q28 - Profitability at each discount level

**Business question:** What happens to profit as the discount increases?

```sql
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
```

**Output:**

| discount | rows_count | total_sales | total_profit | profit_margin_pct | loss_rows |
|---|---|---|---|---|---|
| 0.0 | 4798 | 1087908.47 | 320987.6 | 29.51 | 0 |
| 0.1 | 94 | 54369.35 | 9029.18 | 16.61 | 4 |
| 0.15 | 52 | 27558.52 | 1418.99 | 5.15 | 17 |
| 0.2 | 3657 | 764594.37 | 90337.31 | 11.82 | 502 |
| 0.3 | 227 | 103226.65 | -10369.28 | -10.05 | 208 |
| 0.32 | 27 | 14493.46 | -2391.14 | -16.5 | 27 |
| 0.4 | 206 | 116417.78 | -23057.05 | -19.81 | 180 |
| 0.45 | 11 | 5484.97 | -2493.11 | -45.45 | 11 |
| 0.5 | 66 | 58918.54 | -20506.43 | -34.8 | 66 |
| 0.6 | 138 | 6644.7 | -5944.66 | -89.46 | 138 |
| 0.7 | 418 | 40620.28 | -40075.36 | -98.66 | 418 |
| 0.8 | 300 | 16963.76 | -30539.04 | -180.03 | 300 |

**Explanation:** Profit falls as discount rises. Lines with no discount have a 29.51% margin and no loss-making rows. At 0.20 the margin is 11.82%; at 0.30 and above every discount level has a negative margin. At 0.60, 0.70 and 0.80 every single row (138, 418 and 300) is a loss.

---

## Q29 - Discounted vs non-discounted sales

**Business question:** How do discounted order lines compare with full-price lines?

```sql
SELECT
    CASE WHEN discount > 0 THEN 'Discounted' ELSE 'No discount' END AS discount_status,
    COUNT(*)                                    AS rows_count,
    ROUND(SUM(sales), 2)                        AS total_sales,
    ROUND(SUM(profit), 2)                       AS total_profit,
    ROUND(SUM(profit) * 100.0 / SUM(sales), 2)  AS profit_margin_pct
FROM sales_data
GROUP BY CASE WHEN discount > 0 THEN 'Discounted' ELSE 'No discount' END;
```

**Output:**

| discount_status | rows_count | total_sales | total_profit | profit_margin_pct |
|---|---|---|---|---|
| Discounted | 5196 | 1209292.39 | -34590.58 | -2.86 |
| No discount | 4798 | 1087908.47 | 320987.6 | 29.51 |

**Explanation:** Discounted lines (5,196 rows, about 52% of rows) have a combined profit of -34,590.58. Lines without discount (4,798 rows) have 320,987.60 profit. The two add up to the total profit of 286,397.02.

---

## Q30 - Average discount and margin by sub-category

**Business question:** Do the sub-categories that lose money also receive heavier discounts?

```sql
SELECT
    sub_category,
    ROUND(AVG(discount), 3)                     AS avg_discount,
    ROUND(SUM(sales), 2)                        AS total_sales,
    ROUND(SUM(profit), 2)                       AS total_profit,
    ROUND(SUM(profit) * 100.0 / SUM(sales), 2)  AS profit_margin_pct
FROM sales_data
GROUP BY sub_category
ORDER BY avg_discount DESC;
```

**Output:**

| sub_category | avg_discount | total_sales | total_profit | profit_margin_pct |
|---|---|---|---|---|
| Binders | 0.372 | 203412.73 | 30221.76 | 14.86 |
| Machines | 0.306 | 189238.63 | 3384.76 | 1.79 |
| Tables | 0.261 | 206965.53 | -17725.48 | -8.56 |
| Bookcases | 0.211 | 114880.0 | -3472.56 | -3.02 |
| Chairs | 0.17 | 328449.1 | 26590.17 | 8.1 |
| Appliances | 0.167 | 107532.16 | 18138.01 | 16.87 |
| Copiers | 0.162 | 149528.03 | 55617.82 | 37.2 |
| Phones | 0.155 | 330007.05 | 44515.73 | 13.49 |
| Furnishings | 0.138 | 91705.16 | 13059.14 | 14.24 |
| Fasteners | 0.082 | 3024.28 | 949.52 | 31.4 |
| Envelopes | 0.08 | 16476.4 | 6964.18 | 42.27 |
| Accessories | 0.078 | 167380.32 | 41936.64 | 25.05 |
| Supplies | 0.077 | 46673.54 | -1189.1 | -2.55 |
| Storage | 0.075 | 223843.61 | 21278.83 | 9.51 |
| Paper | 0.075 | 78479.21 | 34053.57 | 43.39 |
| Art | 0.075 | 27118.79 | 6527.79 | 24.07 |
| Labels | 0.069 | 12486.31 | 5546.25 | 44.42 |

**Explanation:** Binders, Machines, Tables and Bookcases have the highest average discounts (0.372, 0.306, 0.261, 0.211). Tables and Bookcases lose money and Machines has a 1.79% margin. But Binders has the highest discount and still shows a 14.86% margin, so the link between discount and loss is not the same for every sub-category.

---
