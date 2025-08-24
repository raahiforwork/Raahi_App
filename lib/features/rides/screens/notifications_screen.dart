import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/repositories/ride/ride_repository.dart';
import '../../../features/personalization/controllers/auth_controller.dart';
import '../screens/chat_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rideRepository = RideRepository.instance;
    final currentUserId =
        Get.find<AuthController>().currentUser.value?.uid.value ?? '';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () => _markAllAsRead(currentUserId),
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: rideRepository.getUserNotifications(currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    color: Colors.white70,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No notifications',
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _buildNotificationCard(notification);
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final isRead = notification['isRead'] ?? false;
    final type = notification['type'] ?? '';
    final title = notification['title'] ?? '';
    final body = notification['body'] ?? '';
    final createdAt = notification['createdAt'] as Timestamp?;
    final notificationId = notification['id'] ?? '';

    IconData iconData;
    Color iconColor;

    switch (type) {
      case 'ride_request':
        iconData = Icons.directions_car;
        iconColor = Colors.blue;
        break;
      case 'ride_accepted':
        iconData = Icons.check_circle;
        iconColor = Colors.green;
        break;
      case 'ride_rejected':
        iconData = Icons.cancel;
        iconColor = Colors.red;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = Colors.orange;
    }

    return GestureDetector(
      onTap: () => _handleNotificationTap(notification),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRead ? const Color(0xFF2A2A2A) : const Color(0xFF3A3A3A),
          borderRadius: BorderRadius.circular(12),
          border: isRead ? null : Border.all(color: Colors.blue, width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(iconData, color: iconColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: isRead ? FontWeight.normal : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    body,
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (createdAt != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _formatTime(createdAt.toDate()),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (!isRead)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _handleNotificationTap(Map<String, dynamic> notification) async {
    final notificationId = notification['id'] ?? '';
    final type = notification['type'] ?? '';

    // Mark as read
    if (notificationId.isNotEmpty) {
      try {
        await RideRepository.instance.markNotificationAsRead(notificationId);
      } catch (e) {
        print('Error marking notification as read: $e');
      }
    }

    // Handle different notification types
    switch (type) {
      case 'ride_accepted':
        // Navigate to chat screen
        final rideId = notification['rideId'];
        final driverName =
            notification['body']?.toString().split(' accepted')[0] ?? 'Driver';
        if (rideId != null) {
          Get.to(
            () => ChatScreen(
              otherUserId: notification['driverId'] ?? '',
              otherUserName: driverName,
              rideInfo: {
                'rideId': rideId,
                'requestId': notification['requestId'],
              },
            ),
          );
        }
        break;
      case 'ride_rejected':
        // Show rejection reason
        final reason = notification['reason'] ?? 'No reason provided';
        Get.snackbar(
          'Request Rejected',
          'Your ride request was rejected: $reason',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        break;
      default:
        // Handle other notification types
        break;
    }
  }

  void _markAllAsRead(String userId) async {
    try {
      final notifications =
          await FirebaseFirestore.instance
              .collection('notifications')
              .where('userId', isEqualTo: userId)
              .where('isRead', isEqualTo: false)
              .get();

      final batch = FirebaseFirestore.instance.batch();
      for (final doc in notifications.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();

      Get.snackbar(
        'Success',
        'All notifications marked as read',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to mark notifications as read: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
