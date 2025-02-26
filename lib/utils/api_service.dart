import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:5000'; // Backend URL

  // Fetch all devices
  static Future<List<dynamic>> fetchDevices() async {
    final response = await http.get(Uri.parse('$baseUrl/devices'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load devices');
    }
  }

  // Add a new device
  static Future<void> addDevice(Map<String, dynamic> deviceData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/devices'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(deviceData),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to add device');
    }
  }

  // Update a device
  static Future<void> updateDevice(int id, Map<String, dynamic> deviceData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/devices/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(deviceData),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update device');
    }
  }

  // Delete a device
  static Future<void> deleteDevice(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/devices/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete device');
    }
  }
}
