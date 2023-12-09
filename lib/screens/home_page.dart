// ignore_for_file: file_names, unused_import

import '/screens/profile_page.dart';
import '/screens/ride_page.dart';
import '/screens/trips_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  // List of pages corresponding to each tab
  final List<Widget> _pages = [
    const RidePage(),
    const TripsPage(),
    const ProfilePage(
      userName: "Karim Shalaby",
      userImageAsset: "assets/image.JPG",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar:
          _currentIndex == 0 ? buildBookingPageAppBar() : buildStandardAppBar(),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.local_taxi),
            label: "Ride",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Trips',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // Custom app bar for BookingPage
  PreferredSizeWidget buildBookingPageAppBar() {
    return AppBar(
      backgroundColor: Colors.black,
      title: Row(
        children: [
          SizedBox(width: 50, child: Image.asset('assets/logo.png')),
          const SizedBox(width: 8), // Add some spacing between logo and texts
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hey, Karim!',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                'Where are you going?',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Standard app bar for other pages
  AppBar buildStandardAppBar() {
    return AppBar(
      backgroundColor: Colors.black,
      title: SizedBox(width: 50, child: Image.asset('assets/logo.png')),
    );
  }
}
