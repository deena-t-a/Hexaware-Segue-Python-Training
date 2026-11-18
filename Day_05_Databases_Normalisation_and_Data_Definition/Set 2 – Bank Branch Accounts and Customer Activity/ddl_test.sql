USE BankDB;

-- Create a temporary test table
CREATE TABLE TestLog (
    log_id INT IDENTITY(1,1) PRIMARY KEY,
    message VARCHAR(100)
);

-- Insert dummy data
INSERT INTO TestLog (message) VALUES ('Log 1'), ('Log 2'), ('Log 3');

-- 1. DELETE: Removes rows conditionally; keeps identity seed going forward; can be rolled back.
BEGIN TRANSACTION;
DELETE FROM TestLog WHERE log_id = 1;
SELECT * FROM TestLog; -- Log 1 is gone
ROLLBACK; -- Reverts the delete

-- 2. TRUNCATE: Empties the entire table instantly, resets IDENTITY seed back to 1, faster, minimal logging.
TRUNCATE TABLE TestLog;
-- Checking reset identity:
INSERT INTO TestLog (message) VALUES ('New Log 1');
SELECT * FROM TestLog; -- log_id will start back at 1!

-- 3. DROP: Completely destroys the table structure and data from the database.
DROP TABLE TestLog;
