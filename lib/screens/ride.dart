class Ride {
  String name;
  String startLocation;
  String endLocation;
  DateTime date;
  String startTime;
  String reservationDeadline;
  int availableSeats;
  String price; // Added price attribute
  String status;

  Ride(
    this.name,
    this.startLocation,
    this.endLocation,
    this.date,
    this.startTime,
    this.reservationDeadline,
    this.availableSeats,
    this.price, // Added price parameter
    this.status,
  );
}

List<Ride> generateDummyRidesForUpcoming() {
  // Added price to dummy data
  return [
    Ride(
      'Morning Ride',
      'Abdu-Basha',
      'Gate 3',
      DateTime(2023, 11, 20),
      '7:30 am',
      '10:00 pm',
      5,
      "20",
      "completed", // Added price
    ),
  ];
}

List<Ride> generateDummyRidesForPrevious() {
  // Added price to dummy data
  return [
    Ride(
      'Morning Ride',
      'Abdu-Basha',
      'Gate 3',
      DateTime(2023, 11, 20),
      '7:30 am',
      '10:00 pm',
      5,
      "20",
      "completed", // Added price
    ),
    Ride(
        'Afternoon Ride',
        'Gate 3',
        'Abdu-Basha',
        DateTime(2023, 11, 21),
        '5:30 pm',
        '1:00 pm',
        3,
        "15", // Added price
        "Completed"),
    // Add more dummy rides as needed
    Ride(
        'Afternoon Ride',
        'Gate 3',
        'Abdu-Basha',
        DateTime(2023, 11, 21),
        '5:30 pm',
        '1:00 pm',
        3,
        "15", // Added price
        "Completed"),
    // Add more dummy rides as needed
  ];
}

List<Ride> generateDummyRidesForRide() {
  // Added price to dummy data
  return [
    Ride(
        'Afternoon Ride',
        'Campus',
        'Nasr City 1',
        DateTime.now().add(const Duration(days: 1)),
        '5:30 pm',
        '1:00 pm',
        5,
        "18",
        "available" // Added price
        ),
    Ride(
        'Afternoon Ride',
        'Campus',
        'Nasr City 1',
        DateTime.now().add(const Duration(days: 2)),
        '5:30 pm',
        '1:00 pm',
        1,
        "18", // Added price
        "available"),
    Ride(
        'Afternoon Ride',
        'Campus',
        'Nasr City 1',
        DateTime.now().add(const Duration(days: 3)),
        '5:30 pm',
        '1:00 pm',
        1,
        "18", // Added price
        "available"),
    Ride(
        'Afternoon Ride',
        'Campus',
        'Nasr City 1',
        DateTime.now().add(const Duration(days: 5)),
        '5:30 pm',
        '1:00 pm',
        1,
        "18", // Added price
        "available"),
    // Add more dummy rides as needed
  ];
}
