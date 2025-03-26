import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Screens
import 'package:hackathon/screens/home_screen.dart';
import 'package:hackathon/screens/login_screen.dart';
import 'package:hackathon/screens/base_screen.dart';

// Providers
import 'package:hackathon/providers/theme_provider.dart';
import 'package:hackathon/providers/auth_provider.dart';
import 'package:hackathon/providers/language_provider.dart';

// Services
import 'package:hackathon/services/auth_service.dart';
import 'package:hackathon/services/pdf_repository.dart';

void main() async {
  // Make sure Flutter is initialized before any async calls
  WidgetsFlutterBinding.ensureInitialized();

  // (Optional) Initialize AuthService if you're handling user sessions
  await AuthService.initialize();

  // Load the PDF from assets/fakedata.pdf and extract text with Syncfusion
  await PdfRepository().loadPdfAndExtract();

  // Run the app with MultiProvider
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Access your dynamic theme if you like
    final themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CiMSO Analysis App',
      theme: themeProvider.currentTheme,
      // Default route
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) =>
            const BaseScreen(), // main dashboard after login
      },
    );
  }
}
