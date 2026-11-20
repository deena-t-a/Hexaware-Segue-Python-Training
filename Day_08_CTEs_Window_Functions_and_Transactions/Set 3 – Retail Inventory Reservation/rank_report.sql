-- Set 3 – Retail Inventory Reservation (SQL Server 2025)

SET NOCOUNT ON;
GO

-- TASK 2: CORRELATED SUBQUERY – STOCK BELOW CATEGORY AVERAGE

PRINT '=== TASK 2: PRODUCTS WITH STOCK BELOW THEIR CATEGORY AVERAGE ===';

SELECT
    p.ProductID,
    p.ProductName,
    p.Category,
    p.StockQty AS CurrentStock,
    (
        SELECT CAST(AVG(CAST(p2.StockQty AS DECIMAL(10, 2))) AS DECIMAL(10, 2))
        FROM dbo.Products p2
        WHERE p2.Category = p.Category   -- Correlated reference to outer query's Category
    ) AS CategoryAvgStock
FROM dbo.Products p
WHERE p.StockQty < (
    SELECT AVG(CAST(p2.StockQty AS DECIMAL(10, 2)))
    FROM dbo.Products p2
    WHERE p2.Category = p.Category
)
ORDER BY p.Category ASC, p.StockQty ASC;
GO

-- SETUP HISTORICAL MONTHLY SALES DATA FOR TASKS 3 & 4

DROP TABLE IF EXISTS dbo.MonthlyProductSales;
GO

CREATE TABLE dbo.MonthlyProductSales (
    SalesMonth  DATE           NOT NULL,  -- First day of month (e.g., '2026-07-01')
    ProductID   INT            NOT NULL FOREIGN KEY REFERENCES dbo.Products(ProductID),
    UnitsSold   INT            NOT NULL,
    Revenue     DECIMAL(12, 2) NOT NULL,
    CONSTRAINT PK_MonthlyProductSales PRIMARY KEY (SalesMonth, ProductID)
);
GO

INSERT INTO dbo.MonthlyProductSales (SalesMonth, ProductID, UnitsSold, Revenue)
VALUES
    -- July 2026
    ('2026-07-01', 101, 20,  90000.00),
    ('2026-07-01', 102, 45, 112500.00),
    ('2026-07-01', 103,  6, 168000.00),
    ('2026-07-01', 104, 12,  78000.00),
    ('2026-07-01', 201, 10, 140000.00),
    ('2026-07-01', 202,  5, 110000.00),
    ('2026-07-01', 203, 18,  63000.00),
    ('2026-07-01', 204, 25,  37500.00),
    -- August 2026
    ('2026-08-01', 101, 28, 126000.00),
    ('2026-08-01', 102, 50, 125000.00),
    ('2026-08-01', 103,  5, 140000.00),
    ('2026-08-01', 104, 15,  97500.00),
    ('2026-08-01', 201, 14, 196000.00),
    ('2026-08-01', 202,  6, 132000.00),
    ('2026-08-01', 203, 14,  49000.00),
    ('2026-08-01', 204, 30,  45000.00),
    -- September 2026
    ('2026-09-01', 101, 35, 157500.00),
    ('2026-09-01', 102, 42, 105000.00),
    ('2026-09-01', 103,  8, 224000.00),
    ('2026-09-01', 104, 20, 130000.00),
    ('2026-09-01', 201, 12, 168000.00),
    ('2026-09-01', 202,  8, 176000.00),
    ('2026-09-01', 203, 22,  77000.00),
    ('2026-09-01', 204, 20,  30000.00);
GO

-- TASK 3: CTE-BASED TOP 3 PRODUCTS BY SALES PER CATEGORY (ROW_NUMBER)

PRINT '=== TASK 3: TOP 3 SELLING PRODUCTS PER CATEGORY ===';

WITH CategorySalesRankCTE AS (
    SELECT
        p.Category,
        p.ProductID,
        p.ProductName,
        SUM(s.UnitsSold) AS TotalUnitsSold,
        SUM(s.Revenue)   AS TotalSalesRevenue,
        ROW_NUMBER() OVER (
            PARTITION BY p.Category
            ORDER BY SUM(s.Revenue) DESC, SUM(s.UnitsSold) DESC
        ) AS CategoryRank
    FROM dbo.Products p
    INNER JOIN dbo.MonthlyProductSales s
        ON p.ProductID = s.ProductID
    GROUP BY
        p.Category,
        p.ProductID,
        p.ProductName
)
SELECT
    Category,
    CategoryRank,
    ProductID,
    ProductName,
    TotalUnitsSold,
    TotalSalesRevenue
FROM CategorySalesRankCTE
WHERE CategoryRank <= 3
ORDER BY Category ASC, CategoryRank ASC;
GO

-- TASK 4: MONTH-ON-MONTH SALES CHANGE PER PRODUCT USING LAG() AND LEAD()

PRINT '=== TASK 4: MONTH-ON-MONTH SALES CHANGE USING LAG() & LEAD() ===';

WITH MonthlyTrendCTE AS (
    SELECT
        p.ProductID,
        p.ProductName,
        p.Category,
        s.SalesMonth,
        s.Revenue AS CurrentMonthSales,
        LAG(s.Revenue, 1) OVER (
            PARTITION BY p.ProductID
            ORDER BY s.SalesMonth ASC
        ) AS PrevMonthSales,
        LEAD(s.Revenue, 1) OVER (
            PARTITION BY p.ProductID
            ORDER BY s.SalesMonth ASC
        ) AS NextMonthSales
    FROM dbo.MonthlyProductSales s
    INNER JOIN dbo.Products p
        ON s.ProductID = p.ProductID
)
SELECT
    ProductID,
    ProductName,
    FORMAT(SalesMonth, 'yyyy-MM') AS SalesMonth,
    PrevMonthSales,
    CurrentMonthSales,
    (CurrentMonthSales - PrevMonthSales) AS MoM_Change_Amount,
    CAST(
        ((CurrentMonthSales - PrevMonthSales) * 100.0) / NULLIF(PrevMonthSales, 0)
        AS DECIMAL(6, 2)
    ) AS MoM_Change_Pct,
    NextMonthSales,
    (NextMonthSales - CurrentMonthSales) AS NextMonth_Delta
FROM MonthlyTrendCTE
ORDER BY ProductID ASC, SalesMonth ASC;
GO