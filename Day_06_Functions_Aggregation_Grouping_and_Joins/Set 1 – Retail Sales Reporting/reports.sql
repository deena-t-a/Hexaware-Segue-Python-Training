
IF DB_ID('RetailDB') IS NULL
    CREATE DATABASE RetailDB;
GO

USE RetailDB;
GO

CREATE TABLE customers (
    customer_id  INT          NOT NULL PRIMARY KEY,
    first_name   VARCHAR(50)  NOT NULL,
    last_name    VARCHAR(50)  NOT NULL,
    email        VARCHAR(100) NOT NULL UNIQUE,
    phone        VARCHAR(15)  NULL,              
    city         VARCHAR(50)  NOT NULL,
    signup_date  DATE         NOT NULL
);

CREATE TABLE products (
    product_id    INT           NOT NULL PRIMARY KEY,
    product_name  VARCHAR(100)  NOT NULL,
    category      VARCHAR(50)   NOT NULL,
    unit_price    DECIMAL(10,2) NOT NULL CHECK (unit_price > 0)
);

CREATE TABLE orders (
    order_id         INT           NOT NULL PRIMARY KEY,
    customer_id      INT           NOT NULL,
    order_date       DATE          NOT NULL,
    status           VARCHAR(20)   NOT NULL DEFAULT 'Pending',
    discount_amount  DECIMAL(10,2) NULL,         
    CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    CONSTRAINT ck_orders_status   CHECK (status IN ('Pending','Shipped','Delivered','Cancelled'))
);

