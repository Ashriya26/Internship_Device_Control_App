import 'package:flutter/material.dart';

class NetworkProvider with ChangeNotifier {
  String _connectedNetwork = "Unknown"; // Default value

  String get connectedNetwork => _connectedNetwork;

  void updateNetwork(String newNetwork) {
    _connectedNetwork = newNetwork;
    notifyListeners(); // Notify listeners to update UI
  }
}
