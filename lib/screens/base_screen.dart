// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:hackathon/screens/booking_arrivals_screen.dart';
// import 'package:hackathon/screens/compare_arrival_bookings_screen.dart';
// import 'package:hackathon/screens/todays_arrival_departure_screen.dart';
// import 'package:hackathon/screens/occupancy_rate_screen.dart';
// import 'package:hackathon/screens/guest_birthday_screen.dart';
// import 'package:hackathon/screens/age_group_segmentation.dart';
// import 'package:hackathon/screens/canceled_bookings_screen.dart';
// import 'package:hackathon/screens/most_frequent_units_screen.dart';
// import 'package:hackathon/screens/total_income_screen.dart'; // ✅ Added new page import
//
// class BaseScreen extends StatefulWidget {
//   const BaseScreen({Key? key}) : super(key: key);
//
//   @override
//   _BaseScreenState createState() => _BaseScreenState();
// }
//
// class _BaseScreenState extends State<BaseScreen> {
//   int _selectedIndex = 0;
//
//   final List<Widget> _pageOptions = [
//     const BookingArrivalsScreen(),
//     const CompareArrivalBookingsScreen(),
//     const TodaysArrivalDepartureScreen(),
//     const OccupancyRateScreen(),
//     const GuestBirthdayScreen(),
//     const AgeGroupSegmentationScreen(),
//     const CanceledBookingsScreen(),
//     const MostFrequentUnitsScreen(),
//     const TotalIncomeScreen(), // ✅ Added new page
//   ];
//
//   final List<String> _titles = [
//     "Booking Arrivals",
//     "Compare Arrival Bookings",
//     "Today's Arrivals & Departures",
//     "Occupancy Rate & ADR",
//     "Guest Birthdays",
//     "Age Group Segmentation",
//     "Canceled Bookings",
//     "Most Frequently Booked Units",
//     "Total Income Analysis", // ✅ Added new page title
//   ];
//
//   void _onSelectPage(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//     Navigator.of(context).pop(); // Close the drawer after selection
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Analysis Dashboard", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//       ),
//       body: _pageOptions[_selectedIndex], // Show the selected page content
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: <Widget>[
//             DrawerHeader(
//               decoration: const BoxDecoration(color: Colors.blue),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Image.asset('assets/images/logo.png', width: 100),
//                   const SizedBox(height: 10),
//                   const Text(
//                     'Analysis Dashboard',
//                     style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
//                   ),
//                 ],
//               ),
//             ),
//             _buildDrawerItem("Booking Arrivals", 0),
//             _buildDrawerItem("Compare Arrival Bookings", 1),
//             _buildDrawerItem("Today's Arrivals & Departures", 2),
//             _buildDrawerItem("Occupancy Rate & ADR", 3),
//             _buildDrawerItem("Guest Birthdays", 4),
//             _buildDrawerItem("Age Group Segmentation", 5),
//             _buildDrawerItem("Canceled Bookings", 6),
//             _buildDrawerItem("Most Frequently Booked Units", 7),
//             _buildDrawerItem("Total Income Analysis", 8), // ✅ Added new page to drawer
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDrawerItem(String title, int index) {
//     return ListTile(
//       title: Text(title, style: const TextStyle(fontSize: 16)),
//       selected: _selectedIndex == index,
//       onTap: () => _onSelectPage(index),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:hackathon/providers/theme_provider.dart';
import 'package:hackathon/providers/auth_provider.dart';
import 'package:hackathon/providers/language_provider.dart';
import 'package:hackathon/screens/booking_arrivals_screen.dart';
import 'package:hackathon/screens/compare_arrival_bookings_screen.dart';
import 'package:hackathon/screens/todays_arrival_departure_screen.dart';
import 'package:hackathon/screens/occupancy_rate_screen.dart';
import 'package:hackathon/screens/guest_birthday_screen.dart';
import 'package:hackathon/screens/age_group_segmentation.dart';
import 'package:hackathon/screens/canceled_bookings_screen.dart';
import 'package:hackathon/screens/most_frequent_units_screen.dart';
import 'package:hackathon/screens/total_income_screen.dart';
import 'package:hackathon/screens/home_screen.dart';

class BaseScreen extends StatefulWidget {
  const BaseScreen({Key? key}) : super(key: key);

  @override
  _BaseScreenState createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pageOptions = [
    const BookingArrivalsScreen(),
    const CompareArrivalBookingsScreen(),
    const TodaysArrivalDepartureScreen(),
    const OccupancyRateScreen(),
    const GuestBirthdayScreen(),
    const AgeGroupSegmentationScreen(),
    const CanceledBookingsScreen(),
    const MostFrequentUnitsScreen(),
    const TotalIncomeScreen(),
  ];

  final List<String> _titles = [
    "Booking Arrivals",
    "Compare Arrival Bookings",
    "Today's Arrivals & Departures",
    "Occupancy Rate & ADR",
    "Guest Birthdays",
    "Age Group Segmentation",
    "Canceled Bookings",
    "Most Frequently Booked Units",
    "Total Income Analysis",
  ];

  void _onSelectPage(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.of(context).pop(); // Close the drawer after selection
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<LanguageProvider>(
          builder: (context, languageProvider, _) => Text(
            languageProvider.getTranslatedText("Analysis Dashboard"),
            style: GoogleFonts.lato(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          // Dark mode toggle button
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) => IconButton(
              icon: Icon(
                themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              ),
              onPressed: () {
                themeProvider.toggleTheme();
              },
              tooltip: themeProvider.isDarkMode
                  ? 'Switch to Light Mode'
                  : 'Switch to Dark Mode',
            ),
          ),
        ],
      ),
      body: _pageOptions[_selectedIndex], // Show the selected page content
      drawer: Drawer(
        child: Column(
          children: [
            // ✅ Fixed Drawer Header to cover full width
            Container(
              width: double.infinity,
              color: Colors.blue, // Ensures full background color
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/images/logo.png',
                      width: 100, fit: BoxFit.contain),
                  const SizedBox(height: 10),
                  Consumer<LanguageProvider>(
                    builder: (context, languageProvider, _) => Text(
                      languageProvider.getTranslatedText('Analysis Dashboard'),
                      style: GoogleFonts.lato(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            // Navigation List
            Expanded(
              child: ListView.builder(
                itemCount: _titles.length,
                itemBuilder: (context, index) {
                  return _buildDrawerItem(_titles[index], index);
                },
              ),
            ),

            // Language Toggle Button
            const Divider(),
            Consumer<LanguageProvider>(
              builder: (context, languageProvider, _) => ListTile(
                leading: const Icon(Icons.language),
                title: Text(
                  languageProvider.getTranslatedText('Language'),
                  style: GoogleFonts.lato(fontSize: 16),
                ),
                trailing: Switch(
                  value: languageProvider.isThai,
                  onChanged: (value) async {
                    await languageProvider.toggleLanguage();
                  },
                  activeThumbImage: const AssetImage('assets/images/logo.png'),
                  inactiveThumbImage:
                      const AssetImage('assets/images/logo.png'),
                  activeColor: Colors.blue,
                ),
                subtitle: Text(
                  languageProvider.isThai
                      ? languageProvider.getTranslatedText('Thai')
                      : languageProvider.getTranslatedText('English'),
                  style: GoogleFonts.lato(fontSize: 12),
                ),
              ),
            ),

            // Logout Button
            const Divider(),
            Consumer2<AuthProvider, LanguageProvider>(
              builder: (context, authProvider, languageProvider, _) => ListTile(
                leading: const Icon(Icons.logout),
                title: Text(languageProvider.getTranslatedText('Logout'),
                    style: GoogleFonts.lato(fontSize: 16)),
                onTap: () async {
                  await authProvider.logout();
                  // Close drawer
                  Navigator.of(context).pop();
                  // Navigate to home screen
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (route) => false,
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(String title, int index) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, _) => ListTile(
        title: Text(languageProvider.getTranslatedText(title),
            style: GoogleFonts.lato(fontSize: 16)),
        selected: _selectedIndex == index,
        onTap: () => _onSelectPage(index),
      ),
    );
  }
}
