import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class GuestBirthdayScreen extends StatefulWidget {
  const GuestBirthdayScreen({Key? key}) : super(key: key);

  @override
  _GuestBirthdayScreenState createState() => _GuestBirthdayScreenState();
}

class _GuestBirthdayScreenState extends State<GuestBirthdayScreen> {
  List<GuestBirthday> guestBirthdays = [];
  List<GuestBirthday> filteredGuests = [];
  List<GuestBirthday> todaysBirthdays = [];
  TextEditingController searchController = TextEditingController();
  bool showAllBirthdays = false;
  String todayDate = "";
  GuestBirthday? selectedGuest;

  @override
  void initState() {
    super.initState();
    _loadBirthdayData();
  }

  Future<void> _loadBirthdayData() async {
    final String jsonString =
        await rootBundle.loadString('assets/guest_birthday_screen.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    setState(() {
      todayDate = jsonData['todayDate'];
      guestBirthdays = (jsonData['guests'] as List)
          .map((item) => GuestBirthday.fromJson(item))
          .toList();

      // Filter today's birthdays
      todaysBirthdays =
          guestBirthdays.where((guest) => guest.date == todayDate).toList();

      // Initially show only today's birthdays
      filteredGuests = todaysBirthdays;
    });
  }

  // Toggle between showing all birthdays or just today's
  void _toggleBirthdayView() {
    setState(() {
      showAllBirthdays = !showAllBirthdays;
      if (showAllBirthdays) {
        filteredGuests = guestBirthdays;
      } else {
        filteredGuests = todaysBirthdays;
      }
      // Clear search when toggling
      searchController.clear();
      // Clear selected guest
      selectedGuest = null;
    });
  }

  // Filters the guest list based on search query
  void _filterSearchResults(String query) {
    setState(() {
      if (query.isEmpty) {
        // If search is cleared, respect the toggle setting
        filteredGuests = showAllBirthdays ? guestBirthdays : todaysBirthdays;
      } else {
        // Search within all birthdays regardless of toggle
        filteredGuests = guestBirthdays.where((guest) {
          return guest.name.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  // Show guest details when clicked
  void _showGuestDetails(GuestBirthday guest) {
    setState(() {
      selectedGuest = guest;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Prevent keyboard overflow issue
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    showAllBirthdays
                        ? "All Birthdays"
                        : "Today's Birthdays ($todayDate)",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Switch(
                    value: showAllBirthdays,
                    onChanged: (value) => _toggleBirthdayView(),
                    activeColor: Colors.pinkAccent,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Search Field
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: "Search Guest",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.search),
                ),
                onChanged: _filterSearchResults,
              ),
              const SizedBox(height: 16),

              // Birthday List
              SizedBox(
                height: 300, // Adjusted height to prevent overflow
                child: ListView.builder(
                  itemCount: filteredGuests.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        leading:
                            const Icon(Icons.cake, color: Colors.pinkAccent),
                        title: Text(filteredGuests[index].name),
                        subtitle:
                            Text("Birthday: ${filteredGuests[index].date}"),
                        onTap: () => _showGuestDetails(filteredGuests[index]),
                        selected:
                            selectedGuest?.name == filteredGuests[index].name,
                      ),
                    );
                  },
                ),
              ),

              // Guest Details Section (when a guest is selected)
              if (selectedGuest != null) ...[
                const SizedBox(height: 16),
                Card(
                  color: Colors.amber[100],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${selectedGuest!.name}'s Details",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text("Age Group: ${selectedGuest!.ageSegment}"),
                        Text(
                            "Preferred Room Type: ${selectedGuest!.preferredRoom}"),
                        const SizedBox(height: 8),
                        const Text(
                          "💡 Promotion Idea: Send a personalized birthday offer for their preferred room type!",
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Birthday Distribution Chart
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 300,
                  child: SfCartesianChart(
                    title: ChartTitle(text: "Birthday Distribution (Weeks)"),
                    legend: Legend(isVisible: false),
                    primaryXAxis: CategoryAxis(),
                    series: <CartesianSeries>[
                      ColumnSeries<GuestBirthday, String>(
                        dataSource: guestBirthdays,
                        xValueMapper: (GuestBirthday guest, _) =>
                            "Week ${guest.weekNumber}",
                        yValueMapper: (GuestBirthday guest, _) =>
                            1, // Count of birthdays
                        dataLabelSettings:
                            const DataLabelSettings(isVisible: true),
                        color: Colors.purpleAccent,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // AI Summary Section (Fake AI-generated insights)
              Card(
                color: Colors.blueGrey[100],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "🎉 AI Birthday Insights",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Today (${todayDate}), we have ${todaysBirthdays.length} guests celebrating their birthdays!"
                        "\nTop guests celebrating: ${todaysBirthdays.isNotEmpty ? todaysBirthdays[0].name : 'None'}, ${todaysBirthdays.length > 1 ? todaysBirthdays[1].name : ''}."
                        "\nConsider sending personalized birthday offers based on their preferred room types!",
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

// Model for Guest Birthday
class GuestBirthday {
  final String name;
  final String date; // Date as a string (e.g., "March 27")
  final int weekNumber; // Week of the month for visualization
  final String ageSegment; // Age segment for personalization
  final String preferredRoom; // Preferred room type

  GuestBirthday(this.name, this.date, this.weekNumber, this.ageSegment,
      this.preferredRoom);

  factory GuestBirthday.fromJson(Map<String, dynamic> json) {
    return GuestBirthday(
      json['name'],
      json['birthdate'],
      json['weekNumber'],
      json['ageSegment'],
      json['preferredRoom'],
    );
  }
}
