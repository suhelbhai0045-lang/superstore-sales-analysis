# Business Insights

Every figure in this file comes from the verified query outputs in `query_results.md` (the query number is shown in brackets, for example **Q04**). The data is the Superstore sample dataset (2014-2017), so these are observations about this file, not about a real company.

A note on wording: when I say two things are "linked" or "go together", I only mean they appear together in the data. The dataset has no cost, list-price or reason-for-discount columns, so it cannot prove what caused what.

---

## 1. Overall performance

- Total sales: **2,297,200.86**. Total profit: **286,397.02**. Profit margin: **12.47%** (Q04).
- 5,009 orders, average order value **458.61**. Order size varies a lot: from 0.56 to 23,661.23 (Q05).

**What it means:** The business is profitable overall, but the margin is modest. The sections below show that the total hides big differences between categories, regions and discount levels.

---

## 2. Furniture earns very little profit

| Category | Sales | Profit | Margin |
|---|---|---|---|
| Technology | 836,154.03 | 145,454.95 | 17.40% |
| Office Supplies | 719,047.03 | 122,490.80 | 17.04% |
| Furniture | 741,999.80 | 18,451.27 | 2.49% |

(Q08)

- Furniture is about 32.3% of total sales but only about 6.4% of total profit.
- 33.66% of Furniture order lines lose money (714 of 2,121), compared with about 14.7% for Office Supplies and Technology (Q11).

**What it means:** Furniture sells as much as Office Supplies but keeps very little of it as profit. Furniture is the weak spot in this dataset.

**Limitation:** The data cannot show whether the reason is product cost, shipping cost, pricing or discounts, because those columns do not exist. (Discounts are discussed in section 4.)

---

## 3. Sub-categories that lose money

Three of 17 sub-categories have negative total profit (Q09):

| Sub-category | Sales | Profit | Margin |
|---|---|---|---|
| Tables | 206,965.53 | -17,725.48 | -8.56% |
| Bookcases | 114,880.00 | -3,472.56 | -3.02% |
| Supplies | 46,673.54 | -1,189.10 | -2.55% |

- Tables and Bookcases are both in Furniture, which helps explain Furniture's low margin.
- Machines (Technology) has sales of 189,238.63 but profit of only 3,384.76 (1.79% margin).
- The strongest sub-categories by profit are Copiers (55,617.82), Phones (44,515.73), Accessories (41,936.64) and Paper (34,053.57). Paper, Labels, Envelopes and Copiers have margins above 37%.

**What it means:** High sales do not always mean high profit. Phones has sales of 330,007.05 and earns 44,515.73, while Tables has sales of 206,965.53 and loses 17,725.48.

---

## 4. Discounts and profit

| Discount | Rows | Profit margin | Loss-making rows |
|---|---|---|---|
| 0 (none) | 4,798 | 29.51% | 0 |
| 0.20 | 3,657 | 11.82% | 502 |
| 0.30 | 227 | -10.05% | 208 |
| 0.40 | 206 | -19.81% | 180 |
| 0.50 | 66 | -34.80% | 66 |
| 0.60 | 138 | -89.46% | 138 |
| 0.70 | 418 | -98.66% | 418 |
| 0.80 | 300 | -180.03% | 300 |

(Q28, selected rows)

- Lines **with no discount** earn **320,987.60** profit (29.51% margin). Lines **with a discount** (5,196 rows) have a combined profit of **-34,590.58** (Q29).
- At a discount of 0.30 or higher, the margin is negative at every level. These 1,393 rows are about 13.9% of all rows, but their combined profit is about **-135,376**. 1,348 of the 1,871 loss-making rows are in this group (adding the rows in Q28).
- At 0.60, 0.70 and 0.80, every single row is a loss (138, 418 and 300 rows).
- All 1,871 loss-making rows have a discount above 0 (see `data_quality_check.md`).

**What it means:** In this dataset, deeper discounts go together with much lower profit, and almost all large losses happen at discounts of 0.30 or more.

**Correlation, not proof of cause:** The data does not show why each discount was given. Items may have been discounted because they were already low-margin, being cleared out, or sold in a promotion. Also, the sub-categories do not behave the same way: Binders has the highest average discount (0.372) but still a 14.86% margin, while Tables (average discount 0.261) loses money (Q30). I also cannot say how much profit would change if discounts were reduced, because sales volume would change too.

---

## 5. Regional performance

| Region | Sales | Profit | Margin | Avg. discount |
|---|---|---|---|---|
| West | 725,457.82 | 108,418.45 | 14.94% | 0.109 |
| East | 678,781.24 | 91,522.78 | 13.48% | 0.145 |
| Central | 501,239.89 | 39,706.36 | 7.92% | 0.240 |
| South | 391,721.91 | 46,749.43 | 11.93% | 0.147 |

(Q20)

