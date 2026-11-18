# Insurance Policy Reporting

Management reports for a policy-administration team, built from policies, customers, premiums and claims.

## Files

| File | What it is |
|------|------------|
| `reports.sql` | Sample tables and data, then 8 report queries plus the policy age band / masked policy number query (SQL Server) |
| `reports.js` | Sample `claims_notes` data and 3 MongoDB aggregation pipelines |
| `output_documentation.txt` | Expected result for every query and pipeline, plus the WHERE vs HAVING explanation |

## Things to know

- The SQL reports use a fixed date (`DECLARE @today DATE = '2026-11-17'`) so the output always matches the documentation. Change it to `GETDATE()` to use the real date.
- Claim ratio = approved amount on settled claims / premium collected x 100.
- Age uses `DATEDIFF(YEAR, ...)`, so it is approximate (it counts calendar years).
- The MongoDB sample data is separate from the SQL data, so claim numbers do not line up between the two.
