db = db.getSiblingDB("insurance");

db.claims_notes.drop();

db.claims_notes.insertMany([
  { claim_no: "CLM-101", status: "Settled",      damage_category: "Collision",       reported_date: new Date("2026-03-10"), settled_date: new Date("2026-03-25"), note: "Rear-end collision, bumper replaced" },
  { claim_no: "CLM-102", status: "Settled",      damage_category: "Hospitalisation", reported_date: new Date("2026-05-02"), settled_date: new Date("2026-05-20"), note: "Three day stay, cashless approved" },
  { claim_no: "CLM-103", status: "Rejected",     damage_category: "Collision",       reported_date: new Date("2026-07-15"), settled_date: null,                   note: "Policy exclusion applied" },
  { claim_no: "CLM-104", status: "Settled",      damage_category: "Hospitalisation", reported_date: new Date("2026-02-01"), settled_date: new Date("2026-02-15"), note: "Surgery claim, documents verified" },
  { claim_no: "CLM-105", status: "Under Review", damage_category: "Theft",           reported_date: new Date("2026-10-20"), settled_date: null,                   note: "Waiting for police report" },
  { claim_no: "CLM-106", status: "Settled",      damage_category: "Collision",       reported_date: new Date("2026-09-05"), settled_date: new Date("2026-09-30"), note: "Side impact, surveyor report received" },
  { claim_no: "CLM-107", status: "Settled",      damage_category: "Water Damage",    reported_date: new Date("2026-08-01"), settled_date: new Date("2026-08-26"), note: "Pipe burst in kitchen" },
  { claim_no: "CLM-108", status: "Under Review", damage_category: "Collision",       reported_date: new Date("2026-11-02"), settled_date: null,                   note: "Photos requested from customer" },
  { claim_no: "CLM-109", status: "Settled",      damage_category: "Hospitalisation", reported_date: new Date("2026-04-10"), settled_date: new Date("2026-04-22"), note: "Day care procedure" },
  { claim_no: "CLM-110", status: "Rejected",     damage_category: "Water Damage",    reported_date: new Date("2026-06-12"), settled_date: null,                   note: "Reported after the policy period" }
]);


// -----------------------------------------------------
// Pipeline 1: Claims per status
// -----------------------------------------------------
print("Pipeline 1: Claims per status");
printjson(
  db.claims_notes.aggregate([
    { $group: { _id: "$status", claims: { $sum: 1 } } },
    { $sort: { claims: -1, _id: 1 } }
  ]).toArray()
);


// -----------------------------------------------------
// Pipeline 2: Average settlement time (in days)
// Only settled claims have a settled_date
// -----------------------------------------------------
print("Pipeline 2: Average settlement time");
printjson(
  db.claims_notes.aggregate([
    { $match: { status: "Settled" } },
    { $project: {
        days: { $dateDiff: { startDate: "$reported_date", endDate: "$settled_date", unit: "day" } }
    } },
    { $group: { _id: null, settled_claims: { $sum: 1 }, avg_days: { $avg: "$days" } } },
    { $project: { _id: 0, settled_claims: 1, avg_settlement_days: { $round: ["$avg_days", 2] } } }
  ]).toArray()
);


// -----------------------------------------------------
// Pipeline 3: Top three damage categories
// -----------------------------------------------------
print("Pipeline 3: Top three damage categories");
printjson(
  db.claims_notes.aggregate([
    { $group: { _id: "$damage_category", claims: { $sum: 1 } } },
    { $sort: { claims: -1, _id: 1 } },
    { $limit: 3 }
  ]).toArray()
);
