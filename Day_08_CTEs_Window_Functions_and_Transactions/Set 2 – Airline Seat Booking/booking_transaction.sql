-- Set 2 – Airline Seat Booking (SQL Server 2025)

SET NOCOUNT ON;
GO

DROP TABLE IF EXISTS dbo.Bookings;
DROP TABLE IF EXISTS dbo.FlightSeats;
GO

CREATE TABLE dbo.FlightSeats (
    FlightNo      VARCHAR(10)  NOT NULL,
    SeatNo        VARCHAR(5)   NOT NULL,
    SeatClass     VARCHAR(20)  NOT NULL CHECK (SeatClass IN ('ECONOMY', 'BUSINESS', 'FIRST')),
    Fare          DECIMAL(10, 2) NOT NULL,
    SeatStatus    VARCHAR(20)  NOT NULL CHECK (SeatStatus IN ('AVAILABLE', 'BOOKED')),
    CONSTRAINT PK_FlightSeats PRIMARY KEY (FlightNo, SeatNo)
);

CREATE TABLE dbo.Bookings (
    BookingID     INT IDENTITY(1001, 1) PRIMARY KEY,
    FlightNo      VARCHAR(10)  NOT NULL,
    SeatNo        VARCHAR(5)   NOT NULL,
    PassengerName VARCHAR(100) NOT NULL,
    FarePaid      DECIMAL(10, 2) NOT NULL,
    BookedAt      DATETIME2    NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_Bookings_Seat FOREIGN KEY (FlightNo, SeatNo)
        REFERENCES dbo.FlightSeats (FlightNo, SeatNo)
);
GO

INSERT INTO dbo.FlightSeats (FlightNo, SeatNo, SeatClass, Fare, SeatStatus)
VALUES
    ('AI-202', '1A',  'BUSINESS', 18500.00, 'AVAILABLE'),
    ('AI-202', '1B',  'BUSINESS', 18500.00, 'AVAILABLE'),
    ('AI-202', '12A', 'ECONOMY',   6500.00, 'AVAILABLE'),
    ('AI-202', '12B', 'ECONOMY',   6500.00, 'AVAILABLE'),
    ('AI-202', '14C', 'ECONOMY',   5200.00, 'AVAILABLE'),
    ('AI-202', '15A', 'ECONOMY',   4500.00, 'AVAILABLE'),
    ('AI-505', '2A',  'BUSINESS', 22000.00, 'AVAILABLE'),
    ('AI-505', '10A', 'ECONOMY',   7800.00, 'AVAILABLE'),
    ('AI-505', '10B', 'ECONOMY',   7800.00, 'AVAILABLE'),
    ('AI-505', '11C', 'ECONOMY',   6100.00, 'AVAILABLE');
GO

-- ============================================================================
-- TASK 1: ATOMIC SEAT BOOKING STORED PROCEDURE
-- Checks seat availability, inserts booking, and marks seat BOOKED atomically.
-- ============================================================================
CREATE OR ALTER PROCEDURE dbo.usp_BookAirlineSeat
    @FlightNo      VARCHAR(10),
    @SeatNo        VARCHAR(5),
    @PassengerName VARCHAR(100),
    @DelaySeconds  VARCHAR(8) = '00:00:00' 
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @CurrentStatus VARCHAR(20);
    DECLARE @SeatFare      DECIMAL(10, 2);

    BEGIN TRY
        BEGIN TRANSACTION;

        -- 1. Check seat existence & status (UPDLOCK + HOLDLOCK prevents double-booking)
        SELECT
            @CurrentStatus = SeatStatus,
            @SeatFare      = Fare
        FROM dbo.FlightSeats WITH (UPDLOCK, HOLDLOCK)
        WHERE FlightNo = @FlightNo
          AND SeatNo   = @SeatNo;

        IF @CurrentStatus IS NULL
            THROW 51001, 'Invalid Flight Number or Seat Number.', 1;

        IF @CurrentStatus <> 'AVAILABLE'
            THROW 51002, 'Seat is already BOOKED. Please choose another seat.', 1;

        -- Optional artificial delay to simulate concurrent user checkouts in Task 2
        IF @DelaySeconds <> '00:00:00'
            WAITFOR DELAY @DelaySeconds;

        -- 2. Insert the booking record
        INSERT INTO dbo.Bookings (FlightNo, SeatNo, PassengerName, FarePaid)
        VALUES (@FlightNo, @SeatNo, @PassengerName, @SeatFare);

        -- 3. Update seat status to BOOKED
        UPDATE dbo.FlightSeats
        SET SeatStatus = 'BOOKED'
        WHERE FlightNo = @FlightNo
          AND SeatNo   = @SeatNo;

        COMMIT TRANSACTION;
        PRINT CONCAT('SUCCESS: Seat ', @SeatNo, ' on ', @FlightNo, ' booked for ', @PassengerName, '.');
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        PRINT CONCAT('FAILED & ROLLED BACK (', @PassengerName, ') | Error ', ERROR_NUMBER(), ': ', ERROR_MESSAGE());
        THROW;
    END CATCH
END;
GO

-- Test Task 1 with a single valid booking
EXEC dbo.usp_BookAirlineSeat @FlightNo = 'AI-202', @SeatNo = '1A', @PassengerName = 'Karthik Subramanian';
SELECT * FROM dbo.FlightSeats WHERE FlightNo = 'AI-202' AND SeatNo = '1A';
SELECT * FROM dbo.Bookings;
GO

