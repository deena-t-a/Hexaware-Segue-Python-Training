use bank_loan_db;

// ---------------------------------------------------------------------
// PIPELINE 1: Combine loan documents with customer information
// ---------------------------------------------------------------------
db.loans.aggregate([
  {
    $lookup: {
      from: "customers",
      localField: "customer_id",
      foreignField: "customer_id",
      as: "customer_details"
    }
  },
  { $unwind: "$customer_details" },
  {
    $project: {
      loan_id: 1,
      loan_amount: 1,
      branch_id: 1,
      "customer_details.customer_name": 1,
      "customer_details.email": 1
    }
  }
]);


// ---------------------------------------------------------------------
// PIPELINE 2: Combine loan documents with repayment history
// ---------------------------------------------------------------------
db.loans.aggregate([
  {
    $lookup: {
      from: "repayments",
      localField: "loan_id",
      foreignField: "loan_id",
      as: "repayment_history"
    }
  },
  {
    $project: {
      loan_id: 1,
      loan_amount: 1,
      total_repayments_logged: { $size: "$repayment_history" },
      repayment_history: 1
    }
  }
]);


// ---------------------------------------------------------------------
// PIPELINE 3: Return each loan along with its absolute last repayment
// ---------------------------------------------------------------------
db.loans.aggregate([
  {
    $lookup: {
      from: "repayments",
      localField: "loan_id",
      foreignField: "loan_id",
      as: "repayments"
    }
  },
  {
    $unwind: {
      path: "$repayments",
      preserveNullAndEmptyArrays: true
    }
  },
  { $sort: { "repayments.repayment_date": -1 } },
  {
    $group: {
      _id: "$loan_id",
      loan_amount: { $first: "$loan_amount" },
      customer_id: { $first: "$customer_id" },
      last_repayment: { $first: "$repayments" }
    }
  }
]);