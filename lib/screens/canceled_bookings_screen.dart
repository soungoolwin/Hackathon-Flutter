import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';

class CanceledBookingsScreen extends StatefulWidget {
  const CanceledBookingsScreen({Key? key}) : super(key: key);

  @override
  State<CanceledBookingsScreen> createState() => _CanceledBookingsScreenState();
}

class _CanceledBookingsScreenState extends State<CanceledBookingsScreen> {
  /// For date filtering
  DateTime? _startDate;
  DateTime? _endDate;

  /// Raw JSON fields
  int _totalBookings = 0;
  int _canceledBookings = 0;
  List<dynamic> _cancellationsByMonth = [];

  /// Flattened list of all cancellations across months
  List<Map<String, dynamic>> _allCancellations = [];

  /// Filtered cancellations for the user-chosen date range
  List<Map<String, dynamic>> _filteredCancellations = [];

  /// We parse the date strings (e.g. "2024-01-05") into a DateTime
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    _loadData(); // Load JSON on creation
  }

  Future<void> _loadData() async {
    try {
      // 1) Load JSON from assets
      final jsonString =
          await rootBundle.loadString('assets/canceled_bookings_screen.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      // 2) Grab top-level fields
      _totalBookings = jsonData['totalBookings'] as int;
      _canceledBookings = jsonData['canceledBookings'] as int;
      _cancellationsByMonth = jsonData['cancellationsByMonth'] as List<dynamic>;

      // 3) Flatten all months' 'cancellations' into one list
      final List<Map<String, dynamic>> all = [];
      for (var monthEntry in _cancellationsByMonth) {
        if (monthEntry is Map<String, dynamic> &&
            monthEntry.containsKey('cancellations')) {
          final monthCancels = monthEntry['cancellations'] as List<dynamic>;
          for (var c in monthCancels) {
            if (c is Map<String, dynamic>) {
              all.add(c);
            }
          }
        }
      }
      _allCancellations = all;

      // 4) By default, let's pick a broad date range or default to no filtering
      // For example, default: last 90 days from now, or do no filter
      // For demonstration, let's do no filter => show all
      setState(() {
        _startDate = null;
        _endDate = null;
        _applyFilter();
      });
    } catch (e) {
      debugPrint("Error loading canceled bookings data: $e");
    }
  }

  void _applyFilter() {
    // If both dates are null, we just show everything
    if (_startDate == null && _endDate == null) {
      setState(() {
        _filteredCancellations = _allCancellations;
      });
      return;
    }

    // If we do have a date range:
    final List<Map<String, dynamic>> filtered = [];
    for (var c in _allCancellations) {
      try {
        final dateString = c["date"] as String; // e.g. "2024-01-05"
        final cDate = _dateFormat.parse(dateString);

        // Decide if cDate is within range
        bool isAfterStart = true; // if no start date, pass
        bool isBeforeEnd = true; // if no end date, pass

        if (_startDate != null) {
          isAfterStart = !cDate.isBefore(_startDate!); // cDate >= startDate
        }
        if (_endDate != null) {
          isBeforeEnd = !cDate.isAfter(_endDate!); // cDate <= endDate
        }

        if (isAfterStart && isBeforeEnd) {
          filtered.add(c);
        }
      } catch (_) {
        // ignore parse errors
      }
    }

    setState(() {
      _filteredCancellations = filtered;
    });
  }

  // --- Date pickers ---

  Future<void> _selectStartDate(BuildContext context) async {
    final initial = _startDate ?? DateTime.now();
    final lastAllowed = DateTime(2025, 12, 31);

    // Ensure initialDate is not after lastDate
    final initialDate = initial.isAfter(lastAllowed) ? lastAllowed : initial;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2023),
      lastDate: lastAllowed,
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
      _applyFilter();
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final lastAllowed = DateTime(2025, 12, 31);

    final proposedInitial = _endDate ?? DateTime.now();
    final initialDate =
        proposedInitial.isAfter(lastAllowed) ? lastAllowed : proposedInitial;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2023, 1, 1),
      lastDate: lastAllowed,
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
      _applyFilter(); // or whatever filter logic you have
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "Select Date";
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Canceled Bookings"),
      ),
      body: Column(
        children: [
          // Summary card
          Card(
            margin: const EdgeInsets.all(16),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Total Bookings: $_totalBookings"),
                  const SizedBox(height: 4),
                  Text("Canceled Bookings: $_canceledBookings"),
                ],
              ),
            ),
          ),

          // Date pickers row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectStartDate(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_formatDate(_startDate)),
                          const Icon(Icons.calendar_today, size: 16),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectEndDate(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_formatDate(_endDate)),
                          const Icon(Icons.calendar_today, size: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Display results
          const SizedBox(height: 10),
          Expanded(
            child: _buildResultsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    if (_filteredCancellations.isEmpty) {
      return const Center(
        child: Text("No cancellations in this date range"),
      );
    }

    return ListView.builder(
      itemCount: _filteredCancellations.length,
      itemBuilder: (context, index) {
        final c = _filteredCancellations[index];
        final dateStr = c["date"] ?? "";
        final name = c["guestName"] ?? "Guest";
        final reason = c["reason"] ?? "Unknown reason";
        final ageGroup = c["ageGroup"] ?? "Unknown age group";
        final bookingAmount = c["bookingAmount"] ?? 0.0;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            title: Text("$name - $reason"),
            subtitle: Text(
                "Date: $dateStr | Age: $ageGroup | \$${bookingAmount.toStringAsFixed(2)}"),
          ),
        );
      },
    );
  }
}
