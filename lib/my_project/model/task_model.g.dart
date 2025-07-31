// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskModel _$TaskModelFromJson(Map<String, dynamic> json) => TaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      status: $enumDecode(_$TaskStatusEnumMap, json['status']),
      priority: $enumDecode(_$TaskPriorityEnumMap, json['priority']),
      projectId: json['projectId'] as String,
      boardId: json['boardId'] as String?,
      assigneeId: json['assigneeId'] as String?,
      assignee: json['assignee'] == null
          ? null
          : UserModel.fromJson(json['assignee'] as Map<String, dynamic>),
      createdById: json['createdById'] as String,
      createdBy: json['createdBy'] == null
          ? null
          : UserModel.fromJson(json['createdBy'] as Map<String, dynamic>),
      labels:
          (json['labels'] as List<dynamic>).map((e) => e as String).toList(),
      attachments: (json['attachments'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      dueDate: json['dueDate'] == null
          ? null
          : DateTime.parse(json['dueDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      estimatedHours: json['estimatedHours'] as int,
      actualHours: json['actualHours'] as int,
      progressPercentage: json['progressPercentage'] as int,
      comments: (json['comments'] as List<dynamic>)
          .map((e) => TaskComment.fromJson(e as Map<String, dynamic>))
          .toList(),
      history: (json['history'] as List<dynamic>)
          .map((e) => TaskHistory.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TaskModelToJson(TaskModel instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'status': _$TaskStatusEnumMap[instance.status]!,
      'priority': _$TaskPriorityEnumMap[instance.priority]!,
      'projectId': instance.projectId,
      'boardId': instance.boardId,
      'assigneeId': instance.assigneeId,
      'assignee': instance.assignee?.toJson(),
      'createdById': instance.createdById,
      'createdBy': instance.createdBy?.toJson(),
      'labels': instance.labels,
      'attachments': instance.attachments,
      'startDate': instance.startDate?.toIso8601String(),
      'dueDate': instance.dueDate?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'estimatedHours': instance.estimatedHours,
      'actualHours': instance.actualHours,
      'progressPercentage': instance.progressPercentage,
      'comments': instance.comments.map((e) => e.toJson()).toList(),
      'history': instance.history.map((e) => e.toJson()).toList(),
    };

const _$TaskStatusEnumMap = {
  TaskStatus.todo: 'todo',
  TaskStatus.inProgress: 'in_progress',
  TaskStatus.review: 'review',
  TaskStatus.done: 'done',
  TaskStatus.blocked: 'blocked',
};

const _$TaskPriorityEnumMap = {
  TaskPriority.veryLow: 'very_low',
  TaskPriority.low: 'low',
  TaskPriority.medium: 'medium',
  TaskPriority.high: 'high',
  TaskPriority.veryHigh: 'very_high',
};

TaskComment _$TaskCommentFromJson(Map<String, dynamic> json) => TaskComment(
      id: json['id'] as String,
      taskId: json['taskId'] as String,
      authorId: json['authorId'] as String,
      author: json['author'] == null
          ? null
          : UserModel.fromJson(json['author'] as Map<String, dynamic>),
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$TaskCommentToJson(TaskComment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'taskId': instance.taskId,
      'authorId': instance.authorId,
      'author': instance.author?.toJson(),
      'content': instance.content,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

TaskHistory _$TaskHistoryFromJson(Map<String, dynamic> json) => TaskHistory(
      id: json['id'] as String,
      taskId: json['taskId'] as String,
      userId: json['userId'] as String,
      user: json['user'] == null
          ? null
          : UserModel.fromJson(json['user'] as Map<String, dynamic>),
      type: $enumDecode(_$TaskHistoryTypeEnumMap, json['type']),
      description: json['description'] as String,
      oldValue: json['oldValue'] as Map<String, dynamic>?,
      newValue: json['newValue'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$TaskHistoryToJson(TaskHistory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'taskId': instance.taskId,
      'userId': instance.userId,
      'user': instance.user?.toJson(),
      'type': _$TaskHistoryTypeEnumMap[instance.type]!,
      'description': instance.description,
      'oldValue': instance.oldValue,
      'newValue': instance.newValue,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$TaskHistoryTypeEnumMap = {
  TaskHistoryType.created: 'created',
  TaskHistoryType.updated: 'updated',
  TaskHistoryType.statusChanged: 'status_changed',
  TaskHistoryType.assigned: 'assigned',
  TaskHistoryType.commented: 'commented',
  TaskHistoryType.attachmentAdded: 'attachment_added',
};

CreateTaskRequest _$CreateTaskRequestFromJson(Map<String, dynamic> json) =>
    CreateTaskRequest(
      title: json['title'] as String,
      description: json['description'] as String,
      priority: $enumDecode(_$TaskPriorityEnumMap, json['priority']),
      projectId: json['projectId'] as String,
      boardId: json['boardId'] as String?,
      assigneeId: json['assigneeId'] as String?,
      labels:
          (json['labels'] as List<dynamic>).map((e) => e as String).toList(),
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      dueDate: json['dueDate'] == null
          ? null
          : DateTime.parse(json['dueDate'] as String),
      estimatedHours: json['estimatedHours'] as int,
    );

Map<String, dynamic> _$CreateTaskRequestToJson(CreateTaskRequest instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'priority': _$TaskPriorityEnumMap[instance.priority]!,
      'projectId': instance.projectId,
      'boardId': instance.boardId,
      'assigneeId': instance.assigneeId,
      'labels': instance.labels,
      'startDate': instance.startDate?.toIso8601String(),
      'dueDate': instance.dueDate?.toIso8601String(),
      'estimatedHours': instance.estimatedHours,
    };

UpdateTaskRequest _$UpdateTaskRequestFromJson(Map<String, dynamic> json) =>
    UpdateTaskRequest(
      title: json['title'] as String?,
      description: json['description'] as String?,
      status: $enumDecodeNullable(_$TaskStatusEnumMap, json['status']),
      priority: $enumDecodeNullable(_$TaskPriorityEnumMap, json['priority']),
      assigneeId: json['assigneeId'] as String?,
      labels: (json['labels'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      dueDate: json['dueDate'] == null
          ? null
          : DateTime.parse(json['dueDate'] as String),
      estimatedHours: json['estimatedHours'] as int?,
      actualHours: json['actualHours'] as int?,
      progressPercentage: json['progressPercentage'] as int?,
    );

Map<String, dynamic> _$UpdateTaskRequestToJson(UpdateTaskRequest instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'status': _$TaskStatusEnumMap[instance.status],
      'priority': _$TaskPriorityEnumMap[instance.priority],
      'assigneeId': instance.assigneeId,
      'labels': instance.labels,
      'startDate': instance.startDate?.toIso8601String(),
      'dueDate': instance.dueDate?.toIso8601String(),
      'estimatedHours': instance.estimatedHours,
      'actualHours': instance.actualHours,
      'progressPercentage': instance.progressPercentage,
    };

K _$enumDecode<K, V>(
  Map<K, V> enumValues,
  Object? source, {
  K? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}

K? _$enumDecodeNullable<K, V>(
  Map<K, V> enumValues,
  dynamic source, {
  K? unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<K, V>(enumValues, source, unknownValue: unknownValue);
}