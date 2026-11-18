# Set 1 – Retail Sales Reporting

The retail sales team needs daily and monthly reports from the `customers`, `products`, `orders`, `order_items` and `payments` tables. This folder has the SQL and MongoDB queries for those reports, plus the expected output of each one.

## Files

| File | What it contains |
|------|------------------|
| `reports.sql` | Table creation with constraints, sample data, the 8 reporting queries, the string/date/math function query (`UPPER`, `CONCAT`, `DATEDIFF`, `FORMAT`, `ROUND`) and the NULL behaviour demo |
| `reports.js` | Sample orders and the 3 MongoDB aggregation pipelines (`$match`, `$group`, `$sort`) for month-wise sales, top products and average basket value |
| `output_documentation.txt` | Expected result and a short explanation for every query and pipeline |


## Queries covered

1. Top 5 products by revenue
2. Month-wise sales
3. Customers with more than three orders (`HAVING`)
4. Average basket value per city
5. Orders without payment (`LEFT JOIN`)
6. Customers with no orders
7. Product-category revenue share
8. Day with the highest sales

Cancelled orders are left out of all revenue figures.
