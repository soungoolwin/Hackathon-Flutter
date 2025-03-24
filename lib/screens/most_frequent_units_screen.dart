import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:math';

class MostFrequentUnitsScreen extends StatelessWidget {
  const MostFrequentUnitsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<_UnitBookingData> data = _generateSampleData();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              "Top Booked Units This Month",
              style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Bar Chart
            SizedBox(
              height: 300,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                title: ChartTitle(text: "Most Frequently Booked Units"),
                legend: Legend(isVisible: false),
                series: <CartesianSeries<_UnitBookingData, String>>[
                  BarSeries<_UnitBookingData, String>(
                    dataSource: data,
                    xValueMapper: (_UnitBookingData unit, _) => unit.unitName,
                    yValueMapper: (_UnitBookingData unit, _) => unit.bookings,
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                    color: Colors.blueAccent,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // AI Summary Section (Fake AI-generated insights)
            Card(
              color: Colors.blueGrey[100],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "📊 AI Insights on Unit Popularity",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "The most booked unit this month is '${data[0].unitName}' with ${data[0].bookings} bookings."
                          "\nLuxury and sea-facing units are preferred by guests."
                          "\nConsider dynamic pricing for high-demand units!",
                      style: GoogleFonts.lato(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Generates random sample data for most booked units
  static List<_UnitBookingData> _generateSampleData() {
    List<String> units = [
      "Luxury Suite", "Sea View Room", "Family Room", "Deluxe Room", "Penthouse",
      "Garden View Room", "Economy Room", "Presidential Suite"
    ];
    Random random = Random();
    return List.generate(units.length, (index) {
      return _UnitBookingData(units[index], random.nextInt(200) + 50);
    }).toList()
      ..sort((a, b) => b.bookings.compareTo(a.bookings)); // Sort by highest bookings
  }
}

// Model class for Unit Booking Data
class _UnitBookingData {
  final String unitName;
  final int bookings;
  _UnitBookingData(this.unitName, this.bookings);
}