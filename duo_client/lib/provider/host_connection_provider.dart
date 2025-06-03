import 'dart:async';
import 'dart:io';

import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';
import 'package:duo_client/provider/dummy_game_provider.dart';
import 'package:duo_client/provider/storage_provider.dart';
import 'package:duo_client/utils/models/client_connection_model.dart';
import 'package:duo_client/utils/models/message_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../utils/constants.dart';

class HostConnectionProvider extends ChangeNotifier {
  final Ref ref;

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

  late final Map<String, Map<String, Function(Parameters?, String, String)>>
      messageRouter;

  Map<String, ClientConnection> get clientSlots => _clientSlots;

  bool get isAdvertising => _isAdvertising;

  String get serviceUuid => _serviceUuid;

  List<ClientConnection> get connectedClients => _connectedClients;

  bool get isGameReady => _isGameReady;

  set isGameReady(bool value) {
    _isGameReady = value;
    notifyListeners();
  }

  HostConnectionProvider(this.ref) {
    messageRouter = {
      'connection': {
        'register': (params, playerId, centralUuid) {
          debugPrint("[message received] connection -> register ${params}");
          registerPlayer(params, playerId, centralUuid);
        },
      },
      'cards': {
        'place': (params, playerId, centralUuid)
            // debugPrint("[message received] cards -> place ${params?.card}")
            {
          debugPrint("[message received] cards -> place ${params?.card}");
          placeCardOnStack(params!.card!, playerId, ref);
        },
        'draw': (params, playerId, centralUuid) =>
            debugPrint("[message received] cards -> draw ${params?.cards}"),
      },
      'game': {},
      //   TODO: Add all other actions that are to be handled with connection
    };
  }

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
    _connectedClients = [];
    _isGameReady = false;
    notifyListeners();
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
          _peripheralManager.connectionStateChanged.listen((eventArgs) {
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

  Future<void> subscribeToNotifyCharacteristics() async {
    try {
      debugPrint("Subscribing to notifyCharacteristics");
      for (var client
          in _clientSlots.values.where((client) => !client.isConnected)) {
        var subscription = _peripheralManager.characteristicWriteRequested
            .listen((eventArgs) async {
          if (eventArgs.characteristic.uuid ==
              UUID.fromString(client.writeCharacteristicUuid)) {
            final request = DuoMessage.fromUint8List(eventArgs.request.value);
            final central = eventArgs.central;
            final centralUuid = central.uuid.toString();

            handleMessage(request, client.playerId, centralUuid);

            // if (request.type == "connection" && request.action == "register") {
            //   client.playerName = request.parameters?.playerName;
            //   client.centralUuid = central.uuid.toString();
            //   client.isConnected = true;
            // }
            // notifyListeners();
            // debugPrint(
            //     "Player Registration received for: ${request.parameters?.playerName}");
          }
          return;
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
      if (_connectedClients.isEmpty) {
        debugPrint("connectedClients is empty");
      } else {
        for (var connectedClient in _connectedClients) {
          debugPrint(
              "${connectedClient.playerId} ${connectedClient.isConnected}");
        }
      }

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
          value: message.toUint8List());
      debugPrint("Sent message: ${message.toUint8List()}");
    } catch (error) {
      debugPrint("Error when looking for playerId: $playerId: $error");
    }
  }

  Future<void> sendMessageToAllClients(DuoMessage message) async {
    for (var client in _connectedClients) {
      await sendMessage(client.playerId, message);
    }
  }

  void handleMessage(DuoMessage message, String playerId, String centralUuid) {
    final typeHandlers = messageRouter[message.type];
    final handler = typeHandlers?[message.action];

    if (handler != null) {
      handler(message.parameters, playerId, centralUuid);
    } else {
      debugPrint(
          "No handler for type='${message.type}', action='${message.action}'");
    }
  }

  Future<void> registerPlayer(
      Parameters? params, String? playerId, String? centralUuid) async {
    final player = _clientSlots.values
        .where((client) => client.playerId == playerId)
        .where((client) => !client.isConnected)
        .first;
    player.playerName = params?.playerName;
    player.isConnected = true;
    player.centralUuid = centralUuid;
    notifyListeners();
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
    sendMessageToAllClients(message);
  }

  Future<void> updateCardsInClient(String playerId, List<String> cards) async {
    debugPrint("Called updateCardsInClient");
    await sendMessage(
        playerId,
        DuoMessage(
            type: "cards",
            action: "update",
            parameters: Parameters(cards: cards)));
  }

  Future<void> placeCardOnStack(
      String cardName, String playerId, Ref ref) async {
    try {
      final dummyGame = ref.read(dummyGameProvider);
      debugPrint("Placing player card on stack from host_connection_provider");
      await dummyGame.placePlayerCardOnStack(cardName, playerId, ref);
      updateCardsInClient(playerId, dummyGame.playerCards[playerId] ?? []);
      // await updateCardsInClient(
      //     playerId, dummyGame.playerCards[playerId] ?? []);
    } on Exception catch (e) {
      debugPrint("Exception $e when trying to do placing cards shit");
    }
  }

  Future<void> notifyPlayerOfTurn(String playerId) async {
    final message = DuoMessage(type: "game", action: "your_turn");
    await sendMessage(playerId, message);
  }
}

final hostConnectionProvider = ChangeNotifierProvider<HostConnectionProvider>(
    (ref) => HostConnectionProvider(ref));
