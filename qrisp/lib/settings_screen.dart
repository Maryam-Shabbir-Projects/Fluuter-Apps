import 'package:flutter/material.dart';
import 'store.dart';
import 'widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListenableBuilder(
        listenable: AppStore.I,
        builder: (context, _) {
          final s = AppStore.I;
          Widget sw(String t, String sub, bool v, String key) => SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(t, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(sub, style: const TextStyle(fontSize: 12, color: kMuted)),
                value: v,
                onChanged: (x) => s.set(key, x),
              );
          Widget link(IconData i, String t, VoidCallback f) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(i, color: kPrimary, size: 20),
                title: Text(t, style: const TextStyle(fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.chevron_right, color: kMuted),
                onTap: f,
              );
          return ListView(padding: const EdgeInsets.fromLTRB(20, 28, 20, 20), children: [
            Text('Settings', style: headStyle(36)),
            const SizedBox(height: 8),
            sw('Beep on scan', 'Play a sound when a code is read', s.beep, 'beep'),
            sw('Vibrate', 'Short vibration on scan', s.vibrate, 'vibrate'),
            sw('Save history', 'Keep scanned and created codes on this phone', s.saveHistory, 'saveHistory'),
            sw('Open links automatically', 'Off is safer: you always get to confirm', s.autoOpen, 'autoOpen'),
            const Divider(color: kLine),
            link(Icons.verified_user_outlined, 'Privacy Policy', () => openUri(context, kPrivacyUrl)),
            link(Icons.description_outlined, 'Terms of Use', () => openUri(context, kTermsUrl)),
            link(Icons.star_outline, 'Rate Qrisp', () => openUri(context, kStoreUrl)),
            link(Icons.delete_sweep_outlined, 'Clear history', () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (c) => AlertDialog(
                  title: const Text('Clear all history?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Clear')),
                  ],
                ),
              );
              if (ok == true) s.clear();
            }),
            const SizedBox(height: 16),
            const Text('Qrisp version 1.0.0', style: TextStyle(fontSize: 12, color: kMuted)),
          ]);
        },
      ),
    );
  }
}
