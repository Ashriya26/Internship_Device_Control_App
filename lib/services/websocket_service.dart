import 'package:web_socket_channel/io.dart';
import 'dart:convert';
import 'database_service.dart';

class WebSocketService {
  IOWebSocketChannel? channel;
  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  /// Callback for when device info is received
  void Function(String deviceId, String deviceType)? onDeviceInfoReceived;

  /// Callback after successful WiFi setup
  Future<void> Function(String deviceId, String ip)? _onSuccessCallback;

  /// 🔌 Connect to ESP WebSocket (Assuming AP mode at 192.168.4.1:81)
  void connectToESP({void Function(String, String)? onDeviceInfo}) {
    try {
      onDeviceInfoReceived = onDeviceInfo;

      channel = IOWebSocketChannel.connect("ws://192.168.4.1:81");

      channel!.stream.listen((message) async {
        print("📩 Received from ESP: $message");
        final response = jsonDecode(message);

        if (response["cmd"] == "device_info" && onDeviceInfoReceived != null) {
          String deviceId = response["device_id"];
          String deviceType = response["type"];
          onDeviceInfoReceived!(deviceId, deviceType);
        }

        if (response["status"] == "success") {
          String deviceId = response["device_id"];
          String ip = response["ip"];
          String password = response["password"] ?? "12345678"; // default/fallback password

          await dbHelper.insertDevice(deviceId, "", password, ip: ip);

          if (_onSuccessCallback != null) {
            await _onSuccessCallback!(deviceId, ip);
          }
        }
      }, onError: (error) {
        print("❌ WebSocket error: $error");
      });

      // Send request to ESP for device info
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
      _onSuccessCallback = onSuccess;

      String message = jsonEncode({
        "cmd": "set_wifi",
        "ssid": ssid,
        "password": password,
      });

      channel?.sink.add(message);
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
