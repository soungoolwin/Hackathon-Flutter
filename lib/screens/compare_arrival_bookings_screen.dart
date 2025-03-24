import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:google_fonts/google_fonts.dart';

class CompareArrivalBookingsScreen extends StatelessWidget {
  const CompareArrivalBookingsScreen({Key? key}) : super(key: key);

  static List<BookingData> _createSampleData() {
    return [
      BookingData('Member', 120, 500),
      BookingData('General', 80, 500),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final data = _createSampleData();

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 300,
              child: SfCircularChart(
                title: ChartTitle(text: 'Booking Composition'),
                legend: Legend(isVisible: true),
                series: <CircularSeries>[
                  DoughnutSeries<BookingData, String>(
                    dataSource: data,
                    xValueMapper: (BookingData bd, _) => bd.category,
                    yValueMapper: (BookingData bd, _) => bd.bookings,
                    dataLabelSettings: DataLabelSettings(isVisible: true),
                    enableTooltip: true,
                  ),
                ],
              ),
            ),
            Container(
              height: 300,
              child: SfCartesianChart(
                title: ChartTitle(text: 'Detailed Comparison'),
                legend: Legend(isVisible: true),
                primaryXAxis: CategoryAxis(),
                series: <CartesianSeries>[
                  ColumnSeries<BookingData, String>(
                    name: 'Bookings',
                    dataSource: data,
                    xValueMapper: (BookingData bd, _) => bd.category,
                    yValueMapper: (BookingData bd, _) => bd.bookings,
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "Analysis: The data shows that Member bookings are significantly higher than General Guest bookings, indicating a stronger loyalty program influence or targeted marketing success.",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.justify,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class BookingData {
  final String category;
  final int bookings;
  final int total;

  BookingData(this.category, this.bookings, this.total);
}