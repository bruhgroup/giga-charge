import 'package:flutter/material.dart';

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
            title: const Text('Edit Profile'),
            onTap: () {
              // Action for editing profile
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
