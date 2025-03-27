import 'package:web_socket_channel/io.dart';
import 'dart:convert';

class WebSocketService {
  IOWebSocketChannel? channel;

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
