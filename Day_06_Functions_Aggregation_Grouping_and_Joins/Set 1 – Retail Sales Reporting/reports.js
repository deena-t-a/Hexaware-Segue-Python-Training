
db = db.getSiblingDB("retail_db");

// Sample data 
db.orders.drop();

db.orders.insertMany([
  {
    _id: 1, customer_id: 1, customer_name: "Arun Kumar", city: "Chennai",
    order_date: ISODate("2026-09-03"), status: "Delivered", order_total: 1297,
    items: [
      { product_id: 1, product_name: "Wireless Mouse", category: "Electronics", quantity: 1, unit_price: 799 },
      { product_id: 4, product_name: "Notebook Pack", category: "Stationery", quantity: 2, unit_price: 249 }
    ]
  },
  {
    _id: 2, customer_id: 2, customer_name: "Priya Nair", city: "Kochi",
    order_date: ISODate("2026-09-05"), status: "Delivered", order_total: 2499,
    items: [
      { product_id: 2, product_name: "Mechanical Keyboard", category: "Electronics", quantity: 1, unit_price: 2499 }
    ]
  },
  {
    _id: 3, customer_id: 3, customer_name: "Rahul Sharma", city: "Delhi",
    order_date: ISODate("2026-09-12"), status: "Delivered", order_total: 2246,
    items: [
      { product_id: 6, product_name: "Backpack", category: "Accessories", quantity: 1, unit_price: 1799 },
      { product_id: 5, product_name: "Gel Pen Set", category: "Stationery", quantity: 3, unit_price: 149 }
    ]
  },
  {
    _id: 4, customer_id: 1, customer_name: "Arun Kumar", city: "Chennai",
    order_date: ISODate("2026-09-18"), status: "Delivered", order_total: 2897,
    items: [
      { product_id: 3, product_name: "USB-C Hub", category: "Electronics", quantity: 1, unit_price: 1299 },
      { product_id: 1, product_name: "Wireless Mouse", category: "Electronics", quantity: 2, unit_price: 799 }
    ]
  },
  {
    _id: 5, customer_id: 4, customer_name: "Meena Iyer", city: "Chennai",
    order_date: ISODate("2026-09-25"), status: "Delivered", order_total: 1997,
    items: [
      { product_id: 8, product_name: "Desk Lamp", category: "Home", quantity: 1, unit_price: 999 },
      { product_id: 7, product_name: "Water Bottle", category: "Accessories", quantity: 2, unit_price: 499 }
    ]
  },
  {
    _id: 6, customer_id: 3, customer_name: "Rahul Sharma", city: "Delhi",
    order_date: ISODate("2026-10-02"), status: "Delivered", order_total: 3798,
    items: [
      { product_id: 2, product_name: "Mechanical Keyboard", category: "Electronics", quantity: 1, unit_price: 2499 },
      { product_id: 3, product_name: "USB-C Hub", category: "Electronics", quantity: 1, unit_price: 1299 }
    ]
  },
  {
    _id: 7, customer_id: 5, customer_name: "Karthik Raj", city: "Bengaluru",
    order_date: ISODate("2026-10-05"), status: "Delivered", order_total: 1841,
    items: [
      { product_id: 4, product_name: "Notebook Pack", category: "Stationery", quantity: 5, unit_price: 249 },
      { product_id: 5, product_name: "Gel Pen Set", category: "Stationery", quantity: 4, unit_price: 149 }
    ]
  },
  {
    _id: 8, customer_id: 1, customer_name: "Arun Kumar", city: "Chennai",
    order_date: ISODate("2026-10-09"), status: "Delivered", order_total: 2298,
    items: [
      { product_id: 6, product_name: "Backpack", category: "Accessories", quantity: 1, unit_price: 1799 },
      { product_id: 7, product_name: "Water Bottle", category: "Accessories", quantity: 1, unit_price: 499 }
    ]
  },
  {
    _id: 9, customer_id: 6, customer_name: "Sneha Reddy", city: "Hyderabad",
    order_date: ISODate("2026-10-09"), status: "Delivered", order_total: 1998,
    items: [
      { product_id: 8, product_name: "Desk Lamp", category: "Home", quantity: 2, unit_price: 999 }
    ]
  },
  {
    _id: 10, customer_id: 3, customer_name: "Rahul Sharma", city: "Delhi",
    order_date: ISODate("2026-10-15"), status: "Delivered", order_total: 4296,
    items: [
      { product_id: 1, product_name: "Wireless Mouse", category: "Electronics", quantity: 1, unit_price: 799 },
      { product_id: 2, product_name: "Mechanical Keyboard", category: "Electronics", quantity: 1, unit_price: 2499 },
      { product_id: 7, product_name: "Water Bottle", category: "Accessories", quantity: 2, unit_price: 499 }
    ]
  },
  {
    _id: 11, customer_id: 7, customer_name: "Vikram Singh", city: "Delhi",
    order_date: ISODate("2026-10-21"), status: "Delivered", order_total: 2598,
    items: [
      { product_id: 3, product_name: "USB-C Hub", category: "Electronics", quantity: 2, unit_price: 1299 }
    ]
  },
  {
    _id: 12, customer_id: 2, customer_name: "Priya Nair", city: "Kochi",
    order_date: ISODate("2026-10-28"), status: "Cancelled", order_total: 1799,
    items: [
      { product_id: 6, product_name: "Backpack", category: "Accessories", quantity: 1, unit_price: 1799 }
    ]
  },
  {
    _id: 13, customer_id: 1, customer_name: "Arun Kumar", city: "Chennai",
    order_date: ISODate("2026-11-02"), status: "Delivered", order_total: 3246,
    items: [
      { product_id: 2, product_name: "Mechanical Keyboard", category: "Electronics", quantity: 1, unit_price: 2499 },
      { product_id: 4, product_name: "Notebook Pack", category: "Stationery", quantity: 3, unit_price: 249 }
    ]
  },
  {
    _id: 14, customer_id: 4, customer_name: "Meena Iyer", city: "Chennai",
    order_date: ISODate("2026-11-04"), status: "Delivered", order_total: 1297,
    items: [
      { product_id: 8, product_name: "Desk Lamp", category: "Home", quantity: 1, unit_price: 999 },
      { product_id: 5, product_name: "Gel Pen Set", category: "Stationery", quantity: 2, unit_price: 149 }
    ]
  },
  {
    _id: 15, customer_id: 3, customer_name: "Rahul Sharma", city: "Delhi",
    order_date: ISODate("2026-11-04"), status: "Delivered", order_total: 2397,
    items: [
      { product_id: 1, product_name: "Wireless Mouse", category: "Electronics", quantity: 3, unit_price: 799 }
    ]
  },
  {
    _id: 16, customer_id: 6, customer_name: "Sneha Reddy", city: "Hyderabad",
    order_date: ISODate("2026-11-08"), status: "Pending", order_total: 3098,
    items: [
      { product_id: 6, product_name: "Backpack", category: "Accessories", quantity: 1, unit_price: 1799 },
      { product_id: 3, product_name: "USB-C Hub", category: "Electronics", quantity: 1, unit_price: 1299 }
    ]
  },
  {
    _id: 17, customer_id: 5, customer_name: "Karthik Raj", city: "Bengaluru",
    order_date: ISODate("2026-11-11"), status: "Delivered", order_total: 1795,
    items: [
      { product_id: 7, product_name: "Water Bottle", category: "Accessories", quantity: 3, unit_price: 499 },
      { product_id: 5, product_name: "Gel Pen Set", category: "Stationery", quantity: 2, unit_price: 149 }
    ]
  },
  {
    _id: 18, customer_id: 7, customer_name: "Vikram Singh", city: "Delhi",
    order_date: ISODate("2026-11-14"), status: "Shipped", order_total: 3298,
    items: [
      { product_id: 2, product_name: "Mechanical Keyboard", category: "Electronics", quantity: 1, unit_price: 2499 },
      { product_id: 1, product_name: "Wireless Mouse", category: "Electronics", quantity: 1, unit_price: 799 }
    ]
  }
]);

