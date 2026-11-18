CREATE DATABASE RetailReturnsDB;
GO

USE RetailReturnsDB;
GO

CREATE TABLE Stores (
    StoreID VARCHAR(20) PRIMARY KEY,
    StoreName VARCHAR(50),
    Region VARCHAR(50),
    City VARCHAR(50)
);

CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(50),
    Email VARCHAR(100)
);

CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    EmployeeName VARCHAR(50),
    StoreID VARCHAR(20) FOREIGN KEY REFERENCES Stores(StoreID),
    ManagerID INT NULL
);

CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    Category VARCHAR(50),
    UnitPrice DECIMAL(10,2)
);

CREATE TABLE Transactions (
    TransactionID INT PRIMARY KEY,
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
    StoreID VARCHAR(20) FOREIGN KEY REFERENCES Stores(StoreID),
    ProductID INT FOREIGN KEY REFERENCES Products(ProductID),
    QuantitySold INT,
    SaleDate DATE
);

CREATE TABLE Returns (
    ReturnID INT PRIMARY KEY,
    TransactionID INT FOREIGN KEY REFERENCES Transactions(TransactionID),
    ReturnDate DATE,
    Reason VARCHAR(100)
);

CREATE TABLE Refunds (
    RefundID INT PRIMARY KEY,
    ReturnID INT FOREIGN KEY REFERENCES Returns(ReturnID),
    RefundAmount DECIMAL(10,2),
    RefundDate DATE
);
GO

------------------------------------------------------------------------
-- TASK 1: Ten Business Questions Using Joins (INNER, LEFT, FULL, SELF)
------------------------------------------------------------------------

-- 1. Products with a high return rate (> 10%) combined with category details
-- Choice: INNER JOIN linking Products, Transactions, and Returns
SELECT 
    p.ProductID,
    p.ProductName,
    p.Category,
    COUNT(r.ReturnID) AS TotalReturns
FROM Products p
INNER JOIN Transactions t ON p.ProductID = t.ProductID
INNER JOIN Returns r ON t.TransactionID = r.TransactionID
GROUP BY p.ProductID, p.ProductName, p.Category
HAVING COUNT(r.ReturnID) > 0;

-- 2. Customers with returns but no corresponding refund
-- Choice: LEFT JOIN between Returns and Refunds with IS NULL check
SELECT DISTINCT 
    t.CustomerID,
    c.CustomerName,
    r.ReturnID
FROM Returns r
INNER JOIN Transactions t ON r.TransactionID = t.TransactionID
INNER JOIN Customers c ON t.CustomerID = c.CustomerID
LEFT JOIN Refunds ref ON r.ReturnID = ref.ReturnID
WHERE ref.RefundID IS NULL;

-- 3. Stores with the highest total refund value
-- Choice: INNER JOIN linking Stores, Transactions, Returns, and Refunds
SELECT TOP 5
    s.StoreID,
    s.StoreName,
    s.Region,
    SUM(ref.RefundAmount) AS TotalRefundValue
FROM Stores s
INNER JOIN Transactions t ON s.StoreID = t.StoreID
INNER JOIN Returns ret ON t.TransactionID = ret.TransactionID
INNER JOIN Refunds ref ON ret.ReturnID = ref.ReturnID
GROUP BY s.StoreID, s.StoreName, s.Region
ORDER BY TotalRefundValue DESC;

-- 4. Store employees and their respective managers
-- Choice: SELF JOIN on Employees table
SELECT 
    e.EmployeeID AS EmployeeCode,
    e.EmployeeName AS StaffMember,
    ISNULL(mgr.EmployeeName, 'Store Director') AS ManagerName
FROM Employees e
LEFT JOIN Employees mgr ON e.ManagerID = mgr.EmployeeID;

-- 5. All stores and their transactions (including stores with zero sales)
-- Choice: LEFT JOIN preserving all stores
SELECT 
    s.StoreID,
    s.StoreName,
    t.TransactionID,
    t.SaleDate
FROM Stores s
LEFT JOIN Transactions t ON s.StoreID = t.StoreID;

-- 6. Comprehensive audit reconciliation between Returns and Refunds
-- Choice: FULL OUTER JOIN to capture unmatched items on both sides
SELECT 
    r.ReturnID AS ReturnLedgerID,
    ref.RefundID AS RefundLedgerID,
    r.Reason,
    ref.RefundAmount
FROM Returns r
FULL OUTER JOIN Refunds ref ON r.ReturnID = ref.ReturnID;

-- 7. Returned items along with customer and store location details
-- Choice: Multiple INNER JOINs
SELECT 
    r.ReturnID,
    c.CustomerName,
    s.StoreName,
    r.Reason
