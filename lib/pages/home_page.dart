import 'package:flutter/material.dart';
import '../widgets/device_card.dart';
import '../widgets/options_popup.dart';
import 'device_control_page.dart';
import '../services/udp_service.dart';  // ✅ Import UDP Service
import '../services/websocket_service.dart';
import 'package:provider/provider.dart';
import '../providers/network_provider.dart';

import "../pages/settings_page.dart";
import 'package:shared_preferences/shared_preferences.dart';


Future<void> getWiFiDetails(BuildContext context, WebSocketService ws, String ip) async {
  String ssid = "";
  String password = "";

  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Enter Home WiFi Details"),
        content: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            TextField(
              onChanged: (val) => ssid = val,
              decoration: const InputDecoration(labelText: "WiFi SSID"),
            ),
            TextField(
              onChanged: (val) => password = val,
              decoration: const InputDecoration(labelText: "WiFi Password"),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
         TextButton(
            onPressed: () async {
              await ws.sendWiFiDetails(
                ssid,
                password,
                (String deviceId, String ip) async {
                  print("✅ Device $deviceId added with IP $ip");
                  Navigator.pop(context); // Close dialog after success
                },
              );
            },
            child: const Text("Connect"),
          ),
        ],
      );
    },
  );
}



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> devices = [];
    late UDPService _udpService; // ✅ Declare it here
    
  

@override
  void initState() {
    super.initState();
    _udpService = UDPService(); // Initialize it

    discoverDevices();  // ✅ Start discovery when page loads

  }

  Future<void> _logout() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear(); // Clears login session

  // Navigate to login screen using named route
  Navigator.pushReplacementNamed(context, '/login');
}

  /// ✅ **Discover devices via UDP**
  void discoverDevices() {
    _udpService.discoverDevices((String id, String ip) {
      setState(() {
        // ✅ Check if the device already exists
        bool exists = devices.any((device) => device["id"] == id);
        if (!exists) {
          devices.add({
            "id": id,
            "name": "Device-$id",
            "status": false,
            "ip": ip,  // ✅ Store IP
            "model": "Unknown",
            "firmware": "Unknown",
            "lastActive": "Just Now",
          });
        }
      });
    });
  }
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
      drawer: Drawer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 235, 171, 75),
                ),
                child: const Center(
                  child: Text(
                    'Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
              ListTile(
        leading: const Icon(Icons.settings),
        title: const Text("WiFi Settings"),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SettingsPage()),
          );
    },
      ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text("Logout"),
                onTap: () {
                  Navigator.pop(context); // Close drawer
                  _logout(); // ✅ Calls the proper logout
                },
              ),
            ],
          ),
        ),
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
                      // Profile Icon (opens drawer)
                        Builder(
                          builder: (context) {
                            return GestureDetector(
                              onTap: () {
                                Scaffold.of(context).openDrawer();
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Color.fromARGB(255, 235, 171, 75),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.person, color: Colors.white),
                                ),
                            );
                          },
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
