import 'package:duo_client/pb/game.pb.dart';
import 'package:duo_client/provider/dummy_game_provider.dart';
import 'package:duo_client/widgets/duo_card_stack.dart';
import 'package:duo_client/widgets/playingcard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GameStacks extends ConsumerStatefulWidget {
  const GameStacks({super.key});

  @override
  ConsumerState<GameStacks> createState() => _GameStacksState();
}

class _GameStacksState extends ConsumerState<GameStacks> {
  @override
  Widget build(BuildContext context) {
    List<String> stackList = ref.watch(dummyGameProvider).stackList;
    debugPrint("$stackList");

    StackState stackState = StackState(
      drawStack: DrawStackState(
          cardIds:
              ref.watch(dummyGameProvider).shuffledCardsList ?? ['green_1']),
      placeStack: PlaceStackState(
          cardIdOnTop: stackList.isNotEmpty ? stackList.last : 'back'),
    );
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          // Draw stack
          SizedBox(
            height: 300,
            child: DUOCardStack(
              cards: [
                PlayingCard(
                  cardName:
                      ref.watch(dummyGameProvider).shuffledCardsList.isNotEmpty
                          ? ref.watch(dummyGameProvider).shuffledCardsList.last
                          : "back",
                  isFaceUp: false,
                ),
              ],
              randomAngles: false,
              onTap: (PlayingCard card) async {
                debugPrint('requesting Card for player');
                ref
                    .read(dummyGameProvider)
                    .sendCardToCurrentPlayer(ref, card.cardName);
                // String token = await ref.read(apiProvider).getToken();
                // ref
                //     .watch(apiProvider)
                //     .requestCard(token, ref.read(apiProvider).gameId);
              },
            ),
          ),
          // Place stack
          SizedBox(
            height: 300,
            child: DUOCardStack(
              cards: [
                PlayingCard(
                  cardName: ref.watch(dummyGameProvider).stackList.isNotEmpty
                      ? ref.watch(dummyGameProvider).stackList.last
                      : 'back',
                  isFaceUp: true,
                ),
              ],
              randomAngles: true,
            ),
          ),
        ],
      ),
    );
  }
}
