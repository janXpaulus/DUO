class HostConnection {
  String playerId;
  String serviceUuid;
  String notifyCharacteristicUuid;
  String writeCharacteristicUuid;
  bool isConnected;

  HostConnection({
    required this.playerId,
    required this.serviceUuid,
    required this.notifyCharacteristicUuid,
    required this.writeCharacteristicUuid,
    required this.isConnected,
  });

  Map<String, dynamic> toJson() {
    return {
      'playerId': playerId,
      'serviceUuid': serviceUuid,
      'notifyCharacteristicUuid': notifyCharacteristicUuid,
      'writeCharacteristicUuid': writeCharacteristicUuid,
      'isConnected': isConnected,
    };
  }

  factory HostConnection.fromJson(Map<String, dynamic> json) {
    return HostConnection(
      playerId: json['playerId'],
      serviceUuid: json['serviceUuid'],
      notifyCharacteristicUuid: json['notifyCharacteristicUuid'] ?? "",
      writeCharacteristicUuid: json['writeCharacteristicUuid'] ?? "",
      isConnected: json['isConnected'],
    );
  }
}
