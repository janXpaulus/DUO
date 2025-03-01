import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';
import 'package:duo_client/utils/models/client_connection_model.dart';
import 'package:duo_client/utils/models/message_model.dart';
import 'package:flutter/cupertino.dart';
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

  late Map<String, ClientConnection> _connectedClients = {};

  late Map<ClientConnection, StreamSubscription> _clientStreamSubscriptions =
      {};

  late List<GATTCharacteristic> _advertisedCharacteristics = [];

  late String _serviceUuid;

  late GATTService _service;

  late bool _isAdvertising = false;

  Map<String, ClientConnection> get connectedClients => _connectedClients;

  bool get isAdvertising => _isAdvertising;

  Future<void> createLobby() async {
    _serviceUuid = "87654321-1234-5678-1234-56789abcdef1";
    //TODO: Generate random _serviceUuid

    for (var client = 0; client <= Constants.maxPlayers; client++) {
      addPlayer();
    }

    _connectedClients["Host"] = ClientConnection(
        playerId: "shit",
        notifyCharacteristicUuid: "shit",
        writeCharacteristicUuid: "shit",
        playerName: "Jan",
        isConnected: true,
        isStack: true);
    // TODO: Have this be dynamically populated with the app wide playerName that has been set

    await generateService();
    await startAdvertising();
  }

  Future<void> leaveLobby() async {
    await stopAdvertising();
    _connectedClients.clear();
  }

  Future<void> startAdvertising() async {
    try {
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
        await _peripheralManager.startAdvertising(
            Advertisement(serviceUUIDs: [UUID.fromString(_serviceUuid)]));
        _isAdvertising = true;
        debugPrint("Started advertising");
        notifyListeners();
      } else {
        debugPrint("App is already advertising");
      }
    } catch (error) {
      debugPrint("Error in startAdvertising(): $error}");
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
    String testMessage = "SHIT is working";

    _advertisedCharacteristics.add(GATTCharacteristic.mutable(
        uuid: UUID.fromString(notifyCharacteristicUuid),
        properties: [GATTCharacteristicProperty.notify],
        permissions: [GATTCharacteristicPermission.read],
        descriptors: []));

    _advertisedCharacteristics.add(GATTCharacteristic.mutable(
      uuid: UUID.fromString(writeCharacteristicUuid),
      properties: [GATTCharacteristicProperty.write],
      permissions: [GATTCharacteristicPermission.write],
      descriptors: [],
    ));

    _connectedClients[playerId] = ClientConnection(
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
          in _connectedClients.values.where((client) => !client.isConnected)) {
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
          }
        });
        _clientStreamSubscriptions[client] = subscription;
      }
    } catch (error) {
      debugPrint("Subscribing to player registrations failed: $error");
    }
    // TODO: Add subscription to wait for player registrations on writeCharacteristics and add playerName to specific ClientConnection
    /*
    String targetUuid = uuid.v4();
    ClientConnection clientConnection = _connectedClients.values
        .firstWhere((client) => client.writeCharacteristicUuid == targetUuid);
    String playerName = clientConnection.writeCharacteristicUuid;

     */
  }

  void sendMessage(String playerId, String message) {
    try {
      final connectedClient = _connectedClients.values
          .firstWhere((client) => client.playerId == playerId);

      final characteristicUuid = connectedClient.notifyCharacteristicUuid;
      final centralUuid = connectedClient.centralUuid;

      _peripheralManager.notifyCharacteristic(
          Central(uuid: UUID.fromString(centralUuid!)),
          GATTCharacteristic.mutable(
              uuid: UUID.fromString(characteristicUuid),
              descriptors: [],
              properties: [GATTCharacteristicProperty.notify],
              permissions: [GATTCharacteristicPermission.read]),
          value: utf8.encode(message));
    } catch (error) {
      debugPrint("Error when looking for playerId: $playerId: $error");
    }
  }
}

final hostConnectionProvider = ChangeNotifierProvider<HostConnectionProvider>(
    (ref) => HostConnectionProvider());
