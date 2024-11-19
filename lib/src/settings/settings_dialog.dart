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
              final shouldLogout = await _showLogoutConfirmationDialog(context);
              if (shouldLogout == true) {
                try {
                  await FirebaseAuth.instance.signOut();
                  // Navigate to the login page and clear the navigation stack
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                        (route) => false, // Remove all previous routes
                  );
                } catch (e) {
                  // Show error dialog if logout fails
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
              }
            },
          ),
          ListTile(
            title: const Text('Settings Option 1'),
            onTap: () {
              // Implement other settings options
            },
          ),
          ListTile(
            title: const Text('Settings Option 2'),
            onTap: () {
              // Implement other settings options
            },
          ),
        ],
      ),
    );
  }

  /// Displays a confirmation dialog before logging out
  Future<bool?> _showLogoutConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Cancel
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // Confirm
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}
