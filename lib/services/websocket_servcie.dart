import 'package:web_socket_channel/io.dart';
import 'dart:convert';
import 'database_service.dart';

class WebSocketService {
  IOWebSocketChannel? channel;
  final DatabaseHelper dbHelper = DatabaseHelper.instance; // ✅ Use DatabaseHelper

  void connectToESP(String ip, String ssid, String password) {
    try {
      channel = IOWebSocketChannel.connect('ws://$ip');

      channel!.sink.add(jsonEncode({
        'cmd': 'setup',
        'ssid': ssid,
        'password': password,
      }));

      channel!.stream.listen((message) {
        print("ESP Response: $message");
        Map<String, dynamic> response = jsonDecode(message);

        if (response["status"] == "success") {
          print("✅ WiFi Setup Successful!");

          // 🔹 Store SSID & password in Database
          dbHelper.insertDevice(ip, ssid, password);
        } else {
          print("❌ WiFi Setup Failed!");
        }
      }, onError: (error) {
        print("WebSocket Error: $error");
      });

    } catch (e) {
      print("Connection Failed: $e");
    }
  }

  void closeConnection() {
    channel?.sink.close();
  }
}
