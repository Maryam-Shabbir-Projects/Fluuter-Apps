import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define nav items excluding Settings
    final navItems = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Tasks'),
      const BottomNavigationBarItem(icon: Icon(Icons.done_all), label: 'Completed'),
      const BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Expired'),
      const BottomNavigationBarItem(icon: Icon(Icons.repeat), label: 'Repeated'),
      // Settings is removed
    ];

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: navItems,
      type: BottomNavigationBarType.fixed,
    );
  }
}
