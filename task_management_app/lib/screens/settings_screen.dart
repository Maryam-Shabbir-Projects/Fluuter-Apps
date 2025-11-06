import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    String selectedSound = 'Default';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              'Appearance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: themeProvider.isDarkMode,
              onChanged: (value) => themeProvider.toggleTheme(),
            ),
            const SizedBox(height: 20),
            const Text(
              'Notifications',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListTile(
              title: const Text('Select Notification Sound'),
              subtitle: Text(selectedSound),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                await showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Choose Sound',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ListTile(
                            title: const Text('Default'),
                            onTap: () {
                              selectedSound = 'Default';
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            title: const Text('Soft Chime'),
                            onTap: () {
                              selectedSound = 'Soft Chime';
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            title: const Text('Beep Tone'),
                            onTap: () {
                              selectedSound = 'Beep Tone';
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings saved successfully!')),
                );
              },
              icon: const Icon(Icons.save),
              label: const Text('Save Settings'),
            ),
          ],
        ),
      ),
    );
  }
}
