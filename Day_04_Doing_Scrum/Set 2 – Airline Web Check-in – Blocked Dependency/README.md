# DAY 4 – DOING SCRUM – SPRINT SIMULATION

### Overview
--------------------------------------------------------------------------------
1. PACKAGE CONTENTS
--------------------------------------------------------------------------------
1. ImpedimentLog_Refinement_AsyncStandup.pdf
   - Complete simulation report containing all 6 tasks, tables, calculations,
     and embedded tool screenshots.

2. README.md
   - Guide to the submission structure, deliverable mapping, and scenario summary.

--------------------------------------------------------------------------------
2. DELIVERABLES & TASK MAPPING (INSIDE THE PDF)
--------------------------------------------------------------------------------
* Deliverable 1: Sprint Plan & Capacity Calculation (Tasks 1 & 2)
  - Team capacity math (6 members, 8 working days, 70% focus factor = 269 hrs).
  - Velocity-based commitment decision (33 Story Points).
  - Sprint Goal & Definition of Ready (DoR) verification for 6 stories.
  - [Includes Screenshot: Sprint Backlog & Committed Stories]

* Deliverable 2: Impediment Log & Removal Plan (Task 3)
  - Formal log entry (IMP-042) for the mid-sprint Payment Gateway sandbox outage.
  - Impact analysis, 3-tier escalation path, and Scrum Master mitigation plan
    (WireMock stub + feature flag fallback).
  - [Includes Screenshot: Blocked Ticket / Impediment Flag]

* Deliverable 3: Backlog Refinement Session (Task 4)
  - Review of Sprint N+1 top 5 candidate stories.
  - Splitting of oversized 13-point epic (WCI-201: Multi-Passenger Check-in)
    into WCI-201A (5 pts), WCI-201B (5 pts), and WCI-201C (3 pts).
  - [Includes Screenshot: Split Stories & Re-estimation in Backlog]

* Deliverable 4: Written Asynchronous Daily Stand-up (Task 6)
  - Day 5 async stand-up log across Bengaluru (IST) and London (GMT).
  - Structured comparison between written async and live synchronous stand-ups.
  - [Includes Screenshot: Distributed Team Stand-up Thread]

* Deliverable 5: Sprint Review Agenda & Demo Script (Task 5)
  - 60-minute time-boxed Sprint Review agenda.
  - Step-by-step live demonstration script mapped to Acceptance Criteria.
  - [Includes Screenshot: Sprint Board / Completed Increment]

--------------------------------------------------------------------------------
3. SCENARIO SUMMARY
--------------------------------------------------------------------------------
Mid-sprint, the third-party Payment Gateway sandbox became unavailable (503
Service Unavailable), blocking end-to-end testing of Paid Seat Upgrades
(WCI-103). The Scrum Master escalated the outage via the vendor TAM while the
team implemented an OpenAPI-compliant WireMock stub and a release feature flag
to protect the Sprint Goal and prevent release delays.
