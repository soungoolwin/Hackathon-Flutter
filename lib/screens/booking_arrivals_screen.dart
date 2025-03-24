// import 'package:flutter/material.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../models/booking_data.dart';
//
// class BookingArrivalsScreen extends StatelessWidget {
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
import '../models/booking_data.dart';

class BookingArrivalsScreen extends StatelessWidget {
  const BookingArrivalsScreen({Key? key}) : super(key: key);

  static List<BookingData> _createSampleData() {
    final int yearlyTotal = 500; // Total bookings for percentage calculation
    return [
      BookingData('Jan', 50, yearlyTotal),
      BookingData('Feb', 80, yearlyTotal),
      BookingData('Mar', 40, yearlyTotal),
      BookingData('Apr', 70, yearlyTotal),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final data = _createSampleData();

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildColumnChart(data),
          _buildDoughnutChart(data),
        ],
      ),
    );
  }

  Widget _buildColumnChart(List<BookingData> data) {
    return Container(
      height: 400,
      child: SfCartesianChart(
        title: ChartTitle(text: 'Monthly Booking Arrivals'),
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
            yValueMapper: (BookingData bd, _) => (bd.bookings / bd.yearlyTotal) * 100,
            dataLabelSettings: DataLabelSettings(isVisible: true, labelPosition: ChartDataLabelPosition.outside),
            enableTooltip: true,
          ),
        ],
      ),
    );
  }
}