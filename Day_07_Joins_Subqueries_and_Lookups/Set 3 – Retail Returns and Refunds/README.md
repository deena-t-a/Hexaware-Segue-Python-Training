# Retail Returns and Refunds – Day 7 Set 3

## Overview
This documentation provides a summary of join types, subquery designs, and MongoDB aggregation strategies utilized across the retail returns analytics module.

## Join Selection Rationale
* **INNER JOIN**: Used extensively for transactional lookups where entity relationships are mandatory (e.g., matching returns to valid transactions, products, and store registries).
* **LEFT JOIN**: Deployed when retaining master records with zero transactional activity is required (e.g., identifying stores with no sales, customers with returns but no refunds, or employees without direct reportees).
* **FULL OUTER JOIN**: Chosen for ledger reconciliation between independent logging tables (`Returns` and `Refunds`) to surface orphaned entries or data discrepancies on either side.
* **SELF JOIN**: Applied for hierarchical table mapping (e.g., employee-to-manager relationships) and spatial matching (e.g., identifying peer stores operating within the same city).

## Subquery vs Join Strategy Note
* **`NOT IN` Pitfall**: When checking exclusion sets in SQL, `NOT IN` evaluates to FALSE if even a single `NULL` value exists in the subquery result set. 
* **Correction**: We utilize `NOT EXISTS` with correlated subqueries as a robust standard because it correctly evaluates multi-valued logic without failing on `NULL` propagation.