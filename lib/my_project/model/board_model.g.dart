// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'board_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BoardModel _$BoardModelFromJson(Map<String, dynamic> json) => BoardModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      managers:
          (json['managers'] as List<dynamic>).map((e) => e as String).toList(),
      labels:
          (json['labels'] as List<dynamic>).map((e) => e as String).toList(),
      status: json['status'] as String,
      priority: $enumDecode(_$PriorityEnumMap, json['priority']),
      startDate: json['startDate'] as String,
      deadLine: json['deadLine'] as String,
    );

Map<String, dynamic> _$BoardModelToJson(BoardModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'managers': instance.managers,
      'labels': instance.labels,
      'status': instance.status,
      'priority': _$PriorityEnumMap[instance.priority]!,
      'startDate': instance.startDate,
      'deadLine': instance.deadLine,
    };

const _$PriorityEnumMap = {
  Priority.veryLow: 'veryLow',
  Priority.low: 'low',
  Priority.medium: 'medium',
  Priority.high: 'high',
  Priority.veryHigh: 'veryHigh',
};
