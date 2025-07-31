import 'package:flutter/material.dart';
import 'task_model.dart';

/// 간트 차트 항목 모델
class GanttItem {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final double progress; // 0.0 - 1.0
  final Color color;
  final GanttItemType type;
  final String? parentId;
  final List<String> dependencies;
  final bool isCollapsed;
  final int level; // 계층 레벨 (0부터 시작)
  final TaskPriority priority;
  final String? assigneeId;
  final String assigneeName;
  
  GanttItem({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.progress,
    required this.color,
    required this.type,
    this.parentId,
    this.dependencies = const [],
    this.isCollapsed = false,
    this.level = 0,
    this.priority = TaskPriority.medium,
    this.assigneeId,
    this.assigneeName = '',
  });
  
  /// TaskModel로부터 GanttItem 생성
  factory GanttItem.fromTask(TaskModel task) {
    return GanttItem(
      id: task.id,
      title: task.title,
      description: task.description,
      startDate: task.startDate ?? DateTime.now(),
      endDate: task.dueDate ?? DateTime.now().add(const Duration(days: 1)),
      progress: task.progressPercentage / 100.0,
      color: _getColorFromPriority(task.priority),
      type: GanttItemType.task,
      priority: task.priority,
      assigneeId: task.assigneeId,
      assigneeName: task.assigneeName,
    );
  }
  
  static Color _getColorFromPriority(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.veryLow:
        return Colors.blue[300]!;
      case TaskPriority.low:
        return Colors.green[400]!;
      case TaskPriority.medium:
        return Colors.orange[400]!;
      case TaskPriority.high:
        return Colors.red[400]!;
      case TaskPriority.veryHigh:
        return Colors.purple[600]!;
    }
  }
  
  GanttItem copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    double? progress,
    Color? color,
    GanttItemType? type,
    String? parentId,
    List<String>? dependencies,
    bool? isCollapsed,
    int? level,
    TaskPriority? priority,
    String? assigneeId,
    String? assigneeName,
  }) {
    return GanttItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      progress: progress ?? this.progress,
      color: color ?? this.color,
      type: type ?? this.type,
      parentId: parentId ?? this.parentId,
      dependencies: dependencies ?? this.dependencies,
      isCollapsed: isCollapsed ?? this.isCollapsed,
      level: level ?? this.level,
      priority: priority ?? this.priority,
      assigneeId: assigneeId ?? this.assigneeId,
      assigneeName: assigneeName ?? this.assigneeName,
    );
  }
  
  /// 기간 (일수)
  int get durationInDays => endDate.difference(startDate).inDays + 1;
  
  /// 지연 여부
  bool get isDelayed {
    final now = DateTime.now();
    return now.isAfter(endDate) && progress < 1.0;
  }
  
  /// 오늘이 작업 기간에 포함되는지
  bool get isActiveToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    
    return today.isAfter(start.subtract(const Duration(days: 1))) && 
           today.isBefore(end.add(const Duration(days: 1)));
  }
  
  /// 마일스톤 여부
  bool get isMilestone => type == GanttItemType.milestone;
  
  /// 부모 작업 여부
  bool get isParent => type == GanttItemType.project || type == GanttItemType.phase;
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GanttItem &&
          runtimeType == other.runtimeType &&
          id == other.id;
  
  @override
  int get hashCode => id.hashCode;
  
  @override
  String toString() {
    return 'GanttItem{id: $id, title: $title, startDate: $startDate, endDate: $endDate, progress: $progress}';
  }
}

/// 간트 차트 항목 타입
enum GanttItemType {
  project,    // 프로젝트
  phase,      // 단계
  task,       // 작업
  milestone,  // 마일스톤
}

/// 간트 차트 뷰 설정
class GanttViewSettings {
  final GanttTimeScale timeScale;
  final DateTime startDate;
  final DateTime endDate;
  final double dayWidth;
  final double rowHeight;
  final bool showWeekends;
  final bool showToday;
  final bool showCriticalPath;
  final bool showDependencies;
  
