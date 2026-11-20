const dbName = "retail_inventory_db";
const retailDb = db.getSiblingDB(dbName);

retailDb.products.drop();
retailDb.orders.drop();

retailDb.products.insertMany([
  { _id: 101, name: "Mechanical Keyboard", category: "Electronics", price: 4500.0, stockQty: 15, reservedQty: 0 },
  { _id: 103, name: "27-Inch 4K Monitor",  category: "Electronics", price: 28000.0, stockQty: 5, reservedQty: 0 }
]);

// ============================================================================
// PART 1: SINGLE-DOCUMENT ATOMIC UPDATE USING $inc (NO TRANSACTION NEEDED)
// ============================================================================
function reserveSingleProductAtomic(productId, qty) {
  // MongoDB guarantees single-document write atomicity.
  // Filtering on { stockQty: { $gte: qty } } inside updateOne prevents negative stock
  // even under heavy concurrent checkout traffic.
  const res = retailDb.products.updateOne(
    { _id: productId, stockQty: { $gte: qty } },
    {
      $inc: {
        stockQty: -qty,
        reservedQty: qty
      },
      $set: { lastUpdated: new Date() }
    }
  );

  if (res.modifiedCount === 1) {
    print(`SUCCESS (Atomic $inc): Reserved ${qty} units of Product ${productId}.`);
    return true;
  } else {
    print(`REJECTED (Atomic $inc): Insufficient stock for Product ${productId} (requested ${qty}).`);
    return false;
  }
}

function releaseSingleProductAtomic(productId, qty) {
  const res = retailDb.products.updateOne(
    { _id: productId, reservedQty: { $gte: qty } },
    {
      $inc: {
        stockQty: qty,
        reservedQty: -qty
      },
      $set: { lastUpdated: new Date() }
    }
  );

  if (res.modifiedCount === 1) {
    print(`RELEASED (Atomic $inc): Returned ${qty} units back to stock for Product ${productId}.`);
  }
}

print("=== PART 1: SINGLE-DOCUMENT ATOMIC $inc TESTS ===");
// 1. Reserve 3 units of Product 101 (15 -> 12)
reserveSingleProductAtomic(101, 3);

// 2. Attempt to reserve 20 units of Product 101 (Rejected atomically; stock stays 12)
reserveSingleProductAtomic(101, 20);

// 3. Payment fails -> Release the 3 reserved units back to available stock (12 -> 15)
releaseSingleProductAtomic(101, 3);

printjson(retailDb.products.find({ _id: 101 }).toArray());

// ============================================================================
// PART 2: MULTI-DOCUMENT TRANSACTION (MULTI-ITEM ORDER + INVENTORY)
// Required when updating multiple product documents AND inserting an order doc.
// ============================================================================
print("\n=== PART 2: MULTI-DOCUMENT TRANSACTION FOR MULTI-ITEM ORDER ===");

function placeMultiItemOrderTxn(customerName, items, simulatePaymentFail = false) {
  const session = db.getMongo().startSession();
  const sDb = session.getDatabase(dbName);

  session.startTransaction({
    readConcern: { level: "snapshot" },
    writeConcern: { w: "majority" }
  });

  try {
    let totalAmount = 0;

    for (const item of items) {
      const updatedProd = sDb.products.findOneAndUpdate(
        { _id: item.productId, stockQty: { $gte: item.qty } },
        { $inc: { stockQty: -item.qty } },
        { returnDocument: "after" }
      );

      if (!updatedProd) {
        throw new Error(`Insufficient stock for ProductID ${item.productId}`);
      }
      totalAmount += updatedProd.price * item.qty;
    }

    sDb.orders.insertOne({
      customerName: customerName,
      items: items,
      totalAmount: totalAmount,
      status: "CONFIRMED",
      createdAt: new Date()
    });

    if (simulatePaymentFail) {
      throw new Error("Payment authorization failed! Aborting multi-document transaction.");
    }

    session.commitTransaction();
    print(`SUCCESS (Multi-Doc Txn): Order placed for ${customerName} | Total: ${totalAmount}`);
  } catch (err) {
    session.abortTransaction();
    print(`ROLLED BACK (Multi-Doc Txn): ${err.message}`);
  } finally {
    session.endSession();
  }
}

placeMultiItemOrderTxn("Rohan Mehta", [{ productId: 101, qty: 2 }, { productId: 103, qty: 1 }], true);

print("Final Products State (101 = 15, 103 = 5):");
printjson(retailDb.products.find().toArray());

// OUTPUT:

// === PART 1: SINGLE-DOCUMENT ATOMIC $inc TESTS ===
// SUCCESS (Atomic $inc): Reserved 3 units of Product 101.
// REJECTED (Atomic $inc): Insufficient stock for Product 101 (requested 20).
// RELEASED (Atomic $inc): Returned 3 units back to stock for Product 101.
// [
//   {
//     _id: 101,
//     name: 'Mechanical Keyboard',
//     category: 'Electronics',
//     price: 4500,
//     stockQty: 15,
//     reservedQty: 0,
//     lastUpdated: 2026-11-19T07:20:45.046Z
//   }
// ]

// === PART 2: MULTI-DOCUMENT TRANSACTION FOR MULTI-ITEM ORDER ===
// ROLLED BACK (Multi-Doc Txn): This MongoDB deployment does not support retryable writes. Please add retryWrites=false to your connection string.
// Final Products State (101 = 15, 103 = 5):
// [
//   {
//     _id: 101,
//     name: 'Mechanical Keyboard',
//     category: 'Electronics',
//     price: 4500,
//     stockQty: 15,
//     reservedQty: 0,
//     lastUpdated: 2026-11-19T07:20:45.046Z
//   },
//   {
//     _id: 103,
//     name: '27-Inch 4K Monitor',
//     category: 'Electronics',
//     price: 28000,
//     stockQty: 5,
//     reservedQty: 0
//   }
// ]