CREATE TABLE order_items (
    order_item_id  INT           NOT NULL PRIMARY KEY,
    order_id       INT           NOT NULL,
    product_id     INT           NOT NULL,
    quantity       INT           NOT NULL CHECK (quantity > 0),
    unit_price     DECIMAL(10,2) NOT NULL,       -- price at the time of the sale
    CONSTRAINT fk_items_order   FOREIGN KEY (order_id)   REFERENCES orders(order_id),
    CONSTRAINT fk_items_product FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE payments (
    payment_id    INT           NOT NULL PRIMARY KEY,
    order_id      INT           NOT NULL UNIQUE,  -- one payment per order
    payment_date  DATE          NOT NULL,
    amount        DECIMAL(10,2) NOT NULL CHECK (amount >= 0),
    method        VARCHAR(20)   NOT NULL,
    CONSTRAINT fk_payments_order FOREIGN KEY (order_id) REFERENCES orders(order_id),
    CONSTRAINT ck_payments_method CHECK (method IN ('UPI','Card','NetBanking','COD'))
);
GO

INSERT INTO customers (customer_id, first_name, last_name, email, phone, city, signup_date) VALUES
    (1, 'Arun', 'Kumar', 'arun.kumar@example.com', '9841000001', 'Chennai', '2026-01-12'),
    (2, 'Priya', 'Nair', 'priya.nair@example.com', NULL, 'Kochi', '2026-01-25'),
    (3, 'Rahul', 'Sharma', 'rahul.sharma@example.com', '9810000003', 'Delhi', '2026-02-08'),
    (4, 'Meena', 'Iyer', 'meena.iyer@example.com', '9841000004', 'Chennai', '2026-02-19'),
    (5, 'Karthik', 'Raj', 'karthik.raj@example.com', NULL, 'Bengaluru', '2026-03-03'),
    (6, 'Sneha', 'Reddy', 'sneha.reddy@example.com', '9900000006', 'Hyderabad', '2026-03-17'),
    (7, 'Vikram', 'Singh', 'vikram.singh@example.com', '9810000007', 'Delhi', '2026-04-02'),
    (8, 'Anita', 'Das', 'anita.das@example.com', NULL, 'Kolkata', '2026-04-21'),
    (9, 'Rohan', 'Mehta', 'rohan.mehta@example.com', '9820000009', 'Mumbai', '2026-05-09'),
    (10, 'Divya', 'Menon', 'divya.menon@example.com', '9847000010', 'Kochi', '2026-05-30');

INSERT INTO products (product_id, product_name, category, unit_price) VALUES
    (1, 'Wireless Mouse', 'Electronics', 799.00),
    (2, 'Mechanical Keyboard', 'Electronics', 2499.00),
    (3, 'USB-C Hub', 'Electronics', 1299.00),
    (4, 'Notebook Pack', 'Stationery', 249.00),
    (5, 'Gel Pen Set', 'Stationery', 149.00),
    (6, 'Backpack', 'Accessories', 1799.00),
    (7, 'Water Bottle', 'Accessories', 499.00),
    (8, 'Desk Lamp', 'Home', 999.00);

INSERT INTO orders (order_id, customer_id, order_date, status, discount_amount) VALUES
    (1, 1, '2026-09-03', 'Delivered', 50.00),
    (2, 2, '2026-09-05', 'Delivered', NULL),
    (3, 3, '2026-09-12', 'Delivered', NULL),
    (4, 1, '2026-09-18', 'Delivered', 100.00),
    (5, 4, '2026-09-25', 'Delivered', NULL),
    (6, 3, '2026-10-02', 'Delivered', 150.00),
    (7, 5, '2026-10-05', 'Delivered', NULL),
    (8, 1, '2026-10-09', 'Delivered', NULL),
    (9, 6, '2026-10-09', 'Delivered', NULL),
    (10, 3, '2026-10-15', 'Delivered', 200.00),
    (11, 7, '2026-10-21', 'Delivered', NULL),
    (12, 2, '2026-10-28', 'Cancelled', NULL),
    (13, 1, '2026-11-02', 'Delivered', 100.00),
    (14, 4, '2026-11-04', 'Delivered', NULL),
    (15, 3, '2026-11-04', 'Delivered', NULL),
    (16, 6, '2026-11-08', 'Pending', NULL),
    (17, 5, '2026-11-11', 'Delivered', NULL),
    (18, 7, '2026-11-14', 'Shipped', NULL);

INSERT INTO order_items (order_item_id, order_id, product_id, quantity, unit_price) VALUES
    (1, 1, 1, 1, 799.00),
    (2, 1, 4, 2, 249.00),
    (3, 2, 2, 1, 2499.00),
    (4, 3, 6, 1, 1799.00),
    (5, 3, 5, 3, 149.00),
    (6, 4, 3, 1, 1299.00),
    (7, 4, 1, 2, 799.00),
    (8, 5, 8, 1, 999.00),
    (9, 5, 7, 2, 499.00),
    (10, 6, 2, 1, 2499.00),
    (11, 6, 3, 1, 1299.00),
    (12, 7, 4, 5, 249.00),
    (13, 7, 5, 4, 149.00),
    (14, 8, 6, 1, 1799.00),
    (15, 8, 7, 1, 499.00),
    (16, 9, 8, 2, 999.00),
    (17, 10, 1, 1, 799.00),
    (18, 10, 2, 1, 2499.00),
    (19, 10, 7, 2, 499.00),
    (20, 11, 3, 2, 1299.00),
    (21, 12, 6, 1, 1799.00),
    (22, 13, 2, 1, 2499.00),
    (23, 13, 4, 3, 249.00),
    (24, 14, 8, 1, 999.00),
    (25, 14, 5, 2, 149.00),
    (26, 15, 1, 3, 799.00),
    (27, 16, 6, 1, 1799.00),
    (28, 16, 3, 1, 1299.00),
    (29, 17, 7, 3, 499.00),
    (30, 17, 5, 2, 149.00),
    (31, 18, 2, 1, 2499.00),
    (32, 18, 1, 1, 799.00);

-- payment amount = order value - discount. Orders 12, 16 and 18 have no payment row.
INSERT INTO payments (payment_id, order_id, payment_date, amount, method) VALUES
    (1, 1, '2026-09-04', 1247.00, 'Card'),
    (2, 2, '2026-09-07', 2499.00, 'NetBanking'),
    (3, 3, '2026-09-15', 2246.00, 'COD'),
    (4, 4, '2026-09-18', 2797.00, 'UPI'),
    (5, 5, '2026-09-26', 1997.00, 'Card'),
    (6, 6, '2026-10-04', 3648.00, 'NetBanking'),
    (7, 7, '2026-10-08', 1841.00, 'COD'),
    (8, 8, '2026-10-09', 2298.00, 'UPI'),
    (9, 9, '2026-10-10', 1998.00, 'Card'),
    (10, 10, '2026-10-17', 4096.00, 'NetBanking'),
    (11, 11, '2026-10-24', 2598.00, 'COD'),
    (12, 13, '2026-11-03', 3146.00, 'Card'),
    (13, 14, '2026-11-06', 1297.00, 'NetBanking'),
    (14, 15, '2026-11-07', 2397.00, 'COD'),
    (15, 17, '2026-11-12', 1795.00, 'Card');
GO



-- ---------------------------------------------------------------------
-- Query 1 : Top 5 products by revenue
-- ---------------------------------------------------------------------
SELECT TOP 5
    p.product_id,
    p.product_name,
    SUM(oi.quantity)                    AS units_sold,
    SUM(oi.quantity * oi.unit_price)    AS total_revenue
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
JOIN orders   o ON o.order_id   = oi.order_id
WHERE o.status <> 'Cancelled'
GROUP BY p.product_id, p.product_name
ORDER BY total_revenue DESC, p.product_name;
GO

-- ---------------------------------------------------------------------
-- Query 2 : Month-wise sales
-- ---------------------------------------------------------------------
SELECT
    FORMAT(o.order_date, 'yyyy-MM')     AS sales_month,
    COUNT(DISTINCT o.order_id)          AS total_orders,
    SUM(oi.quantity * oi.unit_price)    AS monthly_revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status <> 'Cancelled'
GROUP BY FORMAT(o.order_date, 'yyyy-MM')
ORDER BY sales_month;
GO

-- ---------------------------------------------------------------------
-- Query 3 : Customers with more than three orders (HAVING)
-- ---------------------------------------------------------------------
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name)  AS customer_name,
    COUNT(o.order_id)                       AS order_count
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(o.order_id) > 3
ORDER BY order_count DESC, c.customer_id;
GO

