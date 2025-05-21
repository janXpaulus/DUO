import 'package:flutter_test/flutter_test.dart';
import 'package:duo_client/provider/dummy_game_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Cards are loaded from JSON and mapped correctly', () async {
    final provider = DummyGameProvider();
    await provider.loadCardsFromJson();

    // Check that cardData is not empty
    expect(provider.cardData.isNotEmpty, true);

    // Check that _cardsList contains exactly 104 card strings
    expect(
        provider.cardData.values
            .map((c) => c.cardCount)
            .reduce((a, b) => a + b),
        104);
    expect(provider.cardData.length > 0, true);

    // Optionally, check that card attributes are accessible
    final anyCardId = provider.cardData.keys.first;
    final anyCard = provider.cardData[anyCardId];
    expect(anyCard, isNotNull);
  });

  group('DummyGameProvider.canPlaceCard', () {
    late DummyGameProvider provider;

    setUp(() {
      provider = DummyGameProvider();

      // Add two sample cards to the provider's card data
      provider.cardData['red_5'] = UnoCard(
        cardId: 'red_5',
        cardColor: 'red',
        cardValue: '5',
        cardType: 'number',
        specialEffect: '',
        cardCount: 1,
      );
      provider.cardData['red_7'] = UnoCard(
        cardId: 'red_7',
        cardColor: 'red',
        cardValue: '7',
        cardType: 'number',
        specialEffect: '',
        cardCount: 1,
      );
      provider.cardData['blue_5'] = UnoCard(
        cardId: 'blue_5',
        cardColor: 'blue',
        cardValue: '5',
        cardType: 'number',
        specialEffect: '',
        cardCount: 1,
      );
      provider.cardData['wild_draw_4'] = UnoCard(
        cardId: 'wild_draw_4',
        cardColor: 'wild',
        cardValue: 'draw_4',
        cardType: 'special',
        specialEffect: 'draw_4',
        cardCount: 1,
      );
    });

    test('returns true if color matches', () {
      expect(provider.canPlaceCard('red_5', 'red_7'), isTrue);
    });

    test('returns true if value matches', () {
      expect(provider.canPlaceCard('red_5', 'blue_5'), isTrue);
    });

    test('returns true if card to place is wild', () {
      expect(provider.canPlaceCard('wild_draw_4', 'red_7'), isTrue);
    });

    test('returns false if neither color nor value nor wild', () {
      expect(provider.canPlaceCard('red_7', 'blue_5'), isFalse);
    });

    test('returns false if card ids are invalid', () {
      expect(provider.canPlaceCard('invalid', 'red_7'), isFalse);
      expect(provider.canPlaceCard('red_7', 'invalid'), isFalse);
    });
  });

  group('DummyGameProvider.isSpecialCard', () {
    late DummyGameProvider provider;

    setUp(() {
      provider = DummyGameProvider();

      // Add example cards
      provider.cardData['red_5'] = UnoCard(
        cardId: 'red_5',
        cardColor: 'red',
        cardValue: '5',
        cardType: 'number',
        specialEffect: '',
        cardCount: 1,
      );
      provider.cardData['red_suspend'] = UnoCard(
        cardId: 'red_suspend',
        cardColor: 'red',
        cardValue: 'suspend',
        cardType: 'special',
        specialEffect: 'suspend',
        cardCount: 1,
      );
    });

    test('returns false for a number card', () {
      expect(provider.isSpecialCard('red_5'), isFalse);
    });

    test('returns true for a special card', () {
      expect(provider.isSpecialCard('red_suspend'), isTrue);
    });

    test('returns false for an unknown card', () {
      expect(provider.isSpecialCard('unknown_card'), isFalse);
    });
  });
}
