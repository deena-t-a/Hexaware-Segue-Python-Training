# Day 3 – Agile and Scrum Workshop (Set 3)
## Project: MediCare Connect – Hospital Appointment Booking Application

### Overview
This repository and accompanying documentation contain the foundational Agile artifacts, product vision, stakeholder-to-role mapping, prioritized product backlog, INVEST evaluations, Gherkin acceptance criteria, Planning Poker sizing, and operational Definition of Ready (DoR) / Definition of Done (DoD) checklists for **MediCare Connect** — a mobile healthcare platform for booking, rescheduling, and cancelling doctor appointments with automated notifications.

---

### Deliverables Included in this Submission

| File Name | Description |
| :--- | :--- |
| **`Jira_Board_Screenshot.pdf`** | Visual proof of the Jira Scrum board (`MediCare Connect`) showing active workflow columns (`TO DO`, `IN PROGRESS`, `IN REVIEW`, `DONE`), Epics, story point estimates, and MoSCoW priority labels. |
| **`DoR_And_DoD_Checklists.pdf`** | Standalone operational quality gates document defining the 6-item Definition of Ready (DoR) and 6-item Definition of Done (DoD) checklists. |

---

### Summary of Workshop Tasks Completed

1. **Product Vision & Stakeholder Mapping:** Established a clear product vision focused on eliminating appointment queues and mapped hospital stakeholders to Product Owner, Scrum Master, Developer, and Customer roles.
2. **Epics & User Stories:** Created 4 core epics (*Appointment Booking*, *Rescheduling and Cancellation*, *Reminders and Notifications*, *Doctor Schedule Management*) broken down into user stories in the `As a / I want / so that` format.
3. **INVEST Review & Refinement:** Evaluated all stories against the INVEST criteria, splitting tightly coupled booking and payment logic (`US-03`) into independent, testable vertical slices (`US-03A` and `US-03B`).
4. **Acceptance Criteria:** Authored `Given / When / Then` acceptance criteria for booking and cancellation flows, explicitly handling the concurrent *"slot already taken"* edge case.
5. **Prioritisation & Planning Poker:** Prioritised stories using Business Value vs. Effort (MoSCoW), sized them using Fibonacci Story Points, and documented the distinction between story points (relative complexity) and hours (absolute time).
6. **Jira Setup & Quality Checklists:** Published the backlog onto a Jira Scrum board and formalized 6-item Definition of Ready and Definition of Done checklists.

---

### Author & Execution Details
* **Assessment / Workshop:** Day 3 – Agile and Scrum Foundations and Backlog Workshop (Set 3)
* **Application Domain:** Healthcare / Outpatient Appointment Management
* **Tooling:** Jira Cloud, Markdown, PDF Documentation