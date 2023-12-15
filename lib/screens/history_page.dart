// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<String?>(
        stream: getCurrentUserIdStream(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (userSnapshot.hasError) {
            return const Text('Error getting user ID');
          }

          final userId = userSnapshot.data;

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: userId != null
                ? FirebaseFirestore.instance
                    .collection('bookings')
                    .where('userId', isEqualTo: userId)
                    .snapshots()
                : const Stream.empty(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Text('Error fetching bookings');
              }

              final bookingDocs = snapshot.data?.docs ?? [];

              return FutureBuilder<List<Map<String, dynamic>>>(
                future: _getRidesForBookings(bookingDocs),
                builder: (context, rideSnapshot) {
                  if (rideSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (rideSnapshot.hasError) {
                    return const Center(child: Text('No bookings'));
                  }

                  final groupedRides = _groupRidesByDate(rideSnapshot.data!);

                  return FutureBuilder<List<String>>(
                    future: _getBookingStatusList(bookingDocs),
                    builder: (context, statusSnapshot) {
                      if (statusSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (statusSnapshot.hasError) {
                        return const Text('Error fetching booking statuses');
                      }

                      final bookingStatuses = statusSnapshot.data ?? [];

                      return ListView.builder(
                        itemCount: groupedRides.length,
                        itemBuilder: (context, index) {
                          final group = groupedRides[index];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  group['date'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              ..._buildBookingCards(
                                group['rides'],
                                bookingStatuses,
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _getRidesForBookings(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> bookingDocs) async {
    final rideFutures = bookingDocs.map((booking) async {
      final rideId = booking['rideId'];
      final rideDoc = await FirebaseFirestore.instance
          .collection('rides')
          .doc(rideId)
          .get();

      return rideDoc.data()!;
    });

    return Future.wait(rideFutures);
  }

  Future<List<String>> _getBookingStatusList(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> bookingDocs) async {
    final statusFutures = bookingDocs.map((booking) async {
      final status = booking['status'] ?? 'Unknown Status';
      return status.toString();
    });

    return Future.wait(statusFutures);
  }

  List<Map<String, dynamic>> _groupRidesByDate(
      List<Map<String, dynamic>> rides) {
    rides.sort((a, b) {
      final DateTime dateA = a['date'].toDate();
      final DateTime dateB = b['date'].toDate();
      return dateB.compareTo(dateA); // Compare in descending order
    });

    final groupedRides = <String, List<Map<String, dynamic>>>{};

    for (final ride in rides) {
      final date = _formatTimestamp(ride['date']);
      if (!groupedRides.containsKey(date)) {
        groupedRides[date] = [];
      }
      groupedRides[date]!.add(ride);
    }

    return groupedRides.entries
        .map((entry) => {'date': entry.key, 'rides': entry.value})
        .toList();
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp != null) {
      // Format timestamp into a readable string
      final dateTime = timestamp.toDate();
      final formattedDate = DateFormat('dd-MM-yyyy').format(dateTime);
      return formattedDate;
    } else {
      return 'Unknown';
    }
  }

  Widget _buildBookingCard(
      Map<String, dynamic> rideData, String bookingStatus) {
    return Card(
      color: Colors.white,
      elevation: 4.0,
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('From', rideData['start'] ?? '', Icons.location_on,
                Colors.blue),
            _buildInfoRow(
                'To', rideData['end'] ?? '', Icons.location_on, Colors.red),
            _buildInfoRow('Time', rideData['time'] ?? '', Icons.access_time,
                Colors.orange),
            _buildInfoRow('Price', rideData['price'] ?? '', Icons.attach_money,
                Colors.green),
            _buildInfoRow(
              'Status',
              bookingStatus,
              Icons.info,
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBookingCards(
      List<Map<String, dynamic>> rides, List<String> bookingStatuses) {
    return List.generate(
      rides.length,
      (index) => _buildBookingCard(rides[index], bookingStatuses[index]),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color),
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

  Stream<String?> getCurrentUserIdStream() async* {
    try {
      // Get the current authenticated user
      var user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        yield user.uid;
      } else {
        yield null;
      }
    } catch (e) {
      // Handle error, e.g., logging or throwing a custom exception
      print('Error getting current user ID: $e');
      yield null;
    }
  }
}
