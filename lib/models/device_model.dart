class Device {
  final String id;
  final String ip;
  final String type;

  Device({required this.id, required this.ip, required this.type});

  // Convert Device to a Map (for SQLite storage)
  Map<String, dynamic> toMap() {
    return {'id': id, 'ip': ip, 'type': type};
  }

  // Convert Map to Device object
  factory Device.fromMap(Map<String, dynamic> map) {
    return Device(id: map['id'], ip: map['ip'], type: map['type']);
  }
}
