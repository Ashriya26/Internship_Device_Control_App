// import 'package:flutter/material.dart';
// import '../services/database_service.dart';
// import '../services/udp_service.dart';
// import '../services/websocket_service.dart';
// import '../providers/network_provider.dart';
// import '../services/mock_device_service.dart';

// class OptionsPopup extends StatelessWidget {
//   const OptionsPopup({super.key});

//   Future<void> _addDevice(BuildContext context) async {
//     // final NetworkProvider network = NetworkProvider();
//     // final WebSocketService ws = WebSocketService();
//     // final UDPService udp = UDPService();
//     final db = DatabaseHelper.instance;
//     final mock = MockDeviceService(); // ✅ Use the mock device service

//     // Step 1: Connect to ESP Access Point (192.168.4.1)
//     // bool connected = await network.connectToESP();
//     // if (!connected) {
//     //   ScaffoldMessenger.of(context).showSnackBar(
//     //     const SnackBar(content: Text("❌ Could not connect to ESP!")),
//     //   );
//     //   return;
//     // }
//     // Step 2: Simulate sending WiFi credentials
//     await mock.connectToESP();

//     final response = await mock.sendWiFiDetails("TestSSID", "TestPass");

//     if (response["status"] == "success") {
//       await db.insertDevice(
//       response["device_id"],
//       response["ip"],
//       "Your_Home_Password",
//     );
//       // String deviceId = response["device_id"];
//       // String ip = response["ip"];

//       // // Step 3: Simulate discovering device on network
//       // final devices = await mock.discoverDevices();

//       // for (var device in devices) {
//       //   if (device["device_id"] == deviceId) {
//       //     await db.insertDevice(
//       //       device["device_id"]!,
//       //       device["ssid"]!,
//       //       device["password"]!,
//       //       ip: device["ip"],
//       //     );
//       //   }
//       // }

//       // Step 4: Show success
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("✅ Mock Device Added Successfully!")),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("❌ Failed to configure Mock device.")),
//       );
//     }

//     Navigator.pop(context);
//   }
  
   

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         Positioned(
//           top: 100,
//           right: 20,
//           child: Material(
//             color: Colors.transparent,
//             child: Container(
//               width: 200,
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: const Color.fromARGB(255, 235, 171, 75),
//                 borderRadius: BorderRadius.circular(15),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.2),
//                     blurRadius: 8,
//                     offset: const Offset(2, 2),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // 🔘 Add Device Button
//                   Container(
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(15),
//                     ),
//                     child: ListTile(
//                       leading: const Text(
//                         "Add Device",
//                         style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//                       ),
//                       trailing: const Icon(
//                         Icons.add_circle_outline,
//                         color: Color.fromARGB(255, 235, 171, 75),
//                         size: 24,
//                       ),
//                       onTap: () => _addDevice(context),
//                     ),
//                   ),

//                   const SizedBox(height: 10),

//                   // ⚙️ Settings
//                   Container(
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(15),
//                     ),
//                     child: ListTile(
//                       leading: const Text(
//                         "Settings",
//                         style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//                       ),
//                       trailing: const Icon(
//                         Icons.settings,
//                         color: Color.fromARGB(255, 235, 171, 75),
//                         size: 24,
//                       ),
//                       onTap: () {
//                         Navigator.pushNamed(context, '/settings');
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/mock_device_service.dart';


class OptionsPopup extends StatelessWidget {
  const OptionsPopup({super.key});

  /// 🔹 Show dialog to get WiFi credentials from user
  Future<Map<String, String>?> _showWiFiInputDialog(BuildContext context) async {
    String deviceName = await _generateDeviceName(); // auto-generated default

    String ssid = "";
    String password = "";

    TextEditingController deviceNameController = TextEditingController(text: deviceName);

    return showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Configure Wifi and Device"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
            TextField(
              controller: deviceNameController,
              decoration: const InputDecoration(labelText: "Device Name (optional)"),
            ),
              TextField(
                decoration: const InputDecoration(labelText: "WiFi SSID"),
                onChanged: (value) => ssid = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: "WiFi Password"),
                obscureText: true,
                onChanged: (value) => password = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, {"device_name": deviceNameController.text,"ssid": ssid, "password": password});
              },
              child: const Text("Connect"),
            ),
          ],
        );
      },
    );
  }

  /// 🔹 Auto-generate device name based on existing entries
  Future<String> _generateDeviceName() async {
    final devices = await DatabaseHelper.instance.getAllDevices();
    return "Device ${devices.length + 1}";
  }

  /// ✅ Main function to handle adding a mock device
Future<void> _addDevice(BuildContext context) async {
  final db = DatabaseHelper.instance;
  final mock = MockDeviceService();

  // Step 1: Prompt to connect to ESP manually
  bool? proceed = await showDialog<bool>(
  context: context,
  barrierDismissible: false,
  builder: (context) {
    return Dialog(
  backgroundColor: Colors.transparent,
  child: Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: const Color.fromARGB(255, 235, 171, 75),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Center(
            child: Text(
              "Connect to Device",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Please go to your phone’s WiFi settings and connect to the device’s network (e.g., ET-XXXX).\n\nOnce you're connected, press Continue.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black87),
          ),
          const SizedBox(height: 20),

          // 🔘 Buttons inside white box
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 223, 127, 24),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 223, 127, 24),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Continue"),
              ),
            ],
          ),
        ],
      ),
    ),
  ),
);

  },
);

  if (proceed != true) return;

  // Step 2: Show loading while simulating ESP connection
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const AlertDialog(
      title: Text("Connecting..."),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text("Connecting to ESP Access Point..."),
        ],
      ),
    ),
  );

  await Future.delayed(const Duration(seconds: 2)); // Simulate real wait
  await mock.connectToESP();
  Navigator.pop(context); // Close dialog

  // Step 3: Prompt for Home WiFi Credentials
  final credentials = await _showWiFiInputDialog(context);
  if (credentials == null) return;

  String ssid = credentials["ssid"]!;
  String password = credentials["password"]!;
  String deviceName = credentials["device_name"] ?? await _generateDeviceName();

  // Step 4: Show progress again
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const AlertDialog(
      title: Text("Sending WiFi Credentials..."),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text("Sending details to device..."),
        ],
      ),
    ),
  );

  final response = await mock.sendWiFiDetails(ssid, password);
  Navigator.pop(context); // Close progress

  if (response["status"] == "success") {
    await db.insertDevice(
      response["device_id"],
      ssid,
      password,
      ip: response["ip"],
      type: "switch",
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Mock Device Added Successfully!")),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("❌ Failed to configure device.")),
    );
  }

  Navigator.pop(context); // Close the options popup
}



  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 100,
          right: 20,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 200,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 235, 171, 75),
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
                  // ➕ Add Device Button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
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
                      onTap: () => _addDevice(context),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ⚙️ Settings
                  
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
