import 'package:flutter/material.dart';

class DeleteDevicePopup extends StatelessWidget {
  final VoidCallback onDelete;

  const DeleteDevicePopup({super.key, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent, // Transparent to match UI
      child: Container(
        width: 280, // Smaller width
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 235, 171, 75), // Orange background
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🔹 White Header Box (Smaller & Lower)
            Container(
              width: 230, // Smaller than options box
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Delete Device",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  const Icon(
                    Icons.delete,
                    color: Color.fromARGB(255, 235, 171, 75),
                    size: 24,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20), // Space below the header

            // 🔹 Confirmation Text
            const Text(
              "Are you sure you want to delete this device?",
              style: TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // 🔹 Centered Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Cancel Button
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 200, 120, 50), // Darker orange
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                const SizedBox(width: 10), // Space between buttons

                // Confirm Button
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 200, 120, 50), // Darker orange
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    onDelete(); // Calls delete function
                    Navigator.pop(context); // Closes popup
                    Navigator.pop(context); // Closes Device Control Page
                  },
                  child: const Text(
                    "Confirm",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
