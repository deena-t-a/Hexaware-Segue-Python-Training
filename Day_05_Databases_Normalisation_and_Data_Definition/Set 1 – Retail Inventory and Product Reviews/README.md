# Set 1: Retail Inventory and Product Reviews

### Overview
This project module covers database normalisation, DDL schema creation with constraints, data insertion with failure handling, DML updates/deletes, and NoSQL document validation using MongoDB 8.0 for a retail inventory system.

### File Manifest & Structure
- `schema.sql` - Contains SQL Server 2025 DDL scripts establishing 3NF tables (`Suppliers`, `Products`, `Warehouses`, `Inventory`), primary keys, foreign keys with cascade rules, and check constraints.
- `seed_data.sql` - Includes sample insert statements, seed data, and demonstrations of deliberately failing inserts (duplicate keys, missing parents, negative quantities, null violations). Also includes UPDATE and DELETE DML scripts.
- `collections.js` - Sets up MongoDB 8.0 collections with `$jsonSchema` validators for product reviews and includes standard CRUD operations (`insertMany`, `find`, `updateOne`, `deleteOne`).
- `ER_Diagram.pdf` - Visual Entity-Relationship diagram illustrating table relationships and constraints.
- `README.md` - Project documentation and file guide.

### Technologies & Environment
- Microsoft SQL Server 2025 (v17) / SSMS 22
- MongoDB 8.0 / MongoDB Compass / mongosh