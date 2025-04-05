import 'package:flutter/material.dart';
import 'login_page.dart'; // Import LoginPage
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  Future<void> _navigateToNextScreen(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // ✅ Set background color to white
      body: Stack(
        children: [
          // ✅ Background Image Above White Background
          Positioned(
            top: -20, // Adjust if needed
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                "assets/images/back4.png",
                width: MediaQuery.of(context).size.width * 1.0, // Full width
                height: MediaQuery.of(context).size.height * 1.0, // Adjust height if needed
                fit: BoxFit.contain, // Keep image proportions
              ),
            ),
          ),

          // ✅ "Click here to start" button at the bottom
          Positioned(
            bottom: 120, // Adjust if needed
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to Login Page
                      _navigateToNextScreen(context); // ✅ THIS is the fix

                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text(
                  "Get Started",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
