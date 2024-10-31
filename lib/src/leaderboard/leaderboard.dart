import 'package:flutter/material.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
      ),
      body: Column(
        children: [
          // Podium for top three users
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Second place
              Column(
                children: [
                  Text(
                    '2nd',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 100,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(child: Text('User 2')),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              // First place
              Column(
                children: [
                  Text(
                    '1st',
                    style: TextStyle(fontSize: 18, color: Colors.amber[800]),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 120,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.amber[600],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(child: Text('User 1')),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              // Third place
              Column(
                children: [
                  Text(
                    '3rd',
                    style: TextStyle(fontSize: 18, color: Colors.brown[400]),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.brown[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(child: Text('User 3')),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),
          // List of top users
          Expanded(
            child: ListView.builder(
              itemCount: 10, // Placeholder count for other users
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blueGrey,
                    child: Text('${index + 4}'), // Ranks start at 4
                  ),
                  title: Text('User ${index + 4}'),
                  subtitle: Text('${100 - (index * 5)} points'), // Sample points
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
