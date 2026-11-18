CREATE DATABASE LogisticsDB;
GO

USE LogisticsDB;
GO

-- 1. Hubs Table
CREATE TABLE Hubs (
    HubID VARCHAR(20) PRIMARY KEY,
    HubName VARCHAR(50),
    City VARCHAR(50)
);

-- 2. Carriers Table
CREATE TABLE Carriers (
    CarrierID INT PRIMARY KEY,
    CarrierName VARCHAR(50)
);

-- 3. Customers Table
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(50),
    Email VARCHAR(100)
);

-- 4. Employees Table (for Self-Join)
CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    EmployeeName VARCHAR(50),
    SupervisorID INT NULL
);

-- 5. Shipments Table
CREATE TABLE Shipments (
    ShipmentID INT PRIMARY KEY,
    TrackingNumber VARCHAR(50),
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
    CarrierID INT FOREIGN KEY REFERENCES Carriers(CarrierID),
    OriginHubID VARCHAR(20) FOREIGN KEY REFERENCES Hubs(HubID),
    DestinationHubID VARCHAR(20) FOREIGN KEY REFERENCES Hubs(HubID),
    OrderDate DATE,
    EstimatedDeliveryDate DATE,
    ActualDeliveryDate DATE,
    ShippingCost DECIMAL(10,2)
);

-- 6. DeliveryEvents Table
CREATE TABLE DeliveryEvents (
    EventID INT PRIMARY KEY,
    ShipmentID INT FOREIGN KEY REFERENCES Shipments(ShipmentID),
    EventDescription VARCHAR(255),
    EventDate DATETIME
);

ALTER TABLE Shipments ADD Status VARCHAR(30);
ALTER TABLE Shipments ADD DestinationCity VARCHAR(50);
GO

-- TASK 1: Ten Business Questions Using Joins (INNER, LEFT, FULL, SELF)

-- 1. Shipments delayed by more than two days with carrier names
-- Choice: INNER JOIN (only matching records where delay > 2 days are needed)

SELECT 
    s.ShipmentID,
    s.TrackingNumber,
    c.CarrierName,
    DATEDIFF(day, s.EstimatedDeliveryDate, s.ActualDeliveryDate) AS DelayDays
FROM Shipments s
INNER JOIN Carriers c ON s.CarrierID = c.CarrierID
WHERE DATEDIFF(day, s.EstimatedDeliveryDate, s.ActualDeliveryDate) > 2;

-- 2. Hubs with no outbound shipments
-- Choice: LEFT JOIN + IS NULL (to find unmatched rows on the right side)

SELECT 
    h.HubID,
    h.HubName,
    h.City
FROM Hubs h
LEFT JOIN Shipments s ON h.HubID = s.OriginHubID
WHERE s.ShipmentID IS NULL;

-- 3. Employees with their supervisors
-- Choice: SELF JOIN (joining the Employees table to itself via SupervisorID)

SELECT 
    e.EmployeeID AS EmployeeCode,
    e.EmployeeName AS Employee,
    ISNULL(sup.EmployeeName, 'Top Management') AS Supervisor
FROM Employees e
LEFT JOIN Employees sup ON e.SupervisorID = sup.EmployeeID;

-- 4. Customers and all their shipments (including customers with zero shipments)
-- Choice: LEFT JOIN (preserves all customers regardless of shipment activity)

SELECT 
    cust.CustomerID,
    cust.CustomerName,
    s.ShipmentID,
    s.OrderDate
FROM Customers cust
LEFT JOIN Shipments s ON cust.CustomerID = s.CustomerID;

-- 5. Full audit reconciliation of shipments and delivery logs
-- Choice: FULL OUTER JOIN (captures unmatched records from both tables)

SELECT 
    s.ShipmentID AS ShipmentTableID,
    d.ShipmentID AS DeliveryLogID,
    s.Status AS ShipmentStatus,
    d.EventDescription
FROM Shipments s
FULL OUTER JOIN DeliveryEvents d ON s.ShipmentID = d.ShipmentID;

-- 6. Carriers and their assigned shipments originating from Hub 'North-01'
-- Choice: INNER JOIN with multiple conditions/filters

SELECT 
    c.CarrierName,
    s.ShipmentID,
    s.DestinationCity
FROM Carriers c
INNER JOIN Shipments s ON c.CarrierID = s.CarrierID
WHERE s.OriginHubID = 'North-01';


-- 7. Shipments delivered after the promised date along with customer details
-- Choice: INNER JOIN

SELECT 
    s.ShipmentID,
    cust.CustomerName,
    s.EstimatedDeliveryDate,
    s.ActualDeliveryDate
