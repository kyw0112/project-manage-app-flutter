import 'dart:convert';

class EventModel {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String projectId;
  final String? taskId;
  final EventType type;
  final EventPriority priority;
  final bool isAllDay;
  final bool isRecurring;
  final RecurrenceRule? recurrenceRule;
  final List<String> attendees;
  final String color;
  final EventReminder? reminder;
  final DateTime createdAt;
  final DateTime updatedAt;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.projectId,
    this.taskId,
    required this.type,
    required this.priority,
    this.isAllDay = false,
    this.isRecurring = false,
    this.recurrenceRule,
    this.attendees = const [],
    this.color = '#2196F3',
    this.reminder,
    required this.createdAt,
    required this.updatedAt,
  });

  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? projectId,
    String? taskId,
    EventType? type,
    EventPriority? priority,
    bool? isAllDay,
    bool? isRecurring,
    RecurrenceRule? recurrenceRule,
    List<String>? attendees,
    String? color,
    EventReminder? reminder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      projectId: projectId ?? this.projectId,
      taskId: taskId ?? this.taskId,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      isAllDay: isAllDay ?? this.isAllDay,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      attendees: attendees ?? this.attendees,
      color: color ?? this.color,
      reminder: reminder ?? this.reminder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'projectId': projectId,
      'taskId': taskId,
      'type': type.name,
      'priority': priority.name,
      'isAllDay': isAllDay,
      'isRecurring': isRecurring,
      'recurrenceRule': recurrenceRule?.toMap(),
      'attendees': attendees,
      'color': color,
      'reminder': reminder?.toMap(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      projectId: map['projectId'] ?? '',
      taskId: map['taskId'],
      type: EventType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => EventType.meeting,
      ),
      priority: EventPriority.values.firstWhere(
        (e) => e.name == map['priority'],
        orElse: () => EventPriority.medium,
      ),
      isAllDay: map['isAllDay'] ?? false,
      isRecurring: map['isRecurring'] ?? false,
      recurrenceRule: map['recurrenceRule'] != null
          ? RecurrenceRule.fromMap(map['recurrenceRule'])
          : null,
      attendees: List<String>.from(map['attendees'] ?? []),
      color: map['color'] ?? '#2196F3',
      reminder: map['reminder'] != null
          ? EventReminder.fromMap(map['reminder'])
          : null,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  String toJson() => json.encode(toMap());

  factory EventModel.fromJson(String source) =>
      EventModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'EventModel(id: $id, title: $title, startTime: $startTime, endTime: $endTime, type: $type, priority: $priority)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is EventModel && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }

  Duration get duration => endTime.difference(startTime);
  
  bool get isToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(startTime.year, startTime.month, startTime.day);
    return today == eventDay;
  }
  
  bool get isPast => endTime.isBefore(DateTime.now());
  
  bool get isUpcoming => startTime.isAfter(DateTime.now());
}

enum EventType {
  meeting,
  deadline,
  milestone,
  task,
  reminder,
  personal,
}

enum EventPriority {
  low,
  medium,
  high,
  urgent,
}

class RecurrenceRule {
  final RecurrenceFrequency frequency;
  final int interval;
  final DateTime? endDate;
  final int? occurrences;
  final List<int>? weekdays; // 1=Monday, 7=Sunday
  final int? dayOfMonth;

  RecurrenceRule({
    required this.frequency,
    this.interval = 1,
    this.endDate,
    this.occurrences,
    this.weekdays,
    this.dayOfMonth,
  });

  Map<String, dynamic> toMap() {
    return {
      'frequency': frequency.name,
      'interval': interval,
      'endDate': endDate?.toIso8601String(),
      'occurrences': occurrences,
      'weekdays': weekdays,
      'dayOfMonth': dayOfMonth,
    };
  }

  factory RecurrenceRule.fromMap(Map<String, dynamic> map) {
    return RecurrenceRule(
      frequency: RecurrenceFrequency.values.firstWhere(
        (e) => e.name == map['frequency'],
        orElse: () => RecurrenceFrequency.daily,
      ),
      interval: map['interval'] ?? 1,
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
      occurrences: map['occurrences'],
      weekdays: map['weekdays'] != null ? List<int>.from(map['weekdays']) : null,
      dayOfMonth: map['dayOfMonth'],
    );
  }
}

enum RecurrenceFrequency {
  daily,
  weekly,
  monthly,
  yearly,
}

class EventReminder {
  final int minutesBefore;
  final bool isEnabled;

  EventReminder({
    required this.minutesBefore,
    this.isEnabled = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'minutesBefore': minutesBefore,
      'isEnabled': isEnabled,
    };
  }

  factory EventReminder.fromMap(Map<String, dynamic> map) {
    return EventReminder(
      minutesBefore: map['minutesBefore'] ?? 15,
      isEnabled: map['isEnabled'] ?? true,
    );
  }
}