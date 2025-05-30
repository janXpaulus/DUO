import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:duo_client/provider/host_connection_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Card model
class UnoCard {
  final String cardId;
  final String cardColor;
  final String cardValue;
  final String cardType;
  final String specialEffect;
  final int cardCount;

  UnoCard({
    required this.cardId,
    required this.cardColor,
    required this.cardValue,
    required this.cardType,
    required this.specialEffect,
    required this.cardCount,
  });

  factory UnoCard.fromJson(Map<String, dynamic> json) {
    return UnoCard(
      cardId: json['CardId'],
      cardColor: json['CardColor'],
      cardValue: json['CardValue'],
      cardType: json['CardType'],
      specialEffect: json['SpecialEffect'],
      cardCount: json['CardCount'],
    );
  }
}

class DummyGameProvider extends ChangeNotifier {
  final dummyGameProvider = ChangeNotifierProvider<DummyGameProvider>((ref) {
    return DummyGameProvider();
  });

  // List of all cards as CardId strings (with duplicates)
  List<String> _cardsList = [];

  // Map of CardId to UnoCard for attribute lookup
  Map<String, UnoCard> _cardData = {};

  List<String> _shuffledCardsList = [];

  List<String> _stackList = [];

  Map<String, List<String>> _playerCards = {};

  String _currentTurnPlayer = "";

  List<String> get stackList => _stackList;

  Map<String, List<String>> get playerCards => _playerCards;

  List<String> get shuffledCardsList => _shuffledCardsList;

  Map<String, UnoCard> get cardData => _cardData;

  int _currentPlayerIndex = 0;
  int _turnOffset = 1; // How many players to skip (1 = normal, 2 = skip)
  int _direction = 1; // 1 = clockwise, -1 = counterclockwise
  int get turnOffset => _turnOffset;
  int get direction => _direction;

  List<String> _playerOrder = [];

  Future<void> loadCardsFromJson() async {
    //Log the path of the JSON file
    final String jsonString =
        await rootBundle.loadString('assets/uno_cards.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    final List<dynamic> cardsJson = jsonData['cards'];
    _cardsList = [];
    _cardData = {};
    for (var cardJson in cardsJson) {
      final card = UnoCard.fromJson(cardJson);
      _cardData[card.cardId] = card;
      for (int i = 0; i < card.cardCount; i++) {
        _cardsList.add(card.cardId);
      }
    }
  }

  Future<void> startGame(WidgetRef ref) async {
    if (_cardsList.isEmpty) {
      await loadCardsFromJson();
    }
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

    final firstCard = _shuffledCardsList.removeAt(0);
    _stackList.add(firstCard);

    _playerOrder = connectedClients.map((slot) => slot.playerId).toList();
    debugPrint("Player Order: $_playerOrder");
    _currentPlayerIndex = 0;
    _currentTurnPlayer = _playerOrder[_currentPlayerIndex];
    debugPrint("Current player: $_currentTurnPlayer");
    await hostConnection.notifyPlayerOfTurn(_currentTurnPlayer);

    // _currentTurnPlayer = _playerCards.keys.first;
    // await hostConnection.notifyPlayerOfTurn(_currentTurnPlayer);
    // debugPrint("Current player: $_currentTurnPlayer");
    hostConnection.isGameReady = true;
  }

  void nextPlayerTurn(WidgetRef ref) {
    if (_playerOrder.isEmpty) return;
    _currentPlayerIndex = (_currentPlayerIndex + (_turnOffset * _direction)) %
        _playerOrder.length;
    if (_currentPlayerIndex < 0) {
      _currentPlayerIndex += _playerOrder.length;
    }
    _currentTurnPlayer = _playerOrder[_currentPlayerIndex];
    debugPrint("Next player: $_currentTurnPlayer");
    ref.read(hostConnectionProvider).notifyPlayerOfTurn(_currentTurnPlayer);
    _turnOffset = 1;
    notifyListeners();
  }

  Future<void> placePlayerCardOnStack(
      String cardName, String playerId, Ref ref) async {
    if (playerId != _currentTurnPlayer) return; // Only current player can play
    _stackList = List.from(_stackList)..add(cardName);
    notifyListeners();
    _playerCards[playerId]?.remove(cardName);
    notifyListeners();
    // Handle special card logic
    if (isSpecialCard(cardName)) {
      handleSpecialCard(cardName);
    }
    nextPlayerTurn(ref as WidgetRef); // Advance turn
    // await ref
    //     .read(hostConnectionProvider)
    //     .updateCardsInClient(playerId, playerCards[playerId] ?? []);
  }

  Future<void> sendCardToCurrentPlayer(WidgetRef ref, String cardName) async {
    if (_shuffledCardsList.isEmpty) {
      reshuffleStackIntoDeck();
    }

    _playerCards[_currentTurnPlayer]?.add(cardName);
    await ref.read(hostConnectionProvider).updateCardsInClient(
        _currentTurnPlayer, _playerCards[_currentTurnPlayer]!);
  }

  /// Checks if [cardToPlaceId] can be placed on top of [topCardId].
  bool canPlaceCard(String cardToPlaceId, String topCardId) {
    final cardToPlace = _cardData[cardToPlaceId];
    final topCard = _cardData[topCardId];

    if (cardToPlace == null || topCard == null) return false;

    // Allow if color or value matches, or if card is a wild card
    return cardToPlace.cardColor == topCard.cardColor ||
        cardToPlace.cardValue == topCard.cardValue ||
        topCard.cardColor == 'wild' ||
        cardToPlace.cardColor == 'wild';
  }

  //bool canPlace = canPlaceCard(playerCardId, stackTopCardId);

  bool isSpecialCard(String cardId) {
    final card = _cardData[cardId];
    if (card == null) return false;
    return card.cardType == 'special';
  }

  void handleSpecialCard(String cardId) {
    final card = _cardData[cardId];
    if (card == null) return;

    if (card.specialEffect == 'suspend') {
      // Skip next player
      _turnOffset = 2;
    } else if (card.specialEffect == 'change_directions') {
      // Reverse direction
      _direction *= -1;
    }
  }

  void reshuffleStackIntoDeck() {
    if (_stackList.length <= 1) return; // Nothing to reshuffle
    // Remove all but the top card from the stack
    final cardsToReshuffle = _stackList.sublist(0, _stackList.length - 1);
    _stackList = [_stackList.last];
    // Add to deck and shuffle
    _shuffledCardsList.addAll(cardsToReshuffle);
    _shuffledCardsList.shuffle();
    notifyListeners();
  }

  Future<void> stopGame() async {
    _stackList = [];
    _playerCards.clear();
  }
}

final dummyGameProvider =
    ChangeNotifierProvider<DummyGameProvider>((ref) => DummyGameProvider());
