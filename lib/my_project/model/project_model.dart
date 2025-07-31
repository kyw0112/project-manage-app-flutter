import 'package:actual/user/model/user_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'project_model.g.dart';

@JsonSerializable()
class ProjectModel {
  final String id;
  final String name;
  final String description;
  final ProjectStatus status;
  final ProjectPriority priority;
  final String ownerId;
  final UserModel? owner;
  final List<ProjectMember> members;
  final List<String> tags;
  final DateTime? startDate;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  final int progressPercentage;
  final ProjectSettings settings;
  final String? imageUrl;
  final String? color;
  final bool isArchived;
  final bool isPublic;

  const ProjectModel({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.priority,
    required this.ownerId,
    this.owner,
    required this.members,
    required this.tags,
    this.startDate,
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
    required this.progressPercentage,
    required this.settings,
    this.imageUrl,
    this.color,
    required this.isArchived,
    required this.isPublic,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) =>
      _$ProjectModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectModelToJson(this);

  ProjectModel copyWith({
    String? id,
    String? name,
    String? description,
    ProjectStatus? status,
    ProjectPriority? priority,
    String? ownerId,
    UserModel? owner,
    List<ProjectMember>? members,
    List<String>? tags,
    DateTime? startDate,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    int? progressPercentage,
    ProjectSettings? settings,
    String? imageUrl,
    String? color,
    bool? isArchived,
    bool? isPublic,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      ownerId: ownerId ?? this.ownerId,
      owner: owner ?? this.owner,
      members: members ?? this.members,
      tags: tags ?? this.tags,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      settings: settings ?? this.settings,
      imageUrl: imageUrl ?? this.imageUrl,
      color: color ?? this.color,
      isArchived: isArchived ?? this.isArchived,
      isPublic: isPublic ?? this.isPublic,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProjectModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ProjectModel{id: $id, name: $name, status: $status, priority: $priority}';
  }

  /// 프로젝트가 완료되었는지 확인
  bool get isCompleted => status == ProjectStatus.completed;

  /// 프로젝트가 진행 중인지 확인
  bool get isInProgress => status == ProjectStatus.active;

  /// 프로젝트가 지연되었는지 확인
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

  /// 총 멤버 수
  int get memberCount => members.length;

  /// 활성 멤버 수
  int get activeMemberCount => members.where((m) => m.isActive).length;

  /// 프로젝트 소유자 이름
  String get ownerName => owner?.name ?? '알 수 없음';

  /// 우선순위 색상
  String get priorityColor {
    switch (priority) {
      case ProjectPriority.critical:
        return '#FF0000';
      case ProjectPriority.high:
        return '#FF6600';
      case ProjectPriority.medium:
        return '#FFCC00';
      case ProjectPriority.low:
        return '#00CC00';
    }
  }

  /// 상태 색상
  String get statusColor {
    switch (status) {
      case ProjectStatus.planning:
        return '#9E9E9E';
      case ProjectStatus.active:
        return '#2196F3';
      case ProjectStatus.onHold:
        return '#FF9800';
      case ProjectStatus.completed:
        return '#4CAF50';
      case ProjectStatus.cancelled:
        return '#F44336';
    }
  }

  /// 내가 멤버인지 확인
  bool isMember(String userId) {
    return members.any((member) => member.userId == userId);
  }

  /// 내가 관리자인지 확인
  bool isAdmin(String userId) {
    return ownerId == userId || 
           members.any((member) => 
               member.userId == userId && 
               member.role == ProjectRole.admin);
  }

  /// 특정 권한을 가지고 있는지 확인
  bool hasPermission(String userId, ProjectPermission permission) {
    if (ownerId == userId) return true;
    
    final member = members.where((m) => m.userId == userId).firstOrNull;
    if (member == null) return false;
    
    return member.permissions.contains(permission);
  }
}

/// 프로젝트 상태
@JsonEnum()
enum ProjectStatus {
  @JsonValue('planning')
  planning,
  @JsonValue('active')
  active,
  @JsonValue('on_hold')
  onHold,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled;

  String get displayName {
    switch (this) {
      case ProjectStatus.planning:
        return '계획 중';
      case ProjectStatus.active:
        return '진행 중';
      case ProjectStatus.onHold:
        return '보류';
      case ProjectStatus.completed:
        return '완료';
      case ProjectStatus.cancelled:
        return '취소됨';
    }
  }
}

/// 프로젝트 우선순위
@JsonEnum()
enum ProjectPriority {
  @JsonValue('low')
  low,
  @JsonValue('medium')
  medium,
  @JsonValue('high')
  high,
  @JsonValue('critical')
  critical;

  String get displayName {
    switch (this) {
      case ProjectPriority.low:
        return '낮음';
      case ProjectPriority.medium:
        return '보통';
      case ProjectPriority.high:
        return '높음';
      case ProjectPriority.critical:
        return '긴급';
    }
  }

  int get value {
    switch (this) {
      case ProjectPriority.low:
        return 1;
      case ProjectPriority.medium:
        return 2;
      case ProjectPriority.high:
        return 3;
      case ProjectPriority.critical:
        return 4;
    }
  }
}

/// 프로젝트 멤버
@JsonSerializable()
class ProjectMember {
  final String userId;
  final UserModel? user;
  final ProjectRole role;
  final List<ProjectPermission> permissions;
  final DateTime joinedAt;
  final bool isActive;
  final String? title;
  final String? department;

  const ProjectMember({
    required this.userId,
    this.user,
    required this.role,
    required this.permissions,
    required this.joinedAt,
    required this.isActive,
    this.title,
    this.department,
  });

  factory ProjectMember.fromJson(Map<String, dynamic> json) =>
      _$ProjectMemberFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectMemberToJson(this);

  /// 멤버 이름
  String get name => user?.name ?? '알 수 없음';

  /// 멤버 이메일
  String get email => user?.email ?? '';

  /// 권한 확인
  bool hasPermission(ProjectPermission permission) {
    return permissions.contains(permission);
  }
}

/// 프로젝트 역할
@JsonEnum()
enum ProjectRole {
  @JsonValue('member')
  member,
  @JsonValue('manager')
  manager,
  @JsonValue('admin')
  admin;

  String get displayName {
    switch (this) {
      case ProjectRole.member:
        return '멤버';
      case ProjectRole.manager:
        return '매니저';
      case ProjectRole.admin:
        return '관리자';
    }
  }
}

/// 프로젝트 권한
@JsonEnum()
enum ProjectPermission {
  @JsonValue('read')
  read,
  @JsonValue('write')
  write,
  @JsonValue('delete')
  delete,
  @JsonValue('invite')
  invite,
  @JsonValue('manage')
  manage;

  String get displayName {
    switch (this) {
      case ProjectPermission.read:
        return '읽기';
      case ProjectPermission.write:
        return '쓰기';
      case ProjectPermission.delete:
        return '삭제';
      case ProjectPermission.invite:
        return '초대';
      case ProjectPermission.manage:
        return '관리';
    }
  }
}

/// 프로젝트 설정
@JsonSerializable()
class ProjectSettings {
  final bool allowPublicAccess;
  final bool allowMemberInvite;
  final bool requireApprovalForJoin;
  final bool enableNotifications;
  final bool enableTimeTracking;
  final String defaultTaskStatus;
  final int maxMembers;
  final List<String> allowedFileTypes;
  final int maxFileSize;

  const ProjectSettings({
    required this.allowPublicAccess,
    required this.allowMemberInvite,
    required this.requireApprovalForJoin,
    required this.enableNotifications,
    required this.enableTimeTracking,
    required this.defaultTaskStatus,
    required this.maxMembers,
    required this.allowedFileTypes,
    required this.maxFileSize,
  });

  factory ProjectSettings.fromJson(Map<String, dynamic> json) =>
      _$ProjectSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectSettingsToJson(this);

  /// 기본 설정 생성
  factory ProjectSettings.defaultSettings() {
    return const ProjectSettings(
      allowPublicAccess: false,
      allowMemberInvite: true,
      requireApprovalForJoin: false,
      enableNotifications: true,
      enableTimeTracking: true,
      defaultTaskStatus: 'todo',
      maxMembers: 50,
      allowedFileTypes: ['jpg', 'jpeg', 'png', 'gif', 'pdf', 'doc', 'docx'],
      maxFileSize: 10485760, // 10MB
    );
  }
}

/// 프로젝트 생성 요청 모델
@JsonSerializable()
class CreateProjectRequest {
  final String name;
  final String description;
  final ProjectPriority priority;
  final List<String> tags;
  final DateTime? startDate;
  final DateTime? dueDate;
  final ProjectSettings? settings;
  final String? color;
  final bool isPublic;

  const CreateProjectRequest({
    required this.name,
    required this.description,
    required this.priority,
    required this.tags,
    this.startDate,
    this.dueDate,
    this.settings,
    this.color,
    required this.isPublic,
  });

  factory CreateProjectRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateProjectRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateProjectRequestToJson(this);
}

/// 프로젝트 업데이트 요청 모델
@JsonSerializable()
class UpdateProjectRequest {
  final String? name;
  final String? description;
  final ProjectStatus? status;
  final ProjectPriority? priority;
  final List<String>? tags;
  final DateTime? startDate;
  final DateTime? dueDate;
  final int? progressPercentage;
  final ProjectSettings? settings;
  final String? imageUrl;
  final String? color;
  final bool? isArchived;
  final bool? isPublic;

  const UpdateProjectRequest({
    this.name,
    this.description,
    this.status,
    this.priority,
    this.tags,
    this.startDate,
    this.dueDate,
    this.progressPercentage,
    this.settings,
    this.imageUrl,
    this.color,
    this.isArchived,
    this.isPublic,
  });

  factory UpdateProjectRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateProjectRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateProjectRequestToJson(this);
}

/// 프로젝트 멤버 초대 요청 모델
@JsonSerializable()
class InviteMemberRequest {
  final String email;
  final ProjectRole role;
  final List<ProjectPermission> permissions;
  final String? title;
  final String? department;

  const InviteMemberRequest({
    required this.email,
    required this.role,
    required this.permissions,
    this.title,
    this.department,
  });

  factory InviteMemberRequest.fromJson(Map<String, dynamic> json) =>
      _$InviteMemberRequestFromJson(json);

  Map<String, dynamic> toJson() => _$InviteMemberRequestToJson(this);
}