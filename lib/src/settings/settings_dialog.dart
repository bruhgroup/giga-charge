import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../auth/login.dart';

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Log out'),
            onTap: () async {
              try {
                await FirebaseAuth.instance.signOut();
                // Optionally navigate the user to the login page after signing out
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              } catch (e) {
                // Handle any error during sign out, such as showing an error message
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Error'),
                    content: Text(e.toString()),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
          ListTile(
            title: const Text('Settings Option 1'),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Settings Option 2'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
