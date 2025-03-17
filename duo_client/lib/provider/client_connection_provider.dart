import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/models/host_connection_model.dart';

class ClientConnectionProvider extends ChangeNotifier {
  late final List<DiscoveredEventArgs> _discoveries = [];
  late bool _isDiscovering = false;

  late final StreamSubscription _stateChangedSubscription;
  late final StreamSubscription _discoveredSubscription;

  final _centralManager = CentralManager();

  late StreamSubscription _connectionStateChanged;
  late StreamSubscription _discoveredDevices;

  bool _isConnected = false;

  bool _isConnectionWanted = true;

  late HostConnection _connectionInformation = HostConnection(
    playerId: "",
    notifyCharacteristicUuid: "",
    writeCharacteristicUuid: "",
    isConnected: false,
    serviceUuid: "",
  );

  // TODO: Have connectionInformation be populated by QR Code scanner result

  final _serviceUuid = UUID.fromString("87654321-1234-5678-1234-56789abcdef1");

  BluetoothLowEnergyState get state => _centralManager.state;

  bool get isDiscovering => _isDiscovering;

  List<DiscoveredEventArgs> get discoveries => _discoveries;

  UUID get serviceUuids => _serviceUuid;

  bool get isConnectionWanted => _isConnectionWanted;

  Future<void> handleConnection(HostConnection hostConnection) async {
    _connectionInformation = hostConnection;
    await initializeBle();

    while (_isConnectionWanted) {
      await startDiscovery(
          serviceUUIDs: [UUID.fromString(_connectionInformation.serviceUuid)]);
      while (_isDiscovering) {
        var lastDiscovery = _discoveries.last;
        if (lastDiscovery.advertisement.serviceUUIDs ==
            [UUID.fromString(_connectionInformation.serviceUuid)]) {
          stopDiscovery();
          await connectToPeripheral(lastDiscovery.peripheral);
          // TODO: set properties for connection in one central point of client connection provider
          debugPrint("Found host device");

          await registerPlayer("Shitty shit", lastDiscovery.peripheral);
        }
      }
    }
    // await registerPlayer();
  }

  Future<void> initializeBle() async {
    _stateChangedSubscription =
        _centralManager.stateChanged.listen((eventArgs) async {
      if (eventArgs.state == BluetoothLowEnergyState.unauthorized &&
          Platform.isAndroid) {
        await _centralManager.authorize();
      }
      notifyListeners();
    });
    _discoveredSubscription = _centralManager.discovered.listen((eventArgs) {
      final peripheral = eventArgs.peripheral;
      final index = _discoveries.indexWhere((i) => i.peripheral == peripheral);
      if (index < 0) {
        _discoveries.add(eventArgs);
      } else {
        _discoveries[index] = eventArgs;
      }
      notifyListeners();
      debugPrint(
          "peripheral UUID: ${_discoveries.last.peripheral.uuid} serviceUUIDs: ${_discoveries.last.advertisement.serviceUUIDs} rssi: ${discoveries.last.rssi}");
    });
  }

  Future<void> showAppSettings() async {
    await _centralManager.showAppSettings();
  }

  Future<void> startDiscovery({
    List<UUID>? serviceUUIDs,
  }) async {
    debugPrint("Started discovering");

    if (_isDiscovering) {
      return;
    }
    _discoveries.clear();
    await _centralManager.startDiscovery(
      serviceUUIDs: serviceUUIDs,
    );
    _isDiscovering = true;
    notifyListeners();
  }

  Future<void> stopDiscovery() async {
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

  connectToPeripheral(Peripheral peripheral) {
    _centralManager.connect(peripheral);
  }

  registerPlayer(String playerName, Peripheral peripheral) {
    final characteristic = GATTCharacteristic.immutable(
        uuid: UUID.fromString(_connectionInformation.writeCharacteristicUuid),
        value: utf8.encode("shit"),
        descriptors: [
          GATTDescriptor.immutable(
              uuid: UUID
                  .fromString(_connectionInformation.writeCharacteristicUuid),
              value: utf8.encode("shit"))
        ]);
    var value = {
      "type": "connection",
      "action": "register",
      "parameters": {"playerName": "Jann"}
    };
    _centralManager.writeCharacteristic(peripheral, characteristic,
        value: utf8.encode(jsonEncode(value)),
        type: GATTCharacteristicWriteType.withResponse);
  }

// TODO: Add reconnect mechanism to reconnect when connectionState == true. Max timeout 5 minutes
}

final clientConnectionProvider =
    ChangeNotifierProvider<ClientConnectionProvider>(
        (ref) => ClientConnectionProvider());