-- ---------------------------------------------------------------------
-- Query 4 : Average basket value per city
-- basket value = total of one order, so first total each order, then
-- average those totals per city
-- ---------------------------------------------------------------------
SELECT
    c.city,
    COUNT(*) AS orders,
    CAST(ROUND(AVG(CAST(ot.order_total AS FLOAT)), 2) AS DECIMAL(10,2)) AS avg_basket_value
FROM (
        SELECT o.order_id, o.customer_id,
               SUM(oi.quantity * oi.unit_price) AS order_total
        FROM orders o
        JOIN order_items oi ON oi.order_id = o.order_id
        WHERE o.status <> 'Cancelled'
        GROUP BY o.order_id, o.customer_id
     ) AS ot
JOIN customers c ON c.customer_id = ot.customer_id
GROUP BY c.city
ORDER BY avg_basket_value DESC, c.city;
GO

-- ---------------------------------------------------------------------
-- Query 5 : Orders without payment (LEFT JOIN ... IS NULL)
-- ---------------------------------------------------------------------
SELECT
    o.order_id,
    o.order_date,
    o.status,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name
FROM orders o
LEFT JOIN payments  p ON p.order_id    = o.order_id
JOIN      customers c ON c.customer_id = o.customer_id
WHERE p.payment_id IS NULL
ORDER BY o.order_id;
GO

-- ---------------------------------------------------------------------
-- Query 6 : Customers with no orders
-- ---------------------------------------------------------------------
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.city,
    c.signup_date
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
WHERE o.order_id IS NULL
ORDER BY c.customer_id;
GO

-- ---------------------------------------------------------------------
-- Query 7 : Product-category revenue share
-- SUM(SUM(...)) OVER () gives the grand total next to every category row
-- ---------------------------------------------------------------------
SELECT
    p.category,
    SUM(oi.quantity * oi.unit_price) AS category_revenue,
    CAST(ROUND(100.0 * SUM(oi.quantity * oi.unit_price)
               / SUM(SUM(oi.quantity * oi.unit_price)) OVER (), 2) AS DECIMAL(5,2)) AS revenue_share_pct
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
JOIN orders   o ON o.order_id   = oi.order_id
WHERE o.status <> 'Cancelled'
GROUP BY p.category
ORDER BY category_revenue DESC;
GO

-- ---------------------------------------------------------------------
-- Query 8 : Day with the highest sales
-- WITH TIES so that two days with the same total both show up
-- ---------------------------------------------------------------------
SELECT TOP 1 WITH TIES
    o.order_date,
    COUNT(DISTINCT o.order_id)          AS orders_that_day,
    SUM(oi.quantity * oi.unit_price)    AS daily_revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status <> 'Cancelled'
GROUP BY o.order_date
ORDER BY daily_revenue DESC;
GO


SELECT TOP 5
    o.order_id,
    CONCAT(UPPER(c.last_name), ', ', c.first_name)              AS customer_display,
    FORMAT(o.order_date, 'dd-MMM-yyyy')                         AS order_date_fmt,
    CONCAT('Rs. ', FORMAT(t.order_total, 'N2'))                 AS order_value,
    DATEDIFF(DAY, o.order_date, p.payment_date)                 AS days_to_pay,
    CAST(ROUND(t.order_total * 0.18, 2) AS DECIMAL(10,2))       AS gst_amount,
    CONCAT('Hi ', UPPER(c.first_name), '! Order #', o.order_id,
           ' (Rs. ', FORMAT(t.order_total, 'N2'), ') placed on ',
           FORMAT(o.order_date, 'dd-MMM-yyyy'), ' was paid in ',
           DATEDIFF(DAY, o.order_date, p.payment_date), ' day(s). GST @18%: Rs. ',
           FORMAT(ROUND(t.order_total * 0.18, 2), 'N2'))        AS message_text
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
JOIN payments  p ON p.order_id    = o.order_id
JOIN (
        SELECT order_id, SUM(quantity * unit_price) AS order_total
        FROM order_items
        GROUP BY order_id
     ) AS t ON t.order_id = o.order_id
ORDER BY o.order_id;
GO


SELECT
    COUNT(*)                AS total_rows,
    COUNT(phone)            AS rows_with_phone,
    COUNT(*) - COUNT(phone) AS null_phones
FROM customers;
GO

SELECT
    COUNT(*) AS total_orders,
    COUNT(discount_amount) AS orders_with_discount,
    CAST(ROUND(AVG(CAST(discount_amount AS FLOAT)), 2) AS DECIMAL(10,2)) AS avg_ignoring_nulls,
    CAST(ROUND(AVG(CAST(ISNULL(discount_amount, 0) AS FLOAT)), 2) AS DECIMAL(10,2)) AS avg_nulls_as_zero
FROM orders;
GO
