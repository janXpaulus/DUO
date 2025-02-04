import 'dart:convert';
import 'dart:typed_data';

class DuoMessage {
  String? type;
  String? action;
  Parameters? parameters;

  // Constructor
  DuoMessage({required this.type, required this.action, this.parameters});

  // Factory constructor for JSON deserialization
  factory DuoMessage.fromJson(Map<String, dynamic> json) {
    return DuoMessage(
      type: json['type'],
      action: json['action'],
      parameters: json['parameters'] != null
          ? Parameters.fromJson(json['parameters'])
          : null,
    );
  }

  // Method to serialize the class to JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'action': action,
      if (parameters != null) 'parameters': parameters!.toJson(),
    };
  }

  // Factory constructor for Uint8List deserialization
  factory DuoMessage.fromUint8List(Uint8List uint8List) {
    try {
      return DuoMessage.fromJson(
        jsonDecode(utf8.decode(uint8List)) as Map<String, dynamic>,
      );
    } catch (e) {
      throw FormatException("Invalid Uint8List data: $e");
    }
  }

  // Method to serialize the class to Uint8List
  Uint8List toUint8List() {
    return Uint8List.fromList(utf8.encode(jsonEncode(toJson())));
  }
}

class Parameters {
  String? playerName;
  String? sessionName;
  String? recipientDeviceUuid;

  String? card;
  List<String>? cards;

  // Constructor
  Parameters({
    this.playerName,
    this.sessionName,
    this.recipientDeviceUuid,
    this.card,
    this.cards,
  });

  // Factory constructor for JSON deserialization
  factory Parameters.fromJson(Map<String, dynamic> json) {
    return Parameters(
      playerName: json['playerName'],
      sessionName: json['sessionName'],
      recipientDeviceUuid: json['recipientDeviceUuid'],
      card: json['card'],
      cards: (json['cards'] as List<dynamic>?)?.cast<String>(),
    );
  }

  // Method to serialize the class to JSON
  Map<String, dynamic> toJson() {
    return {
      'playerName': playerName,
      'sessionName': sessionName,
      'recipientDeviceUuid': recipientDeviceUuid,
      'card': card,
      'cards': cards,
    };
  }
}
