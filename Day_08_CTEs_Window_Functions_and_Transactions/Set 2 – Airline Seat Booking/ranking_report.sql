-- Set 2 – Airline Seat Booking (SQL Server 2025)

SET NOCOUNT ON;
GO

DELETE FROM dbo.Bookings;
UPDATE dbo.FlightSeats SET SeatStatus = 'AVAILABLE';
GO

EXEC dbo.usp_BookAirlineSeat 'AI-202', '1A',  'Karthik Subramanian'; -- 18,500.00 (Tied #1)
EXEC dbo.usp_BookAirlineSeat 'AI-202', '1B',  'Ananya Deshmukh';     -- 18,500.00 (Tied #1)
EXEC dbo.usp_BookAirlineSeat 'AI-202', '12A', 'Vikram Rathore';      --  6,500.00 (Tied #2)
EXEC dbo.usp_BookAirlineSeat 'AI-202', '12B', 'Priya Menon';         --  6,500.00 (Tied #2)
EXEC dbo.usp_BookAirlineSeat 'AI-202', '14C', 'Rohan Kulkarni';      --  5,200.00
EXEC dbo.usp_BookAirlineSeat 'AI-202', '15A', 'Sneha Iyer';          --  4,500.00

EXEC dbo.usp_BookAirlineSeat 'AI-505', '2A',  'Siddharth Malhotra';  -- 22,000.00
EXEC dbo.usp_BookAirlineSeat 'AI-505', '10A', 'Meera Krishnan';      --  7,800.00 (Tied #2)
EXEC dbo.usp_BookAirlineSeat 'AI-505', '10B', 'Arjun Nair';          --  7,800.00 (Tied #2)
EXEC dbo.usp_BookAirlineSeat 'AI-505', '11C', 'Divya Sharma';        --  6,100.00
GO

-- ============================================================================
-- TASK 3: RANKED PASSENGER REPORT BY FARE PER FLIGHT (RANK vs. DENSE_RANK)
-- ============================================================================
PRINT '=== TASK 3: RANK() vs. DENSE_RANK() BY FARE PER FLIGHT ===';

SELECT
    b.FlightNo,
    b.BookingID,
    b.PassengerName,
    b.SeatNo,
    fs.SeatClass,
    b.FarePaid,
    RANK() OVER (
        PARTITION BY b.FlightNo
        ORDER BY b.FarePaid DESC
    ) AS FareRank_WithGaps,
    DENSE_RANK() OVER (
        PARTITION BY b.FlightNo
        ORDER BY b.FarePaid DESC
    ) AS FareDenseRank_NoGaps
FROM dbo.Bookings b
INNER JOIN dbo.FlightSeats fs
    ON b.FlightNo = fs.FlightNo AND b.SeatNo = fs.SeatNo
ORDER BY b.FlightNo ASC, b.FarePaid DESC, b.BookingID ASC;
GO

-- ============================================================================
-- TASK 4: CTE REWRITE WITH RUNNING TOTAL OF REVENUE PER FLIGHT (SUM() OVER)
-- ============================================================================
PRINT '=== TASK 4: CTE + RUNNING REVENUE PER FLIGHT ===';

WITH FlightRevenueCTE AS (
    SELECT
        b.FlightNo,
        b.BookingID,
        b.PassengerName,
        b.SeatNo,
        fs.SeatClass,
        b.FarePaid,
        b.BookedAt,
        RANK() OVER (
            PARTITION BY b.FlightNo
            ORDER BY b.FarePaid DESC
        ) AS FareRank,
        DENSE_RANK() OVER (
            PARTITION BY b.FlightNo
            ORDER BY b.FarePaid DESC
        ) AS FareDenseRank,
        -- Running total ordered by BookingID (chronological booking sequence)
        SUM(b.FarePaid) OVER (
            PARTITION BY b.FlightNo
            ORDER BY b.BookingID ASC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS RunningFlightRevenue,
        -- Total flight revenue across all rows in the partition (for % share calculation)
        SUM(b.FarePaid) OVER (
            PARTITION BY b.FlightNo
        ) AS TotalFlightRevenue
    FROM dbo.Bookings b
    INNER JOIN dbo.FlightSeats fs
        ON b.FlightNo = fs.FlightNo AND b.SeatNo = fs.SeatNo
)
SELECT
    FlightNo,
    BookingID,
    PassengerName,
    SeatNo,
    SeatClass,
    FarePaid,
    FareRank,
    FareDenseRank,
    RunningFlightRevenue,
    TotalFlightRevenue,
    CAST((FarePaid * 100.0) / TotalFlightRevenue AS DECIMAL(5, 2)) AS PctOfFlightRevenue
FROM FlightRevenueCTE
ORDER BY FlightNo ASC, BookingID ASC;
GO