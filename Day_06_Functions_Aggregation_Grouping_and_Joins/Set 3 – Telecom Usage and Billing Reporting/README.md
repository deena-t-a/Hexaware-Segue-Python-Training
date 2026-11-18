# Set 3 – Telecom Usage and Billing Reporting

The telecom operator requires usage and billing reporting summaries across subscribers, plans, call records, and invoices. This folder provides the SQL and MongoDB implementation scripts along with expected documentation outputs.

## Files

| File | What it contains |
|------|------------------|
| `reports.sql` | Database creation (`TelecomDB`), table schemas with constraints, test data seeds, 8 analytical queries, string/date formatting, and NULL evaluation demos |
| `reports.js` | MongoDB 8.0 aggregation pipelines (`$group`, `$sort`, `$limit`, `$hour`) for hourly usage, session lengths, and cell towers |
| `output_documentation.txt` | Documented purposes and expected result sets for every SQL query and pipeline |
| `README.md` | Project file guide |

## Queries covered

1. Total call minutes per plan
2. Subscribers exceeding their data limit (`HAVING`)
3. Month-wise revenue
4. Invoices overdue by more than 15 days
5. Subscribers with no usage (`LEFT JOIN`)
6. Average Revenue Per User (ARPU) by circle
7. Plan popularity
8. Top-10 data consumers
