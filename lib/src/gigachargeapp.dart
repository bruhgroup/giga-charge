import 'package:flutter/material.dart';
import 'settings/settings_dialog.dart';
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
            // Action for leaderboard
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
            Stack(
              alignment: Alignment.center,
              children: [
                const CircularProgressIndicator(
                  value: 0.7, // Simulating a charging effect
                  strokeWidth: 10,
                  color: Colors.green,
                ),
                // Image.asset(
                //   'assets/images/car.png', // Placeholder for car image
                //   height: 100,
                //   width: 100,
                // ),
                //does this work lmao :fire:
                SizedBox(
                  height: 100,
                  width: 100,
                  child: Image.asset(
                    'assets/images/car.png', // Placeholder for car image
                    fit: BoxFit.contain, // Ensures the image fits within the bounds
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Display GigaVolts
            const Text(
              '200 GigaVolts',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Map location widget placeholder
            const Expanded(child: MarkerMap()),
            const SizedBox(height: 20),
            // Swap Button
            ElevatedButton(
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
                  MaterialPageRoute(builder: (context) => const ChatPage()),
                );
              },
            ),

            IconButton(
              icon: const Icon(Icons.qr_code_scanner),
              onPressed: () {
                // Action for scanning QR code
              },
            ),
          ],
        ),
      ),
    );
  }
}