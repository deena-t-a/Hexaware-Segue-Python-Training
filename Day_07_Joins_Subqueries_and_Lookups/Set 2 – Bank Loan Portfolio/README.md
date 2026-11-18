# Bank Loan Portfolio Analysis – Day 7 Set 2

## Overview
This package contains database setup scripts, advanced SQL queries utilizing complex joins, subqueries, correlation, and MongoDB 8.0 aggregation pipelines for credit portfolio evaluation.

## Join Selection & Rationale
* **INNER JOIN**: Used for strict relational intersections where matching master records must exist on both sides (e.g., pulling active loans tied to valid branches and customers).
* **LEFT JOIN**: Used to preserve all parent records from the primary entity regardless of transactional matches (e.g., identifying branches with zero active loans or listing all customers whether or not they currently hold an open loan).
* **FULL OUTER JOIN**: Chosen for ledger reconciliation and audit tasks to capture unmatched records or anomalies across independent data collections.
* **SELF JOIN**: Utilized for hierarchical relationship evaluation and cross-comparison within the same table (e.g., detecting customers holding loans across multiple branches or cross-referencing guarantors against active borrowers).