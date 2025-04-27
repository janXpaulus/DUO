import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/models/host_connection_model.dart';

class ClientConnectionProvider extends ChangeNotifier {
  late final List<DiscoveredEventArgs> _discoveries = [];
  late bool _isDiscovering = false;

  late StreamSubscription _stateChangedSubscription;
  late StreamSubscription _discoveredSubscription;

  final _centralManager = CentralManager();

  late StreamSubscription _connectionStateChanged;
  late StreamSubscription _discoveredDevices;

  bool _isConnected = false;

  bool _isConnectionWanted = true;

  Timer? _reconnectTimer;
  int _retryCount = 0;
  final int _maxRetrySeconds = 300; // max 5 minutes

  bool _isBleInitialized = false;
  bool _isDeviceDiscovered = false;
  bool _isDeviceConnected = false;
  bool _isPlayerRegistered = false;

  String _playerName = "Spieler 1";
  late List<GATTService> _discoveredGatt;
  late GATTCharacteristic _notifyCharacteristic;
  late GATTCharacteristic _writeCharacteristic;

  final _maxRetries = 3;

  final StreamController<DiscoveredEventArgs> _hostFoundController =
      StreamController.broadcast();

  late HostConnection _connectionInformation = HostConnection(
    playerId: "",
    notifyCharacteristicUuid: "",
    writeCharacteristicUuid: "",
    isConnected: false,
    serviceUuid: "",
  );
  final _serviceUuid = UUID.fromString("87654321-1234-5678-1234-56789abcdef1");

  BluetoothLowEnergyState get state => _centralManager.state;

  bool get isDiscovering => _isDiscovering;

  List<DiscoveredEventArgs> get discoveries => _discoveries;

  UUID get serviceUuids => _serviceUuid;

  bool get isConnectionWanted => _isConnectionWanted;

  Future<void> handleConnection(HostConnection hostConnection) async {
    _connectionInformation = hostConnection;

    try {
      await initializeBle();

      // 1. Discover device
      Peripheral peripheral;
      try {
        peripheral = await startDiscovery().timeout(Duration(seconds: 10));
        await stopDiscovery();
      } on TimeoutException catch (_) {
        debugPrint("Host Device couldn't be discovered!");
        await stopDiscovery();
        return;
      }

      // 2. Connect to discovered peripheral
      try {
        await connectToPeripheral(peripheral).timeout(Duration(seconds: 10));
      } on TimeoutException catch (_) {
        debugPrint("Connection failed!");
        return;
      }

      // 3. Discover characteristics
      await discoverCharacteristics(peripheral);

      // 3. Register player
      await registerPlayer(_playerName, peripheral, hostConnection);

      // 4. Listen for disconnections

      await subscribeToNotifyCharacteristicWithLogging(
          peripheral, hostConnection.notifyCharacteristicUuid);

      await subscribeToStuff(peripheral);
    } catch (e) {
      debugPrint("Error handling connection: $e");
      return;
      // handle errors here, possibly retry or notify user
    }
  }

  Future<void> initializeBle() async {
    if (!_isBleInitialized) {
      _centralManager.stateChanged.listen((eventArgs) async {
        if (eventArgs.state == BluetoothLowEnergyState.unauthorized &&
            Platform.isAndroid) {
          await _centralManager.authorize();
        }
        _stateChangedSubscription =
            _centralManager.connectionStateChanged.listen((state) {
          debugPrint("Connection state: $state");
        });
        _isBleInitialized = true;
        notifyListeners();
      });
    }
  }

  Future<void> showAppSettings() async {
    await _centralManager.showAppSettings();
  }

  Future<Peripheral> startDiscovery() async {
    debugPrint("Started discovering");
    Completer<Peripheral> completer = Completer();

    if (_isDiscovering) {
      debugPrint("Already discovering!");
      return Future.error("Already discovering");
    }

    _discoveries.clear();
    _isDiscovering = true;

    await _centralManager.startDiscovery(
      serviceUUIDs: [UUID.fromString(_connectionInformation.serviceUuid)],
    );

    _discoveredSubscription =
        _centralManager.discovered.listen((eventArgs) async {
      final peripheral = eventArgs.peripheral;
      final index = _discoveries.indexWhere((i) => i.peripheral == peripheral);

      if (index < 0) {
        _discoveries.add(eventArgs);
      } else {
        _discoveries[index] = eventArgs;
      }

      notifyListeners();
      debugPrint(
          "Peripheral UUID: ${peripheral.uuid}, serviceUUIDs: ${eventArgs.advertisement.serviceUUIDs}, RSSI: ${eventArgs.rssi}");

      if (eventArgs.advertisement.serviceUUIDs
          .contains(UUID.fromString(_connectionInformation.serviceUuid))) {
        debugPrint("Found host device!");

        if (!completer.isCompleted) {
          completer.complete(eventArgs.peripheral);
        }
      }
    });

    _isDeviceDiscovered = true;
    return completer.future;
  }

  Future<void> stopDiscovery() async {
    debugPrint("Stopping discovery");
    if (!_isDiscovering) {
      return;
    }
    await _centralManager.stopDiscovery();
    _isDiscovering = false;
    notifyListeners();
  }

  void subscribeToNotifyCharacteristic() {}

  void writeCharacteristic(String message) {}

  Future<void> joinLobby() async {
    try {
      var duoPeripheral = _discoveries
          .where((test) =>
              test.advertisement.serviceUUIDs.last ==
              UUID.fromString(_connectionInformation.serviceUuid))
          .last
          .peripheral
          .uuid;
      debugPrint("duoPeripheral: $duoPeripheral");
    } catch (error) {
      debugPrint("Error when joining lobby: $error");
    }
  }

