import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/settings_page.dart';
import 'package:provider/provider.dart';
import 'providers/network_provider.dart';

import 'pages/login_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => NetworkProvider()), // Add NetworkProvider
      ],
      child: const MyApp(),
    ),
  );
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
      initialRoute: '/login', // Home Page is the default
      routes: {
        '/login': (content)=> const LoginPage(),
        '/': (context) => const HomePage(),
        '/settings': (context) => const SettingsPage(),
      },
    );
  }
}
