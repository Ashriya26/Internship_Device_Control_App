import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/udp_service.dart';
import '../services/websocket_service.dart';
import '../providers/network_provider.dart';

class OptionsPopup extends StatelessWidget {
  const OptionsPopup({super.key});

  Future<void> _addDevice(BuildContext context) async {
    final NetworkProvider network = NetworkProvider();
    final WebSocketService ws = WebSocketService();
    final UDPService udp = UDPService();
    final db = DatabaseHelper.instance;

    // Step 1: Connect to ESP Access Point (192.168.4.1)
    bool connected = await network.connectToESP();
    if (!connected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Could not connect to ESP!")),
      );
      return;
    }

    // Step 2: Start WebSocket communication
    ws.connectToESP();

    // Step 3: Send WiFi credentials to ESP and handle response
    await ws.sendWiFiDetails("Your_Home_SSID", "Your_Home_Password", (deviceId, ip) async {
      // Step 4: Reconnect to original WiFi
      await network.reconnectToHomeWiFi("Your_Home_SSID");

      // Step 5: Discover device on Home WiFi
      await udp.discoverDevices((id, newIp) async {
        if (id == deviceId) {
          await db.insertDevice(id, newIp, "Your_Home_Password");
        }
      });

      // Step 6: Notify user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Device Added Successfully!")),
      );
    });

    ws.closeConnection();
    Navigator.pop(context);
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
                  // 🔘 Add Device Button
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
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      leading: const Text(
                        "Settings",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      trailing: const Icon(
                        Icons.settings,
                        color: Color.fromARGB(255, 235, 171, 75),
                        size: 24,
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, '/settings');
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
