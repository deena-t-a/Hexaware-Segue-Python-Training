# Complexity and Data-Structure Rationale Note (Deliverable 3)
**Module:** Day 1 – Problem Solving Techniques and Data Structures (Set 1 – Retail Order Desk)  
**Technology Stack:** Python 3.10+

---

## Executive Summary
This document outlines the algorithmic complexity and data-structure choices for processing 50,000 daily retail orders. Every design decision balances time efficiency (sub-millisecond latency for live agents) with space optimization to ensure stable scaling under peak traffic.

---

## Task-by-Task Complexity & Architectural Rationale

### 1. Order Lookup (Linear Search vs. Binary Search)
* **Chosen Algorithm:** Binary Search (pre-sorted array by `orderId`)
* **Time Complexity:** $O(\log n)$ (Search) / $O(n \log n)$ (Initial Sort)
* **Space Complexity:** $O(1)$ auxiliary space
* **Business Rationale:** Support agents handling 50,000 daily orders require sub-millisecond retrieval. A Linear Search ($O(n)$) forces a scan across all records, causing severe latency spikes under high concurrency. Binary search halves the search space at each step, dropping 50,000 lookups from ~25,000 average operations down to a maximum of 16 comparisons.

### 2. Order Ranking / Sorting
* **Chosen Algorithm:** Timsort (Python's built-in `sorted()` / `.sort()`)
* **Time Complexity:** $O(n \log n)$ worst/average case, $O(n)$ best case
* **Space Complexity:** $O(n)$
* **Business Rationale:** Warehouse dispatch requires sorting 50,000 orders by amount instantly. A naive $O(n^2)$ Bubble Sort would take minutes for 50k items. Timsort (a hybrid merge and insertion sort) exploits pre-existing ordered slices (runs) in real-world retail data, making it optimal for production workloads.

### 3. Duplicate Order Detection
* **Chosen Algorithm / Structure:** Hash-Based Set (`set()`)
* **Time Complexity:** $O(n)$ total time ($O(1)$ per average lookup)
* **Space Complexity:** $O(n)$ to store unique minute-customer keys
* **Business Rationale:** Finance needs instant checks per incoming order against recent submissions to catch double-clicks or automated bot loops before payment capture. Hash sets provide average $O(1)$ time complexity for membership testing, outperforming nested loop comparisons ($O(n^2)$).

### 4. Undo Edit & Dispatch Line
* **Chosen Structures:** Stack (`list`) and Queue (`collections.deque`)
* **Time Complexity:** $O(1)$ push/pop (Stack) and $O(1)$ append/popleft (`deque`)
* **Space Complexity:** $O(n)$
* **Business Rationale:** 
  * **Stack:** Enforces Last-In, First-Out (LIFO) semantics for the 'undo last order edit' feature. Appending and popping from the end of a Python list occurs in amortized $O(1)$ time.
  * **Queue:** Enforces First-In, First-Out (FIFO) mechanics for the warehouse dispatch line. Using `collections.deque` avoids the $O(n)$ memory-shifting penalty inherent to standard list queues (`pop(0)`).

### 5. Refund Calculation (Greedy vs. Dynamic Programming)
* **Chosen Approaches:** Greedy Algorithm & Dynamic Programming (DP)
* **Time Complexity:** $O(n \log n)$ for Greedy; $O(\text{target} \times k)$ for DP ($k = \text{number of coin denominations}$)
* **Space Complexity:** $O(\text{target})$ for DP table
* **Business Rationale:** 
  * In standard currency systems (canonical coin sets like ₹10, ₹20, ₹50, ₹100), the Greedy approach is optimal and runs in linear time.
  * However, for non-canonical denomination sets (e.g., `[1, 4, 6]`), Greedy fails to find the global minimum (producing sub-optimal change counts). Dynamic Programming explores sub-problems bottom-up to guarantee absolute optimality across arbitrary refund rules.