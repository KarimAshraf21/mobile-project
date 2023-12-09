import '/screens/ride.dart';
import 'package:flutter/material.dart';

class PaymentPage extends StatefulWidget {
  final Ride ride;

  const PaymentPage({Key? key, required this.ride}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String paymentOption = ''; // 'cash' or 'visa'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Details'),
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
              child: const Text('Proceed to Pay'),
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

  void _bookRide() {
    // Implement the logic to decrement available seats and book the ride
    setState(() {
      widget.ride.availableSeats--;
    });
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
      (route) => false, // Remove all existing routes from the stack
    );
  }
}
