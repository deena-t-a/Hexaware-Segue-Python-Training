use retail_returns_db;

// ---------------------------------------------------------------------
// PIPELINE 1: Returns combined with customer feedback and transaction info
// ---------------------------------------------------------------------
db.returns.aggregate([
  {
    $lookup: {
      from: "transactions",
      localField: "transaction_id",
      foreignField: "transaction_id",
      as: "transaction_details"
    }
  },
  { $unwind: "$transaction_details" },
  {
    $lookup: {
      from: "customers",
      localField: "transaction_details.customer_id",
      foreignField: "customer_id",
      as: "customer_info"
    }
  },
  { $unwind: "$customer_info" },
  {
    $project: {
      return_id: 1,
      reason: 1,
      return_date: 1,
      "customer_info.customer_name": 1,
      "transaction_details.sale_date": 1
    }
  }
]);


// ---------------------------------------------------------------------
// PIPELINE 2: Stores with their total processed refunds and return counts
// ---------------------------------------------------------------------
db.stores.aggregate([
  {
    $lookup: {
      from: "transactions",
      localField: "store_id",
      foreignField: "store_id",
      as: "store_transactions"
    }
  },
  { $unwind: "$store_transactions" },
  {
    $lookup: {
      from: "returns",
      localField: "store_transactions.transaction_id",
      foreignField: "transaction_id",
      as: "store_returns"
    }
  },
  { $unwind: "$store_returns" },
  {
    $group: {
      _id: "$store_id",
      store_name: { $first: "$store_name" },
      total_returns_processed: { $sum: 1 }
    }
  }
]);


// ---------------------------------------------------------------------
// PIPELINE 3: Products linked with return statistics and feedback summaries
// ---------------------------------------------------------------------
db.products.aggregate([
  {
    $lookup: {
      from: "transactions",
      localField: "product_id",
      foreignField: "product_id",
      as: "prod_sales"
    }
  },
  { $unwind: "$prod_sales" },
  {
    $lookup: {
      from: "returns",
      localField: "prod_sales.transaction_id",
      foreignField: "transaction_id",
      as: "prod_returns"
    }
  },
  { $unwind: "$prod_returns" },
  {
    $group: {
      _id: "$product_id",
      product_name: { $first: "$product_name" },
      category: { $first: "$category" },
      total_product_returns: { $sum: 1 }
    }
  },
  { $sort: { total_product_returns: -1 } }
]);