FROM Shipments s
INNER JOIN Customers cust ON s.CustomerID = cust.CustomerID
WHERE s.ActualDeliveryDate > s.EstimatedDeliveryDate;

-- 8. Hub pairs located in the same city
-- Choice: SELF JOIN (comparing Hub table against itself excluding self-matches)

SELECT 
    h1.HubName AS HubA,
    h2.HubName AS HubB,
    h1.City
FROM Hubs h1
INNER JOIN Hubs h2 ON h1.City = h2.City AND h1.HubID < h2.HubID;

-- 9. Unassigned shipments with no carrier allocated
-- Choice: LEFT JOIN with IS NULL check

SELECT 
    s.ShipmentID,
    s.TrackingNumber,
    s.OrderDate
FROM Shipments s
LEFT JOIN Carriers c ON s.CarrierID = c.CarrierID
WHERE s.CarrierID IS NULL;

-- 10. Comprehensive shipment summary joining shipments, hubs, and carriers
-- Choice: Multiple INNER JOINs for consolidated reporting

SELECT 
    s.ShipmentID,
    oh.HubName AS OriginHub,
    dh.HubName AS DestinationHub,
    c.CarrierName,
    s.ShippingCost
FROM Shipments s
INNER JOIN Hubs oh ON s.OriginHubID = oh.HubID
INNER JOIN Hubs dh ON s.DestinationHubID = dh.HubID
INNER JOIN Carriers c ON s.CarrierID = c.CarrierID;


-- TASK 2: Subqueries using IN, EXISTS, ANY and ALL

-- 11. Customers who shipped to every hub (Division logic using NOT EXISTS)

SELECT DISTINCT c.CustomerID, c.CustomerName
FROM Customers c
WHERE NOT EXISTS (
    SELECT h.HubID FROM Hubs h
    WHERE NOT EXISTS (
        SELECT s.ShipmentID FROM Shipments s
        WHERE s.CustomerID = c.CustomerID AND s.DestinationHubID = h.HubID
    )
);

-- 12. Carriers whose average delay is above the overall average delay

SELECT CarrierID, AVG(DATEDIFF(day, EstimatedDeliveryDate, ActualDeliveryDate)) AS AvgDelay
FROM Shipments
GROUP BY CarrierID
HAVING AVG(DATEDIFF(day, EstimatedDeliveryDate, ActualDeliveryDate)) > ALL (
    SELECT AVG(CAST(DATEDIFF(day, EstimatedDeliveryDate, ActualDeliveryDate) AS FLOAT))
    FROM Shipments
    GROUP BY CarrierID
);

-- 13. Shipments with cost greater than any shipment handled by 'SwiftLogistics'

SELECT ShipmentID, TrackingNumber, ShippingCost
FROM Shipments
WHERE ShippingCost > ANY (
    SELECT s.ShippingCost
    FROM Shipments s
    INNER JOIN Carriers c ON s.CarrierID = c.CarrierID
    WHERE c.CarrierName = 'SwiftLogistics'
);

-- 14. Hubs that have at least one delayed shipment using IN

SELECT HubID, HubName
FROM Hubs
WHERE HubID IN (
    SELECT OriginHubID 
    FROM Shipments 
    WHERE ActualDeliveryDate > EstimatedDeliveryDate
);


-- TASK 3: Subquery to Join Rewrites & Readability Analysis

/*
-- Original Subquery Version:
SELECT CarrierName FROM Carriers 
WHERE CarrierID IN (SELECT CarrierID FROM Shipments WHERE ShippingCost > 5000);

-- Rewritten Join Version:
SELECT DISTINCT c.CarrierName 
FROM Carriers c
INNER JOIN Shipments s ON c.CarrierID = s.CarrierID
WHERE s.ShippingCost > 5000;

-- Readability Note:
-- The JOIN version is generally more readable for business reporting because 
-- it explicitly exposes the relationship between tables in the FROM clause, 
-- making it easier to add filters, projections, or additional table joins later. 
-- The subquery version can be cleaner only when checking simple existence without 
-- pulling columns from the inner table, but requires DISTINCT or EXISTS to prevent duplication.
*/


------------------------------------------------------------------------
-- TASK 4: Nested Subquery for Second-Highest Shipping Cost per Hub
------------------------------------------------------------------------

SELECT 
    OriginHubID,
    ShippingCost AS SecondHighestCost
FROM (
    SELECT 
        OriginHubID,
        ShippingCost,
    DENSE_RANK() OVER (PARTITION BY OriginHubID ORDER BY ShippingCost DESC) AS CostRank
    FROM Shipments
) RankedShipments
WHERE CostRank = 2;