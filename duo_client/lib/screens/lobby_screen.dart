import 'package:animated_background/animated_background.dart';
import 'package:duo_client/pb/friend.pb.dart';
import 'package:duo_client/pb/user.pb.dart';
import 'package:duo_client/provider/api_provider.dart';
import 'package:duo_client/provider/host_connection_provider.dart';
import 'package:duo_client/provider/storage_provider.dart';
import 'package:duo_client/screens/game_screen.dart';
import 'package:duo_client/screens/home_screen.dart';
import 'package:duo_client/utils/constants.dart';
import 'package:duo_client/widgets/user_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../widgets/add_tile.dart';
import '../widgets/invite_dialog.dart';

class LobbyScreen extends ConsumerStatefulWidget {
  const LobbyScreen({super.key});

  static const route = "/lobby";

  @override
  ConsumerState<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends ConsumerState<LobbyScreen>
    with TickerProviderStateMixin {
  bool joiningGame = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(apiProvider).sendUserstatusUpdate(
          await ref.read(apiProvider).getToken(), FriendState.inLobby);
    });
    ref.read(hostConnectionProvider).subscribeToPlayerRegistrations();
  }

  @override
  Widget build(BuildContext context) {
    // ApiProvider _apiProvider = ref.watch(apiProvider);
    bool creatingLobby = false;
    /*
        ref.watch(apiProvider).lobbyStatus == null &&
        ref.watch(apiProvider).gameId == -1;
    int lobbyId = ref.read(apiProvider).lobbyStatus?.lobbyId ?? 0;*/
    // ref.listen(apiProvider, (ApiProvider? oldState, ApiProvider? newState) {
    //   if ((newState?.gameId ?? 0) > 0 && newState?.lobbyStatus == null) {
    //     Navigator.of(context).pushReplacementNamed(GameScreen.route);
    //   }
    //   if ((newState?.gameId) == -2 && !(newState?.hasLobbyStream ?? true)) {
    //     Navigator.of(context).pushReplacementNamed(HomeScreen.route);
    //   }
    // });

    bool gameReady = ref.watch(apiProvider).gameId > 0 &&
        ref.watch(apiProvider).lobbyStatus == null;

    final hostConnection = ref.watch(hostConnectionProvider);

    return Scaffold(
      backgroundColor: Constants.bgColor,
      appBar: AppBar(
        toolbarHeight: 100,
        automaticallyImplyLeading: false,
        title: const Padding(
          padding: EdgeInsets.all(18.0),
          child: Center(
              child: Text(
            'Lobby',
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
          )),
        ),
      ),
      body: creatingLobby
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SpinKitChasingDots(
                  color: Constants.secondaryColor,
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  joiningGame ? 'Joining Game...' : 'Joining Lobby...',
                  style: const TextStyle(fontSize: 20, color: Colors.white70),
                ),
                const SizedBox(
                  height: 20,
                ),
                IconButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pushReplacementNamed(HomeScreen.route);
                    },
                    icon: const Icon(
                      Icons.exit_to_app_outlined,
                      color: Colors.white,
                    )),
                const SizedBox(
                  width: 20,
                ),
                const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            )
          : AnimatedBackground(
              behaviour: RandomParticleBehaviour(
                options: const ParticleOptions(
                  baseColor: Constants.primaryColor,
                  spawnMaxSpeed: 100,
                  spawnMinSpeed: 50,
                  spawnMaxRadius: 10,
                  spawnMinRadius: 5,
                  particleCount: 100,
                ),
              ),
              vsync: this,
              child: Padding(
                padding: const EdgeInsets.all(Constants.defaultPadding),
                child: Column(
                  children: [
                    const Text(
                      'DUO PLAYERS',
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Expanded(
                      child: GridView(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.5,
                          ),
                          children: [
                            ...hostConnection.connectedClients.entries
                                .map((entry) {
                              final clientConnection = entry.value;
                              if (clientConnection.isConnected) {
                                return Padding(
                                  padding: const EdgeInsets.all(
                                      Constants.defaultPadding / 2),
                                  child: UserTile(
                                    user:
                                        User(name: clientConnection.playerName),
                                    isStack: clientConnection.isStack,
                                  ),
                                );
                              } else {
                                return Padding(
                                  padding: const EdgeInsets.all(
                                      Constants.defaultPadding / 2),
                                  child: AddTile(
                                    Dialog: InviteDialog(
                                        invideCode: "shit",
                                        clientConnection: clientConnection
                                            .toJson()
                                            .toString(),
                                        isConnected:
                                            clientConnection.isConnected),
                                  ),
                                );
                              }
                            }),
                          ]),
                    ),
                    gameReady
                        ? Padding(
                            padding:
                                const EdgeInsets.all(Constants.defaultPadding),
                            child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pushReplacementNamed(GameScreen.route);
                                },
                                child: const Text('Go to Game',
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.white70))),
                          )
                        : Padding(
                            padding:
                                const EdgeInsets.all(Constants.defaultPadding),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Constants.errorColor),
                                      onPressed: () async {
                                        await hostConnection.leaveLobby();
                                        if (!hostConnection.isAdvertising) {
                                          print(
                                              'Disconnected sucessfully from lobby');
                                          Navigator.of(context)
                                              .pushReplacementNamed(
                                                  HomeScreen.route);
                                        } else {
                                          print('Error leaving lobby');
                                        }
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.all(3),
                                        child: Text('Leave Lobby',
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.white70)),
                                      )),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: Constants.defaultPadding),
                                  child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Constants.successColor),
                                      onPressed: () async {
                                        if (ref.read(storageProvider).userId ==
                                            ref
                                                .read(apiProvider)
                                                .lobbyStatus!
                                                .users
                                                .where((element) =>
                                                    element.isAdmin)
                                                .first
                                                .uuid) {
                                          // TODO: change back to 3 players for a game but for testing purposes 2
                                          if (ref
                                                  .read(apiProvider)
                                                  .lobbyStatus!
                                                  .users
                                                  .length <
                                              0) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'You need at least 3 players to start the game'),
                                              ),
                                            );
                                            return;
                                          }
                                          String token = await ref
                                              .read(apiProvider)
                                              .getToken();
                                          ref
                                              .read(apiProvider)
                                              .startGame(token);
                                          //TODO: Start game logic for BLE
                                          joiningGame = true;
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Only the Host can start the game'),
                                            ),
                                          );
                                        }
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.all(2.0),
                                        child: Text('Start Game',
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.white70)),
                                      )),
                                )
                              ],
                            ),
                          ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              )),
    );
  }

  User getStackUser(List<User> users) {
    for (User user in users) {
      if (user.isStack) {
        return user;
      }
    }
    return User();
  }
}
