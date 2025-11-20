import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

import '../models/notification_item.dart';

class NotificationProvider extends ChangeNotifier {
  final List<NotificationItem> _notifications = [];
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<NotificationItem> get notifications => List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  static const _prefsSoundKey = 'notification_sound';

  final Map<String, String> _soundFiles = {
    "sound1.mp3": "sound1.mp3",
    "sound2.mp3": "sound2.mp3",
    "sound3.mp3": "sound3.mp3",
  };

  final Map<String, String> _soundToChannelKey = {
    "sound1.mp3": "basic_channel",
    "sound2.mp3": "chime_channel",
    "sound3.mp3": "alert_channel",
  };

  Future<String> _getSelectedSoundFile() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsSoundKey);

    if (saved != null && _soundFiles.containsKey(saved)) {
      return saved;
    }

    return "sound1.mp3"; // default
  }

  Future<void> _playNotificationSound() async {
    final soundFile = await _getSelectedSoundFile();
    final assetPath = "sounds/$soundFile";

    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(assetPath));
    } catch (e) {
      if (kDebugMode) {
        print("Error playing notification sound: $e");
      }
    }
  }

  Future<void> _showSystemNotification(NotificationItem notification) async {
    final selectedSound = await _getSelectedSoundFile();
    final channelKey = _soundToChannelKey[selectedSound] ?? "basic_channel";

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: channelKey,
        title: notification.title,
        body: notification.body,
        notificationLayout: NotificationLayout.Default,
        payload: {'id': notification.id},
      ),
    );
  }

  void addNotification(NotificationItem notification) {
    _notifications.insert(0, notification);
    _playNotificationSound();
    _showSystemNotification(notification);
    notifyListeners();
  }

  void markAsRead(String id) {
    final idx = _notifications.indexWhere((n) => n.id == id);

    if (idx != -1 && !_notifications[idx].isRead) {
      _notifications[idx].isRead = true;
      notifyListeners();
    }
  }

  void markAllRead() {
    bool changed = false;

    for (var n in _notifications) {
      if (!n.isRead) {
        n.isRead = true;
        changed = true;
      }
    }

    if (changed) notifyListeners();
  }

  void clearAll() {
    if (_notifications.isNotEmpty) {
      _notifications.clear();
      notifyListeners();
    }
  }

  void removeById(String id) {
    final before = _notifications.length;
    _notifications.removeWhere((n) => n.id == id);

    if (_notifications.length < before) {
      notifyListeners();
    }
  }

  /// NEW METHOD: Schedule reminder notification for a task
  Future<void> scheduleTaskReminder({
    required String taskId,
    required String title,
    required String body,
    required DateTime taskDueDateTime,
    Duration reminderBefore = const Duration(minutes: 10),
    bool repeatDaily = false,
  }) async {
    final reminderTime = taskDueDateTime.subtract(reminderBefore);

    // Skip if reminder time is already passed
    if (reminderTime.isBefore(DateTime.now())) return;

    final selectedSound = await _getSelectedSoundFile();
    final channelKey = _soundToChannelKey[selectedSound] ?? "basic_channel";

    final notificationId = taskId.hashCode;

    // Cancel previous notification for this task if any
    await cancelTaskReminder(taskId);

    if (repeatDaily) {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: notificationId,
          channelKey: channelKey,
          title: title,
          body: body,
          payload: {'taskId': taskId},
          notificationLayout: NotificationLayout.Default,
        ),
        schedule: NotificationCalendar(
          hour: reminderTime.hour,
          minute: reminderTime.minute,
          second: 0,
          repeats: true,
        ),
      );
    } else {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: notificationId,
          channelKey: channelKey,
          title: title,
          body: body,
          payload: {'taskId': taskId},
          notificationLayout: NotificationLayout.Default,
        ),
        schedule: NotificationCalendar.fromDate(date: reminderTime),
      );
    }
  }

  /// NEW METHOD: Cancel scheduled reminder notification for a task
  Future<void> cancelTaskReminder(String taskId) async {
    final notificationId = taskId.hashCode;
    await AwesomeNotifications().cancel(notificationId);
  }
}
