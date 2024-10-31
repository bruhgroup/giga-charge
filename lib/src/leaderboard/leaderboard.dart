import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gigacharge/utils/util.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  _LeaderboardPageState createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  List<User> users = [];

  @override
  void initState() {
    super.initState();
    loadJsonData();
  }

  Future<void> loadJsonData() async {
    final String response = await rootBundle.loadString('assets/fakeData.json');
    final List<dynamic> data = json.decode(response);
    setState(() {
      users = data.map((json) => User.fromJson(json)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Sort the users list by points in descending order
    List<User> sortedUsers = List.from(users)..sort((a, b) => b.points.compareTo(a.points));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // Display top three users on the podium
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Second place
              if (sortedUsers.length > 1)
                _buildPodiumPosition('2nd', sortedUsers[1].firstName, sortedUsers[1].points, Colors.grey[400]),
              // First place
              if (sortedUsers.isNotEmpty)
                _buildPodiumPosition('1st', sortedUsers[0].firstName, sortedUsers[0].points, Colors.amber[600]),
              // Third place
              if (sortedUsers.length > 2)
                _buildPodiumPosition('3rd', sortedUsers[2].firstName, sortedUsers[2].points, Colors.brown[300]),
            ],
          ),
          const SizedBox(height: 30),
          // List of remaining users
          Expanded(
            child: ListView.builder(
              itemCount: sortedUsers.length - 3,
              itemBuilder: (context, index) {
                final user = sortedUsers[index + 3];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blueGrey,
                    child: Text('${index + 4}'),
                  ),
                  title: Text('${user.firstName} ${user.lastName}'),
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