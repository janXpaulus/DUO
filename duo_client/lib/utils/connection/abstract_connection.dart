import 'package:duo_client/pb/game.pb.dart';
import 'package:duo_client/pb/lobby.pb.dart';

abstract class AbstractServerConnection {
  LobbyStatus? lobbyStatus;
  GameState? gameState;
  StackState? stackState;
  PlayerState? playerState;

  AbstractServerConnection();

  // User management
  Future<int> registerUser(String username);
  Future<int> loginUser(String uuid);

  // Lobby management
  Future<int> createLobby(String token, int maxPlayers);
  Future<int> joinLobby(String token, int lobbyId);
  Future<int> disconnectLobby(String token, int lobbyId);
  Future<int> startGame(String token, int gameId);

  // Game management
  Future<int> getGameStateStream(String token, int gameId);
  Future<int> getPlayerStream(String token, int gameId);
  Future<int> getStackStream(String token, int gameId);
  Future<int> streamPlayerAction(Stream<PlayerAction> action);
}
