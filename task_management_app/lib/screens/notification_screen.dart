import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import '../models/notification_item.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifProvider = context.watch<NotificationProvider>();
    final notifications = notifProvider.notifications;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        elevation: 0,
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: Colors.black),
            tooltip: 'Mark all read',
            onPressed: () {
              notifProvider.markAllRead();
            },
          ),
          IconButton(
            icon: const Icon(Icons.clear_all, color: Colors.black),
            tooltip: 'Clear All Notifications',
            onPressed: () {
              notifProvider.clearAll();
            },
          ),
        ],
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
          Positioned.fill(
            child: notifications.isEmpty
                ? const Center(
              child: Text(
                'No notifications',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
                : Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.separated(
                itemCount: notifications.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final NotificationItem notif = notifications[index];
                  final bool isUnread = !notif.isRead;

                  return Card(
                    elevation: isUnread ? 4 : 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: isUnread ? Colors.blue.shade50 : Colors.white,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      leading: Stack(
                        children: [
                          Icon(
                            Icons.notifications,
                            size: 32,
                            color:
                            isUnread ? Colors.blue : Colors.grey.shade400,
                          ),
                          if (isUnread)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                      title: Text(
                        notif.title,
                        style: TextStyle(
                          fontWeight:
                          isUnread ? FontWeight.bold : FontWeight.normal,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          notif.body,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      trailing: Text(
                        _formatDateTime(notif.dateTime),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      onTap: () {
                        if (isUnread) {
                          notifProvider.markAsRead(notif.id);
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';

    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
}
