import 'dart:async';
import 'package:get/get.dart';
import '../logger/app_logger.dart';
import '../../my_project/model/task_model.dart';
import '../../my_project/model/event_model.dart';

class NotificationService extends GetxService {
  final AppLogger _logger = AppLogger('NotificationService');
  
  // Notification streams
  final StreamController<NotificationModel> _notificationController =
      StreamController<NotificationModel>.broadcast();
  
  // Observable variables
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxInt unreadCount = 0.obs;
  
  // Timer for checking due dates
  Timer? _dueDateCheckTimer;
  
  Stream<NotificationModel> get notificationStream => _notificationController.stream;
  
  @override
  void onInit() {
    super.onInit();
    _startDueDateMonitoring();
    _logger.info('NotificationService initialized');
  }
  
  @override
  void onClose() {
    _dueDateCheckTimer?.cancel();
    _notificationController.close();
    super.onClose();
  }
  
  /// 마감일 모니터링 시작
  void _startDueDateMonitoring() {
    // 1시간마다 마감일 체크
    _dueDateCheckTimer = Timer.periodic(const Duration(hours: 1), (timer) {
      _logger.info('Checking due dates...');
      _checkDueDates();
    });
    
    // 앱 시작 시 즉시 체크
    _checkDueDates();
  }
  
  /// 마감일 체크 및 알림 생성
  void _checkDueDates() {
    // TODO: TaskController에서 작업 목록 가져오기
    // 현재는 모의 데이터로 테스트
    _checkTaskDueDates();
    _checkEventDueDates();
  }
  
  /// 작업 마감일 체크
  void _checkTaskDueDates() {
    try {
      // TaskController에서 작업 목록 가져오기
      if (Get.isRegistered<dynamic>(tag: 'TaskController')) {
        // final taskController = Get.find<TaskController>();
        // final tasks = taskController.tasks;
        
        // for (final task in tasks) {
        //   _checkTaskDueDate(task);
        // }
      }
    } catch (e) {
      _logger.error('Error checking task due dates', e);
    }
  }
  
  /// 이벤트 마감일 체크
  void _checkEventDueDates() {
    try {
      // CalendarController에서 이벤트 목록 가져오기
      if (Get.isRegistered<dynamic>(tag: 'CalendarController')) {
        // final calendarController = Get.find<CalendarController>();
        // final events = calendarController.events;
        
        // for (final event in events) {
        //   _checkEventDueDate(event);
        // }
      }
    } catch (e) {
      _logger.error('Error checking event due dates', e);
    }
  }
  
  /// 개별 작업 마감일 체크
  void _checkTaskDueDate(TaskModel task) {
    if (task.dueDate == null || task.isCompleted) return;
    
    final now = DateTime.now();
    final dueDate = task.dueDate!;
    final hoursUntilDue = dueDate.difference(now).inHours;
    
    // 마감일이 지났을 때
    if (task.isOverdue) {
      final hoursOverdue = now.difference(dueDate).inHours;
      if (hoursOverdue == 1) { // 1시간 전에 지났을 때만 알림
        _createTaskOverdueNotification(task, hoursOverdue);
      }
    }
    // 마감일 24시간 전
    else if (hoursUntilDue <= 24 && hoursUntilDue > 23) {
      _createTaskDueSoonNotification(task, '1일');
    }
    // 마감일 1시간 전
    else if (hoursUntilDue <= 1 && hoursUntilDue > 0) {
      _createTaskDueSoonNotification(task, '1시간');
    }
  }
  
  /// 개별 이벤트 마감일 체크
  void _checkEventDueDate(EventModel event) {
    final now = DateTime.now();
    final startTime = event.startTime;
    final minutesUntilStart = startTime.difference(now).inMinutes;
    
    // 이벤트 시작 30분 전 알림
    if (minutesUntilStart <= 30 && minutesUntilStart > 25) {
      _createEventReminder(event, '30분');
    }
    // 이벤트 시작 5분 전 알림
    else if (minutesUntilStart <= 5 && minutesUntilStart > 0) {
      _createEventReminder(event, '5분');
    }
  }
  
  /// 작업 마감일 임박 알림 생성
  void _createTaskDueSoonNotification(TaskModel task, String timeLeft) {
    final notification = NotificationModel(
      id: 'task_due_${task.id}_$timeLeft',
      type: NotificationType.taskDue,
      title: '작업 마감일 임박',
      message: '${task.title} 작업이 $timeLeft 후 마감됩니다.',
      data: {'taskId': task.id, 'timeLeft': timeLeft},
      priority: NotificationPriority.high,
      createdAt: DateTime.now(),
    );
    
    _addNotification(notification);
  }
  
  /// 작업 마감일 초과 알림 생성
  void _createTaskOverdueNotification(TaskModel task, int hoursOverdue) {
    final notification = NotificationModel(
      id: 'task_overdue_${task.id}',
      type: NotificationType.taskOverdue,
      title: '작업 마감일 초과',
      message: '${task.title} 작업이 ${hoursOverdue}시간 전에 마감되었습니다.',
      data: {'taskId': task.id, 'hoursOverdue': hoursOverdue},
      priority: NotificationPriority.urgent,
      createdAt: DateTime.now(),
    );
    
    _addNotification(notification);
  }
  
