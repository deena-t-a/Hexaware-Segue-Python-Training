use BankDB;
switched to db BankDB

db.createCollection("customer_activity_logs", {
   capped: true,
   size: 65536, // 64 KB max size
   max: 100     // Maximum 100 documents
});
{ ok: 1 }
// Insert 20 documents of customer login events
for (let i = 1; i <= 20; i++) {
   db.customer_activity_logs.insertOne({
      customer_id: i,
      event: "LOGIN",
      ip_address: "192.168.1." + i,
      login_time: new Date()
   });
}
{
  acknowledged: true,
  insertedId: ObjectId('6afc432db52631f495742915')
}
// Query for the last 5 login events of a specific customer (e.g., customer_id: 5)
db.customer_activity_logs.find({ customer_id: 5 })
                         .sort({ login_time: -1 })
                         .limit(5);
{
  _id: ObjectId('6afc432db52631f495742906'),
  customer_id: 5,
  event: 'LOGIN',
  ip_address: '192.168.1.5',
  login_time: ISODate('2026-11-17T12:06:05.192Z')
}



