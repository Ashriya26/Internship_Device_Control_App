import 'package:flutter/material.dart';

class OptionsPopup extends StatelessWidget {
  const OptionsPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 100, // Adjust vertical position
          right: 20, // Adjust horizontal position
          child: Material(
            color: Colors.transparent, // To match the UI
            child: Container(
              width: 200, // Smaller width instead of full screen
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 235, 171, 75), // 🔸 Full orange background
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 📌 Add Device Button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15), // Rounded corners
                    ),
                    child: ListTile(
                      leading: const Text(
                        "Add Device",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      trailing: const Icon(
                        Icons.add_circle_outline,
                        color: Color.fromARGB(255, 235, 171, 75),
                        size: 24,
                      ),
                      onTap: () {
                        Navigator.pop(context); // Close popup
                      },
                    ),
                  ),

                  const SizedBox(height: 10), // Space between buttons

                  // ⚙️ Settings Button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15), // Rounded corners
                    ),
                    child: ListTile(
                      leading: const Text(
                        "Settings",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      trailing: const Icon(
                        Icons.settings,
                        color: Color.fromARGB(255, 235, 171, 75),
                        size: 24,
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, '/settings');
                      },

                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
