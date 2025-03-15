import 'package:flutter/material.dart';
import '../widgets/delete_device.dart';

class DeviceControlPage extends StatefulWidget {
  final String deviceName;
  final bool initialStatus;
  final String networkName;
  final String deviceModel;
  final String firmwareVersion;
  final String lastActiveTime;
  final Function(String)? onDeleteDevice; // Callback to notify Home Page

  const DeviceControlPage({
    super.key,
    required this.deviceName,
    required this.initialStatus,
    required this.networkName,
    required this.deviceModel,
    required this.firmwareVersion,
    required this.lastActiveTime,
    this.onDeleteDevice, // Callback added
  });

  @override
  State<DeviceControlPage> createState() => _DeviceControlPageState();
}

class _DeviceControlPageState extends State<DeviceControlPage> {
  late bool isDeviceOn;

  @override
  void initState() {
    super.initState();
    isDeviceOn = widget.initialStatus;
  }

  void toggleDevice() {
    setState(() {
      isDeviceOn = !isDeviceOn;
    });
  }

  void _showDeletePopup() {
    showDialog(
      context: context,
      barrierDismissible: true, // Allow closing by tapping outside
      builder: (BuildContext context) {
        return DeleteDevicePopup(
          onDelete: () {
            widget.onDeleteDevice?.call(widget.deviceName); // Notify Home Page
            Navigator.pop(context); // Close popup after deletion
            Navigator.pop(context, true); // Close Device Control Page
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
                        onTap: () => Navigator.pop(context, isDeviceOn),
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
                    // Device Name
                    Text(
                      widget.deviceName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Device Info
                    _buildDeviceInfo("Connected to:", widget.networkName),
                    _buildDeviceInfo("Device Model:", widget.deviceModel),
                    _buildDeviceInfo("Firmware Version:", widget.firmwareVersion),
                    _buildDeviceInfo("Last Active:", widget.lastActiveTime),

                    const SizedBox(height: 10),

                    // Status Indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Spacer(), // Push status to the right
                        Text(
                          isDeviceOn ? "ON" : "OFF",
                          style: TextStyle(
                            fontSize: 18,
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
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
