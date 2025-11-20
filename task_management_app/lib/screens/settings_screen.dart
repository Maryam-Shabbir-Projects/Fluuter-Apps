import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

import '../providers/task_provider.dart';
import 'export_select_screen.dart';

class SettingsScreen extends StatefulWidget {
  static const String routeName = '/settings';

  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final List<String> _notificationSounds = [
    'sound1.mp3',
    'sound2.mp3',
    'sound3.mp3',
  ];

  String? _selectedSound;
  bool _allowNotifications = true;

  static const _prefsSoundKey = 'notification_sound';
  static const _prefsAllowNotificationKey = 'allow_notifications';

  final AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _loadSelectedSound();
    _loadAllowNotifications();
  }

  Future<void> _loadSelectedSound() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedSound = prefs.getString(_prefsSoundKey) ?? _notificationSounds[0];
    });
  }

  Future<void> _saveSelectedSound(String sound) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsSoundKey, sound);
  }

  Future<void> _playSoundPreview(String fileName) async {
    try {
      await _player.stop();
      await _player.play(AssetSource("sounds/$fileName"));
    } catch (e) {
      print("Sound play error: $e");
    }
  }

  Future<void> _loadAllowNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _allowNotifications = prefs.getBool(_prefsAllowNotificationKey) ?? true;
    });
  }

  Future<void> _saveAllowNotifications(bool allow) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsAllowNotificationKey, allow);
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help'),
        content: const Text(
          'This app helps you manage your tasks efficiently.\n\n'
              '- Add tasks with deadlines.\n'
              '- Mark tasks as completed.\n'
              '- View expired tasks separately.\n'
              '- Customize notification settings.\n\n'
              'For further assistance, contact support@example.com',
        ),
        actions: [
          TextButton(
            child: const Text('Close'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Task Manager',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2025 Your Company Name',
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.blueGrey,
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        elevation: 0,
        title: const Text("Settings"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1515377905703-c4788e51af15?auto=format&fit=crop&w=800&q=80',
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.2),
              colorBlendMode: BlendMode.darken,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.85),
            ),
          ),
          ListView(
            children: [
              _buildSectionTitle('Appearance'),
              _buildCard(
                child: SwitchListTile(
                  title: const Text('Dark Mode'),
                  value: provider.isDarkMode,
                  onChanged: (_) => provider.toggleDarkMode(),
                  secondary: const Icon(Icons.dark_mode),
                ),
              ),

              _buildSectionTitle('Notifications'),
              _buildCard(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Allow Notifications'),
                      value: _allowNotifications,
                      onChanged: (value) {
                        setState(() => _allowNotifications = value);
                        _saveAllowNotifications(value);
                      },
                      secondary: const Icon(Icons.notifications_active),
                    ),

                    ListTile(
                      leading: const Icon(Icons.music_note),
                      title: const Text('Notification Sound'),
                      subtitle: _selectedSound == null
                          ? const Text('Loading...')
                          : Text(_selectedSound!),
                      trailing: DropdownButton<String>(
                        value: _selectedSound,
                        items: _notificationSounds
                            .map((sound) => DropdownMenuItem(
                          value: sound,
                          child: Text(sound),
                        ))
                            .toList(),
                        onChanged: (value) async {
                          if (value != null) {
                            setState(() => _selectedSound = value);
                            await _saveSelectedSound(value);
                            await _playSoundPreview(value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),

              _buildSectionTitle('Tasks'),
              _buildCard(
                child: ListTile(
                  title: const Text('Export Tasks as PDF'),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ExportSelectScreen()),
                      );
                    },
                    child: const Text('Export'),
                  ),
                  leading: const Icon(Icons.picture_as_pdf),
                ),
              ),

              _buildSectionTitle('Support'),
              _buildCard(
                child: Column(
                  children: [
                    ListTile(
                      leading:
                      const Icon(Icons.help_outline, color: Colors.teal),
                      title: const Text('Help'),
                      onTap: _showHelpDialog,
                    ),
                    const Divider(indent: 20, endIndent: 20),
                    ListTile(
                      leading:
                      const Icon(Icons.info_outline, color: Colors.teal),
                      title: const Text('About'),
                      onTap: _showAboutDialog,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ],
      ),
    );
  }
}
