import 'package:duo_client/provider/client_connection_provider.dart';
import 'package:duo_client/provider/host_connection_provider.dart';
import 'package:duo_client/utils/models/client_connection_model.dart';
import 'package:duo_client/utils/models/host_connection_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConnectionProvider extends ChangeNotifier {
  final connectionProvider = ChangeNotifierProvider<ConnectionProvider>((ref) {
    return ConnectionProvider();
  });
  bool _isHostConnection = false;
  bool _isInLobby = false;
  List<ClientConnection> _lobbySlots = [];

  bool get isHostConnection => _isHostConnection;

  bool get isInLobby => _isInLobby;

  List<ClientConnection> get lobbySlots => _lobbySlots;

  Future<void> hostGame(WidgetRef ref) async {
    final hostConnection = ref.read(hostConnectionProvider);
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

  Future<void> joinGame(HostConnection hostConnection) async {
    debugPrint("Joining Game");
    ClientConnectionProvider().handleConnection(hostConnection);
    _isHostConnection = false;
    _isInLobby = true;
  }

  Future<void> leaveLobby(WidgetRef ref) async {
    final hostConnection = ref.read(hostConnectionProvider);
    debugPrint("Leaving Lobby");
    if (_isHostConnection) {
      await hostConnection.deleteLobby();
      hostConnection.isAdvertising ? _isInLobby = true : _isInLobby = false;
    } else {
      // ClientConnectionProvider() leave lobby
    }
    _isInLobby = false;
  }

  Future<void> startGame() async {
    if (_isHostConnection) {
    } else {}
  }
}

final connectionProvider =
    ChangeNotifierProvider<ConnectionProvider>((ref) => ConnectionProvider());
