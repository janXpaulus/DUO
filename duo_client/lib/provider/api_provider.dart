import 'dart:async';

import 'package:duo_client/main.dart';
import 'package:duo_client/pb/friend.pb.dart';
import 'package:duo_client/pb/lobby.pb.dart';
import 'package:duo_client/pb/game.pb.dart';
import 'package:duo_client/provider/friend_provider.dart';
import 'package:duo_client/provider/notification_provider.dart';
import 'package:duo_client/utils/connection/server_events.dart';
import 'package:flutter/widgets.dart';

import 'storage_provider.dart';
import '../utils/connection/abstract_connection.dart';
import '../utils/connection/grpc_server_connection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ServerConnectionType {
  grpc,
  bluetooth,
}

class ApiProvider extends ChangeNotifier implements AbstractServerConnection {
  final StorageProvider _storageProvider;
  final FriendProvider _friendProvider;
  final NotificationProvider _notificationProvider;

  StreamSubscription? _eventStreamSubscription;

  LobbyStatus? _lobbyStatus;
  GameState? _gameState;
  StackState? _stackState;
  PlayerState? _playerState;
  int? _gameId;
  bool? _isStackOwner;

  LobbyStatus? get lobbyStatus => _lobbyStatus;

  StackState? get stackState => _stackState;

  PlayerState? get playerState => _playerState;

  GameState? get gameState => _gameState;

  int get gameId => _gameId ?? -1;

  bool get isStackOwner => _isStackOwner ?? false;

  ApiProvider(
      this._storageProvider, this._notificationProvider, this._friendProvider) {
    GrpcServerConnection serverConnection = getIt.get<GrpcServerConnection>();
    _eventStreamSubscription = serverConnection.eventStream.listen((event) {
      switch (event.runtimeType) {
        case RegisterUserEvent:
          {
            //Registration was successful, save the user data
            final registerUserEvent = event as RegisterUserEvent;
            _storageProvider.setUserId(registerUserEvent.uuid);
            _storageProvider.setUsername(registerUserEvent.username);
            _storageProvider.setAccessToken(registerUserEvent.accessToken);
            _storageProvider.setPrivateKey(registerUserEvent.privatePEMKey);
            notifyListeners();
            break;
          }
        case LoginUserEvent:
          {
            //Login was successful, save the token
            final loginUserEvent = event as LoginUserEvent;
            _storageProvider.setAccessToken(loginUserEvent.token);
            _storageProvider.setExpireDate(loginUserEvent.expirationDate);
            notifyListeners();
            break;
          }
        case LobbyStatusEvent:
          {
            //Update the lobby status
            final lobbyStatusEvent = event as LobbyStatusEvent;
            _lobbyStatus = lobbyStatusEvent.status;
            if (_lobbyStatus?.isStarting == true) {
              _gameId = _lobbyStatus!.gameId;
              _isStackOwner = _lobbyStatus!.users
                      .firstWhere((element) => element.isStack)
                      .uuid ==
                  _storageProvider.userId;
            }
            if (_lobbyStatus?.isDeleted == true) {
              _gameId = -2;
              _isStackOwner = false;
              _lobbyStatus = null;
            }
            notifyListeners();
            break;
          }
        case LobbyStatusDoneEvent:
          {
            //Lobby status is done, reset the lobby status
            _lobbyStatus = null;
            notifyListeners();
            break;
          }
        case PlayerStateEvent:
          {
            final playerStateEvent = event as PlayerStateEvent;
            _playerState = playerStateEvent.state;
            notifyListeners();
            break;
          }
        case PlayerStateDoneEvent:
          {
            _playerState = null;
            notifyListeners();
            break;
          }
        case StackStateEvent:
          {
            final stackStateEvent = event as StackStateEvent;
            _stackState = stackStateEvent.state;
            notifyListeners();
            break;
          }
        case StackStateInitEvent:
        case UserStatusInitEvent:
          {
            notifyListeners();
            break;
          }
        case StackStateDoneEvent:
          {
            _stackState = null;
            notifyListeners();
            break;
          }
        case GameStateEvent:
          {
            final gameStateEvent = event as GameStateEvent;
            _gameState = gameStateEvent.state;
            notifyListeners();
            break;
          }
        case GameStateDoneEvent:
          {
            _gameState = null;
            notifyListeners();
            break;
          }
        case GetFriendsEvent:
          {
            final getFriendsEvent = event as GetFriendsEvent;
            _friendProvider.setFriends(getFriendsEvent.friends);
            break;
          }
        case NotificationEvent:
          {
            final notificationEvent = event as NotificationEvent;
            _notificationProvider
                .addNotification(notificationEvent.newNotification);
            break;
          }
        default:
          notifyListeners();
      }
    });
  }

  @override
  void dispose() async {
    await _eventStreamSubscription?.cancel();
    super.dispose();
  }
  // void init(ServerConnectionType type) {
  //   _storageProvider.setLastSelectedConnectionType(type);
  //   switch (type) {
  //     case ServerConnectionType.grpc:
  //       _serverConnection = GrpcServerConnection(_storageProvider,
  //           _notificationProvider, _friendProvider, notifyListeners);
  //       break;
  //     case ServerConnectionType.bluetooth:
  //       //maybe implement bluetooth connection
  //       break;
  //   }
  //   notifyListeners();
  // }

