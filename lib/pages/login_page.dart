import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ✅ Background Image (Your Updated Positioning)
          Positioned(
            top: -10, // Adjusted image position (your value)
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                "assets/images/back4.png",
                width: MediaQuery.of(context).size.width*1.0, // Full width
                height: MediaQuery.of(context).size.height*1.0, // Full height
                fit: BoxFit.contain, // Cover entire screen
              ),
            ),
          ),

          // ✅ "Click here to start" button at the bottom
          Positioned(
            bottom: 100, // Keep button near the bottom (your value)
            left: 0,
            right: 0,
            child: Center(child: _buildStartButton()),
          ),
        ],
      ),
    );
  }

  // ✅ "Click here to start" Button
  Widget _buildStartButton() {
    return ElevatedButton(
      onPressed: () {
        _showLoginDialog(); // Show login popup on button click
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: const Text(
        "Click here to start",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  // ✅ Show Login Dialog Box (Popup) - Full Width
  void _showLoginDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor: Colors.white,
          child: Container(
            width: MediaQuery.of(context).size.width, // Full screen width
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Login",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),

                // ✅ Username Field
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: "Username",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
                const SizedBox(height: 10),

                // ✅ Password Field
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
                const SizedBox(height: 15),

                // ✅ Login Button (Centered, Cancel Button Removed)
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pushReplacementNamed(context, "/"); // Go to Home Page
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(
                    "Login",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
