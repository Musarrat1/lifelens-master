class Event {
  String name;
  DateTime date;
  String id; // Add id field to store Firestore document ID

  // Constructor with name, date, and id
  Event(this.name, this.date, this.id);
}
