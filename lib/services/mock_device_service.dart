
// MockDeviceService.dart

class MockDeviceService {
  static int _deviceCounter = 0;

  late String deviceId;
  late String deviceType;
  late String ipAddress;
  bool isDeviceOn = false;

  // New fields
  String deviceModel = 'MockDevice v1.0';
  String firmwareVersion = '1.0.0';
  String lastActiveTime = 'Just Now'; // You can modify this based on real-time logic


  MockDeviceService() {
    // Generate a new deviceId every time a new instance is created
    _deviceCounter++;
    deviceId = 'mock-device-${_deviceCounter}';
    deviceType = 'mock-type'; // You can change this if needed
    ipAddress = '192.168.1.${100 + _deviceCounter}';
    
  }

  Future<Map<String, dynamic>> connect() async {
    await Future.delayed(Duration(milliseconds: 500)); // Simulate delay
    return {
      'device_id': deviceId,
      'device_type': deviceType,
      'device_model': deviceModel, // Add device model here
      'firmware_version': firmwareVersion, // Add firmware version here
      'last_active_time': lastActiveTime, // Add last active time here
    };
  }
 
//   Future<void> sendConfig(Map<String, dynamic> config) async {
//     // Store config for validation if needed
//   }

//   Future<void> toggleDevice(bool value) async {
//     isDeviceOn = value;
//   }

//   bool getStatus() => isDeviceOn;
// }














  
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
      "device_id": deviceId,
      "ip": ipAddress
    };
  }

  /// Simulates discovering devices on Home WiFi
  Future<List<Map<String, String>>> discoverDevices() async {
    await Future.delayed(const Duration(seconds: 2));
    print("🔍 Mock device discovered on network");

    return [
      {
        "device_id": deviceId,
        "ip": ipAddress,
        "ssid": "TestSSID",
        "password": "TestPass"
      }
    ];
  }
}
