# Observed Behaviour & Technical Explanation – Set 2: Airline Seat Booking

## 1. Concurrent Seat Booking: `READ COMMITTED` vs. `SERIALIZABLE` (Task 2)

When two customers attempt to book the exact same seat (`AI-202`, Seat `12A`/`12B`) simultaneously without explicit locking hints (`UPDLOCK`), SQL Server's isolation level determines whether a race condition occurs:

### A. Under `READ COMMITTED` (Default Isolation Level)
* **Locking Mechanism:** Shared (`S`) locks acquired during a `SELECT` are held **only for the duration of that single statement** and released immediately—not held until `COMMIT`. (If Read Committed Snapshot Isolation / RCSI is enabled, readers don't even take `S` locks; they read the last committed version).
* **Observed Outcome:**
  1. **Session 1** runs `SELECT SeatStatus` and sees `'AVAILABLE'`, then immediately releases its `S` lock.
  2. **Session 2** runs `SELECT SeatStatus` milliseconds later and **also sees `'AVAILABLE'`** (a **Non-Repeatable Read / Check-Then-Act race condition**).
  3. Session 1 acquires an Exclusive (`X`) lock, inserts its booking, updates the seat to `'BOOKED'`, and commits.
  4. Session 2, which was briefly blocked waiting for Session 1's `X` lock, wakes up and **still executes its `INSERT` and `UPDATE`**, resulting in **two confirmed bookings for the same physical seat (Double Booking)**.

### B. Under `SERIALIZABLE` (Strictest Isolation Level)
* **Locking Mechanism:** Shared Key-Range locks (`RangeS-S`) acquired during `SELECT` are **held until the transaction commits or rolls back**.
* **Observed Outcome:**
  1. **Session 1** reads Seat `12B` and holds a `RangeS-S` lock on that key.
  2. **Session 2** reads Seat `12B` and also acquires a compatible `RangeS-S` lock.
  3. When **Session 1** tries to execute `UPDATE dbo.FlightSeats`, it must convert its `RangeS-S` lock into an Exclusive (`RangeX-X`) lock—which is blocked by Session 2's `RangeS-S` lock.
  4. When **Session 2** also attempts to `UPDATE`, it waits on Session 1's `RangeS-S` lock.
  5. **Result:** SQL Server detects a **Lock-Conversion Deadlock (Error 1205)** within seconds, terminates one session as the deadlock victim (rolling back its booking), and allows the surviving session to commit cleanly. Double booking is **completely prevented**.
* **Production Best Practice (Used in Task 1):** Rather than risking Error 1205 deadlocks under `SERIALIZABLE`, Task 1 uses `WITH (UPDLOCK, HOLDLOCK)` on the initial `SELECT`. Because only one session can hold an Update (`U`) lock at a time, Session 2 waits cleanly at the `SELECT` step until Session 1 commits, then reads `'BOOKED'` and exits gracefully with custom error `51002`—zero deadlocks and zero double bookings.

---

## 2. `RANK()` vs. `DENSE_RANK()` with Tied Fares (Task 3)

On Flight **`AI-202`**, two Business Class passengers (**Karthik** and **Ananya**) both paid **`18,500.00`**, and two Economy passengers (**Vikram** and **Priya**) both paid **`6,500.00`**:

| Passenger | Seat | Fare Paid | `RANK()` | `DENSE_RANK()` | Why They Differ |
| :--- | :---: | :---: | :---: | :---: | :--- |
| Karthik Subramanian | 1A | 18,500.00 | **1** | **1** | Highest fare tier (tied) |
| Ananya Deshmukh | 1B | 18,500.00 | **1** | **1** | Tied for 1st place |
| Vikram Rathore | 12A | 6,500.00 | **3** | **2** | **`RANK()` skips 2** (because 2 rows preceded it); **`DENSE_RANK()` assigns 2** (next consecutive tier) |
| Priya Menon | 12B | 6,500.00 | **3** | **2** | Tied in the 2nd fare tier |
| Rohan Kulkarni | 14C | 5,200.00 | **5** | **3** | **`RANK()` skips 4**; **`DENSE_RANK()` assigns 3** |
| Sneha Iyer | 15A | 4,500.00 | **6** | **4** | **`RANK()` assigns 6** (row position); **`DENSE_RANK()` assigns 4** (4th distinct price bracket) |

* **When to use `RANK()`:** When you care about **absolute position** (e.g., *"Top 3 highest-paying passengers get lounge access"*—if two tie at #1, only one spot remains).
* **When to use `DENSE_RANK()`:** When you want to group passengers into **consecutive fare tiers/brackets** without gaps (e.g., Tier 1 = Business, Tier 2 = Flexible Economy, Tier 3 = Standard Economy).