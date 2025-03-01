import 'package:duo_client/provider/api_provider.dart';
import 'package:duo_client/provider/client_connection_provider.dart';
import 'package:duo_client/provider/host_connection_provider.dart';
import 'package:duo_client/provider/storage_provider.dart';
import 'package:duo_client/screens/lobby_screen.dart';
import 'package:duo_client/utils/constants.dart';
import 'package:duo_client/widgets/duo_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'join_dialog.dart';

/// A dialog that allows the user to create or join a game.
///
class GameDialog extends ConsumerStatefulWidget {
  const GameDialog({super.key});

  @override
  ConsumerState<GameDialog> createState() => _GameDialogState();
}

class _GameDialogState extends ConsumerState<GameDialog> {
  bool isLoading = false;

  @override
  Widget build(context) {
    return Dialog(
      backgroundColor: Constants.secondaryColorDark,
      insetPadding: const EdgeInsets.all(20),
      child: SizedBox(
          width: 400,
          height: 270,
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              const Text('NEW GAME',
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  DuoSelectTile(
                    title: 'Host Game',
                    onPressed: () async {
                      ref.read(apiProvider).createLobby(
                          ref.read(storageProvider).accessToken,
                          Constants.maxPlayers);
                      await ref.read(hostConnectionProvider).createLobby();
                      if (ref.watch(hostConnectionProvider).isAdvertising) {
                        Navigator.of(context)
                            .pushReplacementNamed(LobbyScreen.route);
                      }
                    },
                    backgroundColor: Constants.primaryColor,
                    icon: 'res/icons/wifi_house.svg',
                  ),
                  DuoSelectTile(
                    title: !ref.watch(clientConnectionProvider).isDiscovering
                        ? 'Join Game'
                        : 'Leave Game',
                    onPressed: () async {
                      // if (!ref.read(clientConnectionProvider).isDiscovering) {
                      //   ref.read(clientConnectionProvider).initializeBle();
                      //   await ref
                      //       .read(clientConnectionProvider)
                      //       .startDiscovery(serviceUUIDs: []);
                      // } else {
                      //   await ref
                      //       .read(clientConnectionProvider)
                      //       .stopDiscovery();
                      // }
                      //ref.read(await ClientConnectionProvider().onStartScan());

                      showDialog(
                          context: context,
                          builder: (context) => const JoinDialog());
                    },
                    backgroundColor: Constants.primaryColor,
                    icon: 'res/icons/gaming_controller.svg',
                  ),
                ],
              ),
            ],
          )),
    );
  }
}

class DuoSelectTile extends StatelessWidget {
  const DuoSelectTile({
    super.key,
    required this.title,
    required this.onPressed,
    required this.backgroundColor,
    required this.icon,
  });

  final String icon;
  final String title;
  final Function onPressed;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Constants.defaultPadding),
      child: DuoContainer(
        width: 70,
        height: 150,
        backgroundColor: backgroundColor,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(Constants.defaultRadius),
            onTap: () => onPressed(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(icon,
                    width: 100,
                    colorFilter: const ColorFilter.mode(
                        Colors.white60, BlendMode.srcIn)),
                const SizedBox(height: 10),
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.white70)),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
