import 'package:flutter/material.dart';
import 'home_page.dart';
import '../services/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isButtonEnabled = false;
  String? _usernameError;
  String? _passwordError;
  String? _errorMessage; // Stores the error message

  @override
  void initState() {
    super.initState();
    _checkIfLoggedIn(); // ✅ Check if already logged in

    _usernameController.addListener(_validateFields);
    _passwordController.addListener(_validateFields);
  }

  Future<void> _checkIfLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isLoggedIn = prefs.getBool('isLoggedIn');
    if (isLoggedIn == true) {
      // ✅ If already logged in, go to HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }


  void _validateFields() {
    setState(() {
      _usernameError = _usernameController.text.isEmpty ? "Please enter username" : null;
      _passwordError = _passwordController.text.isEmpty ? "Please enter password" : null;
      _isButtonEnabled = _usernameController.text.isNotEmpty && _passwordController.text.isNotEmpty;
    });
  }

Future<void> _login() async {
  String username = _usernameController.text.trim();
  String password = _passwordController.text.trim();

  final user = await DatabaseHelper.instance.getUser(username, password);

  if (user != null) {
    // ✅ Save login state
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);

    // ✅ Go to Home Page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  } else {
    setState(() {
      _errorMessage = "Invalid username or password"; // 🔹 Show error inside UI
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // ✅ Prevents keyboard from pushing UI
      body: Stack(
        children: [
          // ✅ Background Image
          Positioned.fill(
            child: Image.asset(
              "assets/images/back2.png", // Replace with your image
              fit: BoxFit.cover, // Cover entire screen
            ),
          ),

          // ✅ Login Dialog Positioned Towards the Top
          Positioned(
            top: 90, // Adjust this value to move it up/down
            left: 30, // Adjust left padding
            right: 30, // Adjust right padding
            child: Material(
              elevation: 10,
              borderRadius: BorderRadius.circular(15),
              color: Colors.white.withOpacity(0.9),
              child: Padding(
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
                        errorText: _usernameError,
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
                        errorText: _passwordError,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                    ),
                    const SizedBox(height: 15),
                    // 🔹 ERROR MESSAGE (Appears Below Input Fields)
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    // ✅ Login Button
                    ElevatedButton(
                      onPressed: _isButtonEnabled
                          ? () async {
                              final user = await DatabaseHelper.instance.getUser(
                                _usernameController.text,
                                _passwordController.text,
                              );

                              if (user != null) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const HomePage()),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Invalid username or password")),
                                );
                              }
                            }
                          : null,
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
            ),
          ),

          // ✅ GIF at the Bottom (Fixed Position)
          Positioned(
            bottom: 50, // Fixed position
            left: 0,
            right: 0,
            child: Image.asset(
              "assets/images/login.gif",
              width: 300,
              height: 300,
            ),
          ),
        ],
      ),
    );
  }
}
