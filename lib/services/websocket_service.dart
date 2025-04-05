import 'package:web_socket_channel/io.dart';
import 'dart:convert';
import 'database_service.dart';

class WebSocketService {
  IOWebSocketChannel? channel;
  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  /// 🔌 Connect to ESP WebSocket (Assuming AP mode at 192.168.4.1:81)
  void connectToESP() {
    try {
      channel = IOWebSocketChannel.connect("ws://192.168.4.1:81");

      channel!.stream.listen((message) {
        print("📩 Received from ESP: $message");
        // Optional: You can handle incoming messages here globally
      }, onError: (error) {
        print("❌ WebSocket error: $error");
      });

      // Request Device Info (like ID)
      channel!.sink.add(jsonEncode({"cmd": "get_device_info"}));
    } catch (e) {
      print("❌ Failed to connect to ESP WebSocket: $e");
    }
  }

  /// 📡 Send WiFi credentials to ESP
  Future<void> sendWiFiDetails(
  String ssid,
  String password,
  Future<void> Function(String deviceId, String ip) onSuccess,
) async {
  try {
    String message = jsonEncode({
      "cmd": "set_wifi",
      "ssid": ssid,
      "password": password,
    });

    channel!.sink.add(message);

    channel!.stream.listen((message) async {
      print("📩 ESP WiFi Response: $message");
      Map<String, dynamic> response = jsonDecode(message);

      if (response["status"] == "success") {
        print("✅ WiFi Setup Successful");

        String deviceId = response["device_id"];
        String ip = response["ip"];

        // Save to SQLite with SSID + password
        await dbHelper.insertDevice(deviceId, ip, password);

        // Callback to update UI
        await onSuccess(deviceId, ip);
      } else {
        print("❌ WiFi Setup Failed");
      }
    }, onError: (error) {
      print("❌ WebSocket Error (WiFi Setup): $error");
    });

  } catch (e) {
    print("❌ Error sending WiFi details: $e");
  }
}


  /// 🔒 Close the WebSocket connection
  void closeConnection() {
    channel?.sink.close();
    print("🔌 WebSocket connection closed.");
  }
}
