import 'package:flutter/material.dart';
import '../widgets/device_card.dart';
import '../widgets/options_popup.dart';
import 'device_control_page.dart';
import '../services/udp_service.dart';  // ✅ Import UDP Service
import '../services/websocket_service.dart';
import '../services/database_service.dart';
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
    bool showDeviceInfoPopup = true; // Flag to control the popup visibility

  

@override
  void initState() {
    super.initState();
    loadDevices(); // load devices initially
    _udpService = UDPService(); // Initialize it

    discoverDevices();  // ✅ Start discovery when page loads

  }



  Future<void> _logout() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear(); // Clears login session

  // Navigate to login screen using named route
  Navigator.pushReplacementNamed(context, '/login');
}

   Future<void> loadDevices() async {
  final raw = await DatabaseHelper.instance.getAllDevices();
  devices = raw.map((d) => {
    'id':          (d['device_id'] as String?) ?? d['id'].toString(),
    'device_name': (d['device_name'] as String?) ?? 'Device-${d['device_id'] ?? d['id']}',
    // **Convert int → bool here:**
    'status':      (d['status'] as int? ?? 0) == 1,
    'ip':          d['ip']    as String? ?? '',
    'model':       d['device_type']  as String? ?? 'Unknown',
    'firmware':    d['firmware'] as String? ?? 'Unknown',
    'lastActive':  d['lastActive'] as String? ?? 'Just Now',
  }).toList();
  setState(() {});
}

Future<void> refreshDevices() => loadDevices();


  /// ✅ **Discover devices via UDP**
  void discoverDevices() {
    _udpService.discoverMockDevices((String id, String ip,String model, String firmware, String lastActive) {
      setState(() {
        // ✅ Check if the device already exists
        bool exists = devices.any((device) => device["id"] == id);
        if (!exists) {
          devices.add({
            "id": id,
            "name": "Device-$id",
            "status": 0,
            "ip": ip,  // ✅ Store IP
            "model": model.isNotEmpty ? model : "Unknown",
            "firmware": firmware.isNotEmpty ? firmware : "Unknown",
            "lastActive": lastActive.isNotEmpty ? lastActive : "Just Now",
       
          });
          print("Device added: $id");
            } else {
              print("Device already exists: $id");
  
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
  Future<void> updateDeviceName(String deviceId, String newName) async {
  await DatabaseHelper.instance.updateDeviceName(deviceId, newName);
  setState(() {
    final idx = devices.indexWhere((d) => d['id'] == deviceId);
    if (idx != -1) devices[idx]['device_name'] = newName;
  });
}



Future<void> deleteDevice(String deviceId) async {
  await DatabaseHelper.instance.deleteDevice(deviceId);
  setState(() {
    devices.removeWhere((d) => d['id'] == deviceId);
  });
}

  // Function to load devices (fetch from the mock database or service)
  

  void showAddOptions(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
      return OptionsPopup(
        onDeviceAdded: refreshDevices, // ✅ Pass callback here
      );      },
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
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 235, 171, 75),
                ),
                child: Center(
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
            MaterialPageRoute(builder: (context) => const SettingsPage()),
          );
            },
              ),
              const SizedBox(height:16),
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
                      final device = devices[index];

                      // 1️⃣ First try the TEXT device_id, else fallback to PK.toString()
                      final id = (device['device_id'] as String?) 
                                  ?? (device['id']?.toString() ?? '');

                      // 2️⃣ Build a name: use your in‐memory 'name' if set, otherwise "Device-$id"
                      final name = (device['device_name'] as String?) 
                                    ?? 'Device-$id';

                      // 3️⃣ Status was a bool? in your map, so default it to false
                      final status = device['status'] as bool;

                      // 4️⃣ Everything else you had already defaulted correctly:
                      final model      = (device['model']     as String?) ?? 'Unknown';
                      final firmware   = (device['firmware']  as String?) ?? 'Unknown';
                      final lastActive = (device['lastActive']as String?) ?? 'Just Now';
                      return DeviceCard(
                        name:        name,
                        isOn:        status,
                        isConnected: status,
                        onTap: () async {
                          // 1) push control page, wait for returned bool
                          final bool? newStatus = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DeviceControlPage(
                                deviceId:      id,
                                deviceName:    name,
                                initialStatus: status,
                                networkName:   "WiFi XYZ",
                                deviceModel:   model,
                                firmwareVersion: firmware,
                                lastActiveTime:  lastActive,
                                onDeleteDevice: (deletedId) => deleteDevice(deletedId),
                                
                                onNameUpdated: (newName) {
                                  // This is your HomePage helper:
                                  updateDeviceName(id, newName);
                                },
                                onToggleDevice: (_){},// you can safely leave this empty now
                              ),
                            ),
                          );

                          // 2) if user toggled, rebuild only that card
                          if (newStatus != null) {
                            setState(() {
                              devices[index]['status'] = newStatus ;
                            });
                          }
                        },
                        // 2) Satisfy the other required callback
                        onToggleDevice: (_) {
                          // optional: if you ever want a quick-tap-on-card to toggle,
                          // you can call the same flow here. For now, leave it empty.
                        },
                        // no onToggleDevice callback needed here any more
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