- Central has the weakest margin (7.92%) and also the highest average discount (0.24).
- Furniture loses money in the Central region (-2,871.05); in every other region and category the profit is positive (Q23).
- 10 of the 49 states have negative total profit. The largest losses are Texas (-25,729.36), Ohio (-16,971.38), Pennsylvania (-15,559.96) and Illinois (-12,607.89) (Q22).
- Among the top 10 states by sales, Texas is third (170,188.05) but loses money, with an average discount of 0.37. California and New York, the two biggest states, are very profitable with average discounts of 0.073 and 0.055 (Q21).

**What it means:** The region and the states with the highest average discounts (Central, Texas, Illinois) are among the weakest in profit, while the states with very low average discounts (California, New York, Washington, Michigan, Virginia) are very profitable. This fits the discount finding in section 4.

**Limitation:** This is again a link in the data, not proof. State results also depend on which products are sold there, and I did not test that.

---

## 6. Yearly and monthly trends

| Year | Sales | Profit | Margin | Sales growth | Profit growth |
|---|---|---|---|---|---|
| 2014 | 484,247.50 | 49,543.97 | 10.23% | - | - |
| 2015 | 470,532.51 | 61,618.60 | 13.10% | -2.83% | 24.37% |
| 2016 | 609,205.60 | 81,795.17 | 13.43% | 29.47% | 32.74% |
| 2017 | 733,215.26 | 93,439.27 | 12.74% | 20.36% | 14.24% |

(Q24)

- Sales fell slightly in 2015, then grew strongly in 2016 and 2017. Profit grew every year.
- In 2017, profit grew slower (14.24%) than sales (20.36%), so the margin went down from 13.43% to 12.74%.
- Furniture profit stayed small while its sales grew: 5,457.73 profit on 157,192.85 sales in 2014, and 3,018.39 on 215,387.27 in 2017 (Q27).
- Sales are highest in **September, November and December**. Combined over four years: November 352,461.07, December 325,293.50, September 307,649.95; the lowest is February with 59,751.25 (Q25). These three months are the top three in each single year (Q26).

**What it means:** There is a clear year-end sales peak in this data, and it repeats every year. Growth in sales did not automatically mean growth in margin.

**Limitation:** Four years is short, and I did not check the reason for the peak (holidays, promotions or something else). Margin does not follow sales by month: November has a margin of only 10.06% (Q25).

---

## 7. Customers

- The top customer by sales is Sean Miller with **25,043.05** sales but a **negative profit of -1,980.74**. The other nine customers in the top 10 by sales are profitable (Q16).
- The most profitable customer is Tamara Chand with **8,981.32** profit on 19,052.22 sales (Q17).
- **155 of 793 customers (19.55%)** have negative total profit, adding up to **-71,224.47** (Q18).
- 781 of 793 customers (98.49%) ordered more than once, with 6.32 orders on average (Q19).

**What it means:** Biggest spender and most valuable customer are not always the same person. Sales rank alone can be misleading.

**Limitation:** The 98.49% repeat rate is high because the file covers four years of orders for a fixed group of 793 customers; it should not be compared with a normal retail repeat rate. I did not investigate why Sean Miller's orders lost money.

---

## 8. Products

- Top product by sales and by profit: **Canon imageCLASS 2200 Advanced Copier** with 61,599.82 sales and 25,199.93 profit (about 8.8% of total profit) (Q12, Q13).
- The top 10 products make only about 10.6% of total sales, so sales are spread over many products (Q12).
- Three of the top 10 products by sales lose money overall: Cisco TelePresence System EX90 (-1,811.08), GBC DocuBind P400 Electric Binding System (-1,878.17) and High Speed Automatic Electric Letter Opener (-262.00) (Q12).
- **299 of 1,850 products (16.16%)** have a negative total profit (Q15). The biggest loss is the Cubify CubeX 3D Printer Double Head Print (-8,879.97) (Q14).

**Limitation:** Products are counted by name because Product ID is not reliable in this file (see `data_quality_check.md`).

---

## 9. Segments and shipping

- Consumer gives about 50.6% of sales (1,161,401.34) and the most profit (134,119.21). Home Office has the best margin (14.03%) and Consumer the lowest (11.55%) (Q06). The margin differences between segments are small compared with the differences between categories or discount levels.
- About 60% of orders (2,994 of 5,009) use Standard Class, which takes 5.01 days on average. Same Day is used for 264 orders (Q07).

---

## 10. Points worth checking next

These are questions the data raises, **not** conclusions or recommendations:

1. Why do Tables, Bookcases and Supplies lose money? Is it discounting, product cost or something else? (This file cannot answer it.)
2. Why is the average discount in Central (0.24) so much higher than in West (0.109)?
3. What kinds of orders sit behind the 1,348 loss-making rows with a discount of 0.30 or more?

## Overall limitations

- Sample dataset with no cost, list-price, return or reason-for-discount columns.
- The dataset has 49 states (no Alaska or Hawaii) and covers only 2014-2017.
- No statistical tests were run; all findings are descriptive (totals, shares and comparisons).
- Possible duplicate line (1 pair of rows) kept in the data; its effect is very small.
