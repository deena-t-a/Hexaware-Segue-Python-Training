
DROP TABLE IF EXISTS claims;
DROP TABLE IF EXISTS premium_payments;
DROP TABLE IF EXISTS policies;
DROP TABLE IF EXISTS agents;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id   INT PRIMARY KEY,
    customer_name VARCHAR(50),
    dob           DATE
);

CREATE TABLE agents (
    agent_id   INT PRIMARY KEY,
    agent_name VARCHAR(50)
);

CREATE TABLE products (
    product_id   INT PRIMARY KEY,
    product_name VARCHAR(30)
);

CREATE TABLE policies (
    policy_id     INT PRIMARY KEY,
    policy_number VARCHAR(20),
    customer_id   INT REFERENCES customers(customer_id),
    product_id    INT REFERENCES products(product_id),
    agent_id      INT REFERENCES agents(agent_id),
    start_date    DATE,
    end_date      DATE,
    premium       DECIMAL(10,2),
    status        VARCHAR(15)      -- Active / Expired
);

CREATE TABLE premium_payments (
    payment_id INT PRIMARY KEY,
    policy_id  INT REFERENCES policies(policy_id),
    amount     DECIMAL(10,2),
    paid_date  DATE
);

CREATE TABLE claims (
    claim_id        INT PRIMARY KEY,
    policy_id       INT REFERENCES policies(policy_id),
    claim_date      DATE,
    claim_amount    DECIMAL(10,2),
    approved_amount DECIMAL(10,2),
    status          VARCHAR(15)    -- Settled / Rejected / Under Review
);

INSERT INTO customers VALUES
(1, 'Arun Kumar',      '1998-03-12'),
(2, 'Bala Subramani',  '1985-07-21'),
(3, 'Chitra Devi',     '1972-11-02'),
(4, 'Divya Raj',       '1992-05-30'),
(5, 'Elango M',        '1960-01-15'),
(6, 'Fathima Begum',   '2000-09-09'),
(7, 'Gopal Krishnan',  '1978-12-25'),
(8, 'Hema Latha',      '1989-04-18');

INSERT INTO agents VALUES
(1, 'Ravi'),
(2, 'Priya'),
(3, 'Karthik'),
(4, 'Meena'),
(5, 'Suresh'),
(6, 'Anita');

INSERT INTO products VALUES
(1, 'Health'),
(2, 'Motor'),
(3, 'Home'),
(4, 'Life');

INSERT INTO policies VALUES
(1,  'POL-2025-0001', 1, 2, 1, '2025-12-01', '2026-11-30', 12000, 'Active'),
(2,  'POL-2026-0002', 2, 1, 2, '2026-01-15', '2027-01-14', 18000, 'Active'),
(3,  'POL-2025-0003', 2, 2, 2, '2025-12-10', '2026-12-09',  9000, 'Active'),
(4,  'POL-2026-0004', 3, 3, 3, '2026-03-01', '2027-02-28',  7500, 'Active'),
(5,  'POL-2026-0005', 4, 4, 1, '2026-02-20', '2027-02-19', 25000, 'Active'),
(6,  'POL-2025-0006', 5, 1, 4, '2025-06-01', '2026-05-31', 20000, 'Expired'),
(7,  'POL-2026-0007', 5, 4, 4, '2026-04-05', '2027-04-04', 30000, 'Active'),
(8,  'POL-2026-0008', 6, 2, 5, '2026-08-12', '2027-08-11',  8000, 'Active'),
(9,  'POL-2026-0009', 7, 3, 3, '2026-10-01', '2027-09-30',  6500, 'Active'),
(10, 'POL-2026-0010', 8, 1, 6, '2026-11-05', '2027-11-04', 15000, 'Active'),
(11, 'POL-2026-0011', 3, 1, 2, '2026-06-20', '2027-06-19', 16000, 'Active'),
(12, 'POL-2025-0012', 4, 2, 5, '2025-12-15', '2026-12-14', 10000, 'Active');

INSERT INTO premium_payments VALUES
(1,  1,  12000, '2025-12-01'),
(2,  2,   9000, '2026-01-15'),
(3,  2,   9000, '2026-07-15'),
(4,  3,   9000, '2025-12-10'),
(5,  4,   7500, '2026-03-01'),
(6,  5,  25000, '2026-02-20'),
(7,  6,  20000, '2025-06-01'),
(8,  7,  30000, '2026-04-05'),
(9,  8,   8000, '2026-08-12'),
(10, 9,   6500, '2026-10-01'),
(11, 10,  7500, '2026-11-05'),   
(12, 11, 16000, '2026-06-20'),
(13, 12, 10000, '2025-12-15');

INSERT INTO claims VALUES
(1, 1,  '2026-03-10', 15000, 12000, 'Settled'),
(2, 2,  '2026-05-02', 10000, 10000, 'Settled'),
(3, 3,  '2026-07-15',  5000,     0, 'Rejected'),
(4, 6,  '2026-02-01',  8000,  8000, 'Settled'),
(5, 8,  '2026-10-20',  4000,  NULL, 'Under Review'),
(6, 11, '2026-09-05',  6000,  5000, 'Settled'),
(7, 4,  '2026-08-01', 20000, 14000, 'Settled');


