import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/booking_data.dart';

class CompareArrivalBookingsScreen extends StatefulWidget {
  const CompareArrivalBookingsScreen({Key? key}) : super(key: key);

  @override
  State<CompareArrivalBookingsScreen> createState() =>
      _CompareArrivalBookingsScreenState();
}

class _CompareArrivalBookingsScreenState
    extends State<CompareArrivalBookingsScreen> {
  late Future<List<BookingData>> _bookingDataFuture;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _bookingDataFuture = _loadBookingData();
  }

  Future<List<BookingData>> _loadBookingData() async {
    final String jsonString = await rootBundle.loadString(
      'assets/compare_arrival_bookings_screen.json',
    );
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    final List<dynamic> bookingsJson = jsonData['bookings'];

    int totalMember = 0;
    int totalGeneral = 0;

    List<dynamic> filteredBookings = bookingsJson;
    if (_startDate != null && _endDate != null) {
      filteredBookings = bookingsJson.where((booking) {
        DateTime bookingDate = DateTime.parse(booking['date']);
        // Only include bookings between _startDate & _endDate
        return bookingDate.isAtSameMomentAs(_startDate!) ||
            bookingDate.isAtSameMomentAs(_endDate!) ||
            (bookingDate.isAfter(_startDate!) &&
                bookingDate.isBefore(_endDate!));
      }).toList();
    }

    for (var booking in filteredBookings) {
      totalMember += booking['member'] as int;
      totalGeneral += booking['general'] as int;
    }

    // Return 2 aggregated BookingData objects: one for Member, one for General
    return [
      BookingData('Member', totalMember, totalMember + totalGeneral,
          year: 2024),
      BookingData('General', totalGeneral, totalMember + totalGeneral,
          year: 2024),
    ];
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2023),
      lastDate: DateTime(2025, 12, 31),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // If end date is set but is before the new start date, reset it.
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
        _bookingDataFuture = _loadBookingData();
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select Date';
    return DateFormat('dd MMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compare Arrival Bookings'),
      ),
      body: FutureBuilder<List<BookingData>>(
        future: _bookingDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No booking data available'));
          }

          final data = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Date Range Selection
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context, true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_formatDate(_startDate),
                                    style: GoogleFonts.lato()),
                                const Icon(Icons.calendar_today, size: 16),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context, false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_formatDate(_endDate),
                                    style: GoogleFonts.lato()),
                                const Icon(Icons.calendar_today, size: 16),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Pie Chart
                Container(
                  height: 300,
                  child: SfCircularChart(
                    title: ChartTitle(text: 'Booking Composition'),
                    legend: Legend(isVisible: true),
                    series: <CircularSeries>[
                      DoughnutSeries<BookingData, String>(
                        dataSource: data,
                        xValueMapper: (BookingData bd, _) => bd.month,
                        yValueMapper: (BookingData bd, _) => bd.bookings,
                        dataLabelSettings:
                            const DataLabelSettings(isVisible: true),
                        enableTooltip: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Column Chart
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
                        xValueMapper: (BookingData bd, _) => bd.month,
                        yValueMapper: (BookingData bd, _) => bd.bookings,
                        dataLabelSettings:
                            const DataLabelSettings(isVisible: true),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Analysis
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    _startDate != null && _endDate != null
                        ? "Analysis: Between ${_formatDate(_startDate)} and ${_formatDate(_endDate)}, ${data[0].month} bookings are ${data[0].bookings > data[1].bookings ? 'higher' : 'lower'} than ${data[1].month} bookings, with a difference of ${(data[0].bookings - data[1].bookings).abs()} bookings."
                        : "Analysis: The data shows that ${data[0].month} bookings are ${data[0].bookings > data[1].bookings ? 'higher' : 'lower'} than ${data[1].month} bookings, indicating a ${data[0].bookings > data[1].bookings ? 'stronger loyalty program influence' : 'need to improve the loyalty program'}.",
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.justify,
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
