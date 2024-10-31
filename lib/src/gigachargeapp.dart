import 'package:flutter/material.dart';
import 'chat/chat_select.dart';
import 'settings/settings_dialog.dart';
import 'qr_code_scanner/qr_scanner.dart';
import 'leaderboard/leaderboard.dart';
import 'map/marker_map.dart';
import 'chat/chat_ui.dart';

class GigaSwapApp extends StatelessWidget {
  const GigaSwapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.leaderboard, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LeaderboardPage()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              // Open settings drawer or modal
              showModalBottomSheet(
                context: context,
                builder: (context) => const SettingsDialog(),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Glowing charging effect and car image
            Container(
              margin: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0), // Margin around this component
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const CircularProgressIndicator(
                    value: 0.7, // Simulating a charging effect
                    strokeWidth: 10,
                    color: Colors.green,
                  ),
                  SizedBox(
                    height: 100,
                    width: 100,
                    child: Image.asset(
                      'assets/images/car.png', // Placeholder for car image
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
            // Display GigaVolts
            Container(
              margin: const EdgeInsets.all(8.0), // Margin around this component
              child: const Text(
                '200 GigaVolts',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            // Map location widget placeholder
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(18.0), // Space around this component
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: const MarkerMap(),
                ),
              ),
            ),
            // Swap Button
            Container(
              margin: const EdgeInsets.all(8.0), // Margin around this component
              child: ElevatedButton(
                onPressed: () {
                  // Action for swapping
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('SWAP', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
      // Bottom navigation bar for messages and scanning QR codes
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // IconButton(
            //   icon: const Icon(Icons.message),
            //   onPressed: () {
            //     // Action for viewing messages
            //   },
            // ),
            IconButton(
              icon: const Icon(Icons.message),
              onPressed: () {
                // Navigate to the ChatPage when the chat button is pressed
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RoomSelectionPage()),
                );
              },
            ),

            IconButton(
              icon: const Icon(Icons.qr_code_scanner),
              onPressed: () {
                // Navigate to the QR code scanner screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const BarcodeScannerWithZoom()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
