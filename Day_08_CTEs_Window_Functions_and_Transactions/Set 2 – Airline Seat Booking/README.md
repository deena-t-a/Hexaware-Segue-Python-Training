# Day 8 – Set 2: Airline Seat Booking (SQL Server 2025 & MongoDB 8.0)
---

## 1. Repository / Submission Contents

| File Name | Tasks Covered | Description |
| :--- | :---: | :--- |
| `booking_transaction.sql` | **Tasks 1 & 2** | Creates `FlightSeats` and `Bookings` tables; defines `dbo.usp_BookAirlineSeat` with `TRY...CATCH`, `THROW`, and `UPDLOCK/HOLDLOCK`; provides two-session concurrency scripts for `READ COMMITTED` vs. `SERIALIZABLE`. |
| `ranking_report.sql` | **Tasks 3 & 4** | Populates multi-flight booking data with tied fares; generates passenger fare rankings (`RANK` vs. `DENSE_RANK`) and rewrites the report using `FlightRevenueCTE` with a chronological running total (`SUM() OVER`). |
| `booking_txn.js` | **Task 5** | MongoDB 8.0 `mongosh` script executing an atomic multi-document transaction (`startSession` / `startTransaction`) across `flight_seats` and `bookings` collections, including duplicate-booking and mid-transaction crash tests. |
| `observed_behaviour_explanation.md` | **Tasks 2 & 3** | Technical breakdown of why `READ COMMITTED` permits double bookings while `SERIALIZABLE` triggers Error 1205 deadlocks (and how `UPDLOCK` solves both), plus a tie-handling comparison of `RANK()` vs. `DENSE_RANK()`. |
| `README.md` | **Overview** | Submission guide, file mapping, and execution instructions. |

---

## 2. How to Execute & Verify

### A. SQL Server 2025 (SSMS / Azure Data Studio)
1. Open and execute **`booking_transaction.sql`** to create the tables, seed flights `AI-202` and `AI-505`, and run the atomic booking stored procedure.
2. To run the **Task 2 Concurrency Demo**, open two query windows (`Session 1` and `Session 2`) and run the commented `Part A (READ COMMITTED)` and `Part B (SERIALIZABLE)` blocks side-by-side.
3. Open and execute **`ranking_report.sql`** on the same database to view the `RANK()`/`DENSE_RANK()` comparison and the `FlightRevenueCTE` running revenue output.

### B. MongoDB 8.0 (`mongosh`)
1. Ensure your local MongoDB 8.0 server is running as a Replica Set (`mongod --replSet rs0` with `rs.initiate()`).
2. Run the script directly via MongoDB Shell:
   ```bash
   mongosh --file booking_txn.js