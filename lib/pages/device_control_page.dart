import 'package:flutter/material.dart';
import '../widgets/delete_device.dart';
import '../widgets/edit_device.dart';
import 'home_page.dart';
import '../widgets/device_card.dart';
import 'settings_page.dart';
import 'package:provider/provider.dart';
import '../providers/network_provider.dart';

class DeviceControlPage extends StatefulWidget {
  final String deviceName;
  final bool initialStatus;
  final String networkName;
  final String deviceModel;
  final String firmwareVersion;
  final String lastActiveTime;
  final Function(String)? onDeleteDevice; // Callback to notify Home Page
  final Function(bool) onToggleDevice; // ✅ Accept onToggleDevice
  final Function(String) onNameUpdated; // ✅ Callback to update Home Page

  const DeviceControlPage({
    super.key,
    required this.deviceName,
    required this.initialStatus,
    required this.networkName,
    required this.deviceModel,
    required this.firmwareVersion,
    required this.lastActiveTime,
    required this.onNameUpdated, // ✅ Initialize

    this.onDeleteDevice, // Callback added
    required this.onToggleDevice, // ✅ Initialize it
  });

  @override
  State<DeviceControlPage> createState() => _DeviceControlPageState();
}

class _DeviceControlPageState extends State<DeviceControlPage> {
  late String deviceName;
  late bool isDeviceOn;
  late bool deviceStatus;

  @override
  void initState() {
    super.initState();
    deviceName = widget.deviceName;
    isDeviceOn = widget.initialStatus;
    deviceStatus=widget.initialStatus;
    
  }




void toggleDevice() {
  setState(() {
    isDeviceOn = !isDeviceOn; // Toggle the state
  });

  if (deviceName.isNotEmpty) {
    widget.onToggleDevice(isDeviceOn); // ✅ Notify Home Page
    updateDeviceStatus(deviceName, isDeviceOn);
    Navigator.pop(context, isDeviceOn); // ✅ Go back to Home Page
  }
}

void updateDeviceStatus(String deviceName, bool newStatus) {
  print("Updating $deviceName status to ${newStatus ? "ON" : "OFF"}");
}





  void _showDeletePopup() {
  showDialog(
    context: context,
    barrierDismissible: true, // Allow closing by tapping outside
    builder: (BuildContext context) {
      return DeleteDevicePopup(
        onDelete: () {
          if (widget.onDeleteDevice != null) {
            widget.onDeleteDevice!(widget.deviceName); // Notify Home Page
          }
          Navigator.pop(context); // Close the popup
          
          // Ensure redirection to Home Page after deletion
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()), // Ensure this is your actual Home Page widget
                (route) => false, // Remove all previous routes
              );
            }
          });
        },
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
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
              // AppBar (Matching Home Page)
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
                        onTap: () => Navigator.pop(context, false),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 235, 171, 75),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back, color: Colors.white),
                        ),
                      ),
                      const Text(
                        "Device Control",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      GestureDetector(
                        onTap: _showDeletePopup,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 235, 171, 75),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.more_vert, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Device Control Box (Details)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 5),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Device Name with Edit Icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          deviceName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        EditDeviceWidget(
                          initialName: deviceName,
                          onNameUpdated: (newName) {
                            setState(() {
                              deviceName = newName; // Update UI when name changes
                            });
                            widget.onNameUpdated(newName); // ✅ Notify Home Page

                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // Device Info
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start, // Keep left alignment
                        children: [
                          // Connected to (Left-aligned)
                          const Text(
                            "Connected to:",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                          
                          const SizedBox(height: 4), // Small space before network name

                          // Network Name (Centered)
                          Align(
                            alignment: Alignment.center, // Center-align only the network name
                            child: Text(
                              Provider.of<NetworkProvider>(context).connectedNetwork,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 169, 203, 75)),
                            ),
                          ),

                          const SizedBox(height: 15), // Space before the next fields

                          _buildDeviceInfo("Device Model:", widget.deviceModel),
                          _buildDeviceInfo("Firmware Version:", widget.firmwareVersion),
                          _buildDeviceInfo("Last Active:", widget.lastActiveTime),
                        ],
                      ),
                    const SizedBox(height: 30),

                    // Status Indicator with Heading
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Status:",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          isDeviceOn ? "ON" : "OFF",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDeviceOn ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Toggle Button (ON/OFF)
              GestureDetector(
                onTap: toggleDevice,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  decoration: BoxDecoration(
                     color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 8),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildToggleButton("ON", isDeviceOn),
                      _buildToggleButton("OFF", !isDeviceOn),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper function for Device Info Rows
  Widget _buildDeviceInfo(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }

  // Helper function for ON/OFF Buttons
  Widget _buildToggleButton(String text, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 35),
      decoration: BoxDecoration(
        color: isActive ? Colors.orange : Colors.white,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 24,
          color: isActive ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
