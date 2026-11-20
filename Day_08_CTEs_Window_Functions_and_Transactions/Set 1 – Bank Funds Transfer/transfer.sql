/* Set 1 – Bank Funds Transfer (SQL Server 2025)
   
    Task 1: Atomic Funds Transfer (BEGIN TRAN, COMMIT, ROLLBACK, TRY...CATCH, THROW)
    Task 2: Deliberate Post-Debit Failure & Full Rollback Proof
    Task 3: Partial Rollback using SAVE TRANSACTION (Savepoint) for Fee Posting
*/

SET NOCOUNT ON;
GO

DROP TABLE IF EXISTS dbo.TransactionLedger;
DROP TABLE IF EXISTS dbo.Accounts;
GO

CREATE TABLE dbo.Accounts (
    AccountID     INT PRIMARY KEY,
    AccountHolder VARCHAR(100) NOT NULL,
    AccountStatus VARCHAR(20)  NOT NULL CHECK (AccountStatus IN ('ACTIVE', 'FROZEN', 'CLOSED')),
    Balance       DECIMAL(18, 2) NOT NULL CHECK (Balance >= 0)
);

CREATE TABLE dbo.TransactionLedger (
    TxnID          INT IDENTITY(1,1) PRIMARY KEY,
    AccountID      INT NOT NULL FOREIGN KEY REFERENCES dbo.Accounts(AccountID),
    TxnType        VARCHAR(20) NOT NULL CHECK (TxnType IN ('DEBIT', 'CREDIT', 'FEE')),
    Amount         DECIMAL(18, 2) NOT NULL,
    BalanceAfter   DECIMAL(18, 2) NOT NULL,
    TxnTimestamp   DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    ReferenceNote  VARCHAR(200) NULL
);
GO

INSERT INTO dbo.Accounts (AccountID, AccountHolder, AccountStatus, Balance)
VALUES
    (1001, 'Aarav Sharma',  'ACTIVE', 5000.00),
    (1002, 'Meera Nair',    'ACTIVE', 2000.00),
    (1003, 'Rohan Verma',   'FROZEN', 3500.00);
GO

PRINT '=== INITIAL ACCOUNT BALANCES ===';
SELECT * FROM dbo.Accounts;
GO

-- ============================================================================
-- TASK 1: ATOMIC FUNDS TRANSFER STORED PROCEDURE
-- Validates account existence, ACTIVE status, and sufficient balance before debiting.
-- ============================================================================
CREATE OR ALTER PROCEDURE dbo.usp_TransferFunds
    @FromAccountID       INT,
    @ToAccountID         INT,
    @Amount              DECIMAL(18, 2),
    @SimulatePostDebitError BIT = 0   -- Flag used in Task 2 to prove rollback
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @FromBalance DECIMAL(18, 2);
    DECLARE @FromStatus  VARCHAR(20);
    DECLARE @ToBalance   DECIMAL(18, 2);
    DECLARE @ToStatus    VARCHAR(20);

    BEGIN TRY
        IF @Amount <= 0
            THROW 50001, 'Transfer amount must be greater than zero.', 1;

        IF @FromAccountID = @ToAccountID
            THROW 50002, 'Source and destination accounts must be different.', 1;

        BEGIN TRANSACTION;

        -- Lock source and destination rows (UPDLOCK, HOLDLOCK) to prevent lost updates
        SELECT @FromBalance = Balance, @FromStatus = AccountStatus
        FROM dbo.Accounts WITH (UPDLOCK, HOLDLOCK)
        WHERE AccountID = @FromAccountID;

        IF @FromStatus IS NULL
            THROW 50003, 'Source account does not exist.', 1;

        IF @FromStatus <> 'ACTIVE'
            THROW 50004, 'Source account is not ACTIVE. Transfer aborted.', 1;

        IF @FromBalance < @Amount
            THROW 50005, 'Insufficient funds in source account.', 1;

        SELECT @ToBalance = Balance, @ToStatus = AccountStatus
        FROM dbo.Accounts WITH (UPDLOCK, HOLDLOCK)
        WHERE AccountID = @ToAccountID;

        IF @ToStatus IS NULL
            THROW 50006, 'Destination account does not exist.', 1;

        IF @ToStatus <> 'ACTIVE'
            THROW 50007, 'Destination account is not ACTIVE. Transfer aborted.', 1;

        -- Step 1: Debit Source Account
        UPDATE dbo.Accounts
        SET Balance = Balance - @Amount
        WHERE AccountID = @FromAccountID;

        INSERT INTO dbo.TransactionLedger (AccountID, TxnType, Amount, BalanceAfter, ReferenceNote)
        VALUES (@FromAccountID, 'DEBIT', -@Amount, @FromBalance - @Amount,
                CONCAT('Transfer to Account ', @ToAccountID));

        -- Step 2: Deliberate Failure Hook (For Task 2 Demonstration)
        IF @SimulatePostDebitError = 1
        BEGIN
            THROW 50099, 'SIMULATED SYSTEM CRASH: Network timeout after debiting source account!', 1;
        END

        -- Step 3: Credit Destination Account
        UPDATE dbo.Accounts
        SET Balance = Balance + @Amount
        WHERE AccountID = @ToAccountID;

        INSERT INTO dbo.TransactionLedger (AccountID, TxnType, Amount, BalanceAfter, ReferenceNote)
        VALUES (@ToAccountID, 'CREDIT', @Amount, @ToBalance + @Amount,
                CONCAT('Transfer from Account ', @FromAccountID));

        COMMIT TRANSACTION;
        PRINT 'SUCCESS: Transfer committed atomically.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        PRINT CONCAT('ROLLBACK EXECUTED | Error ', ERROR_NUMBER(), ': ', ERROR_MESSAGE());
        THROW; -- Re-throws the exact error to the calling application
    END CATCH
