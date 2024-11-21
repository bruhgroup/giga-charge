import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../chat/chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'scanned_barcode_label.dart';
import 'scanner_button_widgets.dart';
import 'scanner_error_widget.dart';


class BarcodeScannerWithZoom extends StatefulWidget {
  final User user;
  const BarcodeScannerWithZoom({super.key, required this.user});

  @override
  State<BarcodeScannerWithZoom> createState() => _BarcodeScannerWithZoomState();
}

class _BarcodeScannerWithZoomState extends State<BarcodeScannerWithZoom> {
  late types.User a;

  @override
  void initState() {
    super.initState();

    a = types.User(
      id: widget.user.uid,  // UID from Firebase Authentication
      firstName: widget.user.displayName?.split(' ').first,  // First name
      imageUrl: widget.user.photoURL ?? 'https://i.pravatar.cc/300',  // Fallback image if null
    );
  }

  final MobileScannerController controller = MobileScannerController(
    torchEnabled: true,
  );

  double _zoomFactor = 0.0;
  final TextEditingController _licensePlateController = TextEditingController();

  // Method to create new chat (or handle your specific functionality here)
  Future<void> _createNewChat() async {
    final licensePlate = _licensePlateController.text;
    if (licensePlate.isNotEmpty) {
      // Call the function to create the chat with the license plate
      print('Creating new chat for License Plate: $licensePlate');
      final navigator = Navigator.of(context);
      // For debugging purposes, we will create a chat with a fixed user
      final room = await FirebaseChatCore.instance.createRoom(const types.User(id: "BvZIv8zzUSb4dy7iDgoQbeFXddy2"));
      await navigator.push(
        MaterialPageRoute(
          builder: (context) => ChatPage(
            room: room,
            user: a,
          ),
        ),
      );
      // Insert your chat creation logic here, for example, navigating to a new page
    } else {
      _showEmptyLicensePlateDialog();
    }
  }

  // Method to show a dialog if license plate is empty
  void _showEmptyLicensePlateDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: const Text('Please enter a valid license plate'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildZoomScaleSlider() {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, state, child) {
        if (!state.isInitialized || !state.isRunning) {
          return const SizedBox.shrink();
        }

        final TextStyle labelStyle = Theme.of(context)
            .textTheme
            .headlineMedium!
            .copyWith(color: Colors.white);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              Text(
                '0%',
                overflow: TextOverflow.fade,
                style: labelStyle,
              ),
              Expanded(
                child: Slider(
                  value: _zoomFactor,
                  onChanged: (value) {
                    setState(() {
                      _zoomFactor = value;
                      controller.setZoomScale(value);
                    });
                  },
                ),
              ),
              Text(
                '100%',
                overflow: TextOverflow.fade,
                style: labelStyle,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan a QR code'), backgroundColor: const Color(0xff7fafff)),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            fit: BoxFit.contain,
            errorBuilder: (context, error, child) {
              return ScannerErrorWidget(error: error);
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              alignment: Alignment.bottomCenter,
              height: 200, // Increased space to fit the text box
              color: Colors.black.withOpacity(0.4),
              child: Column(
                children: [
                  if (!kIsWeb) _buildZoomScaleSlider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ToggleFlashlightButton(controller: controller),
                      StartStopMobileScannerButton(controller: controller),
                      Expanded(
                        child: Center(
                          child: ScannedBarcodeLabel(
                            barcodes: controller.barcodes,
                          ),
                        ),
                      ),
                      SwitchCameraButton(controller: controller),
                      AnalyzeImageFromGalleryButton(controller: controller),
                    ],
                  ),
                  // License Plate TextField and Button
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _licensePlateController,
                            decoration: InputDecoration(
                              labelText: 'Enter License Plate',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            keyboardType: TextInputType.text,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.check, color: Colors.white),
                          onPressed: _createNewChat, // Call _createNewChat when pressed
                        ),
                      ],
                    ),
                  ),
                  // Display typed license plate (Optional)
                  if (_licensePlateController.text.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'License Plate: ${_licensePlateController.text}',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    await controller.dispose();
    _licensePlateController.dispose(); // Clean up the text controller
  }
}

