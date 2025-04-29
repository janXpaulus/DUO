import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';
import 'package:duo_client/provider/storage_provider.dart';
import 'package:duo_client/utils/models/client_connection_model.dart';
import 'package:duo_client/utils/models/message_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../utils/constants.dart';

class HostConnectionProvider extends ChangeNotifier {
  final hostConnectionProvider =
      ChangeNotifierProvider<HostConnectionProvider>((ref) {
    return HostConnectionProvider();
  });

  final PeripheralManager _peripheralManager = PeripheralManager();
  final uuid = Uuid();
  late StreamSubscription _managerStateChangedSubscription;
  late StreamSubscription _connectionStateChangedSubscription;
  late Map<String, ClientConnection> _clientSlots = {};
  late List<ClientConnection> _connectedClients = [];
  late Map<ClientConnection, StreamSubscription> _clientStreamSubscriptions =
      {};
  late List<GATTCharacteristic> _advertisedCharacteristics = [];
  late String _serviceUuid;
  late GATTService _service;
  late bool _isAdvertising = false;
  bool _isGameReady = false;

  Map<String, ClientConnection> get clientSlots => _clientSlots;

  bool get isAdvertising => _isAdvertising;

  String get serviceUuid => _serviceUuid;

  List<ClientConnection> get connectedClients => _connectedClients;

  bool get isGameReady => _isGameReady;

  Future<void> createLobby() async {
    _serviceUuid = uuid.v4();

    for (var client = 0; client <= Constants.maxPlayers; client++) {
      addPlayer();
    }

    _clientSlots["Host"] = ClientConnection(
        playerId: "shit",
        notifyCharacteristicUuid: "shit",
        writeCharacteristicUuid: "shit",
        playerName: StorageProvider().playerName,
        isConnected: true,
        isStack: true);

    _service = GATTService(
        uuid: UUID.fromString(_serviceUuid),
        isPrimary: true,
        includedServices: [],
        characteristics: _advertisedCharacteristics);

    debugPrint("${_clientSlots}");

    await startAdvertising();
  }

  Future<void> deleteLobby() async {
    await stopAdvertising();
    _clientSlots.clear();
  }

  Future<void> startAdvertising() async {
    if (!_isAdvertising) {
      _managerStateChangedSubscription =
          _peripheralManager.stateChanged.listen((eventArgs) async {
        debugPrint("Peripheral manager state: $eventArgs");
        if (eventArgs.state == BluetoothLowEnergyState.unauthorized &&
            Platform.isAndroid) {
          await _peripheralManager.authorize();
        }
      });

      await _peripheralManager.stopAdvertising();
      await _peripheralManager.removeAllServices();

      await _peripheralManager.addService(_service);
      await _peripheralManager.startAdvertising(Advertisement(
        name: "DUO",
        serviceUUIDs: [UUID.fromString(_serviceUuid)],
        manufacturerSpecificData: Platform.isIOS || Platform.isMacOS
            ? []
            : [
                ManufacturerSpecificData(
                  id: 0x2e19,
                  data: Uint8List.fromList([0x01, 0x02, 0x03]),
                )
              ],
      ));
      _isAdvertising = true;
      debugPrint("Started advertising");
      notifyListeners();
    } else {
      debugPrint("App is already advertising");
    }
  }

  Future<void> stopAdvertising() async {
    try {
      if (_isAdvertising) {
        await _peripheralManager.stopAdvertising();
        await _peripheralManager.removeAllServices();
        _isAdvertising = false;
        debugPrint("Stopped Advertising");
        notifyListeners();
      } else {
        debugPrint("App already stopped advertising");
      }
    } catch (error) {
      debugPrint("Error in stopAdvertising(): $error");
    }
  }

  Future<void> watchForConnectionStateChange() async {
    try {
      _connectionStateChangedSubscription =
          await _peripheralManager.connectionStateChanged.listen((eventArgs) {
        debugPrint("Connection State Changed: $eventArgs");
      });
    } on Exception catch (error) {
      debugPrint("Error when watching connection state: $error");
    }
  }

  Future<void> generateService() async {
    _service = GATTService(
        uuid: UUID.fromString(_serviceUuid),
        isPrimary: true,
        includedServices: [],
        characteristics: _advertisedCharacteristics);
  }

