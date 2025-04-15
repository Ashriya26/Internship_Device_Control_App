import 'dart:convert';

class MockDeviceService {
  /// Simulates connection to ESP Access Point
  Future<bool> connectToESP() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate delay
    print("🔌 Connected to Mock ESP Access Point");
    return true;
  }

  /// Simulates sending WiFi credentials and receiving response
  Future<Map<String, dynamic>> sendWiFiDetails(String ssid, String password) async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate delay
    print("📡 Sent WiFi credentials to Mock ESP");

    // Return a simulated success response
    return {
      "status": "success",
      "device_id": "MOCK1234",
      "ip": "192.168.1.100"
    };
  }

  /// Simulates discovering devices on Home WiFi
  Future<List<Map<String, String>>> discoverDevices() async {
    await Future.delayed(const Duration(seconds: 2));
    print("🔍 Mock device discovered on network");

    return [
      {
        "device_id": "MOCK1234",
        "ip": "192.168.1.100",
        "ssid": "TestSSID",
        "password": "TestPass"
      }
    ];
  }
}
