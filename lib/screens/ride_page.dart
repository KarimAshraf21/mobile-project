// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'ride.dart';
import 'booking_page.dart';

class RidePage extends StatefulWidget {
  const RidePage({Key? key}) : super(key: key);

  @override
  State<RidePage> createState() => _RidePageState();
}

class _RidePageState extends State<RidePage> {
  List<String> locations = ['Campus', 'Nasr City 1', 'Tagamoa', 'Maadi'];
  String selectedStartLocation = "Campus";
  String selectedDestination = 'Nasr City 1';
  List<Ride> rides = generateDummyRidesForRide();

  @override
  Widget build(BuildContext context) {
    List<Widget> rideWidgets = _buildRideList();

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
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
          ),
          Expanded(
            child: Scrollbar(
              child: GlowingOverscrollIndicator(
                axisDirection: AxisDirection.down,
                color: Colors.transparent,
                child: rideWidgets.isNotEmpty
                    ? ListView(
                        children: rideWidgets,
                      )
                    : const Center(
                        child: Text(
                          'No trips found for the selected criteria.',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ],
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

  List<Widget> _buildRideList() {
    // Group rides by date
    Map<DateTime, List<Ride>> ridesGroupedByDate = {};
    DateTime today = DateTime.now();

    for (Ride ride in rides) {
      DateTime date = ride.date;

      // Filter out rides before today
      if (date.isBefore(today)) {
        continue;
      }

      // Filter rides based on start and end destinations
      if (ride.startLocation != selectedStartLocation ||
          ride.endLocation != selectedDestination) {
        continue;
      }

      // Filter out rides with no available seats
      if (ride.availableSeats == 0) {
        continue;
      }

      DateTime formattedDate = DateTime(date.year, date.month, date.day);
      ridesGroupedByDate.putIfAbsent(formattedDate, () => []);
      ridesGroupedByDate[formattedDate]!.add(ride);
    }

    // Sort dates in descending order (latest date first)
    List<DateTime> sortedDates = ridesGroupedByDate.keys.toList()
      ..sort((a, b) => a.compareTo(b));

    List<Widget> rideWidgets = [];
    for (DateTime date in sortedDates) {
      rideWidgets.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "${date.day}/${date.month}/${date.year}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            ...ridesGroupedByDate[date]!.map((ride) {
              return Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                margin: const EdgeInsets.all(8.0),
                elevation: 4.0,
                child: ListTile(
                  title: Row(
                    children: [
                      const Icon(Icons.directions_car, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        ride.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      _buildRideInfoRow(
                        Icons.location_on,
                        'From',
                        ride.startLocation,
                        Colors.blue,
                      ),
                      _buildRideInfoRow(
                        Icons.location_on,
                        'To',
                        ride.endLocation,
                        Colors.red,
                      ),
                      _buildRideInfoRow(
                        Icons.access_time,
                        'Time',
                        ride.startTime,
                        Colors.orange,
                      ),
                      _buildRideInfoRow(
                        Icons.event_seat,
                        'Available seats',
                        ride.availableSeats.toString(),
                        Colors.black,
                      ),
                      _buildRideInfoRow(
                        Icons.attach_money,
                        'Price',
                        ride.price,
                        Colors.green,
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingPage(ride: ride),
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          ],
        ),
      );
    }

    return rideWidgets;
  }

  Widget _buildRideInfoRow(
    IconData icon,
    String label,
    String value,
    Color iconColor,
  ) {
    return Row(
      children: [
        Icon(icon, color: iconColor),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 14),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}
