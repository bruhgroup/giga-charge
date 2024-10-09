import 'package:flutter/material.dart';
import 'settings/settings_dialog.dart';


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
                builder: (context) => SettingsDialog(),
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
                Image.asset(
                  'assets/car.png', // Placeholder for car image
                  height: 100,
                  width: 100,
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
            Container(
              width: 300,
              height: 150,
              color: Colors.grey[300],
              child: const Center(
                child: Text(
                  'Map/Location',
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            ),
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
            IconButton(
              icon: const Icon(Icons.message),
              onPressed: () {
                // Action for viewing messages
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