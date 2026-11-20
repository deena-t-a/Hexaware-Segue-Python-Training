================================================================================
DAY 8 – CTEs, WINDOW FUNCTIONS & TRANSACTIONS
================================================================================

--------------------------------------------------------------------------------
1. PACKAGE CONTENTS & FILE MAPPING
--------------------------------------------------------------------------------
1. transfer.sql (Tasks 1, 2, and 3 – SQL Server 2025)
   - Creates Accounts and TransactionLedger tables with integrity constraints.
   - Task 1: dbo.usp_TransferFunds using BEGIN TRAN, COMMIT, ROLLBACK,
     TRY...CATCH, THROW, UPDLOCK/HOLDLOCK, and balance/status validation.
   - Task 2: Deliberate post-debit failure simulation proving full rollback
     leaves both account balances and ledger entries unchanged.
   - Task 3: dbo.usp_TransferWithOptionalFee demonstrating SAVE TRANSACTION
     (sp_AfterPrincipalTransfer) to roll back only a failed fee-posting step
     while committing the core principal transfer.

2. statement_cte.sql (Task 4 – SQL Server 2025)
   - Generates a monthly account statement using a Common Table Expression
     (MonthlyLedgerCTE), ROW_NUMBER() for chronological line numbering, and
     LAG() to display each transaction's PreviousBalance alongside NetChange
     and ClosingBalance.

3. transaction.js (Task 5B – MongoDB 8.0)
   - Node.js script executing an atomic multi-document bank transfer across
     'accounts' and 'transaction_ledger' collections using ClientSession and
     withTransaction() with snapshot read concern and majority write concern.

4. Isolation_Levels_and_MongoDB_Cost_Note.md (Tasks 5A & 5C + Execution Output)
   - Detailed two-session timeline comparing READ COMMITTED vs. SNAPSHOT
     isolation in SQL Server 2025 (locking, version store, Error 3960).
   - Analysis of WiredTiger cache, oplog, and retry costs in MongoDB 8.0
     multi-document transactions, plus execution output screenshots.

5. README.md
   - Guide to submission files and deliverable verification.

================================================================================