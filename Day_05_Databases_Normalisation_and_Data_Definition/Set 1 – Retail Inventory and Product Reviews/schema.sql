CREATE DATABASE RetailInventoryDB;
GO

USE RetailInventoryDB;
GO

-- 1. Supplier Table
CREATE TABLE Suppliers (
	supplier_id INT IDENTITY(1, 1) PRIMARY KEY,
	supplier_name VARCHAR(100) NOT NULL,
	supplier_phone VARCHAR(15) UNIQUE NOT NULL
);

-- 2. Product Table
CREATE TABLE PRODUCTS (
	sku VARCHAR(50) PRIMARY KEY,
	product_name VARCHAR(150) NOT NULL,
	category VARCHAR(100) NOT NULL,
	supplier_id INT NOT NULL,
	reorder_level INT NOT NULL DEFAULT 10,
	CONSTRAINT FK_Product_Supplier FOREIGN KEY (supplier_id)
		REFERENCES Suppliers(supplier_id)
		ON DELETE CASCADE ON UPDATE CASCADE
);

-- 3. Warehouse Table
CREATE TABLE Warehouses (
    warehouse_id INT IDENTITY(1,1) PRIMARY KEY,
    warehouse_name VARCHAR(100) NOT NULL UNIQUE
);

-- 4. Inventory Table
CREATE TABLE Inventory (
    sku VARCHAR(50) NOT NULL,
    warehouse_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity >= 0),
    PRIMARY KEY (sku, warehouse_id),
    CONSTRAINT FK_Inventory_Product FOREIGN KEY (sku) 
        REFERENCES Products(sku) ON DELETE CASCADE,
    CONSTRAINT FK_Inventory_Warehouse FOREIGN KEY (warehouse_id) 
        REFERENCES Warehouses(warehouse_id) ON DELETE CASCADE
);

