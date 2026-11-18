# Retail Banking Transaction Review – Day 1 Training Module

## Overview
This repository contains working Python solutions for Day 1 (Problem Solving Techniques and Data Structures – Set 2: Retail Banking Transaction Review). It covers search algorithms, sorting stability, hash-based duplicate detection, custom data structures (Stack & Queue), and divide-and-conquer optimization.

---
## Deliverable 3: Complexity & Justification Table

| Task / Operation | Chosen Algorithm / Data Structure | Best Case Time | Average Case Time | Worst Case Time | Space Complexity | Justification & Business Rationale |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **1. Transaction Lookup** | **Binary Search** | $O(1)$ | $O(\\log n)$ | $O(\\log n)$ | $O(1)$ | Auditors reviewing 100,000 daily transactions need sub-millisecond retrieval. Binary search bounds worst-case searches to 17 comparisons. |
| **2. Statement Sorting** | **Insertion Sort / Merge Sort** | $O(n)$ (Insertion) / $O(n \\log n)$ (Merge) | $O(n^2)$ / $O(n \\log n)$ | $O(n^2)$ / $O(n \\log n)$ | $O(1)$ / $O(n)$ | **Stability** matters when two transactions occur at the exact same millisecond; stable sorting preserves their original submission sequence. |
| **3. Duplicate Detection** | **Hash-Based Dictionary** | $O(1)$ | $O(n)$ | $O(n)$ | $O(n)$ | Instant $O(1)$ average-time lookups allow compliance systems to catch double postings within 60 seconds before settlement capture. |
| **4. Queue & Stack** | **Custom List-based Queue & Stack** | $O(1)$ | $O(1)$ | $O(n)$ (Queue pop) | $O(n)$ | Queue models FIFO manual-review backlogs; Stack implements LIFO 'reverse last adjustment' for auditors correcting ledger entries. |
| **5. Min/Max Extraction** | **Divide and Conquer** | $O(n)$ | $O(n)$ | $O(n)$ | $O(\\log n)$ (stack frames) | Recursively splits the daily file to locate extreme transaction amounts with fewer comparisons than iterative linear scans. |

---

## File Structure
* `retail_banking_review.py`: Python source code containing implementations for all 5 tasks.
* `console_output.txt`: Captured console execution results.
* `README.md`: Project overview and Deliverable 3 complexity table.