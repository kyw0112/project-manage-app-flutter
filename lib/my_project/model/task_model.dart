import 'package:actual/user/model/user_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'task_model.g.dart';

@JsonSerializable()
class TaskModel {
  final String id;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final String projectId;
  final String? boardId;
  final String? assigneeId;
  final UserModel? assignee;
  final String createdById;
  final UserModel? createdBy;
  final List<String> labels;
  final List<String> attachments;
  final DateTime? startDate;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  final int estimatedHours;
  final int actualHours;
  final int progressPercentage;
  final List<TaskComment> comments;
  final List<TaskHistory> history;

  const TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.projectId,
    this.boardId,
    this.assigneeId,
    this.assignee,
    required this.createdById,
    this.createdBy,
    required this.labels,
    required this.attachments,
    this.startDate,
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
    required this.estimatedHours,
    required this.actualHours,
    required this.progressPercentage,
    required this.comments,
    required this.history,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) =>
      _$TaskModelFromJson(json);

  Map<String, dynamic> toJson() => _$TaskModelToJson(this);

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    String? projectId,
    String? boardId,
    String? assigneeId,
    UserModel? assignee,
    String? createdById,
    UserModel? createdBy,
    List<String>? labels,
    List<String>? attachments,
    DateTime? startDate,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    int? estimatedHours,
    int? actualHours,
    int? progressPercentage,
    List<TaskComment>? comments,
    List<TaskHistory>? history,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      projectId: projectId ?? this.projectId,
      boardId: boardId ?? this.boardId,
      assigneeId: assigneeId ?? this.assigneeId,
      assignee: assignee ?? this.assignee,
      createdById: createdById ?? this.createdById,
      createdBy: createdBy ?? this.createdBy,
      labels: labels ?? this.labels,
      attachments: attachments ?? this.attachments,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      actualHours: actualHours ?? this.actualHours,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      comments: comments ?? this.comments,
      history: history ?? this.history,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaskModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'TaskModel{id: $id, title: $title, status: $status, priority: $priority}';
  }

  /// 작업이 완료되었는지 확인
  bool get isCompleted => status == TaskStatus.done;

  /// 작업이 진행 중인지 확인
  bool get isInProgress => status == TaskStatus.inProgress;

  /// 작업이 지연되었는지 확인
  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  /// 마감일까지 남은 일수
  int? get daysUntilDue {
    if (dueDate == null) return null;
    final now = DateTime.now();
    final difference = dueDate!.difference(now).inDays;
    return difference;
  }

  /// 할당자 이름 반환
  String get assigneeName => assignee?.name ?? '미할당';

  /// 우선순위 색상
  String get priorityColor {
    switch (priority) {
      case TaskPriority.veryHigh:
        return '#FF0000';
      case TaskPriority.high:
        return '#FF6600';
      case TaskPriority.medium:
        return '#FFCC00';
      case TaskPriority.low:
        return '#00CC00';
      case TaskPriority.veryLow:
        return '#0066CC';
    }
  }

  /// 상태 색상
  String get statusColor {
    switch (status) {
      case TaskStatus.todo:
        return '#9E9E9E';
      case TaskStatus.inProgress:
        return '#2196F3';
      case TaskStatus.review:
        return '#FF9800';
      case TaskStatus.done:
        return '#4CAF50';
      case TaskStatus.blocked:
        return '#F44336';
    }
  }
}

/// 작업 상태
@JsonEnum()
enum TaskStatus {
  @JsonValue('todo')
  todo,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('review')
  review,
  @JsonValue('done')
  done,
  @JsonValue('blocked')
  blocked;

  String get displayName {
    switch (this) {
      case TaskStatus.todo:
        return '할 일';
      case TaskStatus.inProgress:
        return '진행 중';
      case TaskStatus.review:
        return '검토';
      case TaskStatus.done:
        return '완료';
      case TaskStatus.blocked:
        return '차단됨';
    }
  }
}

/// 작업 우선순위
@JsonEnum()
enum TaskPriority {
  @JsonValue('very_low')
  veryLow,
  @JsonValue('low')
  low,
  @JsonValue('medium')
  medium,
  @JsonValue('high')
  high,
  @JsonValue('very_high')
  veryHigh;

