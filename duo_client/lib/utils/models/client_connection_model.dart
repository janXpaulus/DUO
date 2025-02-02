class ClientConnection {
  String playerId;
  String? playerName;
  String? centralUuid;
  String notifyCharacteristicUuid;
  String writeCharacteristicUuid;
  bool isConnected;
  bool isStack;

  ClientConnection(
      {required this.playerId,
      this.playerName,
      this.centralUuid,
      required this.notifyCharacteristicUuid,
      required this.writeCharacteristicUuid,
      required this.isConnected,
      required this.isStack});

  Map<String, dynamic> toJson() {
    return {
      'playerId': playerId,
      'playerName': playerName,
      'centralUuid': centralUuid,
      'notifyCharacteristicUuid': notifyCharacteristicUuid,
      'writeCharacteristicUuid': writeCharacteristicUuid,
      'isConnected': isConnected,
      'isStack': isStack
    };
  }
}