END;
GO

-- ============================================================================
-- TASK 1 EXECUTION: Valid Transfer of 1,000.00 from 1001 -> 1002
-- ============================================================================
PRINT '=== TASK 1: EXECUTING VALID TRANSFER (1000.00 from 1001 to 1002) ===';
EXEC dbo.usp_TransferFunds @FromAccountID = 1001, @ToAccountID = 1002, @Amount = 1000.00;

SELECT AccountID, AccountHolder, AccountStatus, Balance FROM dbo.Accounts;
-- Expected: 1001 = 4000.00, 1002 = 3000.00
GO

-- ============================================================================
-- TASK 2: DEMONSTRATE DELIBERATE FAILURE AFTER DEBIT & VERIFY ROLLBACK
-- ============================================================================
PRINT '=== TASK 2: EXECUTING TRANSFER WITH SIMULATED POST-DEBIT FAILURE ===';
BEGIN TRY
    EXEC dbo.usp_TransferFunds
        @FromAccountID = 1001,
        @ToAccountID   = 1002,
        @Amount        = 1500.00,
        @SimulatePostDebitError = 1;
END TRY
BEGIN CATCH
    PRINT 'Caught expected failure at caller level. Verifying account balances remain unchanged...';
END CATCH;

SELECT AccountID, AccountHolder, AccountStatus, Balance FROM dbo.Accounts;
-- ROLLBACK EVIDENCE: 1001 is STILL 4000.00 and 1002 is STILL 3000.00!
-- Neither the debit on 1001 nor its ledger row persisted.
GO

-- ============================================================================
-- TASK 3: USE SAVEPOINT TO ROLL BACK ONLY FEE-POSTING & RETAIN THE TRANSFER
-- ============================================================================
PRINT '=== TASK 3: TRANSFER WITH SAVEPOINT FOR FEE POSTING ===';
GO

CREATE OR ALTER PROCEDURE dbo.usp_TransferWithOptionalFee
    @FromAccountID INT,
    @ToAccountID   INT,
    @Amount        DECIMAL(18, 2),
    @TransferFee   DECIMAL(18, 2),
    @SimulateFeeFailure BIT = 1
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @FromBal DECIMAL(18, 2);
    DECLARE @ToBal   DECIMAL(18, 2);

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validate & Lock
        SELECT @FromBal = Balance FROM dbo.Accounts WITH (UPDLOCK, HOLDLOCK)
        WHERE AccountID = @FromAccountID AND AccountStatus = 'ACTIVE';

        SELECT @ToBal = Balance FROM dbo.Accounts WITH (UPDLOCK, HOLDLOCK)
        WHERE AccountID = @ToAccountID AND AccountStatus = 'ACTIVE';

        IF @FromBal IS NULL OR @ToBal IS NULL
            THROW 50010, 'One or both accounts are invalid or inactive.', 1;

        IF @FromBal < @Amount
            THROW 50011, 'Insufficient funds for principal transfer.', 1;

        -- Core Transfer (Debit + Credit)
        UPDATE dbo.Accounts SET Balance = Balance - @Amount WHERE AccountID = @FromAccountID;
        INSERT INTO dbo.TransactionLedger (AccountID, TxnType, Amount, BalanceAfter, ReferenceNote)
        VALUES (@FromAccountID, 'DEBIT', -@Amount, @FromBal - @Amount, 'Principal transfer out');

        UPDATE dbo.Accounts SET Balance = Balance + @Amount WHERE AccountID = @ToAccountID;
        INSERT INTO dbo.TransactionLedger (AccountID, TxnType, Amount, BalanceAfter, ReferenceNote)
        VALUES (@ToAccountID, 'CREDIT', @Amount, @ToBal + @Amount, 'Principal transfer in');

        -- Create Savepoint right after core transfer succeeds
        SAVE TRANSACTION sp_AfterPrincipalTransfer;

        -- Nested TRY...CATCH for the non-critical Fee Posting step
        BEGIN TRY
            UPDATE dbo.Accounts
            SET Balance = Balance - @TransferFee
            WHERE AccountID = @FromAccountID;

            INSERT INTO dbo.TransactionLedger (AccountID, TxnType, Amount, BalanceAfter, ReferenceNote)
            VALUES (@FromAccountID, 'FEE', -@TransferFee, (@FromBal - @Amount) - @TransferFee, 'Wire transfer fee');

            IF @SimulateFeeFailure = 1
                THROW 50088, 'Fee subsystem unavailable (Promo/Waiver engine timeout).', 1;
        END TRY
        BEGIN CATCH
            -- Roll back ONLY to the savepoint; principal transfer remains intact!
            ROLLBACK TRANSACTION sp_AfterPrincipalTransfer;
            PRINT CONCAT('WARNING: Fee posting failed (', ERROR_MESSAGE(), '). Rolled back to sp_AfterPrincipalTransfer; principal transfer retained.');
        END CATCH

        COMMIT TRANSACTION;
        PRINT 'SUCCESS: Transaction committed with principal transfer preserved.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

EXEC dbo.usp_TransferWithOptionalFee
    @FromAccountID = 1001,
    @ToAccountID   = 1002,
    @Amount        = 500.00,
    @TransferFee   = 25.00,
    @SimulateFeeFailure = 1;

SELECT AccountID, AccountHolder, Balance FROM dbo.Accounts;
-- Expected: 1001 = 3500.00 (4000 - 500; 25.00 fee was rolled back!), 1002 = 3500.00 (3000 + 500)
SELECT * FROM dbo.TransactionLedger ORDER BY TxnID;
GO