  String get displayName {
    switch (this) {
      case TaskPriority.veryLow:
        return '매우 낮음';
      case TaskPriority.low:
        return '낮음';
      case TaskPriority.medium:
        return '보통';
      case TaskPriority.high:
        return '높음';
      case TaskPriority.veryHigh:
        return '매우 높음';
    }
  }

  int get value {
    switch (this) {
      case TaskPriority.veryLow:
        return 1;
      case TaskPriority.low:
        return 2;
      case TaskPriority.medium:
        return 3;
      case TaskPriority.high:
        return 4;
      case TaskPriority.veryHigh:
        return 5;
    }
  }
}

/// 작업 댓글
@JsonSerializable()
class TaskComment {
  final String id;
  final String taskId;
  final String authorId;
  final UserModel? author;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TaskComment({
    required this.id,
    required this.taskId,
    required this.authorId,
    this.author,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TaskComment.fromJson(Map<String, dynamic> json) =>
      _$TaskCommentFromJson(json);

  Map<String, dynamic> toJson() => _$TaskCommentToJson(this);
}

/// 작업 히스토리
@JsonSerializable()
class TaskHistory {
  final String id;
  final String taskId;
  final String userId;
  final UserModel? user;
  final TaskHistoryType type;
  final String description;
  final Map<String, dynamic>? oldValue;
  final Map<String, dynamic>? newValue;
  final DateTime createdAt;

  const TaskHistory({
    required this.id,
    required this.taskId,
    required this.userId,
    this.user,
    required this.type,
    required this.description,
    this.oldValue,
    this.newValue,
    required this.createdAt,
  });

  factory TaskHistory.fromJson(Map<String, dynamic> json) =>
      _$TaskHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$TaskHistoryToJson(this);
}

/// 작업 히스토리 타입
@JsonEnum()
enum TaskHistoryType {
  @JsonValue('created')
  created,
  @JsonValue('updated')
  updated,
  @JsonValue('status_changed')
  statusChanged,
  @JsonValue('assigned')
  assigned,
  @JsonValue('commented')
  commented,
  @JsonValue('attachment_added')
  attachmentAdded;

  String get displayName {
    switch (this) {
      case TaskHistoryType.created:
        return '생성됨';
      case TaskHistoryType.updated:
        return '수정됨';
      case TaskHistoryType.statusChanged:
        return '상태 변경';
      case TaskHistoryType.assigned:
        return '할당됨';
      case TaskHistoryType.commented:
        return '댓글 추가';
      case TaskHistoryType.attachmentAdded:
        return '첨부파일 추가';
    }
  }
}

/// 작업 생성 요청 모델
@JsonSerializable()
class CreateTaskRequest {
  final String title;
  final String description;
  final TaskPriority priority;
  final String projectId;
  final String? boardId;
  final String? assigneeId;
  final List<String> labels;
  final DateTime? startDate;
  final DateTime? dueDate;
  final int estimatedHours;

  const CreateTaskRequest({
    required this.title,
    required this.description,
    required this.priority,
    required this.projectId,
    this.boardId,
    this.assigneeId,
    required this.labels,
    this.startDate,
    this.dueDate,
    required this.estimatedHours,
  });

  factory CreateTaskRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateTaskRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateTaskRequestToJson(this);
}

/// 작업 업데이트 요청 모델
@JsonSerializable()
class UpdateTaskRequest {
  final String? title;
  final String? description;
  final TaskStatus? status;
  final TaskPriority? priority;
  final String? assigneeId;
  final List<String>? labels;
  final DateTime? startDate;
  final DateTime? dueDate;
  final int? estimatedHours;
  final int? actualHours;
  final int? progressPercentage;

  const UpdateTaskRequest({
    this.title,
    this.description,
    this.status,
    this.priority,
    this.assigneeId,
    this.labels,
    this.startDate,
    this.dueDate,
    this.estimatedHours,
    this.actualHours,
    this.progressPercentage,
  });

  factory UpdateTaskRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateTaskRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateTaskRequestToJson(this);
}