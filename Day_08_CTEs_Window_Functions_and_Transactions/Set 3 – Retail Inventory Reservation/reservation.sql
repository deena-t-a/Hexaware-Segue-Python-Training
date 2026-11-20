-- Set 3 – Retail Inventory Reservation (SQL Server 2025)

SET NOCOUNT ON;
GO

DROP TABLE IF EXISTS dbo.OrderLines;
DROP TABLE IF EXISTS dbo.Orders;
DROP TABLE IF EXISTS dbo.Products;
GO

CREATE TABLE dbo.Products (
    ProductID     INT PRIMARY KEY,
    ProductName   VARCHAR(100)   NOT NULL,
    Category      VARCHAR(50)    NOT NULL,
    UnitPrice     DECIMAL(10, 2) NOT NULL CHECK (UnitPrice > 0),
    StockQty      INT            NOT NULL CHECK (StockQty >= 0)
);

CREATE TABLE dbo.Orders (
    OrderID       INT IDENTITY(5001, 1) PRIMARY KEY,
    CustomerName  VARCHAR(100)   NOT NULL,
    OrderStatus   VARCHAR(20)    NOT NULL CHECK (OrderStatus IN ('RESERVED', 'CONFIRMED', 'CANCELLED')),
    TotalAmount   DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    OrderDate     DATETIME2      NOT NULL DEFAULT SYSDATETIME()
);

CREATE TABLE dbo.OrderLines (
    OrderLineID   INT IDENTITY(1, 1) PRIMARY KEY,
    OrderID       INT            NOT NULL FOREIGN KEY REFERENCES dbo.Orders(OrderID),
    ProductID     INT            NOT NULL FOREIGN KEY REFERENCES dbo.Products(ProductID),
    Quantity      INT            NOT NULL CHECK (Quantity > 0),
    LineTotal     DECIMAL(12, 2) NOT NULL
);
GO

INSERT INTO dbo.Products (ProductID, ProductName, Category, UnitPrice, StockQty)
VALUES
    (101, 'Mechanical Keyboard',   'Electronics', 4500.00, 15),
    (102, 'Wireless Gaming Mouse', 'Electronics', 2500.00, 40),
    (103, '27-Inch 4K Monitor',    'Electronics', 28000.00,  5),
    (104, 'USB-C Docking Station', 'Electronics', 6500.00, 20),
    (201, 'Ergonomic Mesh Chair',  'Furniture',   14000.00,  8),
    (202, 'Standing Desk Frame',   'Furniture',   22000.00,  4),
    (203, 'Monitor Arm Mount',     'Furniture',   3500.00, 25),
    (204, 'Footrest Cushion',      'Furniture',   1500.00, 30);
GO

PRINT '=== INITIAL PRODUCT INVENTORY ===';
SELECT ProductID, ProductName, Category, UnitPrice, StockQty FROM dbo.Products;
GO

DROP TYPE IF EXISTS dbo.OrderItemTableType;
GO
CREATE TYPE dbo.OrderItemTableType AS TABLE (
    ProductID INT NOT NULL PRIMARY KEY,
    Quantity  INT NOT NULL CHECK (Quantity > 0)
);
GO