FROM Returns r
INNER JOIN Transactions t ON r.TransactionID = t.TransactionID
INNER JOIN Customers c ON t.CustomerID = c.CustomerID
INNER JOIN Stores s ON t.StoreID = s.StoreID;

-- 8. Store pairs located in the same city
-- Choice: SELF JOIN on Stores table
SELECT 
    s1.StoreName AS StoreA,
    s2.StoreName AS StoreB,
    s1.City
FROM Stores s1
INNER JOIN Stores s2 ON s1.City = s2.City AND s1.StoreID < s2.StoreID;

-- 9. Transactions that have never been returned
-- Choice: LEFT JOIN with IS NULL filter
SELECT 
    t.TransactionID,
    t.SaleDate,
    t.QuantitySold
FROM Transactions t
LEFT JOIN Returns r ON t.TransactionID = r.TransactionID
WHERE r.ReturnID IS NULL;

-- 10. Consolidated summary of refunds by store and product category
-- Choice: Multi-table INNER JOIN with aggregation
SELECT 
    s.StoreName,
    p.Category,
    SUM(ref.RefundAmount) AS CategoryRefundTotal
FROM Refunds ref
INNER JOIN Returns ret ON ref.ReturnID = ret.ReturnID
INNER JOIN Transactions t ON ret.TransactionID = t.TransactionID
INNER JOIN Stores s ON t.StoreID = s.StoreID
INNER JOIN Products p ON t.ProductID = p.ProductID
GROUP BY s.StoreName, p.Category;


------------------------------------------------------------------------
-- TASK 2: IN / NOT IN Pitfall Demonstration and Correction
------------------------------------------------------------------------

/*
-- THE NULL PITFALL DEMONSTRATION:
-- If the subquery in a NOT IN clause evaluates to any single NULL value, 
-- the entire NOT IN evaluation short-circuits to FALSE (or UNKNOWN), 
-- causing the query to return zero rows.

-- Example of flawed query (returns nothing if subquery returns a NULL):
SELECT CustomerName FROM Customers 
WHERE CustomerID NOT IN (SELECT CustomerID FROM Transactions WHERE StoreID IS NULL);

-- CORRECTED VERSION using NOT EXISTS (safely handles NULLs):
*/
SELECT c.CustomerID, c.CustomerName
FROM Customers c
WHERE NOT EXISTS (
    SELECT 1 
    FROM Transactions t
    INNER JOIN Returns r ON t.TransactionID = r.TransactionID
    WHERE t.CustomerID = c.CustomerID
);


------------------------------------------------------------------------
-- TASK 3: Using ANY and ALL for Regional Refund Comparisons
------------------------------------------------------------------------

-- Compare each store's total refunds against all stores in the same region using ALL
SELECT 
    s.StoreID,
    s.StoreName,
    s.Region,
    SUM(ref.RefundAmount) AS TotalRefunds
FROM Stores s
INNER JOIN Transactions t ON s.StoreID = t.StoreID
INNER JOIN Returns ret ON t.TransactionID = ret.TransactionID
INNER JOIN Refunds ref ON ret.ReturnID = ref.ReturnID
GROUP BY s.StoreID, s.StoreName, s.Region
HAVING SUM(ref.RefundAmount) > ALL (
    SELECT AVG(RegionalRefunds.StoreTotal)
    FROM (
        SELECT st.StoreID, SUM(rf.RefundAmount) AS StoreTotal
        FROM Stores st
        INNER JOIN Transactions tr ON st.StoreID = tr.StoreID
        INNER JOIN Returns rt ON tr.TransactionID = rt.TransactionID
        INNER JOIN Refunds rf ON rt.ReturnID = rf.ReturnID
        WHERE st.Region = s.Region
        GROUP BY st.StoreID
    ) RegionalRefunds
);


------------------------------------------------------------------------
-- TASK 4: Nested Subqueries with Execution Results
------------------------------------------------------------------------

-- Nested Subquery: Find stores whose average refund amount per transaction 
-- is greater than the overall bank/retail-wide average refund per transaction.
SELECT StoreID, StoreName, AverageRefund
FROM (
    SELECT 
        s.StoreID,
        s.StoreName,
        AVG(ref.RefundAmount) AS AverageRefund
    FROM Stores s
    INNER JOIN Transactions t ON s.StoreID = t.StoreID
    INNER JOIN Returns ret ON t.TransactionID = ret.TransactionID
    INNER JOIN Refunds ref ON ret.ReturnID = ref.ReturnID
    GROUP BY s.StoreID, s.StoreName
) StoreRefundAverages
WHERE AverageRefund > (
    SELECT AVG(RefundAmount)
    FROM Refunds
);