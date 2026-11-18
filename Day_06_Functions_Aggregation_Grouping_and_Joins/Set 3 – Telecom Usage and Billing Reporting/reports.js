use TelecomDB;

// 1. Hourly Usage Pipeline
db.usage_events.aggregate([
  {
    $group: {
      _id: { $hour: "$event_timestamp" },
      total_usage: { $sum: "$data_volume_mb" }
    }
  },
  { $sort: { _id: 1 } }
]);

// 2. Average Session Length Pipeline
db.usage_events.aggregate([
  {
    $group: {
      _id: "$subscriber_id",
      avg_session_duration: { $avg: "$session_duration_mins" }
    }
  }
]);

// 3. Busiest Cell Tower Pipeline
db.usage_events.aggregate([
  {
    $group: {
      _id: "$cell_tower_id",
      total_connections: { $sum: 1 }
    }
  },
  { $sort: { total_connections: -1 } },
  { $limit: 1 }
]);