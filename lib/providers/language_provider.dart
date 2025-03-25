import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  // Key for storing language preference
  static const String _languagePreferenceKey = 'language_preference';

  // Default to English
  bool _isThai = false;

  // Getter for current language
  bool get isThai => _isThai;

  // Constructor - loads saved preference
  LanguageProvider() {
    _loadLanguagePreference();
  }

  // Load language preference from SharedPreferences
  Future<void> _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isThai = prefs.getBool(_languagePreferenceKey) ?? false;
    notifyListeners();
  }

  // Toggle between English and Thai
  Future<void> toggleLanguage() async {
    _isThai = !_isThai;

    // Save preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_languagePreferenceKey, _isThai);

    // Notify listeners to rebuild UI
    notifyListeners();
  }

  // Translation map for navigation items
  Map<String, Map<String, String>> translations = {
    'Booking Arrivals': {
      'en': 'Booking Arrivals',
      'th': 'การจองที่มาถึง',
    },
    'Compare Arrival Bookings': {
      'en': 'Compare Arrival Bookings',
      'th': 'เปรียบเทียบการจองที่มาถึง',
    },
    "Today's Arrivals & Departures": {
      'en': "Today's Arrivals & Departures",
      'th': 'การมาถึงและออกเดินทางวันนี้',
    },
    'Occupancy Rate & ADR': {
      'en': 'Occupancy Rate & ADR',
      'th': 'อัตราการเข้าพักและ ADR',
    },
    'Guest Birthdays': {
      'en': 'Guest Birthdays',
      'th': 'วันเกิดของแขก',
    },
    'Age Group Segmentation': {
      'en': 'Age Group Segmentation',
      'th': 'การแบ่งกลุ่มตามอายุ',
    },
    'Canceled Bookings': {
      'en': 'Canceled Bookings',
      'th': 'การจองที่ถูกยกเลิก',
    },
    'Most Frequently Booked Units': {
      'en': 'Most Frequently Booked Units',
      'th': 'หน่วยที่จองบ่อยที่สุด',
    },
    'Total Income Analysis': {
      'en': 'Total Income Analysis',
      'th': 'การวิเคราะห์รายได้ทั้งหมด',
    },
    'Logout': {
      'en': 'Logout',
      'th': 'ออกจากระบบ',
    },
    'Analysis Dashboard': {
      'en': 'Analysis Dashboard',
      'th': 'แดชบอร์ดการวิเคราะห์',
    },
    'Language': {
      'en': 'Language',
      'th': 'ภาษา',
    },
    'English': {
      'en': 'English',
      'th': 'อังกฤษ',
    },
    'Thai': {
      'en': 'Thai',
      'th': 'ไทย',
    },
  };

  // Get translated text
  String getTranslatedText(String key) {
    if (translations.containsKey(key)) {
      return _isThai ? translations[key]!['th']! : translations[key]!['en']!;
    }
    return key; // Return the original text if no translation is found
  }
}