/* ============================================================================
   TASK 2: TWO-SESSION CONCURRENCY SIMULATION (READ COMMITTED vs. SERIALIZABLE)
   Open TWO separate query windows (Session 1 and Session 2) in SSMS/ADS.
   ============================================================================ */

-- ----------------------------------------------------------------------------
-- PART A: UNDER READ COMMITTED (Default Isolation Level)
-- Reset seat 12A first:
-- UPDATE dbo.FlightSeats SET SeatStatus = 'AVAILABLE' WHERE FlightNo = 'AI-202' AND SeatNo = '12A';
-- DELETE FROM dbo.Bookings WHERE FlightNo = 'AI-202' AND SeatNo = '12A';
-- ----------------------------------------------------------------------------

/* >>> RUN IN SESSION 1 (Window 1) FIRST: <<<
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN TRANSACTION;
    -- Step 1: Session 1 reads Seat 12A (acquires short Shared S-lock, releases immediately after SELECT)
    SELECT SeatStatus, Fare FROM dbo.FlightSeats WHERE FlightNo = 'AI-202' AND SeatNo = '12A';
    -- Sees 'AVAILABLE'!

    WAITFOR DELAY '00:00:08'; -- Pause 8 seconds while Session 2 also reads Seat 12A

    -- Step 3: Session 1 inserts booking and updates seat (acquires Exclusive X-lock)
    INSERT INTO dbo.Bookings (FlightNo, SeatNo, PassengerName, FarePaid)
    VALUES ('AI-202', '12A', 'Customer A (Session 1)', 6500.00);

    UPDATE dbo.FlightSeats SET SeatStatus = 'BOOKED' WHERE FlightNo = 'AI-202' AND SeatNo = '12A';
COMMIT TRANSACTION;
*/

/* >>> RUN IN SESSION 2 (Window 2) WITHIN 3 SECONDS OF STARTING SESSION 1: <<<
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN TRANSACTION;
    -- Step 2: Because Session 1 released its S-lock right after SELECT, Session 2 ALSO reads 'AVAILABLE'!
    SELECT SeatStatus, Fare FROM dbo.FlightSeats WHERE FlightNo = 'AI-202' AND SeatNo = '12A';

    -- Step 4: Session 2 attempts to insert & update -> blocks until Session 1 commits,
    -- THEN PROCEEDS AND OVERWRITES, creating a DOUBLE BOOKING!
    INSERT INTO dbo.Bookings (FlightNo, SeatNo, PassengerName, FarePaid)
    VALUES ('AI-202', '12A', 'Customer B (Session 2)', 6500.00);

    UPDATE dbo.FlightSeats SET SeatStatus = 'BOOKED' WHERE FlightNo = 'AI-202' AND SeatNo = '12A';
COMMIT TRANSACTION;
*/

-- Verify Double Booking anomaly after Part A:
-- SELECT * FROM dbo.Bookings WHERE FlightNo = 'AI-202' AND SeatNo = '12A'; -- Shows BOTH Customer A & Customer B!


-- ----------------------------------------------------------------------------
-- PART B: UNDER SERIALIZABLE ISOLATION LEVEL
-- Reset seat 12B first:
-- UPDATE dbo.FlightSeats SET SeatStatus = 'AVAILABLE' WHERE FlightNo = 'AI-202' AND SeatNo = '12B';
-- DELETE FROM dbo.Bookings WHERE FlightNo = 'AI-202' AND SeatNo = '12B';
-- ----------------------------------------------------------------------------

/* >>> RUN IN SESSION 1 (Window 1) FIRST: <<<
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN TRANSACTION;
    -- Step 1: Acquires Key-Range Shared lock (RangeS-S) and HOLDS it until COMMIT
    SELECT SeatStatus, Fare FROM dbo.FlightSeats WHERE FlightNo = 'AI-202' AND SeatNo = '12B';

    WAITFOR DELAY '00:00:08';

    -- Step 3: Tries to convert RangeS-S -> RangeX-X while Session 2 also holds RangeS-S
    INSERT INTO dbo.Bookings (FlightNo, SeatNo, PassengerName, FarePaid)
    VALUES ('AI-202', '12B', 'Customer A (Session 1)', 6500.00);

    UPDATE dbo.FlightSeats SET SeatStatus = 'BOOKED' WHERE FlightNo = 'AI-202' AND SeatNo = '12B';
COMMIT TRANSACTION;
*/

/* >>> RUN IN SESSION 2 (Window 2) WITHIN 3 SECONDS OF STARTING SESSION 1: <<<
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN TRANSACTION;
    -- Step 2: Both sessions can read under RangeS-S simultaneously
    SELECT SeatStatus, Fare FROM dbo.FlightSeats WHERE FlightNo = 'AI-202' AND SeatNo = '12B';

    -- Step 4: Both try to upgrade RangeS-S to Exclusive lock -> DEADLOCK (Error 1205)!
    -- SQL Server kills one session as deadlock victim and lets the other succeed cleanly.
    INSERT INTO dbo.Bookings (FlightNo, SeatNo, PassengerName, FarePaid)
    VALUES ('AI-202', '12B', 'Customer B (Session 2)', 6500.00);

    UPDATE dbo.FlightSeats SET SeatStatus = 'BOOKED' WHERE FlightNo = 'AI-202' AND SeatNo = '12B';
COMMIT TRANSACTION;
*/