  const GanttViewSettings({
    this.timeScale = GanttTimeScale.days,
    required this.startDate,
    required this.endDate,
    this.dayWidth = 30.0,
    this.rowHeight = 40.0,
    this.showWeekends = true,
    this.showToday = true,
    this.showCriticalPath = false,
    this.showDependencies = true,
  });
  
  GanttViewSettings copyWith({
    GanttTimeScale? timeScale,
    DateTime? startDate,
    DateTime? endDate,
    double? dayWidth,
    double? rowHeight,
    bool? showWeekends,
    bool? showToday,
    bool? showCriticalPath,
    bool? showDependencies,
  }) {
    return GanttViewSettings(
      timeScale: timeScale ?? this.timeScale,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      dayWidth: dayWidth ?? this.dayWidth,
      rowHeight: rowHeight ?? this.rowHeight,
      showWeekends: showWeekends ?? this.showWeekends,
      showToday: showToday ?? this.showToday,
      showCriticalPath: showCriticalPath ?? this.showCriticalPath,
      showDependencies: showDependencies ?? this.showDependencies,
    );
  }
  
  /// 전체 너비 계산
  double get totalWidth {
    final days = endDate.difference(startDate).inDays + 1;
    return days * dayWidth;
  }
  
  /// 특정 날짜의 X 좌표 계산
  double getXPosition(DateTime date) {
    final daysDiff = date.difference(startDate).inDays;
    return daysDiff * dayWidth;
  }
  
  /// X 좌표로부터 날짜 계산
  DateTime getDateFromX(double x) {
    final days = (x / dayWidth).round();
    return startDate.add(Duration(days: days));
  }
}

/// 간트 차트 시간 스케일
enum GanttTimeScale {
  days,     // 일별
  weeks,    // 주별
  months,   // 월별
  quarters, // 분기별
}

/// 간트 차트 의존성 관계
class GanttDependency {
  final String fromTaskId;
  final String toTaskId;
  final DependencyType type;
  final int lagDays; // 지연 일수 (음수 가능)
  
  const GanttDependency({
    required this.fromTaskId,
    required this.toTaskId,
    required this.type,
    this.lagDays = 0,
  });
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GanttDependency &&
          runtimeType == other.runtimeType &&
          fromTaskId == other.fromTaskId &&
          toTaskId == other.toTaskId;
  
  @override
  int get hashCode => fromTaskId.hashCode ^ toTaskId.hashCode;
}

/// 의존성 타입
enum DependencyType {
  finishToStart,  // FS: 선행 작업 완료 후 후행 작업 시작
  startToStart,   // SS: 선행 작업 시작과 동시에 후행 작업 시작
  finishToFinish, // FF: 선행 작업 완료와 동시에 후행 작업 완료
  startToFinish,  // SF: 선행 작업 시작 후 후행 작업 완료
}

/// 간트 차트 마일스톤
class GanttMilestone {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final Color color;
  final MilestoneType type;
  final bool isCompleted;
  
  const GanttMilestone({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.color = Colors.red,
    this.type = MilestoneType.major,
    this.isCompleted = false,
  });
  
  GanttMilestone copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    Color? color,
    MilestoneType? type,
    bool? isCompleted,
  }) {
    return GanttMilestone(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      color: color ?? this.color,
      type: type ?? this.type,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
  
  /// 마일스톤 GanttItem으로 변환
  GanttItem toGanttItem() {
    return GanttItem(
      id: id,
      title: title,
      description: description,
      startDate: date,
      endDate: date,
      progress: isCompleted ? 1.0 : 0.0,
      color: color,
      type: GanttItemType.milestone,
    );
  }
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GanttMilestone &&
          runtimeType == other.runtimeType &&
          id == other.id;
  
  @override
  int get hashCode => id.hashCode;
}

/// 마일스톤 타입
enum MilestoneType {
  major,    // 주요 마일스톤
  minor,    // 세부 마일스톤
  deadline, // 마감일
  review,   // 검토 포인트
}