-- -----------------------------------------------------
-- PART B: Reports
-- -----------------------------------------------------

DECLARE @today DATE = '2026-11-17';


-- Query 1: Policies expiring in the next 30 days
SELECT p.policy_number,
       c.customer_name,
       pr.product_name,
       p.end_date,
       DATEDIFF(DAY, @today, p.end_date) AS days_left
FROM policies p
JOIN customers c  ON c.customer_id = p.customer_id
JOIN products pr  ON pr.product_id = p.product_id
WHERE p.status = 'Active'
  AND p.end_date BETWEEN @today AND DATEADD(DAY, 30, @today)
ORDER BY p.end_date;


-- Query 2: Premium collected per product
SELECT pr.product_name,
       SUM(pay.amount) AS premium_collected
FROM products pr
JOIN policies p          ON p.product_id = pr.product_id
JOIN premium_payments pay ON pay.policy_id = p.policy_id
GROUP BY pr.product_name
ORDER BY premium_collected DESC;


-- Query 3: Customers with more than one active policy
-- WHERE vs HAVING:
--   WHERE  filters individual rows BEFORE grouping
--          (here: keep only Active policies).
--   HAVING filters the groups AFTER grouping
--          (here: keep only customers whose count is above 1).
-- Elango (customer 5) has 2 policies, but one is Expired.
-- WHERE removes it first, so he is left with 1 and HAVING drops him.

SELECT c.customer_id,
       c.customer_name,
       COUNT(*) AS active_policies
FROM customers c
JOIN policies p ON p.customer_id = c.customer_id
WHERE p.status = 'Active'
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(*) > 1
ORDER BY c.customer_id;


-- Query 4: Claim ratio per product
-- claim ratio = approved claim amount / premium collected * 100
SELECT pr.product_name,
       pm.premium_collected,
       ISNULL(cl.claims_paid, 0) AS claims_paid,
       CAST(ISNULL(cl.claims_paid, 0) * 100.0 / pm.premium_collected AS DECIMAL(5,2)) AS claim_ratio_pct
FROM products pr
JOIN (SELECT p.product_id, SUM(pay.amount) AS premium_collected
      FROM policies p
      JOIN premium_payments pay ON pay.policy_id = p.policy_id
      GROUP BY p.product_id) pm ON pm.product_id = pr.product_id
LEFT JOIN (SELECT p.product_id, SUM(c.approved_amount) AS claims_paid
           FROM policies p
           JOIN claims c ON c.policy_id = p.policy_id
           WHERE c.status = 'Settled'
           GROUP BY p.product_id) cl ON cl.product_id = pr.product_id
ORDER BY claim_ratio_pct DESC;


-- Query 5: Policies without claims
SELECT p.policy_number,
       c.customer_name,
       pr.product_name
FROM policies p
JOIN customers c ON c.customer_id = p.customer_id
JOIN products pr ON pr.product_id = p.product_id
LEFT JOIN claims cl ON cl.policy_id = p.policy_id
WHERE cl.claim_id IS NULL
ORDER BY p.policy_id;


-- Query 6: Average premium by customer age band
WITH customer_age AS (
    SELECT customer_id,
           DATEDIFF(YEAR, dob, @today) AS age
    FROM customers
),
policy_band AS (
    SELECT p.premium,
           ca.age,
           CASE
               WHEN ca.age < 30 THEN 'Under 30'
               WHEN ca.age < 40 THEN '30-39'
               WHEN ca.age < 50 THEN '40-49'
               WHEN ca.age < 60 THEN '50-59'
               ELSE '60+'
           END AS age_band
    FROM policies p
    JOIN customer_age ca ON ca.customer_id = p.customer_id
)
SELECT age_band,
       COUNT(*) AS policies,
       CAST(AVG(premium) AS DECIMAL(10,2)) AS avg_premium
FROM policy_band
GROUP BY age_band
ORDER BY MIN(age);


-- Query 7: Monthly new policies
SELECT CONVERT(VARCHAR(7), start_date, 120) AS policy_month,
       COUNT(*) AS new_policies
FROM policies
GROUP BY CONVERT(VARCHAR(7), start_date, 120)
ORDER BY policy_month;


-- Query 8: Top 5 agents by premium
SELECT TOP 5
       a.agent_name,
       COUNT(*) AS policies_sold,
       SUM(p.premium) AS total_premium
FROM agents a
JOIN policies p ON p.agent_id = a.agent_id
GROUP BY a.agent_name
ORDER BY total_premium DESC;


-- Query 9 (Task 2): Policy age bands and masked policy numbers
-- DATEADD and DATEDIFF give the policy age, CASE gives the band,
-- LEFT / RIGHT / CONCAT hide the middle of the policy number.
SELECT policy_number,
       CONCAT(LEFT(policy_number, 4), '****-', RIGHT(policy_number, 4)) AS masked_policy_number,
       start_date,
       DATEDIFF(MONTH, start_date, @today) AS policy_age_months,
       CASE
           WHEN start_date >= DATEADD(MONTH, -3, @today) THEN 'New (under 3 months)'
           WHEN start_date >= DATEADD(YEAR, -1, @today)  THEN 'Established (3-12 months)'
           ELSE 'Mature (over 1 year)'
       END AS policy_age_band
FROM policies
ORDER BY policy_id;
