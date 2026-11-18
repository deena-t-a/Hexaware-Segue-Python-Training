USE HospitalDB;

-- 1. Use ALTER TABLE to add an 'insurance_id' column to Patients
ALTER TABLE Patients 
ADD insurance_id VARCHAR(50) NULL;

-- 2. Rename a table (Renaming Billing to VisitBilling)
EXEC sp_rename 'Billing', 'VisitBilling';

-- 3. Drop a constraint (Dropping the bill_amount check constraint to show DDL flexibility)
-- First, query sys.check_constraints to find the exact constraint name if auto-generated, or use the explicit one:
ALTER TABLE VisitBilling 
DROP CONSTRAINT CK__Billing__bill_am__3F466844;
