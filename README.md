Retail Sales Performance Analysis

Project Overview

This project analyzes retail transaction data to evaluate sales performance, product performance, category contribution, store performance, and customer purchasing patterns.

The objective is to identify meaningful business insights from historical retail transactions and present the findings through SQL analysis and an interactive Tableau dashboard.

Business Objectives

This project aims to answer the following business questions:

1. How does sales performance change over time?
2. Which products and product categories generate the highest sales?
3. Which departments contribute the most to total revenue?
4. Which stores have the highest sales performance?
5. During which hours are customers most active?
6. How is sales performance distributed across the observation period?

Dataset Description

Dataset: Dunnhumby – The Complete Journey

The dataset contains retail transaction records from 2,500 households.

| Metric | Value |
|---|---:|
| Transaction Records | 2,595,732 |
| Unique Households | 2,500 |
| Unique Baskets | 276,484 |
| Unique Products | 92,339 |
| Unique Stores | 582 |
| Observation Period | Day 1–711 |
| Observation Weeks | 102 |

Main Data Columns

| Column | Description |
|---|---|
| `household_key` | Unique household identifier |
| `BASKET_ID` | Unique transaction or basket identifier |
| `DAY` | Sequential day index of the transaction |
| `PRODUCT_ID` | Unique product identifier |
| `QUANTITY` | Quantity of products purchased |
| `SALES_VALUE` | Sales value of the transaction |
| `STORE_ID` | Unique store identifier |
| `RETAIL_DISC` | Retail discount amount |
| `TRANS_TIME` | Transaction time |
| `WEEK_NO` | Sequential week number |
| `COUPON_DISC` | Coupon discount amount |
| `COUPON_MATCH_DISC` | Coupon matching discount amount |

Tools & Technologies

- MySQL – Data exploration, data quality checks, aggregation, and analytical views.
- Tableau Desktop – Data visualization and interactive dashboard development.
- DBeaver – SQL database management and query execution.

Data Preparation

Data quality checks were performed before conducting the analysis.

The main checks included:

- Checking missing values.
- Identifying zero and negative sales values.
- Examining zero and unusual quantity values.
- Reviewing transaction time and observation period ranges.
- Investigating unusually high quantity records.
- Validating aggregated sales against the original transaction data.

Data Filtering

Records with "SALES_VALUE <= 0" were excluded from the sales performance analysis.

The original transaction table was preserved. Data preparation and analysis were performed using SQL queries and views without modifying the original records.

Data quality consideration: Some products, particularly gasoline-related products, contain unusually large quantity values. These records were retained but treated cautiously during interpretation.

Coupon discount columns were excluded from the analysis because their original decimal precision was not fully preserved in the imported MySQL table.

Analysis & Key Findings

1. Overall Sales Performance

Metric| Result
Total Sales| $8,057,463.08
Total Quantity| 260,685,622
Total Baskets| 276,484
Total Households| 2,500

2. Weekly Sales Performance

- Week 92 recorded the highest weekly sales at $113,192.87.
- Week 99 followed with $101,363.92.
- Sales performance varied throughout the 102-week observation period.

3. Product Performance

- Product ID 6534178 recorded the highest overall sales at $503,867.11.
- This product belongs to the gasoline category, highlighting the importance of distinguishing grocery products from non-grocery products.
- Among Grocery products, Product ID 1029743 recorded the highest sales at $41,072.06.

4. Department Performance

- Grocery was the largest department, contributing approximately 50.81% of total sales.
- Drug GM contributed approximately 13.10%.
- Produce contributed approximately 6.92%.

5. Grocery Category Performance

- Soft Drinks was the highest-performing Grocery category, generating $327,647.30 in sales.
- It contributed approximately 8.00% of Grocery sales.
- Fluid Milk Products reached the highest number of households, with 2,421 households.

6. Store Performance

- Store 367 recorded the highest sales at $267,614.34.
- It contributed approximately 3.32% of total sales.
- The top 10 stores collectively contributed approximately 17.40% of total sales.

7. Transaction Hour Analysis

- Sales peaked at 5 PM, reaching $828,978.16.
- The highest number of baskets was also recorded at 5 PM, with 27,371 baskets.
- Sales activity increased significantly during the afternoon and declined during the evening.

8. Daily Sales Performance

- DAY 641 recorded the highest daily sales at $24,760.10.
- DAY 643 recorded the lowest daily sales at $2.99.
- DAY 643 contained only two transaction records, indicating unusually low transaction activity.

Note: DAY represents a sequential observation index, not a calendar weekday.

Tableau Dashboard

The Tableau dashboard presents the main findings through:

- Sales Overview and KPI Metrics
- Weekly and Daily Sales Trends
- Product and Category Performance
- Store Performance and Sales Contribution
- Sales by Transaction Hour

Dashboard Preview

<!-- Add your Tableau dashboard screenshot below -->"Retail Sales Dashboard" (dashboard/retail_sales_dashboard.png)

Business Recommendations

Based on the analysis, several opportunities for further business investigation were identified:

1. Grocery Department: Prioritize monitoring the Grocery department because it contributes the largest share of revenue.
2. Product Management: Review high-performing grocery products to support inventory planning and product availability.
3. Store Performance: Investigate operational practices at Store 367 to understand factors associated with its high sales performance.
4. Staff Scheduling: Consider aligning staffing and operational resources with the afternoon transaction peak.
5. Category Strategy: Evaluate the Soft Drinks category for potential assortment and promotional opportunities.

These recommendations are exploratory and should be validated with additional operational and promotional data before implementation.

Limitations

- The dataset uses sequential day indices rather than actual calendar dates.
- Coupon discount fields were excluded because of an import precision limitation.
- Unusually high quantity values may reflect product-specific measurement or recording conventions.
- Transaction sales analysis alone does not establish the causes of sales performance differences.
- Customer demographics and promotional effects were not the primary focus of this project.

Conclusion

This project demonstrates the use of SQL for retail data analysis and Tableau for business intelligence visualization. The analysis identifies key revenue contributors across departments, products, categories, and stores