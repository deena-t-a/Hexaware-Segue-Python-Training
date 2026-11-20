/* Set 1 – Bank Funds Transfer (SQL Server 2025)
   TASK 4: Monthly Statement Report using CTE, ROW_NUMBER(), and LAG()
*/

SET NOCOUNT ON;
GO

INSERT INTO dbo.TransactionLedger (AccountID, TxnType, Amount, BalanceAfter, TxnTimestamp, ReferenceNote)
VALUES
    (1001, 'CREDIT', 2500.00, 6000.00, DATEADD(DAY, -5, SYSDATETIME()), 'Salary Deposit'),
    (1001, 'DEBIT',  -450.00, 5550.00, DATEADD(DAY, -2, SYSDATETIME()), 'Utility Bill Auto-Pay');
GO

DECLARE @StatementYear  INT = YEAR(SYSDATETIME());
DECLARE @StatementMonth INT = MONTH(SYSDATETIME());

WITH MonthlyLedgerCTE AS (
    SELECT
        l.TxnID,
        l.AccountID,
        a.AccountHolder,
        l.TxnTimestamp,
        l.TxnType,
        l.ReferenceNote,
        l.Amount,
        l.BalanceAfter AS ClosingBalance,
        -- Sequence number per account ordered chronologically
        ROW_NUMBER() OVER (
            PARTITION BY l.AccountID
            ORDER BY l.TxnTimestamp ASC, l.TxnID ASC
        ) AS StatementLineNo,
        -- Retrieve previous transaction's closing balance; for line 1, derive opening balance
        LAG(l.BalanceAfter, 1, l.BalanceAfter - l.Amount) OVER (
            PARTITION BY l.AccountID
            ORDER BY l.TxnTimestamp ASC, l.TxnID ASC
        ) AS PreviousBalance
    FROM dbo.TransactionLedger l
    INNER JOIN dbo.Accounts a
        ON l.AccountID = a.AccountID
    WHERE YEAR(l.TxnTimestamp)  = @StatementYear
      AND MONTH(l.TxnTimestamp) = @StatementMonth
)
SELECT
    AccountID,
    AccountHolder,
    StatementLineNo,
    FORMAT(TxnTimestamp, 'yyyy-MM-dd HH:mm:ss') AS TransactionDate,
    TxnType,
    ReferenceNote,
    PreviousBalance,
    Amount          AS NetChange,
    ClosingBalance
FROM MonthlyLedgerCTE
ORDER BY AccountID ASC, StatementLineNo ASC;
GO