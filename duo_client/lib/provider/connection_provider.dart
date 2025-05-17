import 'package:duo_client/provider/client_connection_provider.dart';
import 'package:duo_client/provider/dummy_game_provider.dart';
import 'package:duo_client/provider/host_connection_provider.dart';
import 'package:duo_client/utils/models/client_connection_model.dart';
import 'package:duo_client/utils/models/host_connection_model.dart';
import 'package:duo_client/utils/models/message_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConnectionProvider extends ChangeNotifier {
  final connectionProvider = ChangeNotifierProvider<ConnectionProvider>((ref) {
    return ConnectionProvider();
  });
  bool _isHostConnection = false;
  bool _isInLobby = false;
  List<String> _cards = [];

  List<ClientConnection> _lobbySlots = [];
  List<String> _playerList = [];
  bool _isGameReady = false;

  bool get isHostConnection => _isHostConnection;

  bool get isInLobby => _isInLobby;

  List<String> get playerList => _playerList;

  List<ClientConnection> get lobbySlots => _lobbySlots;

  List<String> get cards => _cards;

  bool get isGameReady => _isGameReady;

  Future<void> hostGame(WidgetRef ref) async {
    final hostConnection = ref.read(hostConnectionProvider);
    debugPrint(
        "Accessed HostConnectionProvider instance: ${hostConnection.hashCode}");
    debugPrint("Hosting Game");
    await hostConnection.createLobby();
    _isHostConnection = true;
    hostConnection.isAdvertising ? _isInLobby = true : _isInLobby = false;
    hostConnection.clientSlots.entries.forEach((client) {
      lobbySlots.add(client.value);
    });
    notifyListeners();
    debugPrint("$_lobbySlots");
  }

  Future<void> joinGame(HostConnection hostConnection, ref) async {
    debugPrint("Joining Game");
    final clientConnection = ref.read(clientConnectionProvider);
    clientConnection.handleConnection(hostConnection);
    _isHostConnection = false;
    _isInLobby = true;
  }

  Future<void> leaveLobby(WidgetRef ref) async {
    final hostConnection = ref.read(hostConnectionProvider);
    final clientConnection = ref.read(clientConnectionProvider);
    debugPrint("Leaving Lobby");
    if (_isHostConnection) {
      await hostConnection.deleteLobby();
      hostConnection.isAdvertising ? _isInLobby = true : _isInLobby = false;
      notifyListeners();
      // hostConnection.dispose();
    } else {
      // ClientConnectionProvider() leave lobby
      // clientConnection.dispose();
    }
    _isInLobby = false;
  }

  Future<void> startGame(WidgetRef ref) async {
    final hostConnection = ref.read(hostConnectionProvider);
    final dummyGame = ref.read(dummyGameProvider);
    // TODO: Send start game command to clients

    if (_isHostConnection) {
      debugPrint("Device is host ... starting game");
      await hostConnection
          .sendMessageToAllClients(DuoMessage(type: "game", action: "start"));
      await dummyGame.startGame(ref);
    } else {}
  }

  Future<void> subscribeToPlayerList(WidgetRef ref) async {
    _playerList = ref.watch(clientConnectionProvider).playerList;
    notifyListeners();
  }

  void updateCards(List<String> cards) {
    _cards = cards;
    notifyListeners();
  }

  Future<void> placePlayerCardOnStack(
      String cardName, String playerId, Ref ref) async {}
}

final connectionProvider =
    ChangeNotifierProvider<ConnectionProvider>((ref) => ConnectionProvider());
