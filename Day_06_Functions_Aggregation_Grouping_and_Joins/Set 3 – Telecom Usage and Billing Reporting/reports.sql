CREATE DATABASE TelecomDB;

USE TelecomDB;

CREATE TABLE Plans (
    plan_id INT IDENTITY(1,1) PRIMARY KEY,
    plan_name VARCHAR(50) NOT NULL,
    data_limit_gb INT NOT NULL
);

CREATE TABLE Subscribers (
    subscriber_id INT IDENTITY(1,1) PRIMARY KEY,
    subscriber_name VARCHAR(100) NOT NULL,
    circle VARCHAR(50) NOT NULL,
    plan_id INT FOREIGN KEY REFERENCES Plans(plan_id)
);

CREATE TABLE CallRecords (
    call_id INT IDENTITY(1,1) PRIMARY KEY,
    subscriber_id INT FOREIGN KEY REFERENCES Subscribers(subscriber_id),
    call_duration_mins INT NOT NULL,
    data_used_gb DECIMAL(5,2) NOT NULL,
    call_date DATETIME NOT NULL
);

CREATE TABLE Invoices (
    invoice_id INT IDENTITY(1,1) PRIMARY KEY,
    subscriber_id INT FOREIGN KEY REFERENCES Subscribers(subscriber_id),
    amount DECIMAL(10,2) NOT NULL,
    invoice_date DATE NOT NULL,
    due_date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'Unpaid'
);

-- Seed Minimal Test Data
INSERT INTO Plans (plan_name, data_limit_gb) VALUES ('Basic 10GB', 10), ('Unlimited 50GB', 50);
INSERT INTO Subscribers (subscriber_name, circle, plan_id) VALUES ('Amit Kumar', 'Mumbai', 1), ('Priya Sharma', 'Delhi', 2), ('Rahul Verma', 'Mumbai', 1);
INSERT INTO CallRecords (subscriber_id, call_duration_mins, data_used_gb, call_date) VALUES (1, 120, 12.5, GETDATE()), (2, 300, 45.0, GETDATE());
INSERT INTO Invoices (subscriber_id, amount, invoice_date, due_date, status) VALUES (1, 499.00, '2026-10-01', '2026-10-15', 'Overdue'), (2, 999.00, '2026-11-01', '2026-11-15', 'Paid');

-----------------------------------------------------------------
-- TASK 1: EIGHT TELECOM QUERIES
-----------------------------------------------------------------

-- 1. Total call minutes per plan
SELECT p.plan_name, SUM(c.call_duration_mins) AS total_call_minutes
FROM Plans p
JOIN Subscribers s ON p.plan_id = s.plan_id
JOIN CallRecords c ON s.subscriber_id = c.subscriber_id
GROUP BY p.plan_name;

-- 2. Subscribers exceeding their data limit
SELECT DISTINCT s.subscriber_id, s.subscriber_name, p.plan_name, p.data_limit_gb, SUM(c.data_used_gb) AS total_data_used
FROM Subscribers s
JOIN Plans p ON s.plan_id = p.plan_id
JOIN CallRecords c ON s.subscriber_id = c.subscriber_id
GROUP BY s.subscriber_id, s.subscriber_name, p.plan_name, p.data_limit_gb
HAVING SUM(c.data_used_gb) > p.data_limit_gb;

-- 3. Month-wise revenue
SELECT FORMAT(invoice_date, 'yyyy-MM') AS revenue_month, SUM(amount) AS total_revenue
FROM Invoices
GROUP BY FORMAT(invoice_date, 'yyyy-MM')
ORDER BY revenue_month;

-- 4. Invoices overdue by more than 15 days
SELECT invoice_id, subscriber_id, amount, due_date, DATEDIFF(day, due_date, GETDATE()) AS days_overdue
FROM Invoices
WHERE status = 'Unpaid' AND DATEDIFF(day, due_date, GETDATE()) > 15;

-- 5. Subscribers with no usage (using LEFT JOIN)
SELECT s.subscriber_id, s.subscriber_name
FROM Subscribers s
LEFT JOIN CallRecords c ON s.subscriber_id = c.subscriber_id
WHERE c.call_id IS NULL;

-- 6. Average Revenue Per User (ARPU) by circle
SELECT s.circle, AVG(i.amount) AS arpu
FROM Subscribers s
JOIN Invoices i ON s.subscriber_id = i.subscriber_id
GROUP BY s.circle;

-- 7. Plan popularity (subscribers count per plan)
SELECT p.plan_name, COUNT(s.subscriber_id) AS subscriber_count
FROM Plans p
LEFT JOIN Subscribers s ON p.plan_id = s.plan_id
GROUP BY p.plan_name
ORDER BY subscriber_count DESC;

-- 8. Top-10 data consumers
SELECT TOP 10 s.subscriber_id, s.subscriber_name, SUM(c.data_used_gb) AS total_data_consumed
FROM Subscribers s
JOIN CallRecords c ON s.subscriber_id = c.subscriber_id
GROUP BY s.subscriber_id, s.subscriber_name
ORDER BY total_data_consumed DESC;
GO

-----------------------------------------------------------------
-- TASK 2: STRING & DATE FORMATTING FOR INVOICES
-----------------------------------------------------------------
SELECT 
    CONCAT('INV-', FORMAT(invoice_id, '000000')) AS formatted_invoice_number,
    invoice_date,
    due_date,
    CASE 
        WHEN GETDATE() > due_date THEN 'Overdue'
        ELSE 'Current / Active'
    END AS due_date_status
FROM Invoices;
GO

-----------------------------------------------------------------
-- TASK 3: NULL DEMONSTRATION ON SUM AND AVG
-----------------------------------------------------------------
CREATE TABLE UsageNullDemo (subscriber_id INT, monthly_data_gb DECIMAL(5,2));
INSERT INTO UsageNullDemo VALUES (1, 15.5), (2, NULL), (3, 8.0);

-- SUM(monthly_data_gb) ignores the NULL row and adds 15.5 + 8.0 = 23.5
SELECT SUM(monthly_data_gb) AS total_data_sum FROM UsageNullDemo;

-- AVG(monthly_data_gb) divides sum (23.5) by count of non-NULL rows (2) = 11.75
SELECT AVG(monthly_data_gb) AS average_data_avg FROM UsageNullDemo;

DROP TABLE UsageNullDemo;
GO