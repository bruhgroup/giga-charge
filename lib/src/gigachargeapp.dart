import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:gigacharge/src/chat/rooms.dart';
import 'package:gigacharge/src/swap/swap_page.dart';
import 'settings/settings_dialog.dart';
import 'qr_code_scanner/qr_scanner.dart';
import 'leaderboard/leaderboard.dart';
import 'map/marker_map.dart';
import 'swap/swapconfirmation.dart';
import 'auth/login.dart';
import 'components/shining_progress_indicator.dart';

class GigaSwapApp extends StatelessWidget {
  const GigaSwapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          scaffoldBackgroundColor: const Color(0xFFFFFFFF),
        primaryColor: const Color(0xFFFFFFFF),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black, backgroundColor: Colors.white, // Text color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          ),
        ),
        appBarTheme: const AppBarTheme(
          color: const Color(0xff7fafff),
          elevation: 0,
          titleTextStyle: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),

      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Stream<DocumentSnapshot<Map<String, dynamic>>> _getUserStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Future.microtask(() {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      });
      return const Stream.empty();
    }
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _getUserStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('No user data available.'));
        }

        final userData = snapshot.data!.data()!;
        final displayName = userData['displayName'] ?? "Guest";
        final points = userData['points'] ?? 0;
        final imageUrl = userData['imageUrl'] ??
            'https://png.pngtree.com/png-clipart/20210129/ourmid/pngtree-default-male-avatar-png-image_2811083.jpg';
        final currentUser = FirebaseAuth.instance.currentUser!;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.leaderboard, color: Colors.black),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const LeaderboardPage()),
                );
              },
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.black),
                onPressed: () {
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
                Text(displayName, style: const TextStyle(fontSize: 20)),
                Container(
                    margin: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
                    child: Stack(alignment: Alignment.center, children: [
                      const ShiningProgressIndicator(
                        color: Colors.green,
                        progress: 0.7,
                      ),
                      SizedBox(
                        height: 100,
                        width: 100,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100.0),
                          child: Image.network(
                            imageUrl,
                          ),
                        ),
                      ),
                    ])),
                Container(
                  margin: const EdgeInsets.all(8.0),
                  child: Text(
                    '$points GigaVolts',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 52.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25.0),
                      child: const MarkerMap(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomAppBar(
            color: const Color(0xff7fafff),
            shape: const CircularNotchedRectangle(),
            notchMargin: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              mainAxisSize: MainAxisSize.max,
              children: [
                GestureDetector(
                  onTap: () {
                    print(currentUser);
                    // Handle Message button tap
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RoomsPage(user: currentUser)),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(0, 0, 150, 0),
                    // Hack to make it centered in the middl
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.message, size: 30, color: Colors.black),
                        // Message Icon
                        Text('Messages',
                            style:
                                TextStyle(fontSize: 12, color: Colors.black)),
                        // Label
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Handle QR Code Scan button tap
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BarcodeScannerWithZoom(user: currentUser)),
                    );
                  },
                  child: Container(
                    // padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.qr_code_scanner,
                            size: 30, color: Colors.black), // QR Code Icon
                        Text('Scan QR',
                            style: TextStyle(
                                fontSize: 12, color: Colors.black)), // Label
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          floatingActionButton: ElevatedButton(
            onPressed: () {
              // Handle Swap button tap
              FirebaseChatCore.instance.createRoom(types.User(
                firstName: 'John',
                id: currentUser.uid,
                imageUrl: 'https://i.pravatar.cc/300',
                lastName: 'Doe',
              ));
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SwapPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50), // Rounded corners
              ),
              elevation: 12,
              // Shadow effect for the button
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
              // Padding around the button
              minimumSize: const Size(
                  100, 100), // Size of the button (adjust to fit content)
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.swap_horiz, size: 48, color: Colors.black),
                // Swap Icon
                Text('Swap',
                    style: TextStyle(fontSize: 12, color: Colors.black)),
                // Label
              ],
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
        );
      },
    );
  }
}
