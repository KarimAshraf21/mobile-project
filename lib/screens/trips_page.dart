// ignore_for_file: file_names, use_key_in_widget_constructors

import '/screens/ride.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

class TripsPage extends StatefulWidget {
  const TripsPage({Key? key});

  @override
  State<TripsPage> createState() => _TripsPageState();
}

class _TripsPageState extends State<TripsPage> {
  bool showUpcomingTrips = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTripsButton(
                  'Upcoming',
                  showUpcomingTrips,
                  () => _toggleTripsView(true),
                ),
                const SizedBox(width: 20),
                _buildTripsButton(
                  'Previous',
                  !showUpcomingTrips,
                  () => _toggleTripsView(false),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: showUpcomingTrips
                  ? const UpcomingTripsList()
                  : const PreviousTripsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripsButton(
      String text, bool isSelected, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: isSelected ? Colors.black : Colors.grey,
        elevation: isSelected ? 5 : 5,
        minimumSize: const Size(150, 40),
        shadowColor: Colors.black.withOpacity(1),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          color: isSelected ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  void _toggleTripsView(bool upcomingTrips) {
    setState(() {
      showUpcomingTrips = upcomingTrips;
    });
  }
}

class UpcomingTripsList extends StatefulWidget {
  const UpcomingTripsList({Key? key});

  @override
  State<UpcomingTripsList> createState() => _UpcomingTripsListState();
}

class _UpcomingTripsListState extends State<UpcomingTripsList> {
  @override
  Widget build(BuildContext context) {
    List<Ride> upcomingRides = generateDummyRidesForUpcoming();

    return Scrollbar(
      child: ListView.builder(
        itemCount: upcomingRides.length,
        itemBuilder: (context, index) {
          return _buildTripCard(upcomingRides[index]);
        },
      ),
    );
  }

  Widget _buildTripCard(Ride ride) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(
          DateFormat('MMMM d, y').format(ride.date),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTripDetailRow('Start Location:', Icons.location_on,
                ride.startLocation, Colors.blue),
            _buildTripDetailRow('End Location:', Icons.location_on,
                ride.endLocation, Colors.red),
            _buildTripDetailRow(
                'Time:', Icons.access_time, ride.startTime, Colors.black),
            _buildTripDetailRow(
                'Status:', Icons.info, ride.status, Colors.greenAccent),
          ],
        ),
      ),
    );
  }

  Widget _buildTripDetailRow(
      String label, IconData icon, String value, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 8),
          Text(
            '$label ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

class PreviousTripsList extends StatefulWidget {
  const PreviousTripsList({Key? key});

  @override
  State<PreviousTripsList> createState() => _PreviousTripsListState();
}

class _PreviousTripsListState extends State<PreviousTripsList> {
  @override
  Widget build(BuildContext context) {
    List<Ride> previousRides = generateDummyRidesForPrevious();

    return ListView.builder(
      itemCount: previousRides.length,
      itemBuilder: (context, index) {
        return _buildTripCard(previousRides[index]);
      },
    );
  }

  Widget _buildTripCard(Ride ride) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(
          DateFormat('MMMM d, y').format(ride.date),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTripDetailRow(
                'From:', Icons.location_on, ride.startLocation, Colors.blue),
            _buildTripDetailRow(
                'To:', Icons.location_on, ride.endLocation, Colors.red),
            _buildTripDetailRow(
                'Time:', Icons.access_time, ride.startTime, Colors.black),
            _buildTripDetailRow(
                'Status:', Icons.info, ride.status, Colors.greenAccent),
          ],
        ),
      ),
    );
  }

  Widget _buildTripDetailRow(
      String label, IconData icon, String value, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 8),
          Text(
            '$label ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
