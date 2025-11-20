import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:workmanager/workmanager.dart';

import 'app.dart';
import 'providers/task_provider.dart';
import 'providers/notification_provider.dart';
import 'db/database_helper.dart';

// Unique name for the background task
const String expiredTaskCheckTask = "checkExpiredTasks";

void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName == expiredTaskCheckTask) {
      // Initialize Awesome Notifications for background isolate
      await AwesomeNotifications().initialize(
        null,
        [
          NotificationChannel(
            channelKey: 'basic_channel',
            channelName: 'Basic Notifications',
            channelDescription: 'Notification channel for basic notifications',
            defaultColor: const Color(0xFF2196F3), // Use explicit color
            importance: NotificationImportance.High,
            ledColor: Colors.white,
            playSound: true,
          ),
          // Add other channels if needed
        ],
      );

      final db = DatabaseHelper.instance;

      // Mark expired tasks
      await db.markExpiredTasks();

      // Get expired tasks
      final expiredTasks = await db.getExpiredTasks();

      // Send notification for each expired task
      for (final task in expiredTasks) {
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: task.id.hashCode,
            channelKey: 'basic_channel',
            title: 'Task Expired',
            body: 'The task "${task.title}" has expired.',
            notificationLayout: NotificationLayout.Default,
            payload: {'taskId': task.id.toString()},
          ),
        );
      }

      return Future.value(true);
    }
    return Future.value(false);
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Awesome Notifications with your channels
  await AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic Notifications',
        channelDescription: 'Notification channel for basic notifications',
        defaultColor: const Color(0xFF2196F3),
        importance: NotificationImportance.High,
        ledColor: Colors.white,
        soundSource: 'resource://raw/sound1',
        playSound: true,
      ),
      NotificationChannel(
        channelKey: 'chime_channel',
        channelName: 'Chime Notifications',
        channelDescription: 'Notification channel with chime sound',
        defaultColor: const Color(0xFF4CAF50),
        importance: NotificationImportance.High,
        ledColor: Colors.white,
        soundSource: 'resource://raw/sound2',
        playSound: true,
      ),
      NotificationChannel(
        channelKey: 'alert_channel',
        channelName: 'Alert Notifications',
        channelDescription: 'Notification channel with alert sound',
        defaultColor: const Color(0xFFF44336),
        importance: NotificationImportance.High,
        ledColor: Colors.white,
        soundSource: 'resource://raw/sound3',
        playSound: true,
      ),
    ],
  );

  bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowed) {
    await AwesomeNotifications().requestPermissionToSendNotifications();
  }

  // Initialize Workmanager with callbackDispatcher
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);

  // Register periodic task (minimum 15 mins on Android)
  await Workmanager().registerPeriodicTask(
    "checkExpiredTasksId", // unique id for the task
    expiredTaskCheckTask,
    frequency: const Duration(minutes: 15),
    initialDelay: const Duration(seconds: 10),
    constraints: Constraints(
      networkType: NetworkType.not_required,
      requiresCharging: false,
      requiresDeviceIdle: false,
      requiresBatteryNotLow: false,
      requiresStorageNotLow: false,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: const MyApp(),
    ),
  );
}
