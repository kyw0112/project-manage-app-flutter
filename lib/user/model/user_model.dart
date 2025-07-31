import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String id;
  final String email;
  final String name;
  final String? profileImage;
  final String? phoneNumber;
  final String? department;
  final String? position;
  final UserRole role;
  final UserStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLoginAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.profileImage,
    this.phoneNumber,
    this.department,
    this.position,
    required this.role,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? profileImage,
    String? phoneNumber,
    String? department,
    String? position,
    UserRole? role,
    UserStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      profileImage: profileImage ?? this.profileImage,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      department: department ?? this.department,
      position: position ?? this.position,
      role: role ?? this.role,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UserModel{id: $id, email: $email, name: $name, role: $role}';
  }

  /// 관리자 권한 확인
  bool get isAdmin => role == UserRole.admin;

  /// 활성 사용자 확인
  bool get isActive => status == UserStatus.active;

  /// 프로필 이미지 URL 반환 (기본 이미지 포함)
  String get profileImageUrl =>
      profileImage ?? 'assets/img/user/user_basic_icon.png';

  /// 표시용 이름 (부서 + 이름)
  String get displayName {
    if (department != null && department!.isNotEmpty) {
      return '$department $name';
    }
    return name;
  }
}

/// 사용자 역할
@JsonEnum()
enum UserRole {
  @JsonValue('admin')
  admin,
  @JsonValue('manager')
  manager,
  @JsonValue('member')
  member,
  @JsonValue('viewer')
  viewer;

  String get displayName {
    switch (this) {
      case UserRole.admin:
        return '관리자';
      case UserRole.manager:
        return '매니저';
      case UserRole.member:
        return '멤버';
      case UserRole.viewer:
        return '뷰어';
    }
  }

  bool get canManageProjects {
    return this == UserRole.admin || this == UserRole.manager;
  }

  bool get canCreateTasks {
    return this != UserRole.viewer;
  }

  bool get canManageUsers {
    return this == UserRole.admin;
  }
}

/// 사용자 상태
@JsonEnum()
enum UserStatus {
  @JsonValue('active')
  active,
  @JsonValue('inactive')
  inactive,
  @JsonValue('suspended')
  suspended,
  @JsonValue('pending')
  pending;

  String get displayName {
    switch (this) {
      case UserStatus.active:
        return '활성';
      case UserStatus.inactive:
        return '비활성';
      case UserStatus.suspended:
        return '정지';
      case UserStatus.pending:
        return '대기';
    }
  }
}

/// 로그인 응답 모델
@JsonSerializable()
class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final UserModel user;

  const LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}

/// 토큰 갱신 응답 모델
@JsonSerializable()
class TokenResponse {
  final String accessToken;
  final String refreshToken;

  const TokenResponse({
    required this.accessToken,
    required this.refreshToken,
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) =>
      _$TokenResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TokenResponseToJson(this);
}