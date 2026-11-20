# MongoDB 8.0: Single-Document Atomic Updates vs. Multi-Document Transactions (Task 5)

## 1. Core Architectural Rule in MongoDB
In MongoDB 8.0, **every write operation on a single document is guaranteed to be ACID-atomic**—even when updating multiple fields, nested sub-documents, or array elements simultaneously. Therefore, multi-document transactions are **only** required when an invariant spans **two or more separate documents** (either in the same collection or across different collections).

---

## 2. Comparison for Retail Inventory Reservation

| Scenario | Recommended Mechanism | Why? |
| :--- | :--- | :--- |
| **Single-Item Stock Reserve / Release** *(e.g., decrementing `stockQty` and incrementing `reservedQty` on one `products` document, or embedding a `reservations[]` array inside that product document)* | **Single-Document Atomic Update (`updateOne` + `$inc`)** | Because both `stockQty` and `reservedQty` (or an embedded `reservations` sub-document) live inside **one** `products` document, `{ _id: 101, stockQty: { $gte: qty } }` combined with `$inc` executes atomically at the WiredTiger document level with **zero transaction coordination overhead**, no `WriteConflict` retries, and lower latency. |
| **Multi-Item Shopping Cart Checkout** *(e.g., decrementing stock across 3 different `products` documents AND inserting a separate `orders` document)* | **Multi-Document ACID Transaction (`startTransaction`)** | The operation modifies multiple distinct documents across `products` and `orders`. If the 3rd product is out of stock or payment fails, a multi-document transaction is mandatory so the 1st and 2nd product decrements roll back cleanly and no orphan order is created. |
| **Order Document + Embedded Line Items** *(without touching `products`)* | **Single-Document Atomic Write (`insertOne`)** | Because `orderLines` are embedded as an array inside the single `orders` document (unlike normalized SQL `Orders` + `OrderLines` tables), inserting the entire order is natively atomic without a transaction. |

---

## 3. Summary Best Practice
1. **Design schema first:** Embed tightly coupled child records (such as `orderLines` inside `orders`, or active `reservations` inside `products`) so 80–90% of operations execute as fast, single-document atomic updates using `$inc` and `$push`.
2. **Use multi-document transactions selectively:** Reserve `session.startTransaction()` for cross-aggregate invariants (such as multi-SKU inventory deduction paired with order creation) where partial failure would leave inventory counts out of sync with confirmed orders.