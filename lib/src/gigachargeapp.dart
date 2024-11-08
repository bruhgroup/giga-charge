import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:gigacharge/src/chat/rooms.dart';
import 'settings/settings_dialog.dart';
import 'qr_code_scanner/qr_scanner.dart';
import 'leaderboard/leaderboard.dart';
import 'map/marker_map.dart';
import 'auth/login.dart';

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
    return FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots();
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
        final imageUrl = userData['imageUrl'] ?? 'https://png.pngtree.com/png-clipart/20210129/ourmid/pngtree-default-male-avatar-png-image_2811083.jpg';
        final currentUser = FirebaseAuth.instance.currentUser!;

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
                Text(displayName),
                Container(
                  margin: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const CircularProgressIndicator(
                        value: 0.7,
                        strokeWidth: 10,
                        color: Colors.green,
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
                  ),]
                  )
                ),
                Container(
                  margin: const EdgeInsets.all(8.0),
                  child: Text(
                    '$points GigaVolts',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: const MarkerMap(),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      FirebaseChatCore.instance.createRoom(types.User(
                        firstName: 'John',
                        id: currentUser.uid,
                        imageUrl: 'https://i.pravatar.cc/300',
                        lastName: 'Doe',
                      ));
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
          bottomNavigationBar: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(Icons.message),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RoomsPage(user: currentUser)),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const BarcodeScannerWithZoom()),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
