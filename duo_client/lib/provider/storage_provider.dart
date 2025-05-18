import 'package:duo_client/provider/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageProvider extends ChangeNotifier {
  static const _keyToPlayerId = 'playerid';
  static const _KeyToPlayerName = 'playername';

  final _storage = const FlutterSecureStorage();

  ServerConnectionType _lastSelectedConnectionType = ServerConnectionType.grpc;
  String _playerId = "";
  String _playerName = "";

  StorageProvider();

  Future<void> init() async {
    _playerId = await _read(key: _keyToPlayerId) ?? "";
    _playerName = await _read(key: _KeyToPlayerName) ?? "";
  }

  Future<void> setUserId(String userId) async {
    _playerId = userId;
    await _write(key: _keyToPlayerId, value: userId);
  }

  Future<void> setUsername(String username) async {
    _playerName = username;
    await _write(key: _KeyToPlayerName, value: username);
  }

  void setLastSelectedConnectionType(ServerConnectionType type) {
    _lastSelectedConnectionType = type;
  }

  ServerConnectionType get lastSelectedConnectionType {
    return _lastSelectedConnectionType;
  }

  String get userId => _playerId;

  String get playerName => _playerName;

  ///WARNING
  ///DO NOT FETCH THE TOKEN FROM HERE, USE API PROVIDER getToken() INSTEAD

  Future<String?> _read({required String key}) async {
    return await _storage.read(key: key);
  }

  Future<void> _write({required String key, required String value}) async {
    await _storage.write(key: key, value: value);
    notifyListeners();
  }
}

final storageProvider = ChangeNotifierProvider<StorageProvider>((ref) {
  return StorageProvider();
});
