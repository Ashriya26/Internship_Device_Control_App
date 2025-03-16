import 'package:flutter/material.dart';

class EditDeviceWidget extends StatefulWidget {
  final String initialName;
  final Function(String) onNameUpdated;

  const EditDeviceWidget({
    super.key,
    required this.initialName,
    required this.onNameUpdated,
  });

  @override
  _EditDeviceWidgetState createState() => _EditDeviceWidgetState();
}

class _EditDeviceWidgetState extends State<EditDeviceWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _saveName() {
    widget.onNameUpdated(_controller.text);
    Navigator.pop(context); // Close dialog after saving
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: const Color.fromARGB(255, 235, 171, 75), // Orange background
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15), // Rounded edges
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Heading "Edit Device Name" (White & Bold)
                  const Text(
                    "Edit Device Name",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold, // Bolded heading
                      color: Colors.white, // White text
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Text Field for Editing Device Name
                  TextField(
                    controller: _controller,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black, // Device name in Black
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      hintText: "Enter device name",
                      hintStyle: const TextStyle(color: Colors.black54),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Save Button (Darker Orange with White Text)
                  ElevatedButton(
                    onPressed: _saveName,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD17D00), // Darker orange
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    ),
                    child: const Text(
                      "Save",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white, // White text
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      child: const Icon(Icons.edit, color: Colors.orange, size: 28), // Edit icon
    );
  }
}
