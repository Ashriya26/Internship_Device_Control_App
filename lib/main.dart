import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/settings_page.dart';
import 'package:provider/provider.dart';
import 'providers/network_provider.dart';
import 'pages/start_page.dart'; // Import StartPage
import 'package:shared_preferences/shared_preferences.dart';
import 'services/database_service.dart';

import 'pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required for async initialization
  await _initializeApp(); // Call initialization function

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => NetworkProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

Future<void> _initializeApp() async {
  final prefs = await SharedPreferences.getInstance();
  bool isFirstTime = prefs.getBool('isFirstTime') ?? true;

  if (isFirstTime) {
    await DatabaseHelper.instance.insertUser("admin", "1234"); // ✅ Insert user
    await prefs.setBool('isFirstTime', false); // ✅ Mark app as initialized
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IoT Device Manager',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        fontFamily: 'Montserrat',
      ),
      initialRoute: '/start', // Home Page is the default
      routes: {
        '/start' :(context) => const StartPage(),
        '/login': (context)=> const LoginPage(),
        '/': (context) => const HomePage(),
        '/settings': (context) => const SettingsPage(),
      },
    );
  }
}
