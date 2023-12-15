// ignore_for_file: use_build_context_synchronously, avoid_print, library_private_types_in_public_api

import 'package:firebase_auth/firebase_auth.dart';

import '/screens/ride.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentPage extends StatefulWidget {
  final Ride ride;

  const PaymentPage({Key? key, required this.ride}) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String paymentOption = ''; // 'cash' or 'visa'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Details',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Payment Page',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Price: ${widget.ride.price}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            _buildPaymentOptions(),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.black),
              ),
              onPressed: () {
                if (paymentOption.isNotEmpty) {
                  _bookRide();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please choose a payment option.'),
                    ),
                  );
                }
              },
              child: const Text('Proceed to Pay',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              paymentOption = 'cash';
            });
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: paymentOption == 'cash' ? Colors.green : Colors.grey,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Column(
              children: [
                Icon(Icons.attach_money_outlined,
                    color: Colors.white, size: 30),
                SizedBox(height: 8),
                Text('Cash', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              paymentOption = 'visa';
            });
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: paymentOption == 'visa' ? Colors.blue : Colors.grey,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Column(
              children: [
                Icon(Icons.credit_card_outlined, color: Colors.white, size: 30),
                SizedBox(height: 8),
                Text('Visa', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _bookRide() async {
    try {
      // Access the Firestore instance
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Create a reference to the ride document
      DocumentReference rideReference =
          firestore.collection('rides').doc(widget.ride.rideId);

      // Create a reference to the booking document
      DocumentReference bookingReference = firestore
          .collection('bookings')
          .doc('${widget.ride.rideId}_${await getCurrentUserId()}');

      // Use a transaction to update the booking status and decrement available seats
      await firestore.runTransaction((transaction) async {
        // Get the current data of the ride
        DocumentSnapshot rideSnapshot = await transaction.get(rideReference);

        // Extract the current available seats
        int availableSeats = rideSnapshot['availableSeats'];

        // Check if there are available seats
        if (availableSeats > 0) {
          // Get the current data of the booking
          DocumentSnapshot bookingSnapshot =
              await transaction.get(bookingReference);

          // Extract the current status
          String? status = bookingSnapshot['status'];

          // Check if the booking status is 'accepted'
          if (status == 'accepted') {
            // Update the status to 'paid'
            transaction.update(bookingReference, {'status': 'paid'});

            // Decrement the available seats
            transaction
                .update(rideReference, {'availableSeats': availableSeats - 1});

            // Navigate to the appropriate screen
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
              (route) => false,
            );
          } else {
            // Handle the case where the booking status is not 'accepted'
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Booking status is not accepted.'),
              ),
            );
          }
        } else {
          // Handle the case where there are no available seats
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No available seats for this ride.'),
            ),
          );
        }
      });
    } catch (e) {
      // Handle Firestore or network errors
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Failed to update the booking status. Please try again.'),
        ),
      );
    }
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
