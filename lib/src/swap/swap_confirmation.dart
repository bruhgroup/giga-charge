import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import '../gigachargeapp.dart';
import '../map/marker_map.dart';

class SwapConfirmationPage extends StatelessWidget {
  final String swapPartnerName = "Joe's Car";
  final String otpCode = "123456"; // Example OTP code
  final String mapLocationUrl = 'https://maps.example.com';

  const SwapConfirmationPage({super.key}); // Placeholder for map

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Swap Confirmation"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Swap Partner Information
            Text(
              "Ready to Swap with $swapPartnerName?",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // QR Code and OTP Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    "Scan this QR Code or Enter OTP",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 16),

                  // QR Code Display
                  QrImageView(
                    data: '1234567890',
                    version: QrVersions.auto,
                    size: 200.0,
                  ),
                  const SizedBox(height: 16),

                  // OTP Code Display
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Your OTP: ",
                        style: TextStyle(fontSize: 16),
                      ),
                      SelectableText(
                        otpCode,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          // Copy OTP to clipboard
                          Clipboard.setData(ClipboardData(text: otpCode));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("OTP copied to clipboard")),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Map Section
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  children: [
                    Text(
                      "Parking Spot Location",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 16),

                    // Placeholder for the map
                    Expanded(
                      child: MarkerMap(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Confirm Button
            ElevatedButton(
              onPressed: () async {
                try {
                  // Increment user points by 20 in Firestore
                  FirebaseAuth auth = FirebaseAuth.instance;
                  final userDoc = FirebaseFirestore.instance
                      .collection('users')
                      .doc(auth.currentUser!.uid);
                  await userDoc.update({
                    'points': FieldValue.increment(20),
                  });

                  // Show success dialog
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Swap Successful!"),
                      content: const Text("You've successfully swapped spots and earned 20 GigaVolts!"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) => const GigaSwapApp()),
                            );
                          },
                          child: const Text("OK"),
                        ),
                      ],
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: ${e.toString()}")),
                  );
                }
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  "Confirm Swap",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
