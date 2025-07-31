import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'notification_service.dart';

class NotificationPanel extends StatelessWidget {
  const NotificationPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final NotificationService notificationService = Get.find<NotificationService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('알림'),
        elevation: 1,
        actions: [
          Obx(() => notificationService.unreadCount.value > 0
              ? TextButton(
                  onPressed: notificationService.markAllAsRead,
                  child: const Text('모두 읽기'),
                )
              : const SizedBox.shrink()),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'clear_all') {
                _showClearAllDialog(context, notificationService);
              } else if (value == 'check_now') {
                notificationService.checkDueDatesNow();
                Get.snackbar('알림', '마감일을 확인했습니다.');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'check_now',
                child: Row(
                  children: [
                    Icon(Icons.refresh, size: 20),
                    SizedBox(width: 8),
                    Text('지금 확인'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.clear_all, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('모두 삭제', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (notificationService.notifications.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: notificationService.notifications.length,
          itemBuilder: (context, index) {
            final notification = notificationService.notifications[index];
            return NotificationItem(
              notification: notification,
              onTap: () => _handleNotificationTap(notification, notificationService),
              onDelete: () => notificationService.deleteNotification(notification.id),
            );
          },
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '알림이 없습니다',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '마감일이 임박한 작업이나 이벤트가 있으면\n여기에 알림이 표시됩니다.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _handleNotificationTap(NotificationModel notification, NotificationService service) {
    service.markAsRead(notification.id);
    
    // 타입별 네비게이션 처리
    switch (notification.type) {
      case NotificationType.taskDue:
      case NotificationType.taskOverdue:
        // TODO: 작업 상세 화면으로 이동
        Get.snackbar('알림', '작업 화면으로 이동합니다.');
        break;
      case NotificationType.eventReminder:
        // TODO: 캘린더 화면으로 이동
        Get.snackbar('알림', '캘린더 화면으로 이동합니다.');
        break;
      case NotificationType.general:
        // 일반 알림은 특별한 처리 없음
        break;
    }
  }

  void _showClearAllDialog(BuildContext context, NotificationService service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('모든 알림 삭제'),
        content: const Text('모든 알림을 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              service.clearAllNotifications();
              Navigator.of(context).pop();
              Get.snackbar('알림', '모든 알림이 삭제되었습니다.');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}

class NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const NotificationItem({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: notification.isRead ? 0 : 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: notification.isRead ? null : Colors.blue[50],
            border: notification.isRead
                ? Border.all(color: Colors.grey[200]!)
                : Border.all(color: Colors.blue[200]!),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 아이콘
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getTypeColor().withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getTypeIcon(),
                  color: _getTypeColor(),
                  size: 20,
                ),
              ),
              
              const SizedBox(width: 12),
              
              // 내용
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 제목과 우선순위
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: notification.isRead
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                            ),
                          ),
                        ),
                        _buildPriorityChip(),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // 메시지
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        height: 1.3,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // 시간
                    Text(
                      _formatTime(notification.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              
              // 액션 버튼
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 16),
                onSelected: (value) {
                  if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 16, color: Colors.red),
                        SizedBox(width: 8),
                        Text('삭제', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityChip() {
    Color chipColor;
    String label;
    
    switch (notification.priority) {
      case NotificationPriority.low:
        chipColor = Colors.grey;
        label = '낮음';
        break;
      case NotificationPriority.medium:
        chipColor = Colors.blue;
        label = '보통';
        break;
      case NotificationPriority.high:
        chipColor = Colors.orange;
        label = '높음';
        break;
      case NotificationPriority.urgent:
        chipColor = Colors.red;
        label = '긴급';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: chipColor.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: chipColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getTypeColor() {
    switch (notification.type) {
      case NotificationType.general:
        return Colors.blue;
      case NotificationType.taskDue:
        return Colors.orange;
      case NotificationType.taskOverdue:
        return Colors.red;
      case NotificationType.eventReminder:
        return Colors.green;
    }
  }

  IconData _getTypeIcon() {
    switch (notification.type) {
      case NotificationType.general:
        return Icons.info;
      case NotificationType.taskDue:
        return Icons.schedule;
      case NotificationType.taskOverdue:
        return Icons.schedule_outlined;
      case NotificationType.eventReminder:
        return Icons.event;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return DateFormat('MM/dd HH:mm').format(dateTime);
    }
  }
}

/// 알림 배지 위젯
class NotificationBadge extends StatelessWidget {
  final Widget child;
  final bool showBadge;
  final int? count;

  const NotificationBadge({
    super.key,
    required this.child,
    this.showBadge = false,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (showBadge)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: count != null && count! > 0
                  ? Text(
                      count! > 99 ? '99+' : count.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    )
                  : null,
            ),
          ),
      ],
    );
  }
}