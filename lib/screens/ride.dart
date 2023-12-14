import 'package:cloud_firestore/cloud_firestore.dart';

class Ride {
  final String rideId; // New field to store the ride ID
  final String name;
  final String startLocation;
  final String endLocation;
  final DateTime date;
  final String time;
  late int availableSeats;
  final String price;
  final String driverId;

  Ride({
    required this.rideId,
    required this.name,
    required this.startLocation,
    required this.endLocation,
    required this.date,
    required this.time,
    required this.availableSeats,
    required this.price,
    required this.driverId,
  });

  factory Ride.fromFirestore(String rideId, Map<String, dynamic> data) {
    return Ride(
      rideId: rideId,
      name: data['name'] ?? '',
      startLocation: data['start'] ?? '',
      endLocation: data['end'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      time: data['time'] ?? '',
      availableSeats: data['availableSeats'] ?? 0,
      price: data['price'] ?? '',
      driverId: data['driverId'] ?? '',
    );
  }
}