-- ============================================================================
-- TASK 1: ATOMIC ORDER & INVENTORY RESERVATION STORED PROCEDURE
-- ============================================================================
CREATE OR ALTER PROCEDURE dbo.usp_PlaceRetailOrder
    @CustomerName         VARCHAR(100),
    @Items                dbo.OrderItemTableType READONLY,
    @SimulatePaymentFail  BIT = 0   -- Set to 1 to test payment gateway failure rollback
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @NewOrderID   INT;
    DECLARE @OrderTotal   DECIMAL(12, 2) = 0.00;
    DECLARE @MissingItem  VARCHAR(100);

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM @Items)
            THROW 52001, 'Order must contain at least one line item.', 1;

        BEGIN TRANSACTION;

        -- 1. Lock target product rows (UPDLOCK, HOLDLOCK) to prevent concurrent overselling
        --    and verify every requested product exists and has sufficient stock.
        SELECT TOP 1 @MissingItem = COALESCE(p.ProductName, CONCAT('ProductID ', i.ProductID))
        FROM @Items i
        LEFT JOIN dbo.Products p WITH (UPDLOCK, HOLDLOCK)
            ON i.ProductID = p.ProductID
        WHERE p.ProductID IS NULL
           OR p.StockQty < i.Quantity;

        IF @MissingItem IS NOT NULL
        BEGIN
            DECLARE @ErrMsg NVARCHAR(2048) = FORMATMESSAGE(
                'Insufficient stock or invalid product for [%s]. Rolling back entire order.',
                @MissingItem
            );
            THROW 52002, @ErrMsg, 1;
        END

        -- 2. Decrement stock for all items in the order
        UPDATE p
        SET p.StockQty = p.StockQty - i.Quantity
        FROM dbo.Products p
        INNER JOIN @Items i
            ON p.ProductID = i.ProductID;

        -- 3. Calculate total & insert Order Header
        SELECT @OrderTotal = SUM(p.UnitPrice * i.Quantity)
        FROM @Items i
        INNER JOIN dbo.Products p
            ON i.ProductID = p.ProductID;

        INSERT INTO dbo.Orders (CustomerName, OrderStatus, TotalAmount)
        VALUES (@CustomerName, 'RESERVED', @OrderTotal);

        SET @NewOrderID = SCOPE_IDENTITY();

        -- 4. Insert Order Lines
        INSERT INTO dbo.OrderLines (OrderID, ProductID, Quantity, LineTotal)
        SELECT
            @NewOrderID,
            i.ProductID,
            i.Quantity,
            (p.UnitPrice * i.Quantity)
        FROM @Items i
        INNER JOIN dbo.Products p
            ON i.ProductID = p.ProductID;

        -- 5. Simulate Payment Authorization Step
        IF @SimulatePaymentFail = 1
        BEGIN
            THROW 52003, 'PAYMENT DECLINED: Gateway authorization failed. Releasing reserved stock.', 1;
        END

        -- Mark order confirmed once payment succeeds
        UPDATE dbo.Orders
        SET OrderStatus = 'CONFIRMED'
        WHERE OrderID = @NewOrderID;

        COMMIT TRANSACTION;
        PRINT CONCAT('SUCCESS: Order #', @NewOrderID, ' confirmed for ', @CustomerName, '. Stock reserved.');
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        PRINT CONCAT('ROLLED BACK (', @CustomerName, ') | Error ', ERROR_NUMBER(), ': ', ERROR_MESSAGE());
        THROW;
    END CATCH
END;
GO

-- ============================================================================
-- TEST A: VALID ORDER (2x Mechanical Keyboard [101], 1x 4K Monitor [103])
-- ============================================================================
PRINT '=== TEST A: PLACING VALID ORDER FOR ANANYA ===';
DECLARE @CartA dbo.OrderItemTableType;
INSERT INTO @CartA (ProductID, Quantity) VALUES (101, 2), (103, 1);

EXEC dbo.usp_PlaceRetailOrder @CustomerName = 'Ananya Rao', @Items = @CartA, @SimulatePaymentFail = 0;

SELECT ProductID, ProductName, StockQty FROM dbo.Products WHERE ProductID IN (101, 103);
-- Expected: Product 101 stock drops 15 -> 13; Product 103 stock drops 5 -> 4.
GO

-- ============================================================================
-- TEST B: INSUFFICIENT STOCK ROLLBACK PROOF
-- Cart requests 1x Mouse (102 - enough stock) AND 10x 4K Monitor (103 - only 4 left!)
-- ============================================================================
PRINT '=== TEST B: INSUFFICIENT STOCK SIMULATION (MUST ROLL BACK COMPLETELY) ===';
DECLARE @CartB dbo.OrderItemTableType;
INSERT INTO @CartB (ProductID, Quantity) VALUES (102, 1), (103, 10);

BEGIN TRY
    EXEC dbo.usp_PlaceRetailOrder @CustomerName = 'Vikram Sethi', @Items = @CartB, @SimulatePaymentFail = 0;
END TRY
BEGIN CATCH
    PRINT 'Caught insufficient stock error as expected. Verifying zero side effects...';
END CATCH;

SELECT ProductID, ProductName, StockQty FROM dbo.Products WHERE ProductID IN (102, 103);
-- ROLLBACK PROOF: Product 102 is STILL 40, Product 103 is STILL 4.
SELECT * FROM dbo.Orders;     -- Only Order #5001 (Ananya) exists; no orphan order for Vikram!
SELECT * FROM dbo.OrderLines; -- Only lines for Order #5001 exist!
GO

-- ============================================================================
-- TEST C: PAYMENT FAILURE ROLLBACK PROOF (RELEASES RESERVED STOCK)
-- ============================================================================
PRINT '=== TEST C: PAYMENT FAILURE SIMULATION (RELEASES RESERVED STOCK) ===';
DECLARE @CartC dbo.OrderItemTableType;
INSERT INTO @CartC (ProductID, Quantity) VALUES (201, 2); -- Ergonomic Mesh Chair (Stock = 8)

BEGIN TRY
    EXEC dbo.usp_PlaceRetailOrder @CustomerName = 'Neha Kapoor', @Items = @CartC, @SimulatePaymentFail = 1;
END TRY
BEGIN CATCH
    PRINT 'Caught payment failure. Verifying reserved stock was released...';
END CATCH;

SELECT ProductID, ProductName, StockQty FROM dbo.Products WHERE ProductID = 201;
-- ROLLBACK PROOF: Product 201 stock remains 8!
GO