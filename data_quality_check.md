# Data Quality Check

This file records the checks I ran on `Sample - Superstore.csv` before doing any analysis. The CSV was **not changed** in any way. No rows were removed, edited or filled in. All results below were calculated from the file itself (with Python/pandas and SQLite).

File SHA-256 (to show the file stays unchanged): `9f957bff189012b8a75a8924fd4fe937795c74ca681f88e64c145d5513c340a7`

## 1. Size and structure

| Check | Result |
|---|---|
| Rows (excluding header) | 9,994 |
| Columns | 21 |
| Encoding | UTF-8 |
| Row ID | Unique for every row (1 to 9,994 in the file) |

## 2. Columns and data types

| Column | Type found | Notes |
|---|---|---|
| Row ID | Integer | Unique row number |
| Order ID | Text | 5,009 distinct values |
| Order Date | Text | Format `M/D/YYYY` (for example `11/8/2016`) |
| Ship Date | Text | Format `M/D/YYYY` |
| Ship Mode | Text | 4 distinct values |
| Customer ID | Text | 793 distinct values |
| Customer Name | Text | 793 distinct values |
| Segment | Text | 3 distinct values |
| Country | Text | Only `United States` |
| City | Text | 531 distinct values |
| State | Text | 49 distinct values |
| Postal Code | Integer | 631 distinct values (see issue 3) |
| Region | Text | 4 distinct values |
| Product ID | Text | 1,862 distinct values (see issue 2) |
| Category | Text | 3 distinct values |
| Sub-Category | Text | 17 distinct values |
| Product Name | Text | 1,850 distinct values |
| Sales | Decimal | Minimum 0.444, maximum 22,638.48 |
| Quantity | Integer | 1 to 14 |
| Discount | Decimal | 0 to 0.80 |
| Profit | Decimal | Minimum -6,599.978, maximum 8,399.976 |

The two date columns are stored as text, not as real dates. In SQLite they are converted to `YYYY-MM-DD` using the view `sales_data` in `superstore_queries.sql`. The conversion was compared with pandas for all 9,994 rows and gave 0 differences.

## 3. Missing and blank values

- NULL / missing values: **0** in all 21 columns.
- Empty strings: **0**.
- Values with extra spaces at the start or end: **16 rows**, all in `Product Name` (for example `Iceberg Mobile Mega Data/Printer Cart `). The queries use `TRIM(product_name)` so these are handled. After trimming, the number of distinct product names stays 1,850.

## 4. Duplicate records

- Fully identical rows (all 21 columns): **0**.
- Rows that are identical in every column **except Row ID**: **1 pair** (Row ID 3406 and 3407). Both are order `US-2014-150119`, product `Global Leather Highback Executive Chair with Pneumatic Height Adjustment, Black`, sales 281.372, quantity 2, discount 0.3, profit -12.0588.
  - This may be a duplicate entry or a genuine repeat line in the order. The file cannot tell which, so I kept both rows. It is 0.01% of sales, so the effect on results is very small.

## 5. Dates

| Check | Result |
|---|---|
| Order Date range | 2014-01-03 to 2017-12-30 |
| Ship Date range | 2014-01-07 to 2018-01-05 |
| Rows where Ship Date is before Order Date | 0 |
| Days from order to shipping | 0 to 7, average 3.96 |
| Rows per order year | 2014: 1,993, 2015: 2,102, 2016: 2,587, 2017: 3,312 |

All dates are valid. The last orders are from December 2017, so the four years are complete. Some ship dates fall in January 2018.

## 6. Sales, Profit, Quantity and Discount

| Field | Result |
|---|---|
| Sales | All values above 0. Total 2,297,200.86 |
| Quantity | All values 1 or more (range 1 to 14) |
| Discount | Between 0 and 0.80. 12 distinct values: 0, 0.1, 0.15, 0.2, 0.3, 0.32, 0.4, 0.45, 0.5, 0.6, 0.7, 0.8 |
| Profit | Total 286,397.02 |
| Rows with negative profit | **1,871** (18.72% of rows), total loss -156,131.29 |
| Rows with exactly zero profit | 65 |
| Negative profit with zero discount | 0 rows. Every loss-making row has a discount above 0 |

The largest single loss is -6,599.978 (Cubify CubeX 3D Printer Double Head Print, discount 0.7). The largest profit is 8,399.976. These are extreme values, but they look like real order lines and not typing errors, so I did not remove them.

## 7. Unique counts

| Item | Count |
|---|---|
| Orders | 5,009 |
| Customers | 793 |
| Products (by name) | 1,850 |
| Products (by Product ID) | 1,862 |
| Categories | 3 (Furniture, Office Supplies, Technology) |
| Sub-categories | 17 |
| Segments | 3 (Consumer, Corporate, Home Office) |
| Regions | 4 (West, East, Central, South) |
| States | 49 (48 contiguous states plus District of Columbia) |

## 8. Issues found

1. **Product ID is not a clean unique key.** 32 Product IDs are used for more than one product name (for example `FUR-BO-10002213` is used for both `DMI Eclipse Executive Suite Bookcases` and `Sauder Forest Hills Library, Woodland Oak Finish`), and 16 product names appear under two different IDs. There are 1,894 distinct (Product ID, Product Name) pairs. Because of this, product analysis in this project groups by **product name**, not Product ID. Product-level numbers are therefore "by name".
2. **Trailing spaces** in 16 `Product Name` values (see section 3). Handled with `TRIM()`.
3. **Postal codes lost their leading zero.** The column is numeric, so 449 postal codes have only 4 digits. They belong to Massachusetts (135 rows), New Jersey (130), Connecticut (82), Rhode Island (56), New Hampshire (27), Vermont (11) and Maine (8). In SQLite the column is loaded as text and not used in any calculation. Postal code should not be used for matching or mapping without adding the zero back. One postal code is linked to more than one city name.
4. **One possible duplicate line** (section 4). Kept.
5. **Dates are text in `M/D/YYYY`.** Sorting them as text would give wrong order. Converted in the SQL view.
6. **No Alaska or Hawaii.** The data covers 48 states plus DC only.

## 9. Consistency checks that passed

- Each Customer ID has exactly one Customer Name and each name has one ID (793 each).
- Each Order ID has exactly one customer, one order date and one ship mode.
- Each Sub-Category belongs to exactly one Category.
- Each State belongs to exactly one Region.
- Each Product ID belongs to exactly one Sub-Category (even though some IDs have several names).

## 10. Limitations

- The file has no documentation. I assume `Sales` is the line revenue after discount and `Profit` is the line profit, but the file does not say so, and no currency is given. It has no cost or list-price column, so I cannot check how profit was calculated.
- This is a sample/practice dataset, not data from a real company. Findings describe this file only and should not be presented as facts about a real business.
- Each row is an order line, not a whole order. Counts of orders use `COUNT(DISTINCT order_id)`.
- Some Product IDs are reused (issue 1), so product results by name may combine or split items differently from the original catalogue.
- Four years of data is a short period for judging trends or seasonality.
