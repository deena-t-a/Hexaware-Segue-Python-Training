CREATE DATABASE BankLoanDB;
GO

USE BankLoanDB;
GO

------------------------------------------------------------------------
-- 0. PREREQUISITE SCHEMA SETUP
------------------------------------------------------------------------

CREATE TABLE Branches (
    BranchID VARCHAR(20) PRIMARY KEY,
    BranchName VARCHAR(50),
    City VARCHAR(50)
);

CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(50),
    Email VARCHAR(100)
);

CREATE TABLE Loans (
    LoanID INT PRIMARY KEY,
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
    BranchID VARCHAR(20) FOREIGN KEY REFERENCES Branches(BranchID),
    LoanAmount DECIMAL(12,2),
    OverdueInstalments INT,
    DisbursementDate DATE
);

CREATE TABLE Guarantors (
    GuarantorID INT PRIMARY KEY,
    LoanID INT FOREIGN KEY REFERENCES Loans(LoanID),
    GuarantorCustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID)
);

CREATE TABLE Repayments (
    RepaymentID INT PRIMARY KEY,
    LoanID INT FOREIGN KEY REFERENCES Loans(LoanID),
    RepaymentAmount DECIMAL(10,2),
    RepaymentDate DATE
);
GO

------------------------------------------------------------------------
-- TASK 1: Ten Business Questions Using Joins (INNER, LEFT, FULL, SELF)
------------------------------------------------------------------------

-- 1. Loans overdue by more than three instalments with customer and branch details
-- Choice: INNER JOIN (only active loans matching criteria are required)
SELECT 
    l.LoanID,
    c.CustomerName,
    b.BranchName,
    l.OverdueInstalments
FROM Loans l
INNER JOIN Customers c ON l.CustomerID = c.CustomerID
INNER JOIN Branches b ON l.BranchID = b.BranchID
WHERE l.OverdueInstalments > 3;

-- 2. Customers with loans in more than one branch
-- Choice: SELF JOIN on Customers/Loans to cross-compare branch allocations
SELECT DISTINCT 
    c.CustomerID,
    c.CustomerName,
    l1.BranchID AS BranchA,
    l2.BranchID AS BranchB
FROM Loans l1
INNER JOIN Loans l2 ON l1.CustomerID = l2.CustomerID AND l1.BranchID < l2.BranchID
INNER JOIN Customers c ON l1.CustomerID = c.CustomerID;

-- 3. Guarantors who are also borrowers themselves
-- Choice: SELF JOIN / INNER JOIN linking Guarantors to Customers and Loans
SELECT DISTINCT 
    c.CustomerID AS BorrowerCustomerID,
    c.CustomerName AS DualRolePerson,
    l.LoanID AS GuaranteedLoanID
FROM Guarantors g
INNER JOIN Customers c ON g.GuarantorCustomerID = c.CustomerID
INNER JOIN Loans l ON c.CustomerID = l.CustomerID;

-- 4. Branches with no active loans
-- Choice: LEFT JOIN + IS NULL (identifies unmatched rows in the right table)
SELECT 
    b.BranchID,
    b.BranchName,
    b.City
FROM Branches b
LEFT JOIN Loans l ON b.BranchID = l.BranchID
WHERE l.LoanID IS NULL;

-- 5. Customers and all their loans (including customers with zero loans)
-- Choice: LEFT JOIN (preserves all records from the Customers master table)
SELECT 
    c.CustomerID,
    c.CustomerName,
    l.LoanID,
    l.LoanAmount
FROM Customers c
LEFT JOIN Loans l ON c.CustomerID = l.CustomerID;

-- 6. Full audit reconciliation of Loans and Repayments
-- Choice: FULL OUTER JOIN (captures discrepancies on both sides of ledger)
SELECT 
    l.LoanID AS LoanTableID,
    r.RepaymentID AS RepaymentTableID,
    l.LoanAmount,
    r.RepaymentAmount
FROM Loans l
FULL OUTER JOIN Repayments r ON l.LoanID = r.LoanID;

-- 7. Active loans linked to their respective branch locations
-- Choice: INNER JOIN
SELECT 
    l.LoanID,
    b.BranchName,
    b.City,
    l.LoanAmount
FROM Loans l
INNER JOIN Branches b ON l.BranchID = b.BranchID;

-- 8. Branch pairs located in the same city
-- Choice: SELF JOIN on Branches table
SELECT 
    b1.BranchName AS BranchOne,
    b2.BranchName AS BranchTwo,
    b1.City
FROM Branches b1
INNER JOIN Branches b2 ON b1.City = b2.City AND b1.BranchID < b2.BranchID;

-- 9. Loans without any recorded repayments
-- Choice: LEFT JOIN with IS NULL check
SELECT 
    l.LoanID,
    l.LoanAmount,
    l.DisbursementDate
FROM Loans l
LEFT JOIN Repayments r ON l.LoanID = r.LoanID
WHERE r.RepaymentID IS NULL;

-- 10. Comprehensive portfolio summary joining customers, loans, and branches
-- Choice: Multiple INNER JOINs for reporting consolidation
SELECT 
    l.LoanID,
    c.CustomerName,
    b.BranchName,
    l.LoanAmount,
    l.OverdueInstalments
FROM Loans l
INNER JOIN Customers c ON l.CustomerID = c.CustomerID
INNER JOIN Branches b ON l.BranchID = b.BranchID;


------------------------------------------------------------------------
-- TASK 2: Correlated and Uncorrelated Subqueries
------------------------------------------------------------------------

-- Find customers whose total loan exposure exceeds their branch average
SELECT 
    c.CustomerID,
    c.CustomerName,
    BranchSummary.BranchID,
    BranchSummary.TotalCustomerLoan
FROM Customers c
INNER JOIN (
    SELECT CustomerID, BranchID, SUM(LoanAmount) AS TotalCustomerLoan
    FROM Loans
    GROUP BY CustomerID, BranchID
) BranchSummary ON c.CustomerID = BranchSummary.CustomerID
WHERE BranchSummary.TotalCustomerLoan > (
    SELECT AVG(BranchLoans.LoanAmount)
    FROM Loans BranchLoans
    WHERE BranchLoans.BranchID = BranchSummary.BranchID
);


------------------------------------------------------------------------
-- TASK 3: Using EXISTS and NOT EXISTS
------------------------------------------------------------------------

-- Find customers with a loan but NO repayment in the last 60 days
SELECT c.CustomerID, c.CustomerName
FROM Customers c
WHERE EXISTS (
    SELECT 1 FROM Loans l WHERE l.CustomerID = c.CustomerID
)
AND NOT EXISTS (
    SELECT 1 FROM Loans l
    INNER JOIN Repayments r ON l.LoanID = r.LoanID
    WHERE l.CustomerID = c.CustomerID 
      AND r.RepaymentDate >= DATEADD(day, -60, GETDATE())
);


------------------------------------------------------------------------
-- TASK 4: Nested Subquery for Branch Maximums vs Bank-Wide Average
------------------------------------------------------------------------

SELECT BranchID, MaxLoanAmount
FROM (
    SELECT 
        BranchID, 
        MAX(LoanAmount) AS MaxLoanAmount
    FROM Loans
    GROUP BY BranchID
) BranchMaxTable
WHERE MaxLoanAmount > (
    SELECT AVG(BranchMax)
    FROM (
        SELECT MAX(LoanAmount) AS BranchMax
        FROM Loans
        GROUP BY BranchID
    ) AllBranchMaximums
);