print("orders loaded: " + db.orders.countDocuments());


// ---------------------------------------------------------------------
// Pipeline 1 : Month-wise sales   (SQL Query 2)
// ---------------------------------------------------------------------
const monthWiseSales = [
  { $match: { status: { $ne: "Cancelled" } } },
  { $group: {
      _id: { $dateToString: { format: "%Y-%m", date: "$order_date" } },
      total_orders: { $sum: 1 },
      monthly_revenue: { $sum: "$order_total" }
  } },
  { $sort: { _id: 1 } }
];

print("\n--- Month-wise sales ---");
printjson(db.orders.aggregate(monthWiseSales).toArray());


// ---------------------------------------------------------------------
// Pipeline 2 : Top 5 products by revenue   (SQL Query 1)
// ---------------------------------------------------------------------
const topProducts = [
  { $match: { status: { $ne: "Cancelled" } } },
  { $unwind: "$items" },
  { $group: {
      _id: "$items.product_name",
      units_sold: { $sum: "$items.quantity" },
      total_revenue: { $sum: { $multiply: ["$items.quantity", "$items.unit_price"] } }
  } },
  { $sort: { total_revenue: -1, _id: 1 } },
  { $limit: 5 }
];

print("\n--- Top 5 products by revenue ---");
printjson(db.orders.aggregate(topProducts).toArray());


// ---------------------------------------------------------------------
// Pipeline 3 : Average basket value per city   (SQL Query 4)
// ---------------------------------------------------------------------
const avgBasketByCity = [
  { $match: { status: { $ne: "Cancelled" } } },
  { $group: {
      _id: "$city",
      orders: { $sum: 1 },
      avg_basket_value: { $avg: "$order_total" }
  } },
  { $sort: { avg_basket_value: -1, _id: 1 } },
  { $project: {
      _id: 0,
      city: "$_id",
      orders: 1,
      avg_basket_value: { $round: ["$avg_basket_value", 2] }
  } }
];

print("\n--- Average basket value per city ---");
printjson(db.orders.aggregate(avgBasketByCity).toArray());
