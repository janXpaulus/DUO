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

  Future<void> stopGame() async {
    _stackList = [];
    _playerCards.clear();
  }
}

final dummyGameProvider =
    ChangeNotifierProvider<DummyGameProvider>((ref) => DummyGameProvider());
