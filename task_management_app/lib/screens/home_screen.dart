import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/task_provider.dart';
import '../providers/notification_provider.dart';
import '../widgets/bottom_nav.dart';
import 'add_task_screen.dart';
import 'completed_screen.dart';
import 'expired_screen.dart';
import 'repeated_screen.dart';
import 'settings_screen.dart';
import '../widgets/task_card.dart';
import '../models/task.dart';
import 'notification_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _screens;
  bool _allowNotifications = true; // default to true

  @override
  void initState() {
    super.initState();
    _screens = [
      const TaskListScreen(),
      const CompletedScreen(),
      const ExpiredScreen(),
      const RepeatedScreen(),
      const SettingsScreen(),
    ];

    _loadAllowNotifications();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(context, listen: false).loadTasks(context);
    });
  }

  Future<void> _loadAllowNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _allowNotifications = prefs.getBool('allow_notifications') ?? true;
    });
  }

  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    final provider = Provider.of<TaskProvider>(context, listen: false);

    switch (index) {
      case 0:
        provider.loadTasks(context);
        break;
      case 1:
        provider.loadCompletedTasks(context);
        break;
      case 2:
        provider.loadExpiredTasks(context);
        break;
      case 3:
        provider.loadRepeatedTasks(context);
        break;
      case 4:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider = context.watch<NotificationProvider>();
    final unreadCount = notificationProvider.unreadCount;

    return Scaffold(
      appBar: AppBar(
        elevation: 3,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        leading: IconButton(
          icon: const Icon(Icons.settings),
          tooltip: 'Settings',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            ).then((_) => _loadAllowNotifications()); // Reload on return
          },
        ),
        title: const Text(
          'Task Manager',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_allowNotifications)
            IconButton(
              tooltip: 'Notifications',
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.notifications_outlined),
                  if (unreadCount > 0)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationScreen()),
                );
                notificationProvider.markAllRead();
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          // Background image relevant to task management
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1515377905703-c4788e51af15?auto=format&fit=crop&w=800&q=80',
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.2),
              colorBlendMode: BlendMode.darken,
            ),
          ),

          // Semi-transparent white overlay for readability
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.85),
            ),
          ),

          // Main content (task screens)
          Positioned.fill(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: _selectedIndex,
        onTap: _onNavTapped,
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
        tooltip: 'Add new task',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTaskScreen()),
          ).then((_) {
            Provider.of<TaskProvider>(context, listen: false).loadTasks(context);
          });
        },
        child: const Icon(Icons.add),
      )
          : null,
    );
  }
}

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  bool showAllTasks = false;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final provider = Provider.of<TaskProvider>(context, listen: false);
    if (showAllTasks) {
      await provider.loadAllTasks(context);
    } else {
      await provider.loadTasks(context);
    }
  }

  Future<void> _onTap(Task task) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddTaskScreen(task: task)),
    );
    await _loadTasks();
  }

  Future<void> _onLongPress(Task task) async {
    final provider = Provider.of<TaskProvider>(context, listen: false);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Task?'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true) {
      await provider.deleteTask(task.id!, task.title, context);
      await _loadTasks();
    }
  }

  String getFormattedDate() {
    final now = DateTime.now();
    final dayName = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
    [now.weekday - 1];
    final dateStr =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    return "$dayName, $dateStr";
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                getFormattedDate(),
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[800],
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  elevation: 3,
                ),
                onPressed: () async {
                  setState(() {
                    showAllTasks = !showAllTasks;
                  });
                  await _loadTasks();
                },
                icon: Icon(showAllTasks ? Icons.today : Icons.list_alt),
                label: Text(showAllTasks ? "Today's Tasks" : "All Tasks"),
              ),
            ],
          ),
        ),
        Expanded(
          child: provider.tasks.isEmpty
              ? Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                showAllTasks
                    ? 'No tasks found.'
                    : 'No tasks found for today.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: provider.tasks.length,
            itemBuilder: (context, index) {
              final task = provider.tasks[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: GestureDetector(
                  onTap: () => _onTap(task),
                  onLongPress: () => _onLongPress(task),
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TaskCard(task: task),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
