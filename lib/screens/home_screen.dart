import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hackathon/widgets/info_card.dart';
import 'package:hackathon/screens/register_screen.dart';
import 'package:hackathon/screens/login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: const Text("Log in", style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RegisterScreen()),
              );
            },
            child: const Text("Register", style: TextStyle(color: Colors.black)),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // Display the CiMSO Logo with error handling
            Center(
              child: Image.asset(
                'assets/images/logo.png',
                width: 120,
                errorBuilder: (context, error, stackTrace) {
                  return const Text(
                    "Image not found",
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  );
                },
              ),
            ),

            const SizedBox(height: 40),
            Expanded(
              child: ListView(
                children: const [
                  InfoCard(
                    title: "Membership Platform",
                    description:
                    "Join our exclusive membership platform designed specifically for resort and hotel management. Access premium features and connect with industry professionals.",
                  ),
                  SizedBox(height: 20),
                  InfoCard(
                    title: "Customer-Centric Solutions",
                    description:
                    "Experience our innovative software solutions designed to enhance your hotel and resort operations. Put your customers first with our comprehensive management tools.",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}