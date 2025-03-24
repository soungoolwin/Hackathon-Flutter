import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class TodaysArrivalDepartureScreen extends StatefulWidget {
  const TodaysArrivalDepartureScreen({Key? key}) : super(key: key);

  @override
  State<TodaysArrivalDepartureScreen> createState() =>
      _TodaysArrivalDepartureScreenState();
}

class _TodaysArrivalDepartureScreenState
    extends State<TodaysArrivalDepartureScreen> {
  late Future<Map<String, dynamic>> _dataFuture;
  DateTime? _selectedDate;
  List<TimeBasedBooking> _arrivalData = [];
  List<TimeBasedBooking> _departureData = [];
  int _totalArrivals = 0;
  int _totalDepartures = 0;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
    _selectedDate = DateTime.now(); // Default to today
  }

  Future<Map<String, dynamic>> _loadData() async {
    final String jsonString = await rootBundle
        .loadString('assets/todays_arrival_departure_screen.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    _totalArrivals = jsonData['totalArrivals'];
    _totalDepartures = jsonData['totalDepartures'];

    return jsonData;
  }

  void _updateDataForSelectedDate() {
    if (_selectedDate == null) return;

    _dataFuture.then((jsonData) {
      final List<dynamic> allData = jsonData['data'];
      final String formattedSelectedDate =
          DateFormat('yyyy-MM-dd').format(_selectedDate!);

      // Find data for selected date
      final dayData = allData.firstWhere(
        (day) => day['date'] == formattedSelectedDate,
        orElse: () =>
            {'date': formattedSelectedDate, 'arrivals': [], 'departures': []},
      );

      setState(() {
        // Parse arrivals data
        _arrivalData = (dayData['arrivals'] as List<dynamic>).map((arrival) {
          return TimeBasedBooking(
            arrival['time'],
            arrival['count'],
          );
        }).toList();

        // Parse departures data
        _departureData =
            (dayData['departures'] as List<dynamic>).map((departure) {
          return TimeBasedBooking(
            departure['time'],
            departure['count'],
          );
        }).toList();
      });
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2025, 12, 31),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _updateDataForSelectedDate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _dataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return const Center(child: Text('No data available'));
        }

        // If this is the first load, initialize the data for selected date
        if (_arrivalData.isEmpty && _departureData.isEmpty) {
          _updateDataForSelectedDate();
        }

        // Calculate totals for the selected day
        int dayArrivals = _arrivalData.fold(0, (sum, item) => sum + item.count);
        int dayDepartures =
            _departureData.fold(0, (sum, item) => sum + item.count);

        // Create summary data for pie chart
        final List<BookingSummary> summaryData = [
          BookingSummary('Arrivals', dayArrivals),
          BookingSummary('Departures', dayDepartures),
        ];

        return Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Date selector
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Select Date: ',
                          style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 10),
                      InkWell(
                        onTap: () => _selectDate(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              Text(
                                _selectedDate != null
                                    ? DateFormat('dd MMM yyyy')
                                        .format(_selectedDate!)
                                    : 'Select Date',
                                style: GoogleFonts.lato(),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.calendar_today, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Summary pie chart
                Container(
                  height: 300,
                  child: SfCircularChart(
                    title: ChartTitle(
                        text:
                            "Bookings Summary for ${_selectedDate != null ? DateFormat('dd MMM yyyy').format(_selectedDate!) : 'Today'}"),
                    legend: Legend(isVisible: true),
                    series: <CircularSeries>[
                      PieSeries<BookingSummary, String>(
                        dataSource: summaryData,
                        xValueMapper: (BookingSummary data, _) => data.category,
                        yValueMapper: (BookingSummary data, _) => data.bookings,
                        dataLabelSettings:
                            const DataLabelSettings(isVisible: true),
                      ),
                    ],
                  ),
                ),

                // Time-based arrivals chart
                Container(
                  height: 300,
                  child: SfCartesianChart(
                    title: ChartTitle(text: 'Arrivals by Time'),
                    primaryXAxis: CategoryAxis(),
                    series: <CartesianSeries>[
                      ColumnSeries<TimeBasedBooking, String>(
                        dataSource: _arrivalData,
                        xValueMapper: (TimeBasedBooking data, _) => data.time,
                        yValueMapper: (TimeBasedBooking data, _) => data.count,
                        name: 'Arrivals',
                        color: Colors.blue,
                      )
                    ],
                  ),
                ),

                // Time-based departures chart
                Container(
                  height: 300,
                  child: SfCartesianChart(
                    title: ChartTitle(text: 'Departures by Time'),
                    primaryXAxis: CategoryAxis(),
                    series: <CartesianSeries>[
                      ColumnSeries<TimeBasedBooking, String>(
                        dataSource: _departureData,
                        xValueMapper: (TimeBasedBooking data, _) => data.time,
                        yValueMapper: (TimeBasedBooking data, _) => data.count,
                        name: 'Departures',
                        color: Colors.orange,
                      )
                    ],
                  ),
                ),

                // AI Summary
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    "AI Summary: On ${_selectedDate != null ? DateFormat('dd MMM yyyy').format(_selectedDate!) : 'today'}, there ${dayArrivals == 1 ? 'was' : 'were'} $dayArrivals arrival${dayArrivals == 1 ? '' : 's'} and $dayDepartures departure${dayDepartures == 1 ? '' : 's'}. ${dayArrivals > dayDepartures ? 'More guests checked in than checked out, indicating an increase in occupancy.' : dayArrivals < dayDepartures ? 'More guests checked out than checked in, indicating a decrease in occupancy.' : 'The number of check-ins and check-outs was balanced, indicating stable occupancy.'}",
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.justify,
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

class BookingSummary {
  final String category;
  final int bookings;

  BookingSummary(this.category, this.bookings);
}

class TimeBasedBooking {
  final String time;
  final int count;

  TimeBasedBooking(this.time, this.count);
}
