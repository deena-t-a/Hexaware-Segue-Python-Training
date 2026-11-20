const dbName = "airline_booking_db";
const airlineDb = db.getSiblingDB(dbName);

airlineDb.flight_seats.drop();
airlineDb.bookings.drop();

airlineDb.flight_seats.insertMany([
  { _id: "AI-202_12A", flightNo: "AI-202", seatNo: "12A", seatClass: "ECONOMY", fare: 6500.0, status: "AVAILABLE" },
  { _id: "AI-202_1A",  flightNo: "AI-202", seatNo: "1A",  seatClass: "BUSINESS", fare: 18500.0, status: "AVAILABLE" }
]);

function bookSeatMongo(flightNo, seatNo, passengerName, simulateFailure = false) {
  const session = db.getMongo().startSession({
    readPreference: { mode: "primary" }
  });

  const sessionDb = session.getDatabase(dbName);
  const seatsCol = sessionDb.getCollection("flight_seats");
  const bookingsCol = sessionDb.getCollection("bookings");

  session.startTransaction({
    readConcern: { level: "snapshot" },
    writeConcern: { w: "majority" }
  });

  try {
    const updatedSeat = seatsCol.findOneAndUpdate(
      { flightNo: flightNo, seatNo: seatNo, status: "AVAILABLE" },
      { $set: { status: "BOOKED", bookedBy: passengerName, updatedAt: new Date() } },
      { returnDocument: "after" }
    );

    if (!updatedSeat) {
      throw new Error(`Seat ${seatNo} on flight ${flightNo} is either invalid or already BOOKED.`);
    }

    if (simulateFailure) {
      throw new Error("SIMULATED CRASH: Payment/Booking service failed after seat lock!");
    }

    const bookingDoc = {
      bookingRef: "PNR-" + Math.floor(100000 + Math.random() * 900000),
      flightNo: flightNo,
      seatNo: seatNo,
      passengerName: passengerName,
      farePaid: updatedSeat.fare,
      bookedAt: new Date()
    };

    bookingsCol.insertOne(bookingDoc);

    session.commitTransaction();
    print(`SUCCESS: Seat ${seatNo} (${flightNo}) booked for ${passengerName} | Ref: ${bookingDoc.bookingRef}`);
  } catch (err) {
    session.abortTransaction();
    print(`ABORTED & ROLLED BACK (${passengerName}): ${err.message}`);
  } finally {
    session.endSession();
  }
}

print("=== TEST 1: Valid Atomic Seat Booking (12A for Karthik) ===");
bookSeatMongo("AI-202", "12A", "Karthik Subramanian", false);

print("\n=== TEST 2: Duplicate Booking Attempt on Already-Booked Seat (12A for Ananya) ===");
bookSeatMongo("AI-202", "12A", "Ananya Deshmukh", false);

print("\n=== TEST 3: Simulated Failure Mid-Transaction on Seat 1A (Rolls Back Seat Status) ===");
bookSeatMongo("AI-202", "1A", "Vikram Rathore", true);

print("\n=== FINAL SEAT DOCUMENTS (12A is BOOKED, 1A remains AVAILABLE) ===");
printjson(airlineDb.flight_seats.find().toArray());

print("\n=== FINAL BOOKING DOCUMENTS (Only Karthik's booking exists) ===");
printjson(airlineDb.bookings.find().toArray());

//OUTPUT:

// === TEST 1: Valid Atomic Seat Booking (12A for Karthik) ===
// ABORTED & ROLLED BACK (Karthik Subramanian): This MongoDB deployment does not support retryable writes. Please add retryWrites=false to your connection string.

// === TEST 2: Duplicate Booking Attempt on Already-Booked Seat (12A for Ananya) ===
// ABORTED & ROLLED BACK (Ananya Deshmukh): This MongoDB deployment does not support retryable writes. Please add retryWrites=false to your connection string.

// === TEST 3: Simulated Failure Mid-Transaction on Seat 1A (Rolls Back Seat Status) ===
// ABORTED & ROLLED BACK (Vikram Rathore): This MongoDB deployment does not support retryable writes. Please add retryWrites=false to your connection string.

// === FINAL SEAT DOCUMENTS (12A is BOOKED, 1A remains AVAILABLE) ===
// [
//   {
//     _id: 'AI-202_12A',
//     flightNo: 'AI-202',
//     seatNo: '12A',
//     seatClass: 'ECONOMY',
//     fare: 6500,
//     status: 'AVAILABLE'
//   },
//   {
//     _id: 'AI-202_1A',
//     flightNo: 'AI-202',
//     seatNo: '1A',
//     seatClass: 'BUSINESS',
//     fare: 18500,
//     status: 'AVAILABLE'
//   }
// ]

// === FINAL BOOKING DOCUMENTS (Only Karthik's booking exists) ===
// []



