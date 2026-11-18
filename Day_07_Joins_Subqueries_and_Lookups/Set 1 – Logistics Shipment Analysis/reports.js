use logistics_db;

// ---------------------------------------------------------------------
// PIPELINE 1: Shipments with their corresponding Delivery Events
// ---------------------------------------------------------------------
db.shipments.aggregate([
  {
    $lookup: {
      from: "delivery_events",
      localField: "tracking_number",
      foreignField: "tracking_number",
      as: "events"
    }
  },
  {
    $project: {
      tracking_number: 1,
      status: 1,
      origin_hub: 1,
      destination_hub: 1,
      events: 1
    }
  }
]);


// ---------------------------------------------------------------------
// PIPELINE 2: Customers with all their shipments
// ---------------------------------------------------------------------
db.customers.aggregate([
  {
    $lookup: {
      from: "shipments",
      localField: "customer_id",
      foreignField: "customer_id",
      as: "customer_shipments"
    }
  },
  {
    $project: {
      customer_name: 1,
      email: 1,
      total_shipments: { $size: "$customer_shipments" },
      customer_shipments: 1
    }
  }
]);


// ---------------------------------------------------------------------
// PIPELINE 3: Carriers with calculated delay statistics
// ---------------------------------------------------------------------
db.carriers.aggregate([
  {
    $lookup: {
      from: "shipments",
      localField: "carrier_id",
      foreignField: "carrier_id",
      as: "carrier_shipments"
    }
  },
  {
    $unwind: "$carrier_shipments"
  },
  {
    $addFields: {
      delay_days: {
        $divide: [
          { $subtract: ["$carrier_shipments.actual_delivery_date", "$carrier_shipments.estimated_delivery_date"] },
          1000 * 60 * 60 * 24
        ]
      }
    }
  },
  {
    $group: {
      _id: "$carrier_id",
      carrier_name: { $first: "$carrier_name" },
      total_shipments: { $sum: 1 },
      average_delay: { $avg: "$delay_days" }
    }
  }
]);


/*
------------------------------------------------------------------------
CONCEPT NOTE: When is Embedding Better than $lookup?
------------------------------------------------------------------------
1. Relationship Cardinality: Embedding works best for 1-to-few or bounded 1-to-many relationships (e.g., a shipment embedding a small array of status updates). $lookup is preferred for unbounded 1-to-many or many-to-many relationships (e.g., a customer with thousands of shipments).
2. Write Frequency: If child documents update frequently and independently (like individual delivery scan events), referencing via $lookup avoids document bloat and write performance overhead from moving large documents in disk storage.
3. Data Consistency & Atomic Updates: Embedding is ideal when data is read together and does not require independent transactional updates.
*/