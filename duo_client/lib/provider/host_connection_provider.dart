import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';
import 'package:duo_client/utils/models/client_connection_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

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

  late List<GATTCharacteristic> _advertisedCharacteristics = [];

  late String _serviceUuid;

  late GATTService _service;

  late bool _isAdvertising = false;

  Map<String, ClientConnection> get connectedClients => _connectedClients;

  bool get isAdvertising => _isAdvertising;

  Future<void> createLobby() async {
    _serviceUuid = "87654321-1234-5678-1234-56789abcdef1";
    //TODO: Generate random _serviceUuid
    _connectedClients["Host"] = ClientConnection(
        playerId: "shit",
        notifyCharacteristicUuid: "shit",
        writeCharacteristicUuid: "shit",
        playerName: "Jan");
    // TODO: Have this be dynamically populated with the app wide playerName that has been set
    await stopAdvertising();
    await generateService();
    await startAdvertising();
  }

  Future<void> leaveLobby() async {
    await stopAdvertising();
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
        await _peripheralManager.startAdvertising(Advertisement(name: "DUO"));
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

  Future<Map<String, String>> addPlayer() async {
    String playerId = "69696969-6969-6969-6969-69696abcdef0";
    String notifyCharacteristicUuid = "12345678-1234-5678-1234-56789abcdef0";
    String writeCharacteristicUuid = "12345678-1234-5678-1234-56789abcdef1";
    String testMessage = "addPlayer()";
    //TODO: Generate Uuids

    _connectedClients[playerId] = ClientConnection(
        playerId: playerId,
        notifyCharacteristicUuid: notifyCharacteristicUuid,
        writeCharacteristicUuid: writeCharacteristicUuid,
        isConnected: false);

    _advertisedCharacteristics.add(GATTCharacteristic.mutable(
        uuid: UUID.fromString(notifyCharacteristicUuid),
        properties: [GATTCharacteristicProperty.notify],
        permissions: [GATTCharacteristicPermission.read],
        descriptors: []));

    _advertisedCharacteristics.add(GATTCharacteristic.immutable(
        uuid: UUID.fromString(writeCharacteristicUuid),
        descriptors: [],
        value: utf8.encode(testMessage)));

    await stopAdvertising();
    await startAdvertising();

    late Map<String, String> playerCode = {};
    playerCode["notifyCharacteristicUuid"] = notifyCharacteristicUuid;
    playerCode["writeCharacteristicUuid"] = writeCharacteristicUuid;
    notifyListeners();
    return playerCode;
  }

  String generateUuid() {
    return uuid.v4().toString();
  }

  void subscribeToPlayerRegistrations() {
    try {
      StreamSubscription playerRegistrationReceived = _peripheralManager
          .characteristicWriteRequested
          .listen((eventArgs) async {
        debugPrint("playerRegistrationReceived: $eventArgs");
      });
    } catch (error) {
      debugPrint("Subscribing to player registrations failed: $error");
    }
    // TODO: Add subscription to wait for player registrations on writeCharacteristics and add playerName to specific ClientConnection
    String targetUuid = uuid.v4();
    ClientConnection clientConnection = _connectedClients.values
        .firstWhere((client) => client.writeCharacteristicUuid == targetUuid);
    String playerName = clientConnection.writeCharacteristicUuid;
  }

  void subscribeToWriteCharacteristic() {}

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