  /// 이벤트 리마인더 알림 생성
  void _createEventReminder(EventModel event, String timeLeft) {
    final notification = NotificationModel(
      id: 'event_reminder_${event.id}_$timeLeft',
      type: NotificationType.eventReminder,
      title: '이벤트 시작 예정',
      message: '${event.title} 이벤트가 $timeLeft 후 시작됩니다.',
      data: {'eventId': event.id, 'timeLeft': timeLeft},
      priority: NotificationPriority.medium,
      createdAt: DateTime.now(),
    );
    
    _addNotification(notification);
  }
  
  /// 알림 추가
  void _addNotification(NotificationModel notification) {
    // 중복 알림 방지
    if (notifications.any((n) => n.id == notification.id)) {
      return;
    }
    
    notifications.insert(0, notification);
    unreadCount.value++;
    
    // 스트림에 알림 전송
    _notificationController.add(notification);
    
    // 시스템 알림 표시
    _showSystemNotification(notification);
    
    _logger.info('Notification added: ${notification.title}');
  }
  
  /// 시스템 알림 표시 (플랫폼별 구현)
  void _showSystemNotification(NotificationModel notification) {
    // TODO: 플랫폼별 시스템 알림 구현
    // - Android: Local Notifications
    // - iOS: Push Notifications
    // - Web: Browser Notifications
    
    // 현재는 Get.snackbar로 임시 구현
    Get.snackbar(
      notification.title,
      notification.message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: _getPriorityColor(notification.priority),
      colorText: _getPriorityTextColor(notification.priority),
      duration: const Duration(seconds: 5),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      onTap: (_) => _handleNotificationTap(notification),
    );
  }
  
  /// 알림 우선순위별 색상
  Color _getPriorityColor(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return Colors.grey[100]!;
      case NotificationPriority.medium:
        return Colors.blue[100]!;
      case NotificationPriority.high:
        return Colors.orange[100]!;
      case NotificationPriority.urgent:
        return Colors.red[100]!;
    }
  }
  
  /// 알림 우선순위별 텍스트 색상
  Color _getPriorityTextColor(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return Colors.grey[800]!;
      case NotificationPriority.medium:
        return Colors.blue[800]!;
      case NotificationPriority.high:
        return Colors.orange[800]!;
      case NotificationPriority.urgent:
        return Colors.red[800]!;
    }
  }
  
  /// 알림 탭 처리
  void _handleNotificationTap(NotificationModel notification) {
    // 알림 읽음 처리
    markAsRead(notification.id);
    
    // 타입별 네비게이션
    switch (notification.type) {
      case NotificationType.taskDue:
      case NotificationType.taskOverdue:
        final taskId = notification.data['taskId'];
        if (taskId != null) {
          // TODO: 작업 상세 화면으로 이동
          _logger.info('Navigate to task: $taskId');
        }
        break;
        
      case NotificationType.eventReminder:
        final eventId = notification.data['eventId'];
        if (eventId != null) {
          // TODO: 캘린더 화면으로 이동
          _logger.info('Navigate to calendar for event: $eventId');
        }
        break;
        
      case NotificationType.general:
        // 일반 알림은 특별한 처리 없음
        break;
    }
  }
  
  /// 알림 읽음 처리
  void markAsRead(String notificationId) {
    final index = notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1 && !notifications[index].isRead) {
      notifications[index] = notifications[index].copyWith(isRead: true);
      unreadCount.value = notifications.where((n) => !n.isRead).length;
      _logger.info('Notification marked as read: $notificationId');
    }
  }
  
  /// 모든 알림 읽음 처리
  void markAllAsRead() {
    for (int i = 0; i < notifications.length; i++) {
      if (!notifications[i].isRead) {
        notifications[i] = notifications[i].copyWith(isRead: true);
      }
    }
    unreadCount.value = 0;
    _logger.info('All notifications marked as read');
  }
  
  /// 알림 삭제
  void deleteNotification(String notificationId) {
    final index = notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      final wasUnread = !notifications[index].isRead;
      notifications.removeAt(index);
      if (wasUnread) {
        unreadCount.value--;
      }
      _logger.info('Notification deleted: $notificationId');
    }
  }
  
  /// 모든 알림 삭제
  void clearAllNotifications() {
    notifications.clear();
    unreadCount.value = 0;
    _logger.info('All notifications cleared');
  }
  
  /// 수동으로 마감일 체크 실행
  void checkDueDatesNow() {
    _logger.info('Manual due date check triggered');
    _checkDueDates();
  }
  
  /// 커스텀 알림 생성
  void createCustomNotification({
    required String title,
    required String message,
    NotificationType type = NotificationType.general,
    NotificationPriority priority = NotificationPriority.medium,
    Map<String, dynamic>? data,
  }) {
    final notification = NotificationModel(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      title: title,
      message: message,
      data: data ?? {},
      priority: priority,
      createdAt: DateTime.now(),
    );
    
    _addNotification(notification);
  }
}

/// 알림 모델
class NotificationModel {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final Map<String, dynamic> data;
  final NotificationPriority priority;
  final DateTime createdAt;
  final bool isRead;
  
  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.data,
    required this.priority,
    required this.createdAt,
    this.isRead = false,
  });
  
  NotificationModel copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? message,
    Map<String, dynamic>? data,
    NotificationPriority? priority,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      data: data ?? this.data,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationModel &&
          runtimeType == other.runtimeType &&
          id == other.id;
  
  @override
  int get hashCode => id.hashCode;
}

/// 알림 타입
enum NotificationType {
  general,
  taskDue,
  taskOverdue,
  eventReminder,
}

/// 알림 우선순위
enum NotificationPriority {
  low,
  medium,
  high,
  urgent,
}