import 'package:duo_client/provider/client_connection_provider.dart';
import 'package:duo_client/utils/constants.dart';
import 'package:duo_client/widgets/playingcard.dart' as duo;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/connection_provider.dart';

class CardScrollView extends ConsumerStatefulWidget {
  const CardScrollView({super.key});

  static Route<Object?> get route =>
      MaterialPageRoute(builder: (_) => CardScrollView());

  final Duration _waitDuration = const Duration(milliseconds: 100);

  @override
  ConsumerState<CardScrollView> createState() => _CardScrollViewState();
}

class _CardScrollViewState extends ConsumerState<CardScrollView> {
  bool isTurn = true;
  List<duo.PlayingCard> cards = [
    //TODO delete
    const duo.PlayingCard.fromCard(cardName: 'green_3'),
    const duo.PlayingCard.fromCard(cardName: 'purple_4'),
    const duo.PlayingCard.fromCard(cardName: 'yellow_draw_2'),
    const duo.PlayingCard.fromCard(cardName: 'red_1'),
  ];
  List<String> cardNames = [];

  //ToDo: BUG if the cards are removed before the animation is done it will crash or before on Reorder is done

  @override
  Widget build(BuildContext context) {
    cardNames = ref.watch(connectionProvider).cards;
    debugPrint("$cardNames");
    cards = cardNames
        .map((element) => duo.PlayingCard.fromCard(cardName: element))
        .toList();

    isTurn = false;
    // isTurn = _apiProvider.gameState == null
    //     ? false
    //     : _apiProvider.gameState!.currentPlayerUuid == _storageProvider.userId;
    // debugPrint('Current hand: ${_apiProvider.playerState?.hand}');
    return Padding(
      padding: const EdgeInsets.only(bottom: Constants.defaultPadding, top: 70),
      child: ListView.builder(
        // onReorderStart: (index) => {
        //   HapticFeedback.lightImpact(),
        // },
        // onReorder: (oldIndex, newIndex) {
        //   setState(() {
        //     if (newIndex > oldIndex) {
        //       newIndex -= 1;
        //     }
        //     final card = cards.removeAt(oldIndex);
        //     cards.insert(newIndex, card);
        //   });
        // },
        scrollDirection: Axis.horizontal,
        itemCount: cards.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: UniqueKey(),
            direction: DismissDirection.up,
            onDismissed: (direction) {
              playCard(index);
              setState(() => cards.removeAt(index));
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: cards[index],
            ),
          );
        },
      ),
    );
  }

  void playCard(int index) {
    final card = cards[index].cardName;
    ref.read(clientConnectionProvider).placeCard(card);
    // debugPrint('Playing card with value ${cards[index].cardName}');
    // ref.read(apiProvider).streamPlayerAction(PlayerAction(
    //       action: PlayerAction_ActionType.PLACE,
    //       cardId: cards[index].cardName,
    //     ));
  }
}
