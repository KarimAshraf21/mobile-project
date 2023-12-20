import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:project/screens/booking_page.dart';
import 'ride.dart';

class RidePage extends StatefulWidget {
  const RidePage({Key? key}) : super(key: key);

  @override
  State<RidePage> createState() => _RidePageState();
}

class _RidePageState extends State<RidePage> {
  final List<String> locations = ['Campus', 'Nasr City 1', 'Tagamoa', 'Maadi'];
  String selectedStartLocation = "Campus";
  String selectedDestination = 'Nasr City 1';

  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime.now();
    DateTime todayStart = DateTime(today.year, today.month, today.day);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    selectedStartLocation,
                    'From',
                    locations,
                    (value) {
                      setState(() {
                        selectedStartLocation = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildDropdown(
                    selectedDestination,
                    'To',
                    locations,
                    (value) {
                      setState(() {
                        selectedDestination = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('rides')
                    .where('date', isGreaterThanOrEqualTo: todayStart)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  if (snapshot.hasError) {
                    return const Text('Error fetching rides');
                  }

                  List<Widget> rideWidgets = _buildRideList(snapshot.data);

                  return ListView(
                    children: rideWidgets.isNotEmpty
                        ? rideWidgets
                        : [
                            const Center(
                              child: Text(
                                'No trips found for the selected criteria.',
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String value, String label, List<String> items,
      Function(String?) onChanged) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        onChanged: onChanged,
        items: items.map<DropdownMenuItem<String>>((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        isExpanded: true,
      ),
    );
  }

  List<Widget> _buildRideList(QuerySnapshot<Map<String, dynamic>>? snapshot) {
    if (snapshot == null || snapshot.docs.isEmpty) {
      return [];
    }

    List<Ride> rides = snapshot.docs
        .map((DocumentSnapshot<Map<String, dynamic>> doc) {
          final data = doc.data() as Map<String, dynamic>; // Explicit casting
          return Ride.fromFirestore(doc.id, data);
        })
        .where((ride) =>
            ride.startLocation == selectedStartLocation &&
            ride.endLocation == selectedDestination &&
            ride.availableSeats > 0)
        .toList();

    // Sort rides by date in ascending order
    rides.sort((a, b) => a.date.compareTo(b.date));

    Map<DateTime, List<Ride>> groupedRides = {};

    for (Ride ride in rides) {
      DateTime formattedDate =
          DateTime(ride.date.year, ride.date.month, ride.date.day);
      groupedRides.putIfAbsent(formattedDate, () => []);
      groupedRides[formattedDate]!.add(ride);
    }

    return groupedRides.keys.map((DateTime date) {
      List<Ride> ridesOnDate = groupedRides[date]!;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              DateFormat('EEEE, dd/MM').format(date),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          ...ridesOnDate.map((ride) {
            return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              future: FirebaseFirestore.instance
                  .collection('drivers')
                  .doc(ride.driverId)
                  .get(),
              builder: (context, driverSnapshot) {
                if (driverSnapshot.connectionState == ConnectionState.waiting ||
                    !driverSnapshot.hasData) {
                  // You can return a loading indicator if needed
                  return const CircularProgressIndicator();
                }

                final driverData = driverSnapshot.data!.data()!;
                final driverName = driverData['firstName'] ?? 'Unknown Driver';
                final driverId = driverData['id'] ?? '';

                return Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 4.0,
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(
                      ride.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRideInfoRow(Icons.person, 'Driver Name',
                            driverName, Colors.black),
                        _buildRideInfoRow(
                            Icons.person, 'Driver Id', driverId, Colors.black),
                        _buildRideInfoRow(Icons.location_on, 'From',
                            ride.startLocation, Colors.blue),
                        _buildRideInfoRow(Icons.location_on, 'To',
                            ride.endLocation, Colors.red),
                        _buildRideInfoRow(Icons.access_time, 'Time', ride.time,
                            Colors.orange),
                        _buildRideInfoRow(Icons.event_seat, 'Available seats',
                            ride.availableSeats.toString(), Colors.black),
                        _buildRideInfoRow(Icons.attach_money, 'Price',
                            ride.price, Colors.green),
                      ],
                    ),
                    onTap: () {
                      // Handle tap
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingPage(
                            ride: ride,
                            driverName: driverName,
                            driverId: driverId,
                          ),
                        ),
                      );
                      // Navigate to booking page
                    },
                  ),
                );
              },
            );
          }).toList(),
        ],
      );
    }).toList();
  }

  Widget _buildRideInfoRow(
      IconData icon, String label, String value, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
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
}
