import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:google_fonts/google_fonts.dart';

class OccupancyRateScreen extends StatelessWidget {
  const OccupancyRateScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Example data for Occupancy Rate and ADR calculations
    final double totalRooms = 200;
    final double roomsSold = 160;
    final double totalRevenue = 20000;

    final double occupancyRate = (roomsSold / totalRooms) * 100;
    final double adr = totalRevenue / roomsSold;

    final List<_OccupancyData> occupancyData = [
      _OccupancyData('Occupied', roomsSold),
      _OccupancyData('Available', totalRooms - roomsSold),
    ];

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildMetricCard("Occupancy Rate", "${occupancyRate.toStringAsFixed(1)}%"),
            _buildMetricCard("Average Daily Rate (ADR)", "\$${adr.toStringAsFixed(2)}"),
            const SizedBox(height: 20),

            // Wrap chart to prevent overflow
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: SfCircularChart(
                  title: ChartTitle(text: 'Room Occupancy Status'),
                  legend: Legend(isVisible: true),
                  series: <CircularSeries>[
                    PieSeries<_OccupancyData, String>(
                      dataSource: occupancyData,
                      xValueMapper: (_OccupancyData data, _) => data.category,
                      yValueMapper: (_OccupancyData data, _) => data.value,
                      dataLabelSettings: DataLabelSettings(isVisible: true),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: SfCartesianChart(
                  title: ChartTitle(text: 'Monthly ADR Trend'),
                  primaryXAxis: CategoryAxis(),
                  series: <CartesianSeries>[
                    LineSeries<_ADRData, String>(
                      name: 'ADR',
                      dataSource: _getADRData(),
                      xValueMapper: (_ADRData data, _) => data.day,
                      yValueMapper: (_ADRData data, _) => data.adr,
                      markerSettings: const MarkerSettings(isVisible: true),
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "AI Summary: The property's occupancy rate is strong at ${occupancyRate.toStringAsFixed(1)}%, indicating high demand. "
                    "The Average Daily Rate (ADR) remains stable at \$${adr.toStringAsFixed(2)}, ensuring consistent revenue flow. "
                    "Based on current trends, the property is performing well this month.",
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.justify,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis, // Prevents text overflow
              ),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }

  List<_ADRData> _getADRData() {
    return [
      _ADRData("Day 1", 120),
      _ADRData("Day 2", 122),
      _ADRData("Day 3", 125),
      _ADRData("Day 4", 130),
      _ADRData("Day 5", 128),
      _ADRData("Day 6", 126),
      _ADRData("Day 7", 127),
    ];
  }
}

class _OccupancyData {
  final String category;
  final double value;

  _OccupancyData(this.category, this.value);
}

class _ADRData {
  final String day;
  final double adr;

  _ADRData(this.day, this.adr);
}