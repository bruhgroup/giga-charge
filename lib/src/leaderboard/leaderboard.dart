import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class User {
  final String displayName;
  final int points;

  User({required this.displayName, required this.points});

  factory User.fromFirestore(DocumentSnapshot doc) {
    return User(
      displayName: doc['displayName'],
      points: doc['points'],
    );
  }
}

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  _LeaderboardPageState createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  List<User> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadDataFromFirebase();
  }

  Future<void> loadDataFromFirebase() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users') // Assuming 'users' is the Firestore collection
          .orderBy('points', descending: true) // Order by points
          .get();

      setState(() {
        users = snapshot.docs
            .map((doc) => User.fromFirestore(doc))
            .toList(); // Convert Firestore documents to User objects
        isLoading = false;
      });
    } catch (e) {
      // Handle error
      print('Error fetching data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ensure itemCount is non-negative
    List<User> sortedUsers = List.from(users);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff7fafff),
        title: const Text('Leaderboard'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // Display top users on the podium dynamically based on the number of users
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (sortedUsers.isNotEmpty) _buildPodiumPosition('1st', sortedUsers[0].displayName, sortedUsers[0].points, Colors.amber[600]),
              if (sortedUsers.length > 1) _buildPodiumPosition('2nd', sortedUsers[1].displayName, sortedUsers[1].points, Colors.grey[400]),
              if (sortedUsers.length > 2) _buildPodiumPosition('3rd', sortedUsers[2].displayName, sortedUsers[2].points, Colors.brown[300]),
            ],
          ),
          const SizedBox(height: 30),
          // Show loading indicator while data is being fetched
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else
          // ListView for displaying sorted users, skipping top 3 users
            Expanded(
              child: sortedUsers.isEmpty
                  ? const Center(child: Text('No users available'))
                  : ListView.builder(
                itemCount: sortedUsers.length > 3 ? sortedUsers.length - 3 : 0, // Ensure item count is correct
                itemBuilder: (context, index) {
                  final user = sortedUsers[index + 3]; // Skip top 3 users
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueGrey,
                      child: Text('${index + 4}'),
                    ),
                    title: Text('${user.displayName}'),
                    subtitle: Text('${user.points} points'),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPodiumPosition(String position, String name, int points, Color? color) {
    return Column(
      children: [
        Text(
          position,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Container(
          height: 100,
          width: 80,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '$points points',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
