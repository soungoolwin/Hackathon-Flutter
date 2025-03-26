import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class MostFrequentUnitsScreen extends StatefulWidget {
  const MostFrequentUnitsScreen({Key? key}) : super(key: key);

  @override
  State<MostFrequentUnitsScreen> createState() =>
      _MostFrequentUnitsScreenState();
}

class _MostFrequentUnitsScreenState extends State<MostFrequentUnitsScreen> {
  List<_UnitBookingData> data = [];
  Map<String, dynamic> jsonData = {};
  String currentInsight = "";
  bool isLoading = true;

  // Date range selection
  DateTime startDate = DateTime(2024, 1, 1);
  DateTime endDate = DateTime(2024, 5, 1);

  @override
  void initState() {
    super.initState();
    loadJsonData();
  }

  Future<void> loadJsonData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final String response =
          await rootBundle.loadString('assets/most_frequent_units_screen.json');
      jsonData = await json.decode(response);

      // Update data based on selected date range
      updateDataForDateRange();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error loading JSON data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void updateDataForDateRange() {
    if (jsonData.isEmpty) return;

    // Filter data entries within the selected date range
    List<dynamic> filteredData = jsonData['data'].where((entry) {
      DateTime entryDate = DateTime.parse(entry['date']);
      return (entryDate.isAtSameMomentAs(startDate) ||
              entryDate.isAfter(startDate)) &&
          (entryDate.isAtSameMomentAs(endDate) || entryDate.isBefore(endDate));
    }).toList();

    // If no data found in range, use empty list
    if (filteredData.isEmpty) {
      setState(() {
        data = [];
        currentInsight = "No data available for the selected date range.";
      });
      return;
    }

    // Get the latest data point in the range for display
    Map<String, int> unitBookings = {};
    Map<String, int> unitRevenue = {};

    // Aggregate bookings and revenue across the date range
    for (var entry in filteredData) {
      for (var unit in entry['units']) {
        String unitName = unit['unitName'];
        unitBookings[unitName] =
            (unitBookings[unitName] ?? 0) + (unit['bookings'] as num).toInt();
        unitRevenue[unitName] =
            (unitRevenue[unitName] ?? 0) + (unit['revenue'] as num).toInt();
      }
    }

    // Convert to list of _UnitBookingData objects
    List<_UnitBookingData> newData = unitBookings.entries.map((entry) {
      return _UnitBookingData(
          entry.key, entry.value, unitRevenue[entry.key] ?? 0);
    }).toList();

    // Sort by highest bookings
    newData.sort((a, b) => b.bookings.compareTo(a.bookings));

    // Find appropriate insight
    String insightKey =
        "${DateFormat('yyyy-MM-dd').format(startDate)}_${DateFormat('yyyy-MM-dd').format(endDate)}";
    String insight = jsonData['insights'][insightKey] ??
        jsonData['insights']['2024-01-01_2024-05-01'] ??
        "No specific insights available for the selected date range.";

    setState(() {
      data = newData;
      currentInsight = insight;
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? startDate : endDate,
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime(2024, 5, 1),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
          // Ensure end date is not before start date
          if (endDate.isBefore(startDate)) {
            endDate = startDate;
          }
        } else {
          endDate = picked;
          // Ensure start date is not after end date
          if (startDate.isAfter(endDate)) {
            startDate = endDate;
          }
        }
        updateDataForDateRange();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              // Added SingleChildScrollView to fix overflow issue
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    "Top Booked Units",
                    style: GoogleFonts.lato(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  // Date Range Selection
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context, true),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Start Date',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0)),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                            child: Text(
                                DateFormat('MMM d, yyyy').format(startDate)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context, false),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'End Date',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0)),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                            child:
                                Text(DateFormat('MMM d, yyyy').format(endDate)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Bar Chart for Bookings
                  SizedBox(
                    height: 300,
                    child: SfCartesianChart(
                      primaryXAxis: CategoryAxis(),
                      title: ChartTitle(
                          text:
                              "Most Frequently Booked Units (${DateFormat('MMM d').format(startDate)} - ${DateFormat('MMM d').format(endDate)})"),
                      legend: Legend(isVisible: false),
                      series: <CartesianSeries<_UnitBookingData, String>>[
                        BarSeries<_UnitBookingData, String>(
                          dataSource: data,
                          xValueMapper: (_UnitBookingData unit, _) =>
                              unit.unitName,
                          yValueMapper: (_UnitBookingData unit, _) =>
                              unit.bookings,
                          dataLabelSettings:
                              const DataLabelSettings(isVisible: true),
                          color: Colors.blueAccent,
                          sortingOrder: SortingOrder.descending,
                          sortFieldValueMapper: (_UnitBookingData data, _) =>
                              data.bookings,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Revenue Chart
                  _buildRevenueChart(),

                  const SizedBox(height: 16),

                  // AI Summary Section with insights from JSON
                  Card(
                    color: Colors.blueGrey[100],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "📊 AI Insights on Unit Popularity",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            data.isNotEmpty
                                ? "The most booked unit in this period is '${data[0].unitName}' with ${data[0].bookings} bookings.\n\n$currentInsight"
                                : "No data available for the selected date range.",
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

  // Revenue chart
  Widget _buildRevenueChart() {
    return SizedBox(
      height: 300,
      child: SfCartesianChart(
        primaryXAxis: CategoryAxis(),
        title: ChartTitle(text: "Revenue by Unit Type"),
        legend: Legend(isVisible: false),
        series: <CartesianSeries<_UnitBookingData, String>>[
          BarSeries<_UnitBookingData, String>(
            dataSource: data,
            xValueMapper: (_UnitBookingData unit, _) => unit.unitName,
            yValueMapper: (_UnitBookingData unit, _) => unit.revenue,
            dataLabelSettings: const DataLabelSettings(isVisible: true),
            color: Colors.greenAccent,
            sortingOrder: SortingOrder.descending,
            sortFieldValueMapper: (_UnitBookingData data, _) => data.revenue,
          ),
        ],
      ),
    );
  }
}

// Model class for Unit Booking Data
class _UnitBookingData {
  final String unitName;
  final int bookings;
  final int revenue;

  _UnitBookingData(this.unitName, this.bookings, this.revenue);
}
