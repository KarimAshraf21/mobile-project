// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '/screens/payment_page.dart';
import '/screens/ride.dart';

class BookingPage extends StatefulWidget {
  final Ride ride;

  const BookingPage({
    Key? key,
    required this.ride,
  }) : super(key: key);

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  late StreamSubscription<DocumentSnapshot> _bookingStatusSubscription;
  bool _bookingAccepted = false;

  @override
  void initState() {
    super.initState();
    _initBookingStatusListener();
  }

  @override
  void dispose() {
    _bookingStatusSubscription.cancel();
    super.dispose();
  }

  void _initBookingStatusListener() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    String? userId = await getCurrentUserId();

    if (userId != null) {
      DocumentReference bookingReference =
          firestore.collection('bookings').doc('${widget.ride.rideId}_$userId');

      _bookingStatusSubscription =
          bookingReference.snapshots().listen((DocumentSnapshot snapshot) {
        if (snapshot.exists) {
          String? status = snapshot['status'];

          if (status == 'accepted') {
            // Set the flag to true when booking is accepted
            setState(() {
              _bookingAccepted = true;
            });
          }
        }
      });
    }
  }

  void _bookRide() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      DocumentReference rideReference =
          firestore.collection('rides').doc(widget.ride.rideId);

      CollectionReference bookingsReference = firestore.collection('bookings');

      String? userId = await getCurrentUserId();
      if (userId != null) {
        DocumentReference bookingReference = bookingsReference.doc(
          '${widget.ride.rideId}_$userId',
        );

        // Check if there is an existing pending booking for the user
        DocumentSnapshot<Object?> existingBooking =
            await bookingReference.get();

        if (existingBooking.exists && existingBooking['status'] == 'pending') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('You already have a pending booking for this ride.'),
            ),
          );
        }
        if (existingBooking.exists && existingBooking['status'] == 'paid') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You already booked this ride and paid for it'),
            ),
          );
        } else {
          // Only update the ride's available seats if the booking is not pending
          await firestore.runTransaction((transaction) async {
            DocumentSnapshot rideSnapshot =
                await transaction.get(rideReference);

            int availableSeats = rideSnapshot['availableSeats'];

            if (availableSeats > 0) {
              await bookingReference.set({
                'rideId': widget.ride.rideId,
                'userId': userId,
                'status': 'pending',
              });

              print('Booking ID: ${bookingReference.id}');
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No available seats for this ride.'),
                ),
              );
            }
          });

          // After booking, check the status and set the flag if 'accepted'
          String bookingStatus = await _getBookingStatus(
              '${widget.ride.rideId}_${await getCurrentUserId()}');
          if (bookingStatus == 'accepted') {
            setState(() {
              _bookingAccepted = true;
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Booking is pending approval.'),
              ),
            );
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User ID is null.'),
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to book the ride. Please try again.'),
        ),
      );
    }
  }

  Future<String> _getBookingStatus(String bookingId) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      DocumentSnapshot bookingSnapshot =
          await firestore.collection('bookings').doc(bookingId).get();

      String? status = bookingSnapshot['status'];

      return status ?? 'pending';
    } catch (e) {
      print('Error: $e');
      return 'pending';
    }
  }

  Future<String?> getCurrentUserId() async {
    try {
      var user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        return user.uid;
      } else {
        return null;
      }
    } catch (e) {
      print('Error getting current user ID: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Ride Details',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
              Icons.directions_car, 'Name', "driverName", Colors.blue),
          _buildDetailRow(Icons.location_on, 'From', widget.ride.startLocation,
              Colors.blue),
          _buildDetailRow(
              Icons.location_on, 'To', widget.ride.endLocation, Colors.red),
          _buildDetailRow(
              Icons.access_time, 'Time', widget.ride.time, Colors.orange),
          _buildDetailRow(Icons.event_seat, 'Available seats',
              widget.ride.availableSeats.toString(), Colors.black),
          _buildDetailRow(
              Icons.attach_money, 'Price', widget.ride.price, Colors.green),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.black),
            ),
            onPressed: () {
              if (_bookingAccepted) {
                // Navigate to the payment page only if booking is accepted
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentPage(ride: widget.ride),
                  ),
                );
              } else {
                // Book the ride if not accepted
                _bookRide();
              }
            },
            child:
                const Text('Book Now', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
      IconData icon, String label, String value, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 8),
          Text(
            '$label: $value',
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
