import 'package:cloud_firestore/cloud_firestore.dart';

class Ride {
  final String name;
  final String startLocation;
  final String endLocation;
  final DateTime date;
  final String time;
  late int availableSeats;
  final String price;
  final String driverId; // Assuming driverId is a field in your Ride model

  Ride({
    required this.name,
    required this.startLocation,
    required this.endLocation,
    required this.date,
    required this.time,
    required this.availableSeats,
    required this.price,
    required this.driverId,
  });

  factory Ride.fromFirestore(Map<String, dynamic> data) {
    return Ride(
      name: data['name'] ?? '',
      startLocation: data['start'] ?? '',
      endLocation: data['end'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      time: data['time'] ?? '',
      availableSeats: data['availableSeats'] ?? 0,
      price: data['price'] ?? '',
      driverId:
          data['driverId'] ?? '', // Assuming 'driverId' is the correct field
    );
  }
}
