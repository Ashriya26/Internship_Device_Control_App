//code before adding soe dummy values for the testing purpose

import 'dart:io';
import 'dart:convert';

class UDPService {
  static const String broadcastAddress = "255.255.255.255";
  static const int port = 4210;

  Future<void> discoverDevices(Function(String, String) onDeviceFound) async {
    RawDatagramSocket udpSocket =
        await RawDatagramSocket.bind(InternetAddress.anyIPv4, port);
    
    udpSocket.send(utf8.encode(jsonEncode({'cmd': 'discover'})),
        InternetAddress(broadcastAddress), port);
    
    udpSocket.listen((event) {
      if (event == RawSocketEvent.read) {
        Datagram? dg = udpSocket.receive();
        if (dg != null) {
          String response = utf8.decode(dg.data);
          Map<String, dynamic> data = jsonDecode(response);
          
          // Extract Device ID and IP Address
          String id = data['id'];
          String ip = data['ip'];

          onDeviceFound(id, ip);
        }
      }
    });
  }
}
