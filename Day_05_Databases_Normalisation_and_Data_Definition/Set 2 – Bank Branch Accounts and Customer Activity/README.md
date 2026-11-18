# Set 2: Bank Branch Accounts and Customer Activity

### Overview
This project module implements a normalized banking schema in SQL Server, compares DDL operations (`DROP`, `TRUNCATE`, `DELETE`), executes complex `WHERE` clause filters, and utilizes MongoDB capped collections for high-frequency customer activity logs.

### File Manifest & Structure
- `schema.sql` - Contains SQL Server DDL scripts for normalized 3NF tables (`Customers`, `Branches`, `Accounts`, `Transactions`), utilizing `IDENTITY(1001,1)` and balance check constraints (`>= 0`).
- `seed_data.sql` - Populates sample data and executes targeted queries using `BETWEEN`, `AND`, `OR`, and `IN` operators.
- `ddl_test.sql` - Demonstrates and contrasts the distinct behavioral differences between `DELETE`, `TRUNCATE`, and `DROP` on test tables.
- `collections.js` - Creates a MongoDB 8.0 capped collection for customer activity logging, inserts bulk login events, and retrieves the last 5 login sessions using sorting and limiting.
- `activity_logs_comparison.txt` - Technical note explaining the architectural rationale for choosing MongoDB over SQL Server for write-heavy activity logs.
- `ER_Diagram.pdf` - Visual Entity-Relationship diagram illustrating account-to-customer and branch mappings.
- `README.md` - Project documentation and file guide.

### Technologies & Environment
- Microsoft SQL Server 2025 (v17) / SSMS 22
- MongoDB 8.0 / MongoDB Compass / mongosh