import 'package:actual/my_project/model/task_model.dart';
import 'package:flutter/material.dart';

/// 칸반 보드 카드 모델
class BoardCardModel {
  final String id;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final String? assigneeId;
  final String assigneeName;
  final String? assigneeAvatar;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int progressPercentage;
  final List<String> tags;
  final int commentCount;
  final int attachmentCount;
  final Color? customColor;
  
  BoardCardModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    this.assigneeId,
    required this.assigneeName,
    this.assigneeAvatar,
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    required this.progressPercentage,
    required this.tags,
    required this.commentCount,
    required this.attachmentCount,
    this.customColor,
  });
  
  /// TaskModel로부터 BoardCardModel 생성
  factory BoardCardModel.fromTask(TaskModel task) {
    return BoardCardModel(
      id: task.id,
      title: task.title,
      description: task.description,
      status: task.status,
      priority: task.priority,
      assigneeId: task.assigneeId,
      assigneeName: task.assigneeName,
      assigneeAvatar: task.assigneeAvatar,
      dueDate: task.dueDate,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
      progressPercentage: task.progressPercentage,
      tags: task.tags,
      commentCount: 0, // TODO: 댓글 기능 추가 시 구현
      attachmentCount: 0, // TODO: 첨부파일 기능 추가 시 구현
      customColor: null,
    );
  }
  
  /// 우선순위에 따른 색상 반환
  Color get priorityColor {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.urgent:
        return Colors.purple;
    }
  }
  
  /// 우선순위 텍스트
  String get priorityText {
    switch (priority) {
      case TaskPriority.low:
        return '낮음';
      case TaskPriority.medium:
        return '보통';
      case TaskPriority.high:
        return '높음';
      case TaskPriority.urgent:
        return '긴급';
    }
  }
  
  /// 상태에 따른 색상 반환
  Color get statusColor {
    switch (status) {
      case TaskStatus.todo:
        return Colors.grey;
      case TaskStatus.inProgress:
        return Colors.blue;
      case TaskStatus.inReview:
        return Colors.orange;
      case TaskStatus.completed:
        return Colors.green;
    }
  }
  
  /// 상태 텍스트
  String get statusText {
    switch (status) {
      case TaskStatus.todo:
        return '할 일';
      case TaskStatus.inProgress:
        return '진행 중';
      case TaskStatus.inReview:
        return '검토 중';
      case TaskStatus.completed:
        return '완료';
    }
  }
  
  /// 마감일까지 남은 일수
  int? get daysUntilDue {
    if (dueDate == null) return null;
    final now = DateTime.now();
    final difference = dueDate!.difference(DateTime(now.year, now.month, now.day));
    return difference.inDays;
  }
  
  /// 마감일 지남 여부
  bool get isOverdue {
    if (dueDate == null) return false;
    return DateTime.now().isAfter(dueDate!);
  }
  
  /// 오늘 마감 여부
  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    final due = dueDate!;
    return now.year == due.year && 
           now.month == due.month && 
           now.day == due.day;
  }
  
  /// 완료 여부
  bool get isCompleted => status == TaskStatus.completed;
  
  /// 진행 중 여부
  bool get isInProgress => status == TaskStatus.inProgress;
  
  /// 검토 중 여부
  bool get isInReview => status == TaskStatus.inReview;
  
  /// 할 일 여부
  bool get isTodo => status == TaskStatus.todo;
  
  /// 마감일 포맷팅
  String get formattedDueDate {
    if (dueDate == null) return '';
    
    final now = DateTime.now();
    final due = dueDate!;
    
    if (isDueToday) {
      return '오늘';
    } else if (isOverdue) {
      final days = now.difference(due).inDays;
      return '$days일 지남';
    } else {
      final days = due.difference(now).inDays;
      if (days == 1) {
        return '내일';
      } else if (days <= 7) {
        return '$days일 후';
      } else {
        return '${due.month}/${due.day}';
      }
    }
  }
  
  /// 진행률 표시용 색상
  Color get progressColor {
    if (progressPercentage >= 100) return Colors.green;
    if (progressPercentage >= 75) return Colors.blue;
    if (progressPercentage >= 50) return Colors.orange;
    if (progressPercentage >= 25) return Colors.yellow;
    return Colors.grey;
  }
  
  /// 카드에 표시할 아이콘들
  List<IconData> get displayIcons {
    final icons = <IconData>[];
    
    // 우선순위 아이콘
    if (priority == TaskPriority.urgent) {
      icons.add(Icons.priority_high);
    }
    
    // 마감일 아이콘
    if (dueDate != null) {
      if (isOverdue) {
        icons.add(Icons.schedule_outlined);
      } else if (isDueToday) {
        icons.add(Icons.today);
      }
    }
    
    // 첨부파일 아이콘
    if (attachmentCount > 0) {
      icons.add(Icons.attachment);
    }
    
    // 댓글 아이콘
    if (commentCount > 0) {
      icons.add(Icons.comment);
    }
    
    return icons;
  }
  
  /// 카드 복사
  BoardCardModel copyWith({
    String? id,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    String? assigneeId,
    String? assigneeName,
    String? assigneeAvatar,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? progressPercentage,
    List<String>? tags,
    int? commentCount,
    int? attachmentCount,
    Color? customColor,
  }) {
    return BoardCardModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      assigneeId: assigneeId ?? this.assigneeId,
      assigneeName: assigneeName ?? this.assigneeName,
      assigneeAvatar: assigneeAvatar ?? this.assigneeAvatar,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      tags: tags ?? this.tags,
      commentCount: commentCount ?? this.commentCount,
      attachmentCount: attachmentCount ?? this.attachmentCount,
      customColor: customColor ?? this.customColor,
    );
  }
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BoardCardModel &&
          runtimeType == other.runtimeType &&
          id == other.id;
  
  @override
  int get hashCode => id.hashCode;
  
  @override
  String toString() {
    return 'BoardCardModel{id: $id, title: $title, status: $status, priority: $priority}';
  }
}