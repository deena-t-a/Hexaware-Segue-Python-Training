# Isolation Levels (`READ COMMITTED` vs. `SNAPSHOT`) & MongoDB 8.0 Transaction Costs

Scenario Set 1 – Bank Funds Transfer (SQL Server 2025 & MongoDB 8.0)  
Task Covered Task 5 – Concurrency Control, Row Versioning, and Distributed Transaction Overhead  

---

## 1. SQL Server 2025 `READ COMMITTED` vs. `SNAPSHOT` Isolation (Two-Session Example)

### Setup Context
Assume Account `1001` (Aarav Sharma) starts with a committed balance of `5,000.00`. Two concurrent database sessions interact with Account `1001` at the same time
 Session A (Funds Transfer Writer) Debits `1,000.00` from Account `1001` (updating `5,000.00 - 4,000.00`).
 Session B (Audit  Balance Check Reader) Reads Account `1001`'s balance twice inside the same transaction.

---

### Case A Under `READ COMMITTED` (Default Locking Behavior)
In standard `READ COMMITTED` (without Read Committed Snapshot Isolation enabled), SQL Server uses pessimistic locking Shared (`S`) locks are acquired for reads and released immediately after the `SELECT` statement finishes, while Exclusive (`X`) locks for writes are held until `COMMIT` or `ROLLBACK`.

 Time  Session A (Writer)  Session B (Reader – `READ COMMITTED`)  Observed Locking & Concurrency Behavior 
 ---  ---  ---  --- 
 T1  `BEGIN TRANSACTION;`  `SET TRANSACTION ISOLATION LEVEL READ COMMITTED;`br`BEGIN TRANSACTION;`  Both sessions open active transactions. 
 T2  `UPDATE dbo.Accounts SET Balance = 4000.00 WHERE AccountID = 1001;` (Uncommitted)  —  Session A acquires an Exclusive (`X`) lock on row `1001`. 
 T3  —  `SELECT Balance FROM dbo.Accounts WHERE AccountID = 1001;`  BLOCKED (Waiting) Session B requests a Shared (`S`) lock to avoid reading uncommitted (dirty) data, so it freezes until Session A finishes. 
 T4  `COMMIT TRANSACTION;` (Releases `X` lock)  (Unblocked) Returns `4,000.00`.  Reader-Writer Blocking Readers wait on writers, reducing throughput under high banking traffic. 
 T5  Starts a 2nd transaction, updates `Balance = 3500.00`, and commits.  Re-runs `SELECT Balance FROM dbo.Accounts WHERE AccountID = 1001;` - Returns `3,500.00`.  Non-Repeatable Read Within a single transaction, Session B read `4,000.00` first and `3,500.00` second. 

---

### Case B Under `SNAPSHOT` Isolation (Optimistic Row Versioning in `tempdb`)
(Prerequisite `ALTER DATABASE CoreBanking SET ALLOW_SNAPSHOT_ISOLATION ON;`)

Under `SNAPSHOT` isolation, SQL Server uses Multi-Version Concurrency Control (MVCC). Whenever a row is modified, the previous committed image is copied to the `tempdb` version store, allowing readers to view a transaction-consistent point-in-time snapshot without acquiring Shared (`S`) locks.

 Time  Session A (Writer)  Session B (Reader – `SNAPSHOT`)  Observed Versioning & Concurrency Behavior 
 ---  ---  ---  --- 
 T1  `BEGIN TRANSACTION;`  `SET TRANSACTION ISOLATION LEVEL SNAPSHOT;`br`BEGIN TRANSACTION;`  Session B locks in its transaction snapshot timestamp (`T1`), where Account `1001 = 5,000.00`. 
 T2  `UPDATE dbo.Accounts SET Balance = 4000.00 WHERE AccountID = 1001;` (Uncommitted)  —  Session A holds an `X` lock on the live row and copies the prior `5,000.00` row version into `tempdb`. 
 T3  (Still uncommitted)  `SELECT Balance FROM dbo.Accounts WHERE AccountID = 1001;`  NO BLOCKING Session B ignores the `X` lock and immediately reads `5,000.00` from the `tempdb` version store. 
 T4  `COMMIT TRANSACTION;`  Re-runs `SELECT Balance FROM dbo.Accounts WHERE AccountID = 1001;` - Still returns `5,000.00`.  Repeatable Read & Phantom Protection Session B sees a consistent snapshot as of `T1`, unaffected by Session A's commit. 
 T5  —  Attempts `UPDATE dbo.Accounts SET Balance = 4800.00 WHERE AccountID = 1001;`  Update Conflict (Error 3960) SQL Server detects that row `1001` changed after `T1` and aborts Session B to prevent a Lost Update. 

---

### Summary Comparison `READ COMMITTED` vs. `SNAPSHOT`

 Dimension  `READ COMMITTED` (Locking)  `SNAPSHOT` (Row Versioning) 
 ---  ---  --- 
 Concurrency Mechanism  Pessimistic locks (`S` and `X` locks)  Optimistic MVCC row versions in `tempdb` 
 Readers vs. Writers  Readers block writers; writers block readers  Readers never block writers and writers never block readers 
 Dirty Reads  Prevented  Prevented 
 Non-Repeatable Reads  Possible  Prevented (transaction-level point-in-time consistency) 
 Lost Updates  Prevented via `X` locks  `UPDLOCK`  Prevented via Error 3960 optimistic write-conflict detection 
 Primary Overhead  Lock contention & wait timeouts  Extra `tempdb` storage & IO for the version store + 14-byte row overhead 

---

## 2. Operational & Performance Cost of MongoDB 8.0 Multi-Document Transactions

In `transaction.js`, transferring funds between two separate documents (`_id 1001` and `_id 1002`) and writing two audit entries to `transaction_ledger` requires a multi-document ACID transaction (`session.startTransaction()`  `session.withTransaction()`). While MongoDB 8.0 provides full snapshot isolation across replica sets and sharded clusters, multi-document transactions introduce four measurable costs compared to single-document atomic writes

1. WiredTiger Cache & History Store Pressure  
   To preserve `readConcern snapshot` for concurrent readers, WiredTiger must retain older versions of modified documents in memory (and spill to the WiredTiger history store on disk if transactions stay open too long). High transaction volume increases cache pressure and page eviction latency.
2. Replication & Majority Write Concern Latency (`w majority`)  
   All writes inside a multi-document transaction are buffered until `commitTransaction()` and written together into the oplog (subject to the 16 MB BSON document size limit per oplog entry). With `writeConcern { w majority }`, the primary node must wait for secondary nodes to replicate and acknowledge the commit before returning success to the banking application, adding network round-trip latency.
3. Document-Level Write Conflicts & Retry Overhead  
   MongoDB does not queue conflicting writes inside transactions like SQL Server's `UPDLOCK`. If two concurrent transfers touch Account `1001` simultaneously, WiredTiger immediately fails the second transaction with a `WriteConflict` (`TransientTransactionError`), forcing the client driver (`withTransaction()`) to abort and retry the entire callback block.
4. Architectural Guidance  
    Use single-document atomic updates (`updateOne` with `$inc`) whenever related state can be embedded in one document (zero transaction coordination overhead).
    Use multi-document transactions strictly for cross-document financial invariants—such as double-entry debits and credits across distinct account documents—where partial writes would violate ledger integrity.