# Day 8 – Set 3: Retail Inventory Reservation (SQL Server 2025 & MongoDB 8.0)
---

## 1. Repository / Submission Contents

| File Name | Tasks Covered | Description |
| :--- | :---: | :--- |
| `reservation.sql` | **Task 1** | Creates `Products`, `Orders`, and `OrderLines` tables; defines `dbo.usp_PlaceRetailOrder` with `TRY...CATCH`, `THROW`, and `UPDLOCK/HOLDLOCK`; proves full rollback on both **insufficient stock** and **payment failure**. |
| `rank_report.sql` | **Tasks 2, 3 & 4** | Executes a correlated subquery for products below category average stock; builds `CategorySalesRankCTE` with `ROW_NUMBER() OVER (PARTITION BY Category)` for Top-3 products; computes month-on-month sales deltas using `LAG()` and `LEAD()`. |
| `stock_update.js` | **Task 5B** | MongoDB 8.0 `mongosh` script demonstrating single-document atomic stock reservation/release via `$inc` with `$gte` filter guards, plus a multi-document transaction for multi-item orders. |
| `mongodb_atomicity_explanation.md` | **Task 5A** | Architectural comparison explaining when single-document atomic updates suffice vs. when multi-document transactions are required in MongoDB 8.0. |
| `README.md` | **Overview** | Submission guide, deliverable mapping, and execution instructions. |

---

## 2. How to Execute & Verify

### A. SQL Server 2025 (SSMS / Azure Data Studio)
1. Execute **`reservation.sql`** first to create the retail schema, seed inventory, and verify **Test A** (valid order), **Test B** (insufficient stock rollback), and **Test C** (payment failure stock release).
2. Execute **`rank_report.sql`** on the same database to generate the below-average stock list, Top-3 per category report, and month-on-month sales trend table.

### B. MongoDB 8.0 (`mongosh`)
1. Ensure your local MongoDB 8.0 server is running as a Replica Set (`mongod --replSet rs0` with `rs.initiate()`).
2. Run the script via MongoDB Shell:
   ```bash
   mongosh --file stock_update.js