import 'package:duo_client/pb/friend.pb.dart';
import 'package:duo_client/utils/constants.dart';
import 'package:duo_client/widgets/qr_join_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class InviteDialog extends ConsumerWidget {
  InviteDialog(
      {super.key, required this.invideCode, required this.clientConnection});
  //TODO: input inviteCode from lobby screen

  late final Friend friendInvited;
  final String invideCode;
  final String clientConnection;

  final Map<String, String> data = {
    "serviceUuid": "9338175b-20ca-4173-bea3-32214c49cb3e",
    "writeUuid": "fc384875-ee34-4f92-a0cf-b83479a69978",
    "readUuid": "26ea668e-f15a-4e67-9bd1-454836fe91ad"
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // if this code is executed, it will cause an error
    // the lobbyStatus will become null and the app will crash
    // ref.read(apiProvider).getToken().then((token) {
    //   ref.read(apiProvider).getFriends(token);
    // });

    return Dialog(
      backgroundColor: Constants.secondaryColorDark,
      insetPadding: const EdgeInsets.all(20),
      child: SizedBox(
          width: 400,
          height: 450,
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              const Text('INVITE FRIENDS',
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70)),
              const SizedBox(height: 20),
              Center(
                child: QrImageView(
                  data: clientConnection,
                  version: QrVersions.auto,
                  size: 200,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: Constants.defaultPadding),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: Constants.defaultPadding * 2),
                child: Row(
                  children: [
                    Text(
                      'Join via Code:  $invideCode',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => showDialog(
                          context: context,
                          builder: (context) => QrJoinDialog(
                                title:
                                    'Scan this QR code with the DUO app to join the group:',
                                data: invideCode,
                              )),
                      icon: const Icon(
                        Icons.qr_code_2_rounded,
                        color: Colors.white54,
                      ),
                    ),
                    const SizedBox(width: Constants.defaultPadding / 2),
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.white54),
                      onPressed: () async {
                        await Share.share(
                            'Join me on Duo using this code: *$invideCode*');
                      },
                    ),
                    // const SizedBox(width: Constants.defaultPadding / 2),
                  ],
                ),
              ),
              const SizedBox(height: Constants.defaultPadding),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child:
                    const Text('Cancel', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: Constants.defaultPadding),
            ],
          )),
    );
  }
}
