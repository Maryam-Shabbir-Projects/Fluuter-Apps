import 'notification_type.dart';

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final DateTime dateTime;
  bool isRead;
  final NotificationType type;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.dateTime,
    this.isRead = false,
    required this.type,
  });
}
