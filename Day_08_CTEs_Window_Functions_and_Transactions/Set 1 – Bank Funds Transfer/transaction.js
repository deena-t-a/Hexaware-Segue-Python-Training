const dbName = "core_banking";
const bankDb = db.getSiblingDB(dbName);

bankDb.accounts.drop();
bankDb.transaction_ledger.drop();

bankDb.accounts.insertMany([
  { _id: 1001, holder: "Aarav Sharma", status: "ACTIVE", balance: 5000.0 },
  { _id: 1002, holder: "Meera Nair", status: "ACTIVE", balance: 2000.0 },
  { _id: 1003, holder: "Rohan Verma", status: "FROZEN", balance: 3500.0 }
]);

function transferFunds(fromId, toId, amount, simulateCrash) {
  const session = db.getMongo().startSession();
  const sDb = session.getDatabase(dbName);

  session.startTransaction({
    readConcern: { level: "snapshot" },
    writeConcern: { w: "majority" }
  });

  try {
    const fromAcc = sDb.accounts.findOne({ _id: fromId });
    const toAcc = sDb.accounts.findOne({ _id: toId });

    if (!fromAcc || fromAcc.status !== "ACTIVE") throw new Error("Source account invalid or inactive.");
    if (!toAcc || toAcc.status !== "ACTIVE") throw new Error("Destination account invalid or inactive.");
    if (fromAcc.balance < amount) throw new Error("Insufficient funds.");

    // Debit
    sDb.accounts.updateOne({ _id: fromId }, { $inc: { balance: -amount } });
    sDb.transaction_ledger.insertOne({
      accountId: fromId, txnType: "DEBIT", amount: -amount,
      balanceAfter: fromAcc.balance - amount, timestamp: new Date()
    });

    if (simulateCrash) {
      throw new Error("SIMULATED CRASH after debiting source account!");
    }

    // Credit
    sDb.accounts.updateOne({ _id: toId }, { $inc: { balance: amount } });
    sDb.transaction_ledger.insertOne({
      accountId: toId, txnType: "CREDIT", amount: amount,
      balanceAfter: toAcc.balance + amount, timestamp: new Date()
    });

    session.commitTransaction();
    print(`SUCCESS: Transferred ${amount} from ${fromId} to ${toId}`);
  } catch (error) {
    session.abortTransaction();
    print(`ROLLED BACK: ${error.message}`);
  } finally {
    session.endSession();
  }
}

transferFunds(1001, 1002, 1000.0, false);

transferFunds(1001, 1002, 1500.0, true);

printjson(bankDb.accounts.find().toArray());

// OUTPUT:

// ROLLED BACK: Transaction numbers are only allowed on a replica set member or mongos
// ROLLED BACK: Transaction numbers are only allowed on a replica set member or mongos
// [
//   { _id: 1001, holder: 'Aarav Sharma', status: 'ACTIVE', balance: 5000 },
//   { _id: 1002, holder: 'Meera Nair', status: 'ACTIVE', balance: 2000 },
//   { _id: 1003, holder: 'Rohan Verma', status: 'FROZEN', balance: 3500 }
// ]



