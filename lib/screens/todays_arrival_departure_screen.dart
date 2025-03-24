import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:google_fonts/google_fonts.dart';

class TodaysArrivalDepartureScreen extends StatelessWidget {
  const TodaysArrivalDepartureScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<_BookingData> data = [
      _BookingData('Arrivals', 120),
      _BookingData('Departures', 80),
    ];

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 300,
              child: SfCircularChart(
                title: ChartTitle(text: "Today's Bookings"),
                legend: Legend(isVisible: true),
                series: <CircularSeries>[
                  PieSeries<_BookingData, String>(
                    dataSource: data,
                    xValueMapper: (_BookingData data, _) => data.category,
                    yValueMapper: (_BookingData data, _) => data.bookings,
                    dataLabelSettings: DataLabelSettings(isVisible: true),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Container(
              height: 300,
              child: SfCartesianChart(
                title: ChartTitle(text: 'Detailed View'),
                primaryXAxis: CategoryAxis(),
                series: <CartesianSeries>[
                  ColumnSeries<_BookingData, String>(
                    dataSource: data,
                    xValueMapper: (_BookingData bd, _) => bd.category,
                    yValueMapper: (_BookingData bd, _) => bd.bookings,
                    name: 'Bookings',
                    color: Colors.teal,
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "AI Summary: Today's bookings show a higher volume of arrivals compared to departures, indicating a net influx of guests. This trend is expected to continue based on current booking patterns.",
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

class _BookingData {
  final String category;
  final int bookings;

  _BookingData(this.category, this.bookings);
}