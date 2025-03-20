import 'package:flutter/material.dart';
class DeviceCard extends StatelessWidget {
  final String name;
  final bool isOn;
  final bool isConnected;
  final VoidCallback onTap;
  final Function(bool) onToggleDevice; // ✅ Add this

  const DeviceCard({
    super.key,
    required this.name,
    required this.isOn,
    required this.isConnected,
    required this.onTap,
    required this.onToggleDevice,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12), // Adjusted padding
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
          crossAxisAlignment: CrossAxisAlignment.start, // Aligns all text to the left
          children: [
            // Reduced Space Above Icon
            const SizedBox(height: 5), 
            
            // Device Icon Centered
            Center(
              child: Image.asset(
                isOn ? 'assets/images/light_on.png' : 'assets/images/light_off.png',
                width: 60,
                height: 60,
              ),
            ),

            const SizedBox(height: 3), // Reduced spacing after icon

            // Device Name (First Row)
            Text(
              name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isOn ? Colors.black : Colors.white,
                fontFamily: 'Montserrat',
              ),
              softWrap: true,
              maxLines: 2, // Allows long names to wrap
              overflow: TextOverflow.ellipsis, // Prevents overflow errors
            ),

            const SizedBox(height: 4), // Spacing between name & status
            
            // Connection Status (Second Row)
            Text(
              isConnected ? 'Connected' : 'Offline',
              style: TextStyle(
                fontSize: 14,
                color: isConnected ? Colors.black : Colors.white,
                fontFamily: 'Montserrat',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
