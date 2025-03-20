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

      // 3. Register player
      await registerPlayer(_playerName, peripheral, hostConnection);

      // 4. Listen for disconnections
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
    var discoveredGatt = await _centralManager.discoverGATT(peripheral);
    debugPrint("${discoveredGatt.last.characteristics.last.uuid.value}");
    var value = {
      "type": "connection",
      "action": "register",
      "parameters": {"playerName": playerName}
    };

    var characteristic2 = discoveredGatt
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

// TODO: Add reconnect mechanism to reconnect when connectionState == true. Max timeout 5 minutes
}

final clientConnectionProvider =
    ChangeNotifierProvider<ClientConnectionProvider>(
        (ref) => ClientConnectionProvider());
