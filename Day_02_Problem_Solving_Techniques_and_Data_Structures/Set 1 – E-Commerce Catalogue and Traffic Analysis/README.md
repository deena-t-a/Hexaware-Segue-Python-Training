# E-Commerce Catalogue and Traffic Analysis – Day 2 Set 1

## Overview
This repository contains working Python solutions for Day 2 – Set 1, covering advanced data structures and algorithmic patterns:
* **Binary Search Tree (BST)** for product category hierarchies and traversals.
* **Hash Table with Chaining** vs. Built-in Dictionaries for SKUs.
* **Directed Graphs & Topological Sort (DFS)** for microservice deployment dependency resolution and cycle detection.
* **Sliding Window Pattern** for identifying peak 3-hour traffic windows from 24-hour telemetry.
* **Two-Pointer Technique** for efficient gift-card pair matching on sorted order values.

---

## Deliverable 3: Decision Table

| Problem / Business Scenario | Chosen Data Structure / Pattern | Time Complexity | Space Complexity | Reason & Justification |
| :--- | :--- | :--- | :--- | :--- |
| **1. Category Browsing & Search** | **Binary Search Tree (BST)** | $O(\log n)$ avg | $O(n)$ | Maintains categories in sorted order for efficient traversal (inorder, preorder, postorder) and rapid hierarchical lookups. |
| **2. Instant SKU Look-up** | **Hash Map / Dictionary** | $O(1)$ avg | $O(n)$ | Provides near-instantaneous average time lookups for 100,000 SKUs, outperforming linear list scans. Chaining resolves collisions. |
| **3. Microservice Deployment** | **Directed Graph & Topological Sort (DFS)** | $O(V + E)$ | $O(V + E)$ | Models service dependencies (cart → pricing → inventory) and detects circular deadlocks before infrastructure provisioning. |
| **4. Peak Traffic Sizing** | **Sliding Window Pattern** | $O(n)$ | $O(1)$ | Avoids redundant recomputations across overlapping intervals to efficiently pinpoint the busiest continuous 3-hour window in 24-hour telemetry. |
| **5. Gift-Card Value Matching** | **Two-Pointer Technique** | $O(n)$ | $O(1)$ | Operates on sorted order values by converging inward from both ends, replacing inefficient $O(n^2)$ nested loops. |

---

## Repository Structure
* `ecommerce_catalogue.py`: Python source code implementing all 5 tasks.
* `console_output.txt`: Captured console execution results.
* `README.md`: Project documentation and Deliverable 3 decision table.