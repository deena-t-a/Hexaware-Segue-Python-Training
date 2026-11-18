use RetailInventoryDB;
switched to db RetailInventoryDB
db.createCollection("reviews", {
   validator: {
      $jsonSchema: {
         bsonType: "object",
         required: ["sku", "rating", "comment", "review_date"],
         properties: {
            sku: { bsonType: "string" },
            rating: { bsonType: "int", minimum: 1, maximum: 5 },
            comment: { bsonType: "string" },
            review_date: { bsonType: "date" }
         }
      }
   }
});
{ ok: 1 }
// 1. insertMany
db.reviews.insertMany([
  { sku: "SKU-101", rating: NumberInt(5), comment: "Very smooth mouse!", review_date: new Date() },
  { sku: "SKU-101", rating: NumberInt(4), comment: "Good battery life.", review_date: new Date() },
  { sku: "SKU-102", rating: NumberInt(5), comment: "Excellent fabric quality.", review_date: new Date() }
]);
{
  acknowledged: true,
  insertedIds: {
    '0': ObjectId('6afc327fcdbf24f2cf84c691'),
    '1': ObjectId('6afc327fcdbf24f2cf84c692'),
    '2': ObjectId('6afc327fcdbf24f2cf84c693')
  }
}
// 2. find
db.reviews.find({ sku: "SKU-101" }).pretty();
{
  _id: ObjectId('6afc327fcdbf24f2cf84c691'),
  sku: 'SKU-101',
  rating: 5,
  comment: 'Very smooth mouse!',
  review_date: ISODate('2026-11-17T10:54:55.948Z')
}
{
  _id: ObjectId('6afc327fcdbf24f2cf84c692'),
  sku: 'SKU-101',
  rating: 4,
  comment: 'Good battery life.',
  review_date: ISODate('2026-11-17T10:54:55.948Z')
}
// 3. updateOne
db.reviews.updateOne(
  { comment: "Very smooth mouse!" },
  { $set: { comment: "Extremely smooth and ergonomic mouse!" } }
);
{
  acknowledged: true,
  insertedId: null,
  matchedCount: 1,
  modifiedCount: 1,
  upsertedCount: 0
}
// 4. deleteOne
db.reviews.deleteOne({ comment: "Good battery life." });
{
  acknowledged: true,
  deletedCount: 1
}


