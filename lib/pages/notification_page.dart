import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final List<NotificationItem> _notifications = [
    NotificationItem(
      title: "Đơn mới",
      message: "Bạn có một yêu cầu dịch vụ dọn dẹp nhà mới từ Nguyễn Văn A",
      time: DateTime.now().subtract(const Duration(minutes: 15)),
      type: NotificationType.newRequest,
      isRead: false,
    ),
    NotificationItem(
      title: "Thanh toán thành công",
      message:
          "Bạn đã nhận được thanh toán 300.000đ cho dịch vụ dọn dẹp nhà từ Trần Thị B",
      time: DateTime.now().subtract(const Duration(hours: 2)),
      type: NotificationType.payment,
      isRead: false,
    ),
    NotificationItem(
      title: "Đánh giá mới",
      message: "Lê Văn C đã đánh giá 5 sao cho dịch vụ sửa điện của bạn",
      time: DateTime.now().subtract(const Duration(days: 1)),
      type: NotificationType.rating,
      isRead: true,
    ),
    NotificationItem(
      title: "Cập nhật hệ thống",
      message:
          "Ứng dụng đã được cập nhật lên phiên bản mới với nhiều tính năng hấp dẫn",
      time: DateTime.now().subtract(const Duration(days: 3)),
      type: NotificationType.system,
      isRead: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Thông báo",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Quicksand',
                  ),
                ),
                if (unreadCount > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "$unreadCount chưa đọc",
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontFamily: 'Quicksand',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Mark all as read button
          if (unreadCount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        for (var notification in _notifications) {
                          notification.isRead = true;
                        }
                      });
                    },
                    icon: Icon(
                      Icons.check_circle_outline,
                      size: 16,
                      color: Colors.green,
                    ),
                    label: Text(
                      "Đánh dấu tất cả đã đọc",
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 14,
                        fontFamily: 'Quicksand',
                      ),
                    ),
                  ),
                ],
              ),
            ),

          Divider(height: 1, color: Colors.grey[200]),

          // Notifications list
          Expanded(
            child: _notifications.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    itemCount: _notifications.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      color: Colors.grey[200],
                    ),
                    itemBuilder: (context, index) {
                      return _buildNotificationItem(_notifications[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            "Bạn chưa có thông báo nào",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontFamily: 'Quicksand',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(NotificationItem notification) {
    IconData iconData;
    Color iconColor;

    switch (notification.type) {
      case NotificationType.newRequest:
        iconData = Icons.assignment_add;
        iconColor = Colors.green;
        break;
      case NotificationType.payment:
        iconData = Icons.payment;
        iconColor = Colors.green;
        break;
      case NotificationType.rating:
        iconData = Icons.star;
        iconColor = Colors.amber;
        break;
      case NotificationType.system:
        iconData = Icons.system_update;
        iconColor = Colors.purple;
        break;
    }

    return InkWell(
      onTap: () {
        setState(() {
          notification.isRead = true;
        });
      },
      child: Container(
        color: notification.isRead
            ? Colors.transparent
            : Colors.green.withOpacity(0.05),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                iconData,
                color: iconColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
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
                          fontSize: 16,
                          fontFamily: 'Quicksand',
                          fontWeight: notification.isRead
                              ? FontWeight.normal
                              : FontWeight.bold,
                        ),
                      ),
                      Text(
                        _formatTime(notification.time),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontFamily: 'Quicksand',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontFamily: 'Quicksand',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return "${difference.inDays} ngày trước";
    } else if (difference.inHours > 0) {
      return "${difference.inHours} giờ trước";
    } else if (difference.inMinutes > 0) {
      return "${difference.inMinutes} phút trước";
    } else {
      return "Vừa xong";
    }
  }
}

enum NotificationType {
  newRequest,
  payment,
  rating,
  system,
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
