import '/screens/payment_page.dart';
import '/screens/ride.dart';
import 'package:flutter/material.dart';

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
              // Implement logic to book the ride
              // You can add more functionality here, such as handling payment, etc.
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PaymentPage(ride: widget.ride)),
              );
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
