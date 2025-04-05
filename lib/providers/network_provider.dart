import 'package:flutter/material.dart';
import 'package:wifi_iot/wifi_iot.dart';

class NetworkProvider extends ChangeNotifier {
  String _connectedNetwork = "";

  String get connectedNetwork => _connectedNetwork; // Getter for network name

  void updateNetwork(String networkName) {
    _connectedNetwork = networkName;
    notifyListeners(); // Notify listeners to update UI
  }
  Future<bool> connectToESP() async {
    bool success = await WiFiForIoTPlugin.connect(
      "ESP_DEVICE_SSID", // Replace with actual ESP SSID
      password: "12345678", // Replace with actual ESP password
      security: NetworkSecurity.WPA,
      joinOnce: true,
      withInternet: false,
    );

    if (success) {
      _connectedNetwork = "ESP_DEVICE_SSID";
      notifyListeners(); // Notify UI of network change
    }
    return success;
  }

  Future<bool> reconnectToHomeWiFi(String homeSSID) async {
    bool success = await WiFiForIoTPlugin.connect(homeSSID);
    
    if (success) {
      _connectedNetwork = homeSSID;
      notifyListeners(); // Notify UI of network change
    }
    return success;
  }
}
