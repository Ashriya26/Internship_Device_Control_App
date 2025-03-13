import 'package:flutter/material.dart';

class DeviceCard extends StatelessWidget {
  final String name;
  final bool isOn;
  final bool isConnected; // To determine connection status (True/False)
  final VoidCallback onTap;

  const DeviceCard({
    super.key,
    required this.name,
    required this.isOn,
    required this.isConnected, // Adding this parameter
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isOn ? Colors.white : const Color.fromARGB(255, 99, 99, 99),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align everything to the left
          children: [
            // Image at the center, with larger icon size
            Center(
              child: Image.asset(
                isOn 
                  ? 'assets/images/light_on.png' 
                  : 'assets/images/light_off.png',  // Change icon based on state
                width: isOn ? 63.5 : 50, // Set larger width for 'on' state
                height: isOn ? 63.5 : 50, // Set larger height for 'on' state
              ),
            ),
            const SizedBox(height: 0.5), // Reduced gap
            // Device name text
            Text(
              name,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: isOn ? Colors.black : Colors.white,
                fontFamily: 'Montserrat', // Using custom font
              ),
            ),
            const SizedBox(height: 0.5), // Reduced gap
            // Connection status text (Connected / Offline)
            Text(
              isConnected ? 'Connected' : 'Offline',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.normal,
                color: isConnected ? const Color.fromARGB(255, 0, 0, 0) : const Color.fromARGB(255, 255, 255, 255),
                fontFamily: 'Montserrat', // Using custom font
              ),
            ),
            const SizedBox(height: 0.5), // Reduced gap to the bottom
          ],
        ),
      ),
    );
  }
}
