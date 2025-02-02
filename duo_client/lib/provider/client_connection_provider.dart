import 'dart:async';

import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';
import 'package:duo_client/utils/models/client_connection_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClientConnectionProvider extends ChangeNotifier {
  final clientConnectionProvider =
      ChangeNotifierProvider<ClientConnectionProvider>((ref) {
    return ClientConnectionProvider();
  });

  late final Peripheral _peripheral;
  final CentralManager _centralManager = CentralManager();

  late StreamSubscription _connectionStateChanged;
  late StreamSubscription _discoveredDevices;

  bool _shouldReconnect = false;
  bool _isConnected = false;

  late ClientConnection _connectionInformation = ClientConnection(
      playerId: "69696969-6969-6969-6969-69696abcdef0",
      notifyCharacteristicUuid: "12345678-1234-5678-1234-56789abcdef0",
      writeCharacteristicUuid: "12345678-1234-5678-1234-56789abcdef1",
      isConnected: false,
      isStack: false);
  //TODO: Have connectionInformation be populated by QR Code scanner result

  void reconnect() async {
    try {
      while (_shouldReconnect && !_isConnected) {
        _centralManager.startDiscovery(serviceUUIDs: [
          UUID.fromString("87654321-1234-5678-1234-56789abcdef1")
        ]);

        _discoveredDevices =
            _centralManager.discovered.listen((eventArgs) async {
          eventArgs.peripheral;
          debugPrint("Discovered devices: $eventArgs ${eventArgs.peripheral}");
          _centralManager.connect(eventArgs.peripheral);
        });

        _connectionStateChanged =
            _centralManager.connectionStateChanged.listen((eventArgs) async {
          debugPrint("Connection state changed: $eventArgs");
        });
      }
    } catch (error) {
      debugPrint("Error during reconnecting: $error");
    }
  }

  void subscribeToNotifyCharacteristic() {}

  void writeCharacteristic(String message) {}

  //TODO: Add reconnect mechanism to reconnect when connectionState == true. Max timeout 5 minutes
}
