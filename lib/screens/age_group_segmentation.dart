import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

// Model for Age Group Data
class AgeGroupData {
  final String ageGroup;
  final int bookings;
  final double revenue; // Unique metric: revenue generated by each age group
  final Map<String, dynamic> preferences; // Room preferences and booking days

  AgeGroupData(this.ageGroup, this.bookings, this.revenue, this.preferences);

  factory AgeGroupData.fromJson(Map<String, dynamic> json) {
    return AgeGroupData(
      json['ageGroup'],
      json['bookings'],
      json['revenue'],
      json['preferences'],
    );
  }
}

class AgeGroupSegmentationScreen extends StatefulWidget {
  const AgeGroupSegmentationScreen({Key? key}) : super(key: key);

  @override
  _AgeGroupSegmentationScreenState createState() =>
      _AgeGroupSegmentationScreenState();
}

class _AgeGroupSegmentationScreenState
    extends State<AgeGroupSegmentationScreen> {
  List<AgeGroupData> ageGroupData = [];
  List<Map<String, dynamic>> monthlyData = [];
  String selectedMonth = "";
  int selectedYear = 0;
  AgeGroupData? selectedAgeGroup;

  // For month/year picker
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadAgeGroupData();
  }

  Future<void> _loadAgeGroupData() async {
    final String jsonString =
        await rootBundle.loadString('assets/age_group_segmentation.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    setState(() {
      monthlyData = List<Map<String, dynamic>>.from(jsonData['data']);

      // Set initial month and year to the first entry in the data
      if (monthlyData.isNotEmpty) {
        selectedMonth = monthlyData[0]['month'];
        selectedYear = monthlyData[0]['year'];
        selectedDate = DateTime(selectedYear, _getMonthNumber(selectedMonth));
        _updateAgeGroupData();
      }
    });
  }

  int _getMonthNumber(String monthName) {
    final Map<String, int> monthMap = {
      'January': 1,
      'February': 2,
      'March': 3,
      'April': 4,
      'May': 5,
      'June': 6,
      'July': 7,
      'August': 8,
      'September': 9,
      'October': 10,
      'November': 11,
      'December': 12
    };
    return monthMap[monthName] ?? 1;
  }

  String _getMonthName(int monthNumber) {
    final Map<int, String> monthMap = {
      1: 'January',
      2: 'February',
      3: 'March',
      4: 'April',
      5: 'May',
      6: 'June',
      7: 'July',
      8: 'August',
      9: 'September',
      10: 'October',
      11: 'November',
      12: 'December'
    };
    return monthMap[monthNumber] ?? 'January';
  }

  void _updateAgeGroupData() {
    // Find the data for the selected month and year
    final selectedData = monthlyData.firstWhere(
      (data) => data['month'] == selectedMonth && data['year'] == selectedYear,
      orElse: () => monthlyData.isNotEmpty ? monthlyData[0] : {'ageGroups': []},
    );

    setState(() {
      ageGroupData = List<Map<String, dynamic>>.from(selectedData['ageGroups'])
          .map((ageGroup) => AgeGroupData.fromJson(ageGroup))
          .toList();

      // Clear selected age group when data changes
      selectedAgeGroup = null;
    });
  }

  Future<void> _selectMonthYear(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
      initialDatePickerMode: DatePickerMode.year,
      // We only need month and year
      selectableDayPredicate: (DateTime date) {
        // Make all days selectable, we'll only use month and year
        return true;
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        selectedMonth = _getMonthName(picked.month);
        selectedYear = picked.year;
        _updateAgeGroupData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Title
              const Text(
                "Age Group Segmentation",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              // Month/Year Picker in a separate row
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () => _selectMonthYear(context),
                  icon: const Icon(Icons.calendar_today),
                  label: Text("${selectedMonth} ${selectedYear}"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 📊 Pie Chart for Age Group Bookings
              SizedBox(
                height: 300,
                child: SfCircularChart(
                  title: ChartTitle(text: "Guest Bookings by Age Group"),
                  legend: Legend(isVisible: true),
                  series: <CircularSeries>[
                    DoughnutSeries<AgeGroupData, String>(
                      dataSource: ageGroupData,
                      xValueMapper: (AgeGroupData data, _) => data.ageGroup,
                      yValueMapper: (AgeGroupData data, _) => data.bookings,
                      dataLabelSettings:
                          const DataLabelSettings(isVisible: true),
                      enableTooltip: true,
                      // Make sectors clickable
                      onPointTap: (ChartPointDetails details) {
                        if (details.pointIndex != null &&
                            details.pointIndex! < ageGroupData.length) {
                          setState(() {
                            selectedAgeGroup =
                                ageGroupData[details.pointIndex!];
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Selected Age Group Details (when an age group is selected)
              if (selectedAgeGroup != null) ...[
                Center(
                  child: Card(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.amber[800]
                        : Colors.amber[100],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${selectedAgeGroup!.ageGroup} Details",
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text("Total Bookings: ${selectedAgeGroup!.bookings}"),
                          Text(
                              "Total Revenue: \$${selectedAgeGroup!.revenue.toStringAsFixed(2)}"),
                          const SizedBox(height: 12),
                          const Text("Room Preferences:",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          ..._buildRoomPreferences(selectedAgeGroup!),
                          const SizedBox(height: 12),
                          const Text("Booking Day Preferences:",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          ..._buildBookingDayPreferences(selectedAgeGroup!),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 📈 Line Chart for Revenue per Age Group
              SizedBox(
                height: 300,
                child: SfCartesianChart(
                  title: ChartTitle(text: "Revenue Contribution by Age Group"),
                  legend: Legend(isVisible: false),
                  primaryXAxis: CategoryAxis(),
                  series: <CartesianSeries>[
                    LineSeries<AgeGroupData, String>(
                      dataSource: ageGroupData,
                      xValueMapper: (AgeGroupData data, _) => data.ageGroup,
                      yValueMapper: (AgeGroupData data, _) => data.revenue,
                      dataLabelSettings:
                          const DataLabelSettings(isVisible: true),
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // AI Summary Section
              Center(
                child: Card(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.blueGrey[700]
                      : Colors.blueGrey[100],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "📊 AI Age Group Insights",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _generateAISummary(),
                          style: GoogleFonts.lato(
                            fontSize: 14,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build room preferences widgets
  List<Widget> _buildRoomPreferences(AgeGroupData ageGroup) {
    final List<dynamic> roomTypes = ageGroup.preferences['roomTypes'];
    return roomTypes.map<Widget>((room) {
      return Padding(
        padding: const EdgeInsets.only(left: 16.0, top: 4.0),
        child: Text("${room['type']}: ${room['count']} bookings"),
      );
    }).toList();
  }

  // Helper method to build booking day preferences widgets
  List<Widget> _buildBookingDayPreferences(AgeGroupData ageGroup) {
    final List<dynamic> bookingDays = ageGroup.preferences['bookingDays'];
    return bookingDays.map<Widget>((day) {
      return Padding(
        padding: const EdgeInsets.only(left: 16.0, top: 4.0),
        child: Text("${day['day']}: ${day['count']} bookings"),
      );
    }).toList();
  }

  // Generate AI summary based on current data
  String _generateAISummary() {
    if (ageGroupData.isEmpty) {
      return "No data available for the selected month and year.";
    }

    // Find age group with highest bookings
    final highestBookingsGroup = ageGroupData
        .reduce((curr, next) => curr.bookings > next.bookings ? curr : next);

    // Find age group with highest revenue
    final highestRevenueGroup = ageGroupData
        .reduce((curr, next) => curr.revenue > next.revenue ? curr : next);

    // Calculate total bookings
    final totalBookings =
        ageGroupData.fold(0, (sum, item) => sum + item.bookings);

    // Calculate percentage of highest booking group
    final bookingPercentage =
        (highestBookingsGroup.bookings / totalBookings * 100)
            .toStringAsFixed(1);

    return "${highestBookingsGroup.ageGroup} contribute the highest number of bookings, "
        "accounting for $bookingPercentage% of total arrivals in $selectedMonth $selectedYear. "
        "\nHowever, ${highestRevenueGroup.ageGroup} guests generate the highest revenue at \$${highestRevenueGroup.revenue.toStringAsFixed(0)}."
        "\nConsider targeted promotions for high-value customer groups!"
        "\n\nTip: Click on a pie chart segment to see detailed preferences for that age group.";
  }
}
