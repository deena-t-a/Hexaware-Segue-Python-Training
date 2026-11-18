# Set 3: Hospital Patient Records and Clinical Notes

### Overview
This project module focuses on hospital visit normalisation, table modifications via `ALTER TABLE`, chronological date filtering, and semi-structured clinical document storage with JSON schema validation in MongoDB.

### File Manifest & Structure
- `schema.sql` - Implements 3NF hospital schema (`Patients`, `Departments`, `Doctors`, `Visits`, `VisitBilling`) with primary/foreign keys, date check constraints (`<= GETDATE()`), and default status values (`'Open'`).
- `alter_tests.sql` - Proves schema evolution using `ALTER TABLE ADD` for insurance fields, table renaming (`sp_rename`), and constraint dropping.
- `seed_data.sql` - Seeds test records and runs queries for monthly patient visits and department doctor listings using `JOIN` and `WHERE` clauses.
- `collections.js` - Sets up MongoDB 8.0 collection validation supporting variable clinical note structures and stores documents with differing shapes (e.g., prescription arrays vs. lab result objects).
- `ER_Diagram.pdf` - Visual Entity-Relationship diagram with documented design assumptions (1-to-Many patient visits, Many-to-1 doctor departments, and 1-to-1 visit billing).
- `README.md` - Project documentation and file guide.

### Technologies & Environment
- Microsoft SQL Server 2025 (v17) / SSMS 22
- MongoDB 8.0 / MongoDB Compass / mongosh