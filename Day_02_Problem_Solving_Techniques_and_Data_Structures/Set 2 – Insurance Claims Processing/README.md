# Insurance Claims Processing – Day 2 Set 2

## Overview
This repository contains complete Python solutions for Day 2 Set 2, covering Binary Search Trees, Hash-based near-duplicate detection, Workflow Graphs (BFS/DFS), Sliding Window spike analysis, and Two-Pointer list merging.

---

## Complexity Table

| Task / Operation | Chosen Data Structure / Algorithm | Time Complexity | Space Complexity | Justification & Business Rationale |
| :--- | :--- | :--- | :--- | :--- |
| **1. Claim ID Lookup & BST** | **Binary Search Tree** | $O(\log n)$ avg ($O(n)$ worst) | $O(n)$ | Inorder traversal outputs claims in sorted order for hierarchical reporting and quick node traversal. |
| **2. Near-Duplicate Detection** | **Hash Map / Dictionary** | $O(n)$ | $O(n)$ | Normalizes string formatting (case/spacing) and checks submissions in average $O(1)$ time per claim. |
| **3. Workflow Shortest Path / Cycles**| **Directed Graph (BFS & DFS)** | $O(V + E)$ | $O(V + E)$ | BFS finds the shortest approval route across stages; DFS detects accidental circular feedback loops in claims routing. |
| **4. Spike Run Analysis** | **Sliding Window** | $O(n)$ | $O(1)$ | Efficiently computes the longest consecutive streak of regional claim spikes exceeding 100 claims per day. |
| **5. Regional List Merging** | **Two-Pointer Technique** | $O(n + m)$ | $O(n + m)$ | Merges two pre-sorted regional claim lists in linear time without requiring an expensive secondary sort. |

---

## File Structure
* `insurance_claims_processing.py`: Python source code implementing all 5 tasks.
* `console_output.txt`: Captured test execution results.
* `README.md`: Project documentation and complexity table.