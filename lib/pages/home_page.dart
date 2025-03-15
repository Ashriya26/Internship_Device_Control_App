import 'package:flutter/material.dart';
import '../widgets/device_card.dart';
import '../widgets/options_popup.dart';
import 'device_control_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> devices = [
    {"name": "Main Lights", "status": false, "model": "Light-X1", "firmware": "v1.0.1", "lastActive": "5 mins ago"},
    {"name": "ABC_ui78", "status": false, "model": "SmartPlug-2", "firmware": "v2.3.0", "lastActive": "10 mins ago"},
    {"name": "Mixer", "status": false, "model": "MixPro", "firmware": "v1.5.2", "lastActive": "2 hours ago"},
    {"name": "Hall Fan", "status": false, "model": "CoolBreeze 5", "firmware": "v3.1.4", "lastActive": "30 mins ago"},
    {"name": "EDSF_897yf", "status": false, "model": "Unknown", "firmware": "Unknown", "lastActive": "Offline"},
    {"name": "Bedroom Fan", "status": false, "model": "BreezeMax", "firmware": "v1.2.5", "lastActive": "1 hour ago"},
    {"name": "Bedroom Light", "status": false, "model": "LightBeam", "firmware": "v1.4.0", "lastActive": "20 mins ago"},
    {"name": "Fridge", "status": false, "model": "FreezeMaster", "firmware": "v2.1.1", "lastActive": "15 mins ago"},
    {"name": "AC", "status": false, "model": "CoolX 500", "firmware": "v4.2.0", "lastActive": "3 hours ago"},
    {"name": "GDYGWD_98324", "status": false, "model": "Unknown", "firmware": "Unknown", "lastActive": "Offline"},
  ];

  void updateDeviceStatus(int index, bool newStatus) {
    setState(() {
      devices[index]["status"] = newStatus;
    });
  }

  void deleteDevice(int index) {
    setState(() {
      devices.removeAt(index);
    });
  }

  void showAddOptions(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
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
                  Colors.white70,
                  BlendMode.dstATop,
                ),
              ),
            ),
          ),
          Column(
            children: [
              // AppBar
              Container(
                height: 80,
                margin: const EdgeInsets.only(top: 30),
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

              // Device Grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: devices.length,
                    itemBuilder: (context, index) {
                      return DeviceCard(
                        name: devices[index]["name"],
                        isOn: devices[index]["status"],
                        isConnected: devices[index]["status"],
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DeviceControlPage(
                                deviceName: devices[index]["name"],
                                initialStatus: devices[index]["status"],
                                networkName: "WiFi XYZ",
                                deviceModel: devices[index]["model"],
                                firmwareVersion: devices[index]["firmware"],
                                lastActiveTime: devices[index]["lastActive"],
                              ),
                            ),
                          );

                          if (result == true) {
                            deleteDevice(index);
                          }
                        },
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
