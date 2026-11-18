USE RetailInventoryDB;

-- Insert Suppliers (10 rows)
SET IDENTITY_INSERT Suppliers ON;

INSERT INTO Suppliers (supplier_id, supplier_name, supplier_phone) VALUES
(1, 'Alpha Electronics', '9876543210'),
(2, 'Beta Textiles', '9876543211'),
(3, 'Gamma Home', '9876543212'),
(4, 'Delta Foods', '9876543213'),
(5, 'Epsilon Sports', '9876543214'),
(6, 'Zeta Toys', '9876543215'),
(7, 'Eta Books', '9876543216'),
(8, 'Theta Auto', '9876543217'),
(9, 'Iota Audio', '9876543218'),
(10, 'Kappa Office', '9876543219');
SET IDENTITY_INSERT Suppliers OFF;

-- Insert Products (10 rows)
INSERT INTO Products (sku, product_name, category, supplier_id, reorder_level) VALUES
('SKU-101', 'Wireless Mouse', 'Electronics', 1, 15),
('SKU-102', 'Cotton Shirt', 'Apparel', 2, 20),
('SKU-103', 'Ceramic Mug', 'Home', 3, 10),
('SKU-104', 'Organic Honey', 'Groceries', 4, 25),
('SKU-105', 'Yoga Mat', 'Sports', 5, 12),
('SKU-106', 'Building Blocks', 'Toys', 6, 8),
('SKU-107', 'Python Programming', 'Books', 7, 5),
('SKU-108', 'Car Wiper Blade', 'Automotive', 8, 10),
('SKU-109', 'Bluetooth Speaker', 'Audio', 9, 14),
('SKU-110', 'A4 Printer Paper', 'Office', 10, 30);

-- Insert Warehouses (3 rows)
SET IDENTITY_INSERT Warehouses ON;
INSERT INTO Warehouses (warehouse_id, warehouse_name) VALUES
(1, 'North Hub'),
(2, 'South Hub'),
(3, 'Central Hub');
SET IDENTITY_INSERT Warehouses OFF;

-- Insert Inventory (10 rows)
INSERT INTO Inventory (sku, warehouse_id, quantity) VALUES
('SKU-101', 1, 50),
('SKU-102', 2, 100),
('SKU-103', 3, 40),
('SKU-104', 1, 75),
('SKU-105', 2, 30),
('SKU-106', 3, 60),
('SKU-107', 1, 25),
('SKU-108', 2, 15),
('SKU-109', 3, 45),
('SKU-110', 1, 120);


-- DELIBERATELY FAILING INSERTS (For demonstration)

-- 1. Duplicate Key Violation (Primary Key on Products)
INSERT INTO Products (sku, product_name, category, supplier_id, reorder_level) 
VALUES ('SKU-101', 'Duplicate Mouse', 'Electronics', 1, 10);
-- Error: Violation of PRIMARY KEY constraint 'PK__PRODUCTS__DDDF4BE629B16AA2'. Cannot insert duplicate key in object 'dbo.PRODUCTS'. The duplicate key value is (SKU-101).

-- 2. Missing Parent Violation (Foreign Key constraint on supplier_id)
INSERT INTO Products (sku, product_name, category, supplier_id, reorder_level) 
VALUES ('SKU-999', 'Ghost Product', 'Misc', 99, 10);
-- Error: The INSERT statement conflicted with the FOREIGN KEY constraint "FK_Product_Supplier". The conflict occurred in database "RetailInventoryDB", table "dbo.Suppliers", column 'supplier_id'.

-- 3. Check Constraint Violation (quantity < 0)
INSERT INTO Inventory (sku, warehouse_id, quantity) 
VALUES ('SKU-102', 1, -5);
-- Error: The INSERT statement conflicted with the CHECK constraint "CK__Inventory__quant__66603565". The conflict occurred in database "RetailInventoryDB", table "dbo.Inventory", column 'quantity'.

-- 4. Nullable / Mandatory Column Violation (NOT NULL constraint)
INSERT INTO Suppliers (supplier_name, supplier_phone) 
VALUES (NULL, '9111111111');
-- Error: Cannot insert the value NULL into column 'supplier_name', table 'RetailInventoryDB.dbo.Suppliers'; column does not allow nulls. INSERT fails.


-- PART 4: DML Operations (Update and Delete)

-- BEFORE UPDATE: View supplier phone
SELECT supplier_id, supplier_name, supplier_phone FROM Suppliers WHERE supplier_id = 1;

-- Update supplier phone number
UPDATE Suppliers 
SET supplier_phone = '9888888888' 
WHERE supplier_id = 1;

-- AFTER UPDATE: Verify change
SELECT supplier_id, supplier_name, supplier_phone FROM Suppliers WHERE supplier_id = 1;

-- BEFORE DELETE: Check SKUs
SELECT sku, product_name FROM Products WHERE sku IN ('SKU-106', 'SKU-110');

-- Remove discontinued SKUs 
DELETE FROM Products 
WHERE sku IN ('SKU-106', 'SKU-110');

-- AFTER DELETE: Verify removal
SELECT sku, product_name FROM Products;