  List<BluetoothDevice> _systemDevices = [];
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<bool> _isScanningSubscription;
  late StreamSubscription<List<BluetoothService>> _discoverServicesSubscription;

  Future<void> connectToPeripheral(Peripheral peripheral) async {
    try {
      debugPrint("Waiting to connect to ${peripheral.uuid}");
      await _centralManager.connect(peripheral);
      var connectedDevices =
          await _centralManager.retrieveConnectedPeripherals();
      debugPrint("Connected devices: ${connectedDevices}");
      _isDeviceConnected = true;
      _retryCount = 0;
      debugPrint("Connected successfully!");
      return;
    } on Exception catch (e) {
      debugPrint("Error when connecting: $e");
    }
  }

  Future<void> registerPlayer(String playerName, Peripheral peripheral,
      HostConnection hostConnection) async {
    debugPrint("Waiting to register player");
    final characteristic = GATTCharacteristic.mutable(
      uuid: UUID.fromString(_connectionInformation.writeCharacteristicUuid),
      properties: [GATTCharacteristicProperty.write],
      permissions: [GATTCharacteristicPermission.write],
      descriptors: [],
    );
    debugPrint("${_discoveredGatt.last.characteristics.last.uuid.value}");
    var value = {
      "type": "connection",
      "action": "register",
      "parameters": {"playerName": playerName}
    };

    var characteristic2 = _discoveredGatt
        .firstWhere((service) =>
            service.uuid == UUID.fromString(_connectionInformation.serviceUuid))
        .characteristics
        .firstWhere((characteristic) =>
            characteristic.uuid ==
            UUID.fromString(_connectionInformation.writeCharacteristicUuid));

    await _centralManager.writeCharacteristic(peripheral, characteristic2,
        value: utf8.encode(jsonEncode(value)),
        type: GATTCharacteristicWriteType.withResponse);
  }

  Future<bool> setPlayerName(String playerName) async {
    _playerName = playerName;
    return true;
  }

  Future<void> subscribeToNotifyCharacteristicWithLogging(
      Peripheral peripheral, String notifyCharacteristicUuid) async {
    try {
      // Discover GATT services of the peripheral
      var discoveredGatt = await _centralManager.discoverGATT(peripheral);

      // Find the service containing the notify characteristic
      var service = discoveredGatt.firstWhere((service) =>
          service.characteristics.any((characteristic) =>
              characteristic.uuid ==
              UUID.fromString(notifyCharacteristicUuid)));

      // Find the notify characteristic within the service
      var notifyCharacteristic = service.characteristics.firstWhere(
          (characteristic) =>
              characteristic.uuid == UUID.fromString(notifyCharacteristicUuid));

      // Enable notifications for the characteristic
      await _centralManager.setCharacteristicNotifyState(
        peripheral,
        notifyCharacteristic,
        state: true, // Enable notifications
      );

      debugPrint(
          "Subscribed to notifications for characteristic: $notifyCharacteristicUuid");

      // Listen to notifications
      _centralManager.characteristicNotified.listen((event) {
        if (event.characteristic.uuid == notifyCharacteristic.uuid) {
          // Decode and print the received data
          final receivedData = utf8.decode(event.value);
          debugPrint(
              "Received data from $notifyCharacteristicUuid: $receivedData");
        }
      });
    } catch (e) {
      debugPrint("Error subscribing to notify characteristic: $e");
    }
  }

  Future<void> subscribeToStuff(Peripheral peripheral) async {
    final characteristic = GATTCharacteristic.mutable(
      uuid: UUID.fromString(_connectionInformation.notifyCharacteristicUuid),
      properties: [GATTCharacteristicProperty.notify],
      permissions: [GATTCharacteristicPermission.read],
      descriptors: [],
    );

    var notifyCharacteristic = _discoveredGatt
        .firstWhere((service) =>
            service.uuid == UUID.fromString(_connectionInformation.serviceUuid))
        .characteristics
        .firstWhere((characteristic) =>
            characteristic.uuid ==
            UUID.fromString(_connectionInformation.notifyCharacteristicUuid));

    // var notification = _centralManager
    //     .setCharacteristicNotifyState(peripheral, characteristic, state: state);
    var subscription =
        _centralManager.characteristicNotified.listen((notification) async {
      debugPrint("$notification");
    });
  }

  Future<void> discoverCharacteristics(Peripheral peripheral) async {
    _discoveredGatt = await _centralManager.discoverGATT(peripheral);
    _notifyCharacteristic = _discoveredGatt
        .firstWhere((service) =>
            service.uuid == UUID.fromString(_connectionInformation.serviceUuid))
        .characteristics
        .firstWhere((characteristic) =>
            characteristic.uuid ==
            UUID.fromString(_connectionInformation.notifyCharacteristicUuid));

    _writeCharacteristic = _discoveredGatt
        .firstWhere((service) =>
            service.uuid == UUID.fromString(_connectionInformation.serviceUuid))
        .characteristics
        .firstWhere((characteristic) =>
            characteristic.uuid ==
            UUID.fromString(_connectionInformation.writeCharacteristicUuid));

    debugPrint("${_notifyCharacteristic.uuid}, ${_writeCharacteristic.uuid}");
  }
}

// TODO: Add reconnect mechanism to reconnect when connectionState == true. Max timeout 5 minutes

final clientConnectionProvider =
    ChangeNotifierProvider<ClientConnectionProvider>(
        (ref) => ClientConnectionProvider());
