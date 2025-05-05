import 'package:flutter/material.dart';
import '../widgets/delete_device.dart';
import '../widgets/edit_device.dart';
import 'home_page.dart';
import 'package:provider/provider.dart';
import '../providers/network_provider.dart';
import '../services/database_service.dart';
import '../services/mock_device_service.dart';

class DeviceControlPage extends StatefulWidget {
  final String deviceId;
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
    required this.deviceId,
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
  late String deviceModel;
  late String firmwareVersion;
  late String lastActiveTime;
  late MockDeviceService _mockDeviceService;

  @override
  void initState() {
    super.initState();
    deviceName = widget.deviceName;
    _mockDeviceService = MockDeviceService();

    isDeviceOn = widget.initialStatus  ;
  // Ensure the device starts in OFF state by default

  // Use the mock data passed into the constructor
    deviceModel = widget.deviceModel;
    firmwareVersion = widget.firmwareVersion;
    lastActiveTime = widget.lastActiveTime;
  }

  Future<void> _toggleDevice() async {
    setState(() => isDeviceOn = !isDeviceOn);
    await DatabaseHelper.instance.updateDeviceStatus(widget.deviceId, isDeviceOn);

    // inform HomePage via callback (optional)…
    widget.onToggleDevice(isDeviceOn);

    // then pop and return the new status
    Navigator.pop(context, isDeviceOn);
  }
  Future<void> _updateDeviceInfo(Map<String, dynamic> response) async {
  // Assuming response["device_type"] exists and should be reflected in the UI
  setState(() {
    deviceModel = response["device_type"];
  });
  Future<void> _fetchDeviceData() async {
  // Simulating a response from the mock device or network call
  Map<String, dynamic> response = {
    'device_type': 'MockDeviceModel', // This will be the new model you want to set
  };

  // Update the device model with the new data
  _updateDeviceInfo(response);  // This will update the device model
}
Future<void> discoverDevice() async {
    // Call the mock device service to discover the device
    Map<String, dynamic> deviceData = await _mockDeviceService.connect();
    setState(() {
      // Use the device data to update UI
      print("Device discovered: ${deviceData['device_id']}");
    });
  }
}

 
  

    void _showDeletePopup() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return DeleteDevicePopup(
          onDelete: () async {
            // 1. Delete from database
            await DatabaseHelper.instance.deleteDevice(widget.deviceId);

            // 2. Notify Home Page (optional if you're also clearing it from UI)
            if (widget.onDeleteDevice != null) {
              widget.onDeleteDevice!(widget.deviceId); // use deviceId instead of name
            }

            Navigator.pop(context); // Close popup

            // 3. Redirect to HomePage
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                  (route) => false,
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
      resizeToAvoidBottomInset: false,
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
                        onTap: () => Navigator.pop(context),
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
                          onNameUpdated: (newName) async {
                            setState(() => deviceName = newName);

                            // 1) Persist into SQLite
                            await DatabaseHelper.instance.updateDeviceName(widget.deviceId, newName);

                            // 2) Tell HomePage to update its list (and repaint)
                            widget.onNameUpdated(newName);
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // Device Info
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                onTap: _toggleDevice,
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