import 'package:flutter/material.dart';
import 'package:scankit/services/store.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: Store.i,
        builder: (context, _) {
          final s = Store.i;
          return Scaffold(
            appBar: AppBar(title: const Text('Settings')),
            body: ListView(children: [
              SwitchListTile(title: const Text('Beep'), subtitle: const Text('Sound on successful scan'), value: s.beep, onChanged: (v) => s.setFlag('beep', v)),
              SwitchListTile(title: const Text('Vibrate'), subtitle: const Text('Haptic feedback on scan'), value: s.vibrate, onChanged: (v) => s.setFlag('vibrate', v)),
              SwitchListTile(title: const Text('Save history'), subtitle: const Text('Keep scanned and created codes'), value: s.save, onChanged: (v) => s.setFlag('save', v)),
              const Divider(),
              ListTile(title: const Text('Privacy policy'), onTap: () => launchUrl(Uri.parse('https://example.com/privacy'))),
              const ListTile(title: Text('About'), trailing: Text('v1.0.0')),
            ]),
          );
        },
      );
}
