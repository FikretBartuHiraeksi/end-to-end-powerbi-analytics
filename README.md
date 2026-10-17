# Cosmetics E-Commerce Sales & Performance Analytics

An end-to-end analytics project on a fictional cosmetics retailer (Vaeolara Beauty): cleaning six raw tables in Python, modelling them as a star schema in PostgreSQL, answering business questions in SQL, and presenting the results in a three-page Power BI dashboard.

## Overview

Retail data rarely arrives ready for analysis. This project follows the whole path from messy source files to a decision-ready dashboard: finding and fixing data problems, designing a dimensional model, writing analytical queries, and building an interactive report. The business questions are about revenue, store performance, product profitability, campaigns, customer value and the online vs in-store split.

The full write-up with all charts and query results is in 📄 [Full Project Report (PDF)](Vaeolara%20Beauty%20Project%20Explanation.pdf). The cleaning code is in 📓 [Jupyter Notebook](clean/cleaning.ipynb). The model and queries are in 🗄️ [sql/](sql/), and the dashboard is in 📊 [powerbi/](report/Vaeolara%20Beauty.pbix).

## Data

- **Dataset:** six CSV files describing a fictional cosmetics retailer with 28 physical stores and an online store, January 2024 to December 2025
- **Source:** synthetic data generated with Claude. All brands, stores, customers and transactions are fictional, and any resemblance to real people or businesses is coincidental.

| Table | Rows (after cleaning) | What it holds |
|---|---|---|
| customers | 6,000 | demographics, signup date, acquisition channel, loyalty tier |
| products | 215 | 13 brands, 6 categories, 22 subcategories, unit cost and price |
| stores | 28 (+ Online) | city, state, region, store type, open date |
| campaigns | 24 | dates, discount, channel scope, target category |
| orders | 52,389 | order header: customer, channel, store, payment method, campaign |
| order_items | 101,042 | one row per product line in an order |

## Method

1. **Diagnosis:** checked nulls, duplicates, data types and value formats in every table.
2. **Cleaning (Python, pandas):**
   - Filled missing states with "Unknown", missing campaign target categories with "General", missing subcategories with "Unknown" and missing campaign IDs with "No Campaign". Online orders got the placeholder store "Online".
   - Removed duplicate rows (24 customers, 1,515 order items, 4 products).
   - Expanded state abbreviations to full names, stripped stray spaces, removed `$` from prices, and standardised brand and payment-method capitalisation.
   - Converted all date columns to datetime.
   - Converted 15 negative quantities to positive (line totals were already positive) and dropped 12 order lines pointing to products that do not exist.
   - Recalculated `order_total` from the line items for orders where the two disagreed (1,575 orders).
   - Saved the cleaned tables to `clean/`.
3. **Modelling (PostgreSQL):** built a star schema in a `vaeolara` schema with auto-generated surrogate keys. A fact table at order-item grain links to four dimensions: customer, product, store and campaign. The dimensions include "Online" and "No Campaign" members so no sales are lost in the joins.
4. **Analysis (SQL):** seven queries using CTEs, window functions and aggregations.
5. **Reporting (Power BI):** connected the star schema and built DAX measures (revenue, profit, profit margin, average order value, growth vs previous year) and a three-page interactive report.

## Star schema

```
dim_customer ─┐
dim_product  ─┼── fact_sales (order-item grain)
dim_store    ─┤
dim_campaign ─┘
```

## SQL analysis

| Query | Question |
|---|---|
| Customer LTV | How much does the average customer spend, by acquisition channel and loyalty tier? |
| Product profit margin | Which 10 products have the highest profit margin? |
| Best stores | Which store earns the most revenue in each region? |
| Campaign performance | How did each campaign perform, and which product sold best in it? |
| Acquisition channels | Which signup channel brings the most customers and revenue? |
| Online vs in-store | How do the two channels compare? |
| Loyalty tiers | How do customers differ across tiers? |

## Results

| Loyalty tier | Customers | Revenue | Revenue per customer |
|---|---|---|---|
| Platinum | 180 | $1.48M | $8,225 |
| Gold | 540 | $1.63M | $3,017 |
| Silver | 1,080 | $1.37M | $1,272 |
| Basic | 4,200 | $0.96M | $230 |

- **Channels:** in-store sales make up about 65% of revenue ($3.55M of $5.45M). Average order value is almost identical in both channels (about $104).
- **Customers:** the 180 Platinum customers spend about 36 times more each than the average Basic customer. Customers who signed up in-store bring the most revenue ($1.92M).
- **Stores:** the New York City Outlet is the top store in the Northeast ($396K), ahead of the best stores in the West ($218K), South ($190K) and Midwest ($182K).
- **Products:** the ten highest-margin products all earn a margin of about 70%.
- **Campaigns:** "12 Days of Beauty 2025" generated the most campaign revenue ($156K).

## Dashboard

The Power BI report has three pages:

- **Summary:** revenue, sales, active customers and stores, a map of revenue by city, a monthly trend, and a store table with growth versus the previous year.
- **Products:** revenue by category, sales split by gender, profit versus sales volume, leading brands and a product table with margins.
- **Customers & Campaigns:** loyalty tier mix, age and gender distribution, payment methods, campaign revenue and a decomposition tree.

The `.pbix` file contains a saved snapshot of the data, so it opens without a database. To refresh it, point it at your own PostgreSQL copy under Transform data → Data source settings.

## Project structure

```
├── raw/                 original CSV files
├── clean/               cleaned CSV files and cleaning notebook
│    └── cleaning.ipynb  cleaning notebook (reads raw/, writes clean/)
├── sql/
│   ├── dim-fact.sql     star schema creation
│   └── queries.sql      analysis queries
│   
└── report/
│   ├── Vaeolara Beauty Pages.pdf      
│   └── Vaeolara Beauty.pbix           
│
├── Vaeolara Beauty Project Explonation.pdf in-depth explanation

```

## Tools

- 🐍 Python 3
- 📓 Jupyter Notebook
- 🐼 pandas
- 🐘 PostgreSQL
- 🦫 DBeaver
- 📊 Power BI Desktop

## How to run

```bash
pip install pandas jupyter
jupyter notebook cleaning.ipynb
```

1. Run the notebook. It reads `raw/` and writes the cleaned tables to `clean/`.
2. In PostgreSQL, create a database named `Cosmetics` and import the six files from `clean/` into the `public` schema as tables named `customers`, `campaigns`, `products`, `stores`, `orders` and `order_items`.
3. Run `sql/dim-fact.sql` to build the `vaeolara` star schema.
4. Run `sql/queries.sql` to reproduce the analysis.
5. Open `powerbi/Vaeolara_Beauty.pbix` in Power BI Desktop.

## Author

Fikret Bartu Hıraekşi
