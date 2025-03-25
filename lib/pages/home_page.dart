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
    {"id": "1", "name": "Main Lights", "status": false, "model": "Light-X1", "firmware": "v1.0.1", "lastActive": "5 mins ago"},
    {"id": "2", "name": "ABC_ui78", "status": false, "model": "SmartPlug-2", "firmware": "v2.3.0", "lastActive": "10 mins ago"},
    {"id": "3", "name": "Mixer", "status": false, "model": "MixPro", "firmware": "v1.5.2", "lastActive": "2 hours ago"},
    {"id": "4", "name": "Hall Fan", "status": false, "model": "CoolBreeze 5", "firmware": "v3.1.4", "lastActive": "30 mins ago"},
    {"id": "5", "name": "EDSF_897yf", "status": false, "model": "Unknown", "firmware": "Unknown", "lastActive": "Offline"},
    {"id": "6", "name": "Bedroom Fan", "status": false, "model": "BreezeMax", "firmware": "v1.2.5", "lastActive": "1 hour ago"},
    {"id": "7", "name": "Bedroom Light", "status": false, "model": "LightBeam", "firmware": "v1.4.0", "lastActive": "20 mins ago"},
    {"id": "8", "name": "Fridge", "status": false, "model": "FreezeMaster", "firmware": "v2.1.1", "lastActive": "15 mins ago"},
    {"id": "9", "name": "AC", "status": false, "model": "CoolX 500", "firmware": "v4.2.0", "lastActive": "3 hours ago"},
    {"id": "10", "name": "GDYGWD_98324", "status": false, "model": "Unknown", "firmware": "Unknown", "lastActive": "Offline"},
  ];

void updateDeviceStatus(String name, bool status) {
  setState(() {
    devices = devices.map((device) {
      if (device["name"] == name) {
        device["status"] = status; // Update status in device list
      }
      return device;
    }).toList();
  });
}
  /// ✅ **Function to update device name**
  void updateDeviceName(String deviceId, String newName) {
    setState(() {
      int index = devices.indexWhere((device) => device["id"] == deviceId);
      if (index != -1) {
        devices[index]["name"] = newName;
      }
    });
  }


  void deleteDevice(String deviceId) {
    setState(() {
      int indexToDelete = devices.indexWhere((device) => device["id"] == deviceId);
      if (indexToDelete != -1) {
        devices.removeAt(indexToDelete);
      }
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
    return WillPopScope(
    onWillPop: () async {
      return false; // 🔹 Prevents going back to login page
    },
    
    child: Scaffold(
      body: Stack(
        children: [
          // 🔹 Background Image
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
              // 🔹 AppBar
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
                        onTap: () {// 🔹 Logout and go back to login
                          Navigator.pushReplacementNamed(context, '/login');
                          },
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

              // 🔹 Device Grid
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
                                onDeleteDevice: (deviceName) {
                                  String deviceIdToDelete = devices[index]["id"];
                                  deleteDevice(deviceIdToDelete);
                                },
                                /// ✅ **Pass `onNameUpdated` to update Home Page**
                                onNameUpdated: (newName) {
                                  updateDeviceName(devices[index]["id"], newName);
                                },
                                /// ✅ Pass `onToggleDevice` to update in real-time
                                onToggleDevice: (newStatus) {
                                  setState(() {
                                    devices[index]["status"] = newStatus;
                                  });
                                },
                              ),
                            ),
                          );

                          // ✅ Fix: Check if the device still exists before updating
                          if (result is bool) {
                            setState(() {
                              int updatedIndex = devices.indexWhere((device) => device["id"] == devices[index]["id"]);
                              if (updatedIndex != -1) {
                                devices[updatedIndex]["status"] = result;
                              }
                            });
                          }
                        },
                        /// ✅ **Fix: Add `onToggleDevice` here too**
                        onToggleDevice: (newStatus) {
                          setState(() {
                            devices[index]["status"] = newStatus;
                          });
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
    ),
    );
  }
}
