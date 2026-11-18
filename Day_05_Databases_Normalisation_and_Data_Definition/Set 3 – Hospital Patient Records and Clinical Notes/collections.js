use HospitalDB;
switched to db HospitalDB

db.createCollection("clinical_notes", {
   validator: {
      $jsonSchema: {
         bsonType: "object",
         required: ["patient_id", "visit_id", "diagnosis", "visit_date"],
         properties: {
            patient_id: { bsonType: "int" },
            visit_id: { bsonType: "int" },
            diagnosis: { bsonType: "string" },
            visit_date: { bsonType: "date" },
            prescription: { bsonType: "array" },
            lab_results: { bsonType: "object" },
            doctor_remarks: { bsonType: "string" }
         }
      }
   }
});
{ ok: 1 }
// Document 1: Has prescription array
db.clinical_notes.insertOne({
   patient_id: 1,
   visit_id: 1,
   diagnosis: "Hypertension Stage 1",
   visit_date: new Date("2026-10-15"),
   prescription: ["Amlodipine 5mg", "Lifestyle modification"],
   doctor_remarks: "Patient advised low sodium diet."
});
{
  acknowledged: true,
  insertedId: ObjectId('6afc728c05239d850bdf7515')
}
// Document 2: Has lab_results object instead of a simple prescription array (Variable Schema)
db.clinical_notes.insertOne({
   patient_id: 2,
   visit_id: 2,
   diagnosis: "Migraine",
   visit_date: new Date("2026-10-20"),
   lab_results: { mri_scan: "Normal", blood_sugar: "98 mg/dL" },
   doctor_remarks: "Prescribed pain management therapy."
});
{
  acknowledged: true,
  insertedId: ObjectId('6afc729405239d850bdf7516')
}
// Query by diagnosis
db.clinical_notes.find({ diagnosis: "Hypertension Stage 1" }).pretty();
{
  _id: ObjectId('6afc728c05239d850bdf7515'),
  patient_id: 1,
  visit_id: 1,
  diagnosis: 'Hypertension Stage 1',
  visit_date: ISODate('2026-10-15T00:00:00.000Z'),
  prescription: [
    'Amlodipine 5mg',
    'Lifestyle modification'
  ],
  doctor_remarks: 'Patient advised low sodium diet.'
}