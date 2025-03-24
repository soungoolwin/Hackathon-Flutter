import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:math';

class GuestBirthdayScreen extends StatefulWidget {
  const GuestBirthdayScreen({Key? key}) : super(key: key);

  @override
  _GuestBirthdayScreenState createState() => _GuestBirthdayScreenState();
}

class _GuestBirthdayScreenState extends State<GuestBirthdayScreen> {
  List<GuestBirthday> guestBirthdays = [];
  List<GuestBirthday> filteredGuests = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    guestBirthdays = _generateSampleBirthdays();
    filteredGuests = guestBirthdays;
  }

  // Generates random sample guest birthday data
  List<GuestBirthday> _generateSampleBirthdays() {
    List<String> names = [
      "John Doe", "Emma Smith", "Liam Johnson", "Sophia Brown", "Mason Lee",
      "Ava Garcia", "James Wilson", "Isabella Martinez", "Ethan Thomas", "Olivia Taylor"
    ];
    List<String> dates = ["Feb 3", "Feb 8", "Feb 12", "Feb 15", "Feb 18", "Feb 21", "Feb 25", "Feb 28"];

    Random random = Random();
    return List.generate(10, (index) {
      return GuestBirthday(names[index], dates[random.nextInt(dates.length)], random.nextInt(4) + 1);
    });
  }

  // Filters the guest list based on search query
  void _filterSearchResults(String query) {
    setState(() {
      filteredGuests = guestBirthdays.where((guest) {
        return guest.name.toLowerCase().contains(query.toLowerCase());
      }).toList();
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
              // Search Field
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: "Search Guest",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
                        leading: const Icon(Icons.cake, color: Colors.pinkAccent),
                        title: Text(filteredGuests[index].name),
                        subtitle: Text("Birthday: ${filteredGuests[index].date}"),
                      ),
                    );
                  },
                ),
              ),

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
                        xValueMapper: (GuestBirthday guest, _) => "Week ${guest.weekNumber}",
                        yValueMapper: (GuestBirthday guest, _) => 1, // Count of birthdays
                        dataLabelSettings: const DataLabelSettings(isVisible: true),
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
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "This month, most guest birthdays fall in the third week of February."
                            "\nTop guests celebrating: ${guestBirthdays[0].name}, ${guestBirthdays[1].name}."
                            "\nConsider sending personalized birthday offers or discounts!",
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

// Sample model for Guest Birthday
class GuestBirthday {
  final String name;
  final String date; // Date as a string (e.g., "Feb 14")
  final int weekNumber; // Week of the month for visualization

  GuestBirthday(this.name, this.date, this.weekNumber);
}