// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProjectModel _$ProjectModelFromJson(Map<String, dynamic> json) => ProjectModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      status: $enumDecode(_$ProjectStatusEnumMap, json['status']),
      priority: $enumDecode(_$ProjectPriorityEnumMap, json['priority']),
      ownerId: json['ownerId'] as String,
      owner: json['owner'] == null
          ? null
          : UserModel.fromJson(json['owner'] as Map<String, dynamic>),
      members: (json['members'] as List<dynamic>)
          .map((e) => ProjectMember.fromJson(e as Map<String, dynamic>))
          .toList(),
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
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
      progressPercentage: (json['progressPercentage'] as num).toInt(),
      settings:
          ProjectSettings.fromJson(json['settings'] as Map<String, dynamic>),
      imageUrl: json['imageUrl'] as String?,
      color: json['color'] as String?,
      isArchived: json['isArchived'] as bool,
      isPublic: json['isPublic'] as bool,
    );

Map<String, dynamic> _$ProjectModelToJson(ProjectModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'status': _$ProjectStatusEnumMap[instance.status]!,
      'priority': _$ProjectPriorityEnumMap[instance.priority]!,
      'ownerId': instance.ownerId,
      'owner': instance.owner,
      'members': instance.members,
      'tags': instance.tags,
      'startDate': instance.startDate?.toIso8601String(),
      'dueDate': instance.dueDate?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'progressPercentage': instance.progressPercentage,
      'settings': instance.settings,
      'imageUrl': instance.imageUrl,
      'color': instance.color,
      'isArchived': instance.isArchived,
      'isPublic': instance.isPublic,
    };

const _$ProjectStatusEnumMap = {
  ProjectStatus.planning: 'planning',
  ProjectStatus.active: 'active',
  ProjectStatus.onHold: 'on_hold',
  ProjectStatus.completed: 'completed',
  ProjectStatus.cancelled: 'cancelled',
};

const _$ProjectPriorityEnumMap = {
  ProjectPriority.low: 'low',
  ProjectPriority.medium: 'medium',
  ProjectPriority.high: 'high',
  ProjectPriority.critical: 'critical',
};

ProjectMember _$ProjectMemberFromJson(Map<String, dynamic> json) =>
    ProjectMember(
      userId: json['userId'] as String,
      user: json['user'] == null
          ? null
          : UserModel.fromJson(json['user'] as Map<String, dynamic>),
      role: $enumDecode(_$ProjectRoleEnumMap, json['role']),
      permissions: (json['permissions'] as List<dynamic>)
          .map((e) => $enumDecode(_$ProjectPermissionEnumMap, e))
          .toList(),
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      isActive: json['isActive'] as bool,
      title: json['title'] as String?,
      department: json['department'] as String?,
    );

Map<String, dynamic> _$ProjectMemberToJson(ProjectMember instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'user': instance.user,
      'role': _$ProjectRoleEnumMap[instance.role]!,
      'permissions': instance.permissions
          .map((e) => _$ProjectPermissionEnumMap[e]!)
          .toList(),
      'joinedAt': instance.joinedAt.toIso8601String(),
      'isActive': instance.isActive,
      'title': instance.title,
      'department': instance.department,
    };

const _$ProjectRoleEnumMap = {
  ProjectRole.member: 'member',
  ProjectRole.manager: 'manager',
  ProjectRole.admin: 'admin',
};

const _$ProjectPermissionEnumMap = {
  ProjectPermission.read: 'read',
  ProjectPermission.write: 'write',
  ProjectPermission.delete: 'delete',
  ProjectPermission.invite: 'invite',
  ProjectPermission.manage: 'manage',
};

