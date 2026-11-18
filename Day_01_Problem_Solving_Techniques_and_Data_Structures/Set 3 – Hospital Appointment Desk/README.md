# Hospital Appointment Desk – Day 1 Training Module

## Overview
This repository contains complete solutions for Day 1 (Problem Solving Techniques and Data Structures – Set 3: Hospital Appointment Desk). It covers search performance benchmarking, sorting comparisons, hash-based double-booking prevention, custom stack and queue structures, and interval scheduling.

---

## Complexity & Data-Structure Rationale Table

| Task / Operation | Chosen Algorithm / Data Structure | Best Case Time | Average Case Time | Worst Case Time | Space Complexity | Justification & Business Rationale |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **1. Patient Lookup** | **Binary Search** | $O(1)$ | $O(\log n)$ | $O(\log n)$ | $O(1)$ | Receptionists performing 1,000 look-ups across 20,000 patient records require sub-millisecond response times. Binary search limits worst-case lookups to 15 comparisons. |
| **2. Urgency Sorting** | **Quick Sort / Selection Sort** | $O(n \log n)$ | $O(n \log n)$ | $O(n^2)$ | $O(\log n)$ | Orders appointments by clinical urgency and arrival time; Quick Sort scales efficiently for large multi-speciality rosters. |
| **3. Double-Booking** | **Hash Set (`set`)** | $O(1)$ | $O(n)$ | $O(n)$ | $O(n)$ | A linear list scan ($O(n^2)$ for all bookings) is unacceptable at hospital volume. Hash sets provide $O(1)$ average checks to instantly block double-booked slots. |
| **4. Token Queue & Stack** | **Custom List Queue & Stack** | $O(1)$ | $O(1)$ | $O(n)$ (Queue pop) | $O(n)$ | Queue models FIFO walk-in tokens; Stack tracks LIFO 'recent patient charts viewed' history for clinicians. |
| **5. Shift Scheduling** | **Greedy Interval Scheduling** | $O(n \log n)$ | $O(n \log n)$ | $O(n \log n)$ | $O(1)$ | Maximizes the number of non-overlapping appointments a doctor can attend during a shift by greedily selecting slots ending earliest. |

---

## File Structure
* `hospital_appointment_desk.py`: Source code implementing all 5 tasks with test data.
* `README.md`: Project documentation and complexity justification table (Deliverable 3).