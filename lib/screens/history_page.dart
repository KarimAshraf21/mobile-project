// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking History'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('userId', isEqualTo: getCurrentUserId())
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          if (snapshot.hasError) {
            return const Text('Error fetching bookings');
          }

          List<Widget> bookingCards =
              _buildBookingCards(snapshot.data?.docs ?? []);

          return ListView(
            children: bookingCards.isNotEmpty
                ? bookingCards
                : [
                    const Center(
                      child: Text(
                        'No booking history available.',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
          );
        },
      ),
    );
  }

  List<Widget> _buildBookingCards(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> bookingDocs) {
    return bookingDocs.map((booking) {
      return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance
            .collection('rides')
            .doc(booking['rideId'])
            .get(),
        builder: (context, rideSnapshot) {
          if (rideSnapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          if (rideSnapshot.hasError) {
            return const Text('Error fetching ride details');
          }

          final rideData = rideSnapshot.data?.data();
          if (rideData == null) {
            return const SizedBox(); // Handle case where ride data is missing or invalid
          }

          return Card(
            elevation: 4.0,
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(rideData['name'] ?? 'Unnamed Ride'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('From', rideData['startLocation'], Colors.blue),
                  _buildInfoRow('To', rideData['endLocation'], Colors.red),
                  _buildInfoRow('Time', rideData['time'], Colors.orange),
                  _buildInfoRow(
                    'Status',
                    booking['status'],
                    Colors.green,
                  ), // Assuming 'status' is a valid field in the booking
                ],
              ),
            ),
          );
        },
      );
    }).toList();
  }

  Widget _buildInfoRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Row(
        children: [
          Icon(Icons.info, color: color),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Future<String?> getCurrentUserId() async {
    try {
      // Get the current authenticated user
      var user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        return user.uid;
      } else {
        return null;
      }
    } catch (e) {
      // Handle error, e.g., logging or throwing a custom exception
      print('Error getting current user ID: $e');
      return null;
    }
  }
}
