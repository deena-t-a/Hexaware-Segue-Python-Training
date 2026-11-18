CREATE DATABASE BankDB;
USE BankDB;

-- 1. Customers Table
CREATE TABLE Customers (
    customer_id INT IDENTITY(1,1) PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    address VARCHAR(255) NOT NULL
);

-- 2. Branches Table
CREATE TABLE Branches (
    branch_id INT IDENTITY(1,1) PRIMARY KEY,
    branch_name VARCHAR(100) NOT NULL UNIQUE,
    relationship_manager VARCHAR(100) NOT NULL
);

-- 3. Accounts Table 
CREATE TABLE Accounts (
    account_number INT IDENTITY(1001,1) PRIMARY KEY,
    customer_id INT NOT NULL,
    branch_id INT NOT NULL,
    account_type VARCHAR(50) NOT NULL,
    balance DECIMAL(12,2) NOT NULL CHECK (balance >= 0),
    CONSTRAINT FK_Account_Customer FOREIGN KEY (customer_id) 
        REFERENCES Customers(customer_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT FK_Account_Branch FOREIGN KEY (branch_id) 
        REFERENCES Branches(branch_id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- 4. Transactions Table
CREATE TABLE Transactions (
    transaction_id INT IDENTITY(1,1) PRIMARY KEY,
    account_number INT NOT NULL,
    last_transaction_text VARCHAR(255) NOT NULL,
    transaction_date DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Transaction_Account FOREIGN KEY (account_number) 
        REFERENCES Accounts(account_number) ON DELETE CASCADE
);
