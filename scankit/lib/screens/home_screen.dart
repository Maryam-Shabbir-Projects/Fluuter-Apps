import 'package:flutter/material.dart';
import 'package:scankit/screens/create_screen.dart';
import 'package:scankit/screens/history_screen.dart';
import 'package:scankit/screens/scan_screen.dart';
import 'package:scankit/screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: IndexedStack(index: _tab, children: [
          ScanScreen(active: _tab == 0),
          const CreateScreen(),
          const HistoryScreen(),
          const SettingsScreen(),
        ]),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: (i) => setState(() => _tab = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.qr_code_scanner), label: 'Scan'),
            NavigationDestination(icon: Icon(Icons.add_box_outlined), label: 'Create'),
            NavigationDestination(icon: Icon(Icons.history), label: 'History'),
            NavigationDestination(icon: Icon(Icons.tune), label: 'Settings'),
          ],
        ),
      );
}