  Future<void> addPlayer() async {
    final playerId = uuid.v4();
    final notifyCharacteristicUuid = uuid.v4();
    final writeCharacteristicUuid = uuid.v4();

    _advertisedCharacteristics.add(GATTCharacteristic.mutable(
        uuid: UUID.fromString(notifyCharacteristicUuid),
        properties: [GATTCharacteristicProperty.notify],
        permissions: [GATTCharacteristicPermission.read],
        descriptors: []));

    _advertisedCharacteristics.add(GATTCharacteristic.mutable(
      uuid: UUID.fromString(writeCharacteristicUuid),
      properties: [
        GATTCharacteristicProperty.write,
        GATTCharacteristicProperty.writeWithoutResponse
      ],
      permissions: [GATTCharacteristicPermission.write],
      descriptors: [],
    ));

    _clientSlots[playerId] = ClientConnection(
        playerId: playerId,
        notifyCharacteristicUuid: notifyCharacteristicUuid,
        writeCharacteristicUuid: writeCharacteristicUuid,
        isConnected: false,
        isStack: false);

    notifyListeners();
  }

  String generateUuid() {
    return uuid.v4().toString();
  }

  Future<void> subscribeToPlayerRegistrations() async {
    try {
      debugPrint("Subscribing to player registrations");
      for (var client
          in _clientSlots.values.where((client) => !client.isConnected)) {
        var subscription = _peripheralManager.characteristicWriteRequested
            .listen((eventArgs) async {
          if (eventArgs.characteristic.uuid ==
              UUID.fromString(client.writeCharacteristicUuid)) {
            final request = DuoMessage.fromUint8List(eventArgs.request.value);
            final central = eventArgs.central;

            if (request.type == "connection" && request.action == "register") {
              client.playerName = request.parameters?.playerName;
              client.centralUuid = central.uuid.toString();
              client.isConnected = true;
            }
            notifyListeners();
            debugPrint(
                "Player Registration received for: ${request.parameters?.playerName}");
            updateLobbyInClients();
          }
        });
        _clientStreamSubscriptions[client] = subscription;
      }
    } catch (error) {
      debugPrint("Subscribing to player registrations failed: $error");
    }
    /*
    String targetUuid = uuid.v4();
    ClientConnection clientConnection = _connectedClients.values
        .firstWhere((client) => client.writeCharacteristicUuid == targetUuid);
    String playerName = clientConnection.writeCharacteristicUuid;

     */
  }

  Future<void> sendMessage(String playerId, DuoMessage message) async {
    try {
      debugPrint("Sending message to playerId: $playerId");
      final clientInformation =
          _connectedClients.firstWhere((client) => client.playerId == playerId);

      debugPrint(
          "Sending message to player with clientInformation: ${clientInformation.toJson().toString()}");

      final characteristicUuid = clientInformation.notifyCharacteristicUuid;
      final centralUuid = clientInformation.centralUuid;

      final characteristic = _advertisedCharacteristics.firstWhere(
        (c) => c.uuid == UUID.fromString(characteristicUuid),
        orElse: () => throw Exception('Characteristic not found!'),
      );

      await _peripheralManager.notifyCharacteristic(
          Central(uuid: UUID.fromString(centralUuid!)), characteristic,
          value: utf8.encode(message.toJson().toString()));
    } catch (error) {
      debugPrint("Error when looking for playerId: $playerId: $error");
    }
  }

  Future<void> updateLobbyInClients() async {
    _clientSlots.forEach((String playerId, ClientConnection clientConnection) {
      if (clientConnection.isConnected && !clientConnection.isStack) {
        _connectedClients.add(clientConnection);
      }
    });

    var message = DuoMessage(
        type: "connection",
        action: "update_lobby",
        parameters: Parameters(
            lobbyList: _connectedClients
                .map((element) => element.playerName)
                .whereType<String>()
                .toList()));

    for (var clientConnection in _connectedClients) {
      debugPrint(clientConnection.playerName);
      sendMessage(
        clientConnection.playerId,
        message,
      );
    }
  }
}

final hostConnectionProvider = ChangeNotifierProvider<HostConnectionProvider>(
    (ref) => HostConnectionProvider());
