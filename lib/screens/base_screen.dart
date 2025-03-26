import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// Providers
import 'package:hackathon/providers/theme_provider.dart';
import 'package:hackathon/providers/auth_provider.dart';
import 'package:hackathon/providers/language_provider.dart';

// Screens (existing ones)
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

// New AI PDF Chat screen
import 'package:hackathon/screens/ai_pdf_chat_screen.dart';

class BaseScreen extends StatefulWidget {
  const BaseScreen({Key? key}) : super(key: key);

  @override
  _BaseScreenState createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pageOptions = [
    // Existing analysis pages
    const BookingArrivalsScreen(),
    const CompareArrivalBookingsScreen(),
    const TodaysArrivalDepartureScreen(),
    const OccupancyRateScreen(),
    const GuestBirthdayScreen(),
    const AgeGroupSegmentationScreen(),
    const CanceledBookingsScreen(),
    const MostFrequentUnitsScreen(),
    const TotalIncomeScreen(),
    //  New PDF AI Chat page
    const AiPdfChatScreen(),
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
    "AI Powered Chat",
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
            // Drawer header with full width
            Container(
              width: double.infinity,
              color: Colors.blue, // Ensures full background color
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    width: 100,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 10),
                  Consumer<LanguageProvider>(
                    builder: (context, languageProvider, _) => Text(
                      languageProvider.getTranslatedText('Analysis Dashboard'),
                      style: GoogleFonts.lato(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Navigation List for pages
            Expanded(
              child: ListView.builder(
                itemCount: _titles.length,
                itemBuilder: (context, index) {
                  return _buildDrawerItem(_titles[index], index);
                },
              ),
            ),

            // Language Toggle
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
                title: Text(
                  languageProvider.getTranslatedText('Logout'),
                  style: GoogleFonts.lato(fontSize: 16),
                ),
                onTap: () async {
                  await authProvider.logout();
                  Navigator.of(context).pop(); // close drawer
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
        title: Text(
          languageProvider.getTranslatedText(title),
          style: GoogleFonts.lato(fontSize: 16),
        ),
        selected: _selectedIndex == index,
        onTap: () => _onSelectPage(index),
      ),
    );
  }
}
