import 'package:duo_client/provider/host_connection_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DummyGameProvider extends ChangeNotifier {
  final dummyGameProvider = ChangeNotifierProvider<DummyGameProvider>((ref) {
    return DummyGameProvider();
  });

  final _cardsList = [
    "draw_4",
    "green_1",
    "green_2",
    "green_3",
    "green_4",
    "green_5",
    "green_6",
    "green_7",
    "green_8",
    "green_9",
    "green_change_directions",
    "green_draw_2",
    "green_suspend",
    "purple_1",
    "purple_2",
    "purple_3",
    "purple_4",
    "purple_5",
    "purple_6",
    "purple_7",
    "purple_8",
    "purple_9",
    "purple_change_directions",
    "purple_draw_2",
    "purple_suspend",
    "red_1",
    "red_2",
    "red_3",
    "red_4",
    "red_5",
    "red_6",
    "red_7",
    "red_8",
    "red_9",
    "red_change_directions",
    "red_draw_2",
    "red_suspend",
    "select_color",
    "yellow_1",
    "yellow_2",
    "yellow_3",
    "yellow_4",
    "yellow_5",
    "yellow_6",
    "yellow_7",
    "yellow_8",
    "yellow_9",
    "yellow_change_directions",
    "yellow_draw_2",
    "yellow_suspend",
  ];

  List<String> _shuffledCardsList = [];

  List<String> _stackList = [];

  Map<String, List<String>> _playerCards = {};

  String _currentTurnPlayer = "";

  List<String> get stackList => _stackList;

  Map<String, List<String>> get playerCards => _playerCards;

  List<String> get shuffledCardsList => _shuffledCardsList;

  Future<void> startGame(WidgetRef ref) async {
    //  Generate hands of cards
    _cardsList.shuffle();
    _shuffledCardsList = List<String>.from(_cardsList);
    final hostConnection = ref.read(hostConnectionProvider);
    final connectedClients = hostConnection.connectedClients;
    for (var slot in connectedClients) {
      List<String> playerCardList = [];
      for (var i = 0; i < 7; i++) {
        playerCardList.add(_shuffledCardsList.removeAt(0));
      }
      playerCards[slot.playerId] = playerCardList;
    }

    debugPrint("Player Cards: ${playerCards.toString()}");

    //   Send hands of cards to players
    for (var slot in connectedClients) {
      debugPrint("${playerCards[slot.playerId]}");
      await hostConnection.updateCardsInClient(
          slot.playerId, playerCards[slot.playerId] ?? []);
    }

    _currentTurnPlayer = _playerCards.keys.first;
    await hostConnection.notifyPlayerOfTurn(_currentTurnPlayer);
    debugPrint("Current player: $_currentTurnPlayer");
    hostConnection.isGameReady = true;
  }

  Future<void> placePlayerCardOnStack(
      String cardName, String playerId, Ref ref) async {
    _stackList = List.from(_stackList)..add(cardName);
    notifyListeners();
    _playerCards[playerId]?.remove(cardName);
    notifyListeners();
    // await ref
    //     .read(hostConnectionProvider)
    //     .updateCardsInClient(playerId, playerCards[playerId] ?? []);
  }

  Future<void> sendCardToCurrentPlayer(WidgetRef ref, String cardName) async {
    _playerCards[_currentTurnPlayer]?.add(cardName);
    await ref.read(hostConnectionProvider).updateCardsInClient(
        _currentTurnPlayer, _playerCards[_currentTurnPlayer]!);
  }

  Future<void> stopGame() async {
    _stackList = [];
    _playerCards.clear();
  }
}

final dummyGameProvider =
    ChangeNotifierProvider<DummyGameProvider>((ref) => DummyGameProvider());
