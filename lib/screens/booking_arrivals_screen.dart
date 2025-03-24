// import 'package:flutter/material.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../models/booking_data.dart';
//
// class BookingArrivalsScreen extends StatefulWidget {
//   const BookingArrivalsScreen({Key? key}) : super(key: key);
//
//   static List<BookingData> _createSampleData() {
//     // Assuming yearlyTotal is used for percentage calculations across various components
//     final int yearlyTotal = 500;
//     return [
//       BookingData('Jan', 50, yearlyTotal),
//       BookingData('Feb', 80, yearlyTotal),
//       BookingData('Mar', 40, yearlyTotal),
//       BookingData('Apr', 70, yearlyTotal),
//       // Add more months if necessary
//     ];
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final data = _createSampleData();
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Booking Arrivals', style: GoogleFonts.lato()),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             _buildColumnChart(data),
//             _buildDoughnutChart(data),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildColumnChart(List<BookingData> data) {
//     return Container(
//       height: 400,
//       child: SfCartesianChart(
//         title: ChartTitle(text: 'Monthly Booking Arrivals'),
//         legend: Legend(isVisible: false),
//         primaryXAxis: CategoryAxis(),
//         series: <CartesianSeries<BookingData, String>>[
//           ColumnSeries<BookingData, String>(
//             name: 'Arrivals',
//             dataSource: data,
//             xValueMapper: (BookingData bd, _) => bd.month,
//             yValueMapper: (BookingData bd, _) => bd.bookings,
//             dataLabelSettings: const DataLabelSettings(isVisible: true),
//             color: Colors.blue,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDoughnutChart(List<BookingData> data) {
//     return Container(
//       height: 400,
//       child: SfCircularChart(
//         title: ChartTitle(text: 'Percentage of Yearly Bookings'),
//         legend: Legend(isVisible: true),
//         series: <CircularSeries>[
//           DoughnutSeries<BookingData, String>(
//             dataSource: data,
//             xValueMapper: (BookingData bd, _) => bd.month,
//             yValueMapper: (BookingData bd, _) => (bd.bookings / bd.yearlyTotal) * 100,
//             dataLabelSettings: DataLabelSettings(isVisible: true, labelPosition: ChartDataLabelPosition.outside),
//             enableTooltip: true,
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/booking_data.dart';

class BookingArrivalsScreen extends StatefulWidget {
  const BookingArrivalsScreen({Key? key}) : super(key: key);

  @override
  State<BookingArrivalsScreen> createState() => _BookingArrivalsScreenState();
}

class _BookingArrivalsScreenState extends State<BookingArrivalsScreen> {
  late Future<List<BookingData>> _bookingDataFuture;
  String _selectedMonth = 'All'; // Default to show all months

  Future<List<BookingData>> _loadBookingData() async {
    // Load the JSON file from the assets
    final String jsonString =
        await rootBundle.loadString('assets/booking_arrivals_screens.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    final int yearlyTotal = jsonData['yearlyTotal'];
    final List<dynamic> bookingsJson = jsonData['bookings'];

    // Convert JSON data to BookingData objects
    return bookingsJson
        .map((booking) => BookingData.fromJson(booking, yearlyTotal))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _bookingDataFuture = _loadBookingData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BookingData>>(
      future: _bookingDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No booking data available'));
        }

        final allData = snapshot.data!;

        // Get unique months for dropdown
        final List<String> months = [
          'All',
          ...allData.map((data) => data.month).toSet().toList()
        ];

        // Filter data based on selected month
        final filteredData = _selectedMonth == 'All'
            ? allData
            : allData.where((data) => data.month == _selectedMonth).toList();

        return SingleChildScrollView(
          child: Column(
            children: [
              // Month selection dropdown
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Text('Select Month:',
                        style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 16),
                    DropdownButton<String>(
                      value: _selectedMonth,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedMonth = newValue;
                          });
                        }
                      },
                      items:
                          months.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              _buildColumnChart(filteredData),
              _buildDoughnutChart(
                  allData), // Always show all data for yearly percentage
            ],
          ),
        );
      },
    );
  }

  Widget _buildColumnChart(List<BookingData> data) {
    return Container(
      height: 400,
      child: SfCartesianChart(
        title: ChartTitle(
            text: _selectedMonth == 'All'
                ? 'Monthly Booking Arrivals'
                : '$_selectedMonth Booking Arrivals'),
        legend: Legend(isVisible: false),
        primaryXAxis: CategoryAxis(),
        series: <CartesianSeries<BookingData, String>>[
          ColumnSeries<BookingData, String>(
            name: 'Arrivals',
            dataSource: data,
            xValueMapper: (BookingData bd, _) => bd.month,
            yValueMapper: (BookingData bd, _) => bd.bookings,
            dataLabelSettings: const DataLabelSettings(isVisible: true),
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildDoughnutChart(List<BookingData> data) {
    return Container(
      height: 400,
      child: SfCircularChart(
        title: ChartTitle(text: 'Percentage of Yearly Bookings'),
        legend: Legend(isVisible: true),
        series: <CircularSeries>[
          DoughnutSeries<BookingData, String>(
            dataSource: data,
            xValueMapper: (BookingData bd, _) => bd.month,
            yValueMapper: (BookingData bd, _) =>
                (bd.bookings / bd.yearlyTotal) * 100,
            dataLabelSettings: DataLabelSettings(
                isVisible: true, labelPosition: ChartDataLabelPosition.outside),
            enableTooltip: true,
          ),
        ],
      ),
    );
  }
}
