# Logistics Network and Delivery Windows – Day 2 Set 3

## Overview
This repository contains production-ready Python implementations for Day 2 Set 3, covering Binary Search Trees, Hash-based duplicate scan detection, Graph algorithms (BFS shortest path and DFS reachability), Sliding Window window-average analytics, and Two-Pointer palindrome validation.

---

## Algorithm Choices & Explanation Note

| Task / Operation | Chosen Data Structure / Algorithm | Time Complexity | Space Complexity | Rationale & Justification |
| :--- | :--- | :--- | :--- | :--- |
| **1. Hub Code Lookup** | **Binary Search Tree (BST)** | $O(\log n)$ avg | $O(n)$ | Organizes hub codes hierarchically. Note: Inserting sorted inputs results in a skewed tree ($O(n)$ height), mitigated in production via self-balancing trees. |
| **2. Parcel Double-Scan** | **Hash Set / Map** | $O(1)$ avg | $O(n)$ | Provides instantaneous $O(1)$ membership checks to immediately flag parcels scanned twice at the exact same hub. |
| **3. Network Routing** | **Adjacency List with BFS & DFS** | $O(V + E)$ | $O(V + E)$ | BFS explores level-by-level to guarantee the shortest path (fewest hops) between hubs; DFS traverses deeply to verify network reachability from the central depot. |
| **4. Peak Window Sizing** | **Sliding Window Pattern** | $O(n)$ | $O(1)$ | Eliminates redundant calculations across overlapping 4-hour blocks to efficiently identify peak parcel throughput averages. |
| **5. Route Palindrome Check**| **Two-Pointer Technique** | $O(n)$ | $O(n)$ | Converges inward from both ends of the cleaned route string to validate palindromic symmetry in $O(1)$ auxiliary space. |

---

## File Structure
* `logistics_network.py`: Source code implementing all 5 tasks.
* `console_output.txt`: Captured test execution output.
* `README.md`: Project documentation and algorithm explanation note.