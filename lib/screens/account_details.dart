// ignore_for_file: file_names, unused_import, library_private_types_in_public_api

import 'package:flutter/material.dart';

class AccountManagementPage extends StatefulWidget {
  final String userName;

  const AccountManagementPage({Key? key, required this.userName})
      : super(key: key);

  @override
  _AccountManagementPageState createState() => _AccountManagementPageState();
}

class _AccountManagementPageState extends State<AccountManagementPage> {
  final String _phoneNumber = ''; // Add the user's phone number
  final String _password = ''; // Add the user's password

  // Assume you have functions to fetch and update user information from Firebase
  // Replace these functions with your actual implementation

  Future<void> _fetchUserInformation() async {
    // Fetch user information from Firebase or your authentication provider
    // Set _phoneNumber and _password with the user's actual data
  }

  Future<void> _updatePhoneNumber(String newPhoneNumber) async {
    // Update user's phone number in Firebase or your authentication provider
  }

  Future<void> _updatePassword(String newPassword) async {
    // Update user's password in Firebase or your authentication provider
  }

  @override
  void initState() {
    super.initState();
    _fetchUserInformation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: SizedBox(width: 50, child: Image.asset('assets/logo.png')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Username: ${widget.userName}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Text(
              'Phone Number: $_phoneNumber',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Implement logic to update phone number
                // This can navigate to a new screen or show a dialog
              },
              child: const Text('Update Phone Number'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Implement logic to update password
                // This can navigate to a new screen or show a dialog
              },
              child: const Text('Update Password'),
            ),
          ],
        ),
      ),
    );
  }
}
