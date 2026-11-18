# Logistics Shipment Analysis – Day 7 Report

## Overview
This repository contains advanced SQL Server 2025 scripts and MongoDB 8.0 aggregation pipelines for analyzing logistics operations across hubs, carriers, customers, and delivery events.

## Repository Structure
* `advanced_reports.sql`: Contains 10 join queries, subqueries (`IN`, `EXISTS`, `ANY`, `ALL`), subquery-to-join rewrites, and nested ranking queries.
* `reports.js`: Contains MongoDB 8.0 aggregation pipelines utilizing `$lookup` stages and analytical notes.

## Join Types Chosen & Rationale
* **INNER JOIN**: Used when records must exist in both tables (e.g., matching shipments to carriers or customers).
* **LEFT JOIN**: Used to retain all records from the left table even if there are no matches in the right table (e.g., finding hubs with no outbound shipments, or listing all customers regardless of order history).
* **FULL OUTER JOIN**: Used for comprehensive audits and reconciliation where unmatched rows on either side need identification.
* **SELF JOIN**: Used for hierarchical data or intra-table comparisons (e.g., mapping employees to supervisors, or finding hub pairs in the same city).