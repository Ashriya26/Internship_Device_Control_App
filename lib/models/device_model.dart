class Device {
  final String id;
  final String ip;
  final String type;
  final int status; // <-- ✅ added status field
  final bool isConnected; // <-- ✅ also track if it's online/offline

  Device({
    required this.id,
    required this.ip,
    required this.type,
    required this.status,
    required this.isConnected,
  });

  // Convert Device to a Map (for SQLite storage)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ip': ip,
      'type': type,
      'status': status,
      'isConnected': isConnected ? 1 : 0, // true -> 1, false -> 0
    };
  }

  // Convert Map to Device object
  factory Device.fromMap(Map<String, dynamic> map) {
    return Device(
      id: map['id'],
      ip: map['ip'],
      type: map['type'],
      status: map['status'] ?? 0,
      isConnected: (map['isConnected'] ?? 0) == 1,
    );
  }
}
