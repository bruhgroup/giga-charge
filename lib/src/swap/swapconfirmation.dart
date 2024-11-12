import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import '../map/marker_map.dart';

class SwapConfirmationPage extends StatelessWidget {
  final String swapPartnerName = "Joe's Car";
  final String otpCode = "123456"; // Example OTP code
  final String mapLocationUrl = 'https://maps.example.com'; // Placeholder for map

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Swap Confirmation"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Swap Partner Information
            Text(
              "Ready to Swap with $swapPartnerName?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),

            // QR Code and OTP Section
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    "Scan this QR Code or Enter OTP",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 16),

                  // QR Code Display
                  QrImageView(
                    data: '1234567890',
                    version: QrVersions.auto,
                    size: 200.0,
                  ),
                  SizedBox(height: 16),

                  // OTP Code Display
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Your OTP: ",
                        style: TextStyle(fontSize: 16),
                      ),
                      SelectableText(
                        otpCode,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.copy),
                        onPressed: () {
                          // Copy OTP to clipboard
                          Clipboard.setData(ClipboardData(text: otpCode));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("OTP copied to clipboard")),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Map Section
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16),
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
            SizedBox(height: 24),

            // Confirm Button
            ElevatedButton(
              onPressed: () {
                // Handle confirm swap action
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("Swap Successful!"),
                    content: Text("You've successfully swapped spots and earned 20 GigaVolts!"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text("OK"),
                      ),
                    ],
                  ),
                );
              },
              child: Padding(
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
