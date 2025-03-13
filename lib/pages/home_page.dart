import 'package:flutter/material.dart';
import '../widgets/device_card.dart';
import '../widgets/options_popup.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> devices = [
    {"name": "Main Lights", "status": true},
    {"name": "ABC_ui78", "status": false},
    {"name": "Mixer", "status": true},
    {"name": "Hall Fan", "status": true},
    {"name": "EDSF_897yf", "status": true},
    {"name": "Main Lights", "status": true},
    {"name": "ABC_ui78", "status": false},
    {"name": "Mixer", "status": true},
    {"name": "Hall Fan", "status": false},
    {"name": "EDSF_897yf", "status": true}
  ];

  void toggleDevice(int index) {
    setState(() {
      devices[index]["status"] = !devices[index]["status"];
    });
  }

void showAddOptions(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true, // Close when tapping outside
    builder: (BuildContext context) {
      return const OptionsPopup();
    },
  );
}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/back2.png'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.white70, // Apply a lighter overlay
                  BlendMode.dstATop,
                ),
              ),
            ),
          ),
          Column(
            children: [
              Container(
                height: 80, // Adjusted height
                margin: const EdgeInsets.only(top: 30), // Moves the taskbar down
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 235, 171, 75),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                      ),
                      const Text(
                        "IoT Device Manager",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => showAddOptions(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 235, 171, 75),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add_circle_outline, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: devices.length,
                    itemBuilder: (context, index) {
                      return DeviceCard(
                        name: devices[index]["name"],
                        isOn: devices[index]["status"],
                        isConnected: devices[index]["status"],
                        onTap: () => toggleDevice(index),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