ProjectSettings _$ProjectSettingsFromJson(Map<String, dynamic> json) =>
    ProjectSettings(
      allowPublicAccess: json['allowPublicAccess'] as bool,
      allowMemberInvite: json['allowMemberInvite'] as bool,
      requireApprovalForJoin: json['requireApprovalForJoin'] as bool,
      enableNotifications: json['enableNotifications'] as bool,
      enableTimeTracking: json['enableTimeTracking'] as bool,
      defaultTaskStatus: json['defaultTaskStatus'] as String,
      maxMembers: (json['maxMembers'] as num).toInt(),
      allowedFileTypes: (json['allowedFileTypes'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      maxFileSize: (json['maxFileSize'] as num).toInt(),
    );

Map<String, dynamic> _$ProjectSettingsToJson(ProjectSettings instance) =>
    <String, dynamic>{
      'allowPublicAccess': instance.allowPublicAccess,
      'allowMemberInvite': instance.allowMemberInvite,
      'requireApprovalForJoin': instance.requireApprovalForJoin,
      'enableNotifications': instance.enableNotifications,
      'enableTimeTracking': instance.enableTimeTracking,
      'defaultTaskStatus': instance.defaultTaskStatus,
      'maxMembers': instance.maxMembers,
      'allowedFileTypes': instance.allowedFileTypes,
      'maxFileSize': instance.maxFileSize,
    };

CreateProjectRequest _$CreateProjectRequestFromJson(
        Map<String, dynamic> json) =>
    CreateProjectRequest(
      name: json['name'] as String,
      description: json['description'] as String,
      priority: $enumDecode(_$ProjectPriorityEnumMap, json['priority']),
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      dueDate: json['dueDate'] == null
          ? null
          : DateTime.parse(json['dueDate'] as String),
      settings: json['settings'] == null
          ? null
          : ProjectSettings.fromJson(json['settings'] as Map<String, dynamic>),
      color: json['color'] as String?,
      isPublic: json['isPublic'] as bool,
    );

Map<String, dynamic> _$CreateProjectRequestToJson(
        CreateProjectRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'priority': _$ProjectPriorityEnumMap[instance.priority]!,
      'tags': instance.tags,
      'startDate': instance.startDate?.toIso8601String(),
      'dueDate': instance.dueDate?.toIso8601String(),
      'settings': instance.settings,
      'color': instance.color,
      'isPublic': instance.isPublic,
    };

UpdateProjectRequest _$UpdateProjectRequestFromJson(
        Map<String, dynamic> json) =>
    UpdateProjectRequest(
      name: json['name'] as String?,
      description: json['description'] as String?,
      status: $enumDecodeNullable(_$ProjectStatusEnumMap, json['status']),
      priority: $enumDecodeNullable(_$ProjectPriorityEnumMap, json['priority']),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      dueDate: json['dueDate'] == null
          ? null
          : DateTime.parse(json['dueDate'] as String),
      progressPercentage: (json['progressPercentage'] as num?)?.toInt(),
      settings: json['settings'] == null
          ? null
          : ProjectSettings.fromJson(json['settings'] as Map<String, dynamic>),
      imageUrl: json['imageUrl'] as String?,
      color: json['color'] as String?,
      isArchived: json['isArchived'] as bool?,
      isPublic: json['isPublic'] as bool?,
    );

Map<String, dynamic> _$UpdateProjectRequestToJson(
        UpdateProjectRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'status': _$ProjectStatusEnumMap[instance.status],
      'priority': _$ProjectPriorityEnumMap[instance.priority],
      'tags': instance.tags,
      'startDate': instance.startDate?.toIso8601String(),
      'dueDate': instance.dueDate?.toIso8601String(),
      'progressPercentage': instance.progressPercentage,
      'settings': instance.settings,
      'imageUrl': instance.imageUrl,
      'color': instance.color,
      'isArchived': instance.isArchived,
      'isPublic': instance.isPublic,
    };

InviteMemberRequest _$InviteMemberRequestFromJson(Map<String, dynamic> json) =>
    InviteMemberRequest(
      email: json['email'] as String,
      role: $enumDecode(_$ProjectRoleEnumMap, json['role']),
      permissions: (json['permissions'] as List<dynamic>)
          .map((e) => $enumDecode(_$ProjectPermissionEnumMap, e))
          .toList(),
      title: json['title'] as String?,
      department: json['department'] as String?,
    );

Map<String, dynamic> _$InviteMemberRequestToJson(
        InviteMemberRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'role': _$ProjectRoleEnumMap[instance.role]!,
      'permissions': instance.permissions
          .map((e) => _$ProjectPermissionEnumMap[e]!)
          .toList(),
      'title': instance.title,
      'department': instance.department,
    };
