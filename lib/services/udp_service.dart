import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'database_service.dart'; // ✅ Import DatabaseHelper

class UDPService {
  static const String broadcastAddress = "255.255.255.255";
  static const int port = 4210;
  final DatabaseHelper dbHelper = DatabaseHelper.instance; // ✅ Use DatabaseHelper

  Future<void> discoverDevices(Function(String, String) onDeviceFound) async {
    try {
      RawDatagramSocket udpSocket =
          await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);

      print("🔹 Broadcasting UDP discovery request...");

      // ✅ Send a UDP broadcast message to discover devices
      udpSocket.send(
        utf8.encode(jsonEncode({'cmd': 'discover'})), // ✅ Command to discover ESP32
        InternetAddress(broadcastAddress, type: InternetAddressType.IPv4),
        port,
      );

      // ✅ Set a timeout to wait for responses (3 seconds)
      Completer<void> completer = Completer();
      Timer(const Duration(seconds: 3), () {
        if (!completer.isCompleted) {
          print("❌ No devices found within timeout.");
          completer.complete();
        }
      });

      udpSocket.listen((event) {
        if (event == RawSocketEvent.read) {
          Datagram? dg = udpSocket.receive();
          if (dg != null) {
            String response = utf8.decode(dg.data);
            Map<String, dynamic> data = jsonDecode(response);

            String deviceId = data['device_id']; // ✅ Get Device ID from ESP response
            String ip = data['ip']; // ✅ Get IP Address

            print("✅ Device Found: $deviceId ($ip)");

            // ✅ Store the discovered device in the database
            dbHelper.insertDevice(deviceId, ip, ""); // Empty password for now

            // ✅ Notify UI to update the device list
            onDeviceFound(deviceId, ip);

            
          }
        }
      });

      await completer.future; // Wait until timeout or first response

    } catch (e) {
      print("❌ Error in UDP Discovery: $e");
    }
  }
}

