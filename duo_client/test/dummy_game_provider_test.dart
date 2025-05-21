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
}
