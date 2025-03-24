// import 'package:flutter/material.dart';
// import 'package:hackathon/screens/base_screen.dart';
// import 'package:hackathon/screens/home_screen.dart';
//
// void main() {
//   runApp(MaterialApp(
//     title: 'CiMSO Analysis App',
//     home: BaseScreen(), // This is the first screen after login
//   ));
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'CiMSO',
//       theme: ThemeData(
//         primarySwatch: Colors.green,
//       ),
//       home: const HomeScreen(),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:hackathon/screens/home_screen.dart';
import 'package:hackathon/screens/login_screen.dart';
import 'package:hackathon/screens/base_screen.dart';
import 'package:hackathon/providers/theme_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CiMSO Analysis App',
      theme: themeProvider.currentTheme,
      initialRoute: '/', // Default entry point
      routes: {
        '/': (context) => const HomeScreen(), // Start at HomeScreen
        '/login': (context) => const LoginScreen(), // Login Page
        '/dashboard': (context) => const BaseScreen(), // Dashboard after login
      },
    );
  }
}
