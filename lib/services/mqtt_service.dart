import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MQTTService {
  late MqttServerClient client;
  final String broker = '127.0.0.1'; // or your IP address
  final int port = 1883;
  final String clientId;
  
  MQTTService(this.clientId);

  Future<void> connect() async {
    client = MqttServerClient(broker, clientId);
    client.port = port;
    client.keepAlivePeriod = 20;
    client.logging(on: true);
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
    client.onSubscribed = onSubscribed;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    client.connectionMessage = connMessage;

    try {
      await client.connect();
    } catch (e) {
      print('MQTT connection failed: $e');
      client.disconnect();
    }
  }

  void onConnected() => print('MQTT Connected!');
  void onDisconnected() => print('MQTT Disconnected');
  void onSubscribed(String topic) => print('Subscribed to $topic');

  void subscribe(String topic) {
    client.subscribe(topic, MqttQos.atLeastOnce);
  }

  void publish(String topic, String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }

  void listen(Function(String topic, String payload) onMessage) {
    client.updates?.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final payload =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      onMessage(c[0].topic, payload);
    });
  }

  void disconnect() {
    client.disconnect();
  }
  void searchForDevices(Function callback) {
  // Define a topic for searching devices
  const searchTopic = 'device/search';

  // Publish a search message to the broker (example message)
  final message = '{"action": "search_devices"}';
  publish(searchTopic, message);

  // Subscribe to the topic that will give a list of devices (this can be adjusted based on your needs)
  client.subscribe('device/response', MqttQos.atLeastOnce);

  // Listen for messages on the subscribed topic
  listen((topic, payload) {
    if (topic == 'device/response') {
      // Assuming the payload contains device details as a JSON string
      final deviceDetails = payload;

      // Call the callback function with the device details
      // Example: Assuming the payload contains device info in this format: {"id": "123", "ip": "192.168.1.1", "model": "DeviceModel", "firmware": "1.0", "lastActive": "2025-05-07"}
      // You can modify this depending on the actual payload format.
      callback(deviceDetails);
    }
  });
}

void updateDeviceStatus(String deviceId, String status) {
  // Define a topic for updating the device status
  const statusTopic = 'device/status/update';

  // Create a payload to send the status update to the device
  final payload = '{"device_id": "$deviceId", "status": "$status"}';

  // Publish the status update message to the MQTT topic
  publish(statusTopic, payload);
}

}

