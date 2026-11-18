USE BankDB;

-- Seed Customers
INSERT INTO Customers (customer_name, address) VALUES
('Aarav Sharma', 'Mumbai'), ('Diya Patel', 'Ahmedabad'), 
('Rohan Gupta', 'Delhi'), ('Neha Singh', 'Bangalore'), ('Kabir Verma', 'Pune');

-- Seed Branches
INSERT INTO Branches (branch_name, relationship_manager) VALUES
('Andheri West', 'Amit Kumar'), ('Navrangpura', 'Priya Shah'), 
('Connaught Place', 'Rajesh Verma'), ('Koramangala', 'Sneha Rao'), ('Kothrud', 'Vikram Joshi');

-- Seed Accounts (balance >= 0 check in action)
INSERT INTO Accounts (customer_id, branch_id, account_type, balance) VALUES
(1, 1, 'Savings', 45000.00),
(2, 2, 'Current', 120000.50),
(3, 3, 'Savings', 15000.00),
(4, 4, 'Salary', 85000.00),
(5, 5, 'Savings', 5200.00);

-- Seed Transactions
INSERT INTO Transactions (account_number, last_transaction_text) VALUES
(1001, 'ATM Withdrawal'),
(1002, 'NEFT Received'),
(1003, 'UPI Payment'),
(1004, 'Salary Credited'),
(1005, 'POS Purchase');



-- TASK 4: QUERYING USING AND, OR, IN, BETWEEN

-- 1. Using BETWEEN: Accounts opened in the last quarter / balance threshold
SELECT * FROM Accounts 
WHERE balance BETWEEN 10000 AND 100000;

-- 2. Using AND & OR: Savings accounts with balance > 10000 OR Current accounts
SELECT * FROM Accounts 
WHERE (account_type = 'Savings' AND balance > 10000) 
   OR (account_type = 'Current');

-- 3. Using IN: Filtering by specific account types or branch IDs
SELECT * FROM Accounts 
WHERE account_type IN ('Savings', 'Salary');

USE BankDB;

