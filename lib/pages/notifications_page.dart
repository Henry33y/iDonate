import 'package:flutter/material.dart';
import '../widgets/hover_button.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final List<NotificationItem> _notifications = [
    NotificationItem(
      title: 'Urgent: Blood Needed',
      message: 'Type A+ blood urgently needed at City Hospital',
      time: DateTime.now().subtract(const Duration(minutes: 30)),
      type: NotificationType.urgent,
      isRead: false,
    ),
    NotificationItem(
      title: 'Donation Reminder',
      message: 'You are eligible to donate blood again in 3 days',
      time: DateTime.now().subtract(const Duration(hours: 2)),
      type: NotificationType.reminder,
      isRead: false,
    ),
    NotificationItem(
      title: 'Thank You!',
      message: 'Your recent blood donation helped save 3 lives',
      time: DateTime.now().subtract(const Duration(days: 1)),
      type: NotificationType.success,
      isRead: true,
    ),
    NotificationItem(
      title: 'Appointment Confirmed',
      message: 'Your donation appointment is confirmed for tomorrow at 10:00 AM',
      time: DateTime.now().subtract(const Duration(days: 2)),
      type: NotificationType.appointment,
      isRead: true,
    ),
    NotificationItem(
      title: 'Blood Drive Event',
      message: 'Join us for a community blood drive this weekend',
      time: DateTime.now().subtract(const Duration(days: 3)),
      type: NotificationType.event,
      isRead: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFCC2B2B),
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          HoverButton(
            onPressed: () {
              setState(() {
                for (var notification in _notifications) {
                  notification.isRead = true;
                }
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All notifications marked as read'),
                  backgroundColor: Color(0xFFCC2B2B),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const Text(
              'Mark all as read',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return _buildNotificationCard(notification, index);
              },
            ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notification, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Dismissible(
        key: Key(notification.title),
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 16),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) {
          setState(() {
            _notifications.removeAt(index);
          });
        },
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: notification.isRead ? 1 : 3,
          child: InkWell(
            onTap: () {
              setState(() {
                notification.isRead = true;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: notification.isRead ? Colors.white : const Color(0xFFFFF3F3),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNotificationIcon(notification.type),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              notification.title,
                              style: TextStyle(
                                fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            if (!notification.isRead)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFCC2B2B),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification.message,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatTime(notification.time),
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(NotificationType type) {
    IconData icon;
    Color color;

    switch (type) {
      case NotificationType.urgent:
        icon = Icons.priority_high;
        color = Colors.red;
        break;
      case NotificationType.reminder:
        icon = Icons.access_time;
        color = Colors.orange;
        break;
      case NotificationType.success:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case NotificationType.appointment:
        icon = Icons.calendar_today;
        color = Colors.blue;
        break;
      case NotificationType.event:
        icon = Icons.event;
        color = Colors.purple;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }
}

enum NotificationType {
  urgent,
  reminder,
  success,
  appointment,
  event,
}

class NotificationItem {
  final String title;
  final String message;
  final DateTime time;
  final NotificationType type;
  bool isRead;

  NotificationItem({
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    required this.isRead,
  });
} 