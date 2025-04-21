import 'dart:async';
import 'dart:convert';

import 'package:duo_client/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_scanner_overlay/qr_scanner_overlay.dart';

import '../provider/client_connection_provider.dart';
import '../utils/models/client_connection_model.dart';
import '../utils/models/host_connection_model.dart';
import 'lobby_screen.dart';

class QrCodeScanner extends ConsumerStatefulWidget {
  static const route = '/qr-code-scanner';

  const QrCodeScanner({super.key});

  @override
  ConsumerState<QrCodeScanner> createState() => _QrCodeScannerState();
}

class _QrCodeScannerState extends ConsumerState<QrCodeScanner>
    with WidgetsBindingObserver {
  final MobileScannerController _controller = MobileScannerController(
      autoStart: true,
      detectionTimeoutMs: 500,
      detectionSpeed: DetectionSpeed.noDuplicates);
  Color borderColor = Colors.white;
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    _controller.stop();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          buildQrView(context),
          //barcode overlay
          _isLoading
              ? const CircularProgressIndicator(
                  color: Colors.white,
                )
              : SizedBox(
                  child: QRScannerOverlay(
                    scanAreaSize:
                        Size.square(MediaQuery.of(context).size.width * 0.7),
                    borderColor: borderColor,
                  ),
                ),
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              onPressed: () {
                _controller.stop();
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
              icon: const Icon(Icons.close, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> setInvalidColor() async {
    setState(() {
      borderColor = Constants.errorColor.withOpacity(0.4);
    });
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() {
      borderColor = Colors.white;
    });
  }

  Future<void> setValidColor() async {
    setState(() {
      borderColor = Constants.successColor.withOpacity(0.4);
    });
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() {
      borderColor = Colors.white;
      _isLoading = true;
    });
  }

  Widget buildQrView(BuildContext context) {
    return MobileScanner(
        scanWindow: Rect.fromCenter(
            center: Offset(MediaQuery.of(context).size.width / 2,
                MediaQuery.of(context).size.height / 2),
            width: MediaQuery.of(context).size.width * 0.75,
            height: MediaQuery.of(context).size.width * 0.75),
        placeholderBuilder: (BuildContext context, Widget? widget) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        controller: _controller,
        // onDetect: (data) => _foundQrCode(data.barcodes.first));

        onDetect: (data) {
          if (!mounted) return;
          _foundQrCode(data.barcodes.first);
        });
  }

  void printCode(Barcode barcode) {
    //debugPrint("Detected QR code: ${data.rawValue}");
    final encodedData = jsonDecode(barcode.rawValue ?? "");
    ClientConnection clientConnection = ClientConnection.fromJson(encodedData);
    debugPrint(
        "writeCharacteristicUuid: ${clientConnection.writeCharacteristicUuid}");
  }

  bool _validateQrData(HostConnection hostConnection) {
    debugPrint(hostConnection.toString());
    return hostConnection.notifyCharacteristicUuid.isNotEmpty &&
        hostConnection.writeCharacteristicUuid.isNotEmpty;
  }

  void _foundQrCode(Barcode barcode) async {
    if (_isLoading) return; // Prevent multiple scans
    setState(() {
      _isLoading = true;
    });

    debugPrint("Raw QR code data: ${barcode.rawValue ?? ""}");
    final data = barcode.rawValue ?? "";

    try {
      final encodedData = jsonDecode(data);
      final HostConnection hostConnection =
          HostConnection.fromJson(encodedData);

      final isQrValid = _validateQrData(hostConnection);
      if (isQrValid) {
        await setValidColor();
        if (!mounted) return;
        Navigator.of(context).pop();
        ref.read(clientConnectionProvider).handleConnection(hostConnection);
        Navigator.of(context).pushReplacementNamed(LobbyScreen.route);
      } else {
        if (borderColor == Colors.white) await setInvalidColor();
      }
    } catch (e) {
      debugPrint("QR processing error: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