  Future<String> getToken() async {
    if (_storageProvider.expireDate
            ?.isBefore(DateTime.now().subtract(const Duration(minutes: 2))) ??
        false) {
      await getIt
          .get<GrpcServerConnection>()
          .loginUser(_storageProvider.userId, _storageProvider.privateKey);
      return _storageProvider.accessToken;
    }
    return _storageProvider.accessToken;
  }

  @override
  Future<int> createLobby(String token, int maxPlayers) {
    return getIt.get<GrpcServerConnection>().createLobby(token, maxPlayers);
  }

  @override
  Future<int> disconnectLobby(String token, int lobbyId) {
    return getIt.get<GrpcServerConnection>().disconnectLobby(token, lobbyId);
  }

  @override
  Future<int> joinLobby(String token, int lobbyId) {
    return getIt.get<GrpcServerConnection>().joinLobby(token, lobbyId);
  }

  @override
  Future<int> loginUser(String uuid, String privateKey) {
    return getIt.get<GrpcServerConnection>().loginUser(uuid, privateKey);
  }

  @override
  Future<int> registerUser(String username) {
    return getIt.get<GrpcServerConnection>().registerUser(username);
  }

  @override
  Future<int> startGame(String token) {
    return getIt.get<GrpcServerConnection>().startGame(token);
  }

  @override
  Future<int> getPlayerStream(String token, int gameId) {
    return getIt.get<GrpcServerConnection>().getPlayerStream(token, gameId);
  }

  @override
  Future<int> changeStackDevice(String token, String deviceId) {
    return getIt.get<GrpcServerConnection>().changeStackDevice(token, deviceId);
  }

  @override
  Future<int> getStackStream(String token, int gameId) {
    return getIt.get<GrpcServerConnection>().getStackStream(token, gameId);
  }

  @override
  Future<int> requestCard(String token, int gameId) async {
    if (hasStackStream == false) {
      debugPrint('No Stack Stream');
      final statusCode = await getStackStream(token, gameId);
      if (statusCode != 0) return statusCode;
    }
    return getIt.get<GrpcServerConnection>().requestCard(token, gameId);
  }

  @override
  Future<int> streamPlayerAction(PlayerAction action) {
    return getIt.get<GrpcServerConnection>().streamPlayerAction(action);
  }

  @override
  Future<int> getGameStateStream(String token, int gameId) {
    return getIt.get<GrpcServerConnection>().getGameStateStream(token, gameId);
  }

  @override
  Future<int> initUserStatusStream() async {
    debugPrint('Init User Status Stream');
    final response =
        await getIt.get<GrpcServerConnection>().initUserStatusStream();
    debugPrint('User Status Stream: $hasUserStatusStream');
    // notifyListeners();
    return response;
  }

  @override
  void sendUserstatusUpdate(String token, FriendState state) async {
    if (hasUserStatusStream == false) {
      debugPrint('No User Status Stream');
      await initUserStatusStream();
    }
    getIt.get<GrpcServerConnection>().sendUserstatusUpdate(token, state);
  }

  @override
  Future<int> answerFriendRequest(
      String token, String requesterId, bool accept) {
    return getIt
        .get<GrpcServerConnection>()
        .answerFriendRequest(token, requesterId, accept);
  }

  @override
  Future<int> deleteFriend(String token, String friendId) {
    return getIt.get<GrpcServerConnection>().deleteFriend(token, friendId);
  }

  @override
  Future<List<FriendRequest>> getFriendRequests(String token) {
    return getIt.get<GrpcServerConnection>().getFriendRequests(token);
  }

  @override
  Future<List<Friend>> getFriends(String token) {
    return getIt.get<GrpcServerConnection>().getFriends(token);
  }

  @override
  Future<int> sendFriendRequest(
      String token, String username, String friendId) {
    return getIt
        .get<GrpcServerConnection>()
        .sendFriendRequest(token, username, friendId);
  }

  @override
  Future<int> getNotificationStream(String token) {
    return getIt.get<GrpcServerConnection>().getNotificationStream(token);
  }

  @override
  bool get hasGameStream => getIt.get<GrpcServerConnection>().hasGameStream;

  @override
  bool get hasLobbyStream => getIt.get<GrpcServerConnection>().hasLobbyStream;

  @override
  bool get hasUserStatusStream =>
      getIt.get<GrpcServerConnection>().hasUserStatusStream;

  @override
  bool get hasPlayerStream => getIt.get<GrpcServerConnection>().hasPlayerStream;

  @override
  bool get hasStackStream => getIt.get<GrpcServerConnection>().hasStackStream;

  @override
  bool get hasNotificationStream =>
      getIt.get<GrpcServerConnection>().hasNotificationStream;

  @override
  Stream<ServerEvent> get eventStream => throw UnimplementedError(
      //Is not allowed to be set from here, but needs to be implemented
      "Event stream should not be accessed from apiProvider");

  @override
  // TODO: implement eventController
  StreamController<ServerEvent> get eventController => throw UnimplementedError(
      "Event controller should not be accessed from apiProvider");
}

final apiProvider = ChangeNotifierProvider<ApiProvider>((ref) {
  return ApiProvider(ref.watch(storageProvider),
      ref.watch(notificationProvider), ref.watch(friendProvider));
});
