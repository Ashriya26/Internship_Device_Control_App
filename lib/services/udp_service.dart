import 'dart:io';
import 'dart:convert';
import 'dart:async';

class UDPService {
  static const String broadcastAddress = "255.255.255.255";
  static const int port = 4210;

  Future<void> discoverDevices(Function(String, String) onDeviceFound) async {
    try {
      RawDatagramSocket udpSocket =
          await RawDatagramSocket.bind(InternetAddress.anyIPv4, port);

      udpSocket.send(utf8.encode(jsonEncode({'cmd': 'discover'})),
          InternetAddress(broadcastAddress), port);

      bool responseReceived = false;

      udpSocket.listen((event) {
        if (event == RawSocketEvent.read) {
          Datagram? dg = udpSocket.receive();
          if (dg != null) {
            responseReceived = true;
            String response = utf8.decode(dg.data);
            Map<String, dynamic> data = jsonDecode(response);

            // Extract Device ID and IP Address
            String id = data['id'];
            String ip = data['ip'];

            onDeviceFound(id, ip);
          }
        }
      });

      // 🔹 If no real devices respond within 2 seconds, return dummy devices
      await Future.delayed(Duration(seconds: 2));
      if (!responseReceived) {
        _addDummyDevices(onDeviceFound);
      }

    } catch (e) {
      print("Error in UDP Discovery: $e");
      _addDummyDevices(onDeviceFound); // Use dummy data if an error occurs
    }
  }

  // 🔹 Function to return dummy devices
  void _addDummyDevices(Function(String, String) onDeviceFound) {
    List<Map<String, String>> dummyDevices = [
      {"id": "ESP_001", "ip": "192.168.1.10"},
      {"id": "ESP_002", "ip": "192.168.1.11"},
    ];

    for (var device in dummyDevices) {
      onDeviceFound(device["id"]!, device["ip"]!);
    }
  }
}
