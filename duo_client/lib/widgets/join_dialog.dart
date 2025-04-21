import 'package:duo_client/provider/api_provider.dart';
import 'package:duo_client/provider/storage_provider.dart';
import 'package:duo_client/screens/lobby_screen.dart';
import 'package:duo_client/screens/qr_scanner_screen.dart';
import 'package:duo_client/utils/constants.dart';
import 'package:duo_client/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class JoinDialog extends ConsumerStatefulWidget {
  const JoinDialog({super.key});

  @override
  ConsumerState<JoinDialog> createState() => _JoinDialogState();
}

class _JoinDialogState extends ConsumerState<JoinDialog> {
  final TextEditingController _controller = TextEditingController();
  bool wrongInviteCode = false;
  String hintText = 'Scan the Host Code to join a game';

  @override
  Widget build(BuildContext context) {
    return Dialog(
        backgroundColor: Constants.secondaryColorDark,
        insetPadding: const EdgeInsets.all(20),
        child: SizedBox(
          width: 400,
          height: 200,
          child: Padding(
            padding: const EdgeInsets.all(Constants.defaultPadding),
            child: Column(
              children: [
                const Text(
                  'Join a Game',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70),
                ),
                const SizedBox(height: 20),
                Text(
                  hintText,
                  style: TextStyle(
                    fontSize: 16,
                    color:
                        wrongInviteCode ? Constants.errorColor : Colors.white70,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.white),
                        )),
                    ElevatedButton.icon(
                      onPressed: () async {
                        //Just here pushNamed and not pushReplacementNamed
                        dynamic id = await Navigator.of(context)
                            .pushNamed(QrCodeScanner.route);
                      },
                      icon: const Icon(
                        Icons.qr_code_scanner_rounded,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Join Game',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ));
  }
}
