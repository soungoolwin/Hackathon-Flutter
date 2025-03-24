import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart'; // ✅ Import this for the gauge

class CanceledBookingsScreen extends StatefulWidget {
  const CanceledBookingsScreen({Key? key}) : super(key: key);

  @override
  _CanceledBookingsScreenState createState() => _CanceledBookingsScreenState();
}

class _CanceledBookingsScreenState extends State<CanceledBookingsScreen> {
  final int totalBookings = 500;
  final int canceledBookings = 120;
  late double cancellationPercentage;

  @override
  void initState() {
    super.initState();
    cancellationPercentage = (canceledBookings / totalBookings) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView( // ✅ Fix overflow issue
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Canceled Bookings Summary
              Card(
                elevation: 4,
                color: Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        "Total Bookings: $totalBookings",
                        style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Canceled Bookings: $canceledBookings",
                        style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Cancellation Rate: ${cancellationPercentage.toStringAsFixed(1)}%",
                        style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Radial Gauge (Circular Progress Indicator)
              Center(
                child: SizedBox(
                  height: 300,
                  child: SfRadialGauge(
                    axes: <RadialAxis>[
                      RadialAxis(
                        minimum: 0,
                        maximum: 100,
                        ranges: <GaugeRange>[
                          GaugeRange(startValue: 0, endValue: 25, color: Colors.green),
                          GaugeRange(startValue: 25, endValue: 50, color: Colors.yellow),
                          GaugeRange(startValue: 50, endValue: 75, color: Colors.orange),
                          GaugeRange(startValue: 75, endValue: 100, color: Colors.red),
                        ],
                        pointers: <GaugePointer>[
                          NeedlePointer(value: cancellationPercentage),
                        ],
                        annotations: <GaugeAnnotation>[
                          GaugeAnnotation(
                            widget: Text(
                              "${cancellationPercentage.toStringAsFixed(1)}%",
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            angle: 90,
                            positionFactor: 0.5,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // AI Summary Section (Fake AI-generated insights)
              Card(
                color: Colors.blueGrey[100],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "📊 AI Insights on Cancellations",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "The cancellation rate this month is ${cancellationPercentage.toStringAsFixed(1)}%. "
                            "\nHigh cancellation rates were observed on weekends. "
                            "\nConsider improving refund policies or offering last-minute discounts to reduce cancellations.",
                        style: GoogleFonts.lato(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}