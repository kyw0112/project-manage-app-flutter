
import 'package:actual/common/const/data.dart';
import 'package:actual/my_project/model/member_model.dart';
import 'package:actual/my_project/model/project_model.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/http.dart';

part 'project_repository.g.dart';

@RestApi()
abstract class ProjectRepository {
  factory ProjectRepository(Dio dio, {String baseUrl}) = _ProjectRepository;

  /// 사용자의 모든 프로젝트 조회
  @GET('/projects')
  Future<List<ProjectModel>> getProjects();

  /// 특정 프로젝트 조회
  @GET('/projects/{projectId}')
  Future<ProjectModel> getProject(@Path('projectId') String projectId);

  /// 새 프로젝트 생성
  @POST('/projects')
  Future<ProjectModel> createProject(@Body() CreateProjectRequest request);

  /// 프로젝트 업데이트
  @PUT('/projects/{projectId}')
  Future<ProjectModel> updateProject(
    @Path('projectId') String projectId,
    @Body() UpdateProjectRequest request,
  );

  /// 프로젝트 삭제
  @DELETE('/projects/{projectId}')
  Future<void> deleteProject(@Path('projectId') String projectId);

  /// 프로젝트 멤버 조회
  @GET('/projects/{projectId}/members')
  Future<List<ProjectMember>> getProjectMembers(@Path('projectId') String projectId);

  /// 프로젝트 멤버 초대
  @POST('/projects/{projectId}/members')
  Future<ProjectMember> inviteMember(
    @Path('projectId') String projectId,
    @Body() InviteMemberRequest request,
  );

  /// 프로젝트 멤버 제거
  @DELETE('/projects/{projectId}/members/{userId}')
  Future<void> removeMember(
    @Path('projectId') String projectId,
    @Path('userId') String userId,
  );

  /// 프로젝트 멤버 역할 업데이트
  @PUT('/projects/{projectId}/members/{userId}')
  Future<ProjectMember> updateMemberRole(
    @Path('projectId') String projectId,
    @Path('userId') String userId,
    @Body() UpdateMemberRoleRequest request,
  );

  /// 프로젝트 아카이브
  @PUT('/projects/{projectId}/archive')
  Future<ProjectModel> archiveProject(@Path('projectId') String projectId);

  /// 프로젝트 아카이브 해제
  @PUT('/projects/{projectId}/unarchive')
  Future<ProjectModel> unarchiveProject(@Path('projectId') String projectId);

  /// 프로젝트 복제
  @POST('/projects/{projectId}/duplicate')
  Future<ProjectModel> duplicateProject(
    @Path('projectId') String projectId,
    @Body() DuplicateProjectRequest request,
  );

  /// 공개 프로젝트 검색
  @GET('/projects/public')
  Future<List<ProjectModel>> getPublicProjects(
    @Query('q') String? query,
    @Query('tags') List<String>? tags,
  );

  /// 프로젝트 통계 조회
  @GET('/projects/{projectId}/stats')
  Future<ProjectStats> getProjectStats(@Path('projectId') String projectId);

  /// 내가 소유한 프로젝트 조회
  @GET('/projects/owned')
  Future<List<ProjectModel>> getOwnedProjects();

  /// 내가 참여한 프로젝트 조회
  @GET('/projects/joined')
  Future<List<ProjectModel>> getJoinedProjects();
}

/// ProjectRepository 구현 클래스 (개발용)
class ProjectRepositoryImpl implements ProjectRepository {
  final Dio _dio;
  final String _baseUrl;

  ProjectRepositoryImpl(this._dio, {String? baseUrl}) 
      : _baseUrl = baseUrl ?? 'http://$ip';

  @override
  Future<List<ProjectModel>> getProjects() async {
    try {
      final response = await _dio.get(
        '$_baseUrl/projects',
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      final List<dynamic> projectsJson = response.data;
      return projectsJson.map((json) => ProjectModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('프로젝트 목록을 가져오는 중 오류가 발생했습니다: ${e.message}');
    }
  }

  @override
  Future<ProjectModel> getProject(String projectId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/projects/$projectId',
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      return ProjectModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('프로젝트를 찾을 수 없습니다.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('프로젝트에 접근할 권한이 없습니다.');
      } else {
        throw Exception('프로젝트 정보를 가져오는 중 오류가 발생했습니다: ${e.message}');
      }
    }
  }

  @override
  Future<ProjectModel> createProject(CreateProjectRequest request) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/projects',
        data: request.toJson(),
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      return ProjectModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final message = e.response?.data['message'] ?? '잘못된 입력값입니다.';
        throw Exception(message);
      } else {
        throw Exception('프로젝트 생성 중 오류가 발생했습니다: ${e.message}');
      }
    }
  }

  @override
  Future<ProjectModel> updateProject(String projectId, UpdateProjectRequest request) async {
    try {
      final response = await _dio.put(
        '$_baseUrl/projects/$projectId',
        data: request.toJson(),
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      return ProjectModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('프로젝트를 찾을 수 없습니다.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('프로젝트를 수정할 권한이 없습니다.');
      } else if (e.response?.statusCode == 400) {
        final message = e.response?.data['message'] ?? '잘못된 입력값입니다.';
        throw Exception(message);
      } else {
        throw Exception('프로젝트 수정 중 오류가 발생했습니다: ${e.message}');
      }
    }
  }

  @override
  Future<void> deleteProject(String projectId) async {
    try {
      await _dio.delete(
        '$_baseUrl/projects/$projectId',
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('프로젝트를 찾을 수 없습니다.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('프로젝트를 삭제할 권한이 없습니다.');
      } else {
        throw Exception('프로젝트 삭제 중 오류가 발생했습니다: ${e.message}');
      }
    }
  }

  @override
  Future<List<ProjectMember>> getProjectMembers(String projectId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/projects/$projectId/members',
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      final List<dynamic> membersJson = response.data;
      return membersJson.map((json) => ProjectMember.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('프로젝트 멤버를 가져오는 중 오류가 발생했습니다: ${e.message}');
    }
  }

  @override
  Future<ProjectMember> inviteMember(String projectId, InviteMemberRequest request) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/projects/$projectId/members',
        data: request.toJson(),
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      return ProjectMember.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final message = e.response?.data['message'] ?? '이미 프로젝트 멤버입니다.';
        throw Exception(message);
      } else if (e.response?.statusCode == 403) {
        throw Exception('멤버를 초대할 권한이 없습니다.');
      } else {
        throw Exception('멤버 초대 중 오류가 발생했습니다: ${e.message}');
      }
    }
  }

  @override
  Future<void> removeMember(String projectId, String userId) async {
    try {
      await _dio.delete(
        '$_baseUrl/projects/$projectId/members/$userId',
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('멤버를 찾을 수 없습니다.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('멤버를 제거할 권한이 없습니다.');
      } else {
        throw Exception('멤버 제거 중 오류가 발생했습니다: ${e.message}');
      }
    }
  }

  @override
  Future<ProjectMember> updateMemberRole(String projectId, String userId, UpdateMemberRoleRequest request) async {
    try {
      final response = await _dio.put(
        '$_baseUrl/projects/$projectId/members/$userId',
        data: request.toJson(),
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      return ProjectMember.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('멤버를 찾을 수 없습니다.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('멤버 역할을 변경할 권한이 없습니다.');
      } else {
        throw Exception('멤버 역할 변경 중 오류가 발생했습니다: ${e.message}');
      }
    }
  }

  @override
  Future<ProjectModel> archiveProject(String projectId) async {
    try {
      final response = await _dio.put(
        '$_baseUrl/projects/$projectId/archive',
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      return ProjectModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('프로젝트 아카이브 중 오류가 발생했습니다: ${e.message}');
    }
  }

  @override
  Future<ProjectModel> unarchiveProject(String projectId) async {
    try {
      final response = await _dio.put(
        '$_baseUrl/projects/$projectId/unarchive',
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      return ProjectModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('프로젝트 아카이브 해제 중 오류가 발생했습니다: ${e.message}');
    }
  }

  @override
  Future<ProjectModel> duplicateProject(String projectId, DuplicateProjectRequest request) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/projects/$projectId/duplicate',
        data: request.toJson(),
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      return ProjectModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('프로젝트 복제 중 오류가 발생했습니다: ${e.message}');
    }
  }

  @override
  Future<List<ProjectModel>> getPublicProjects(String? query, List<String>? tags) async {
    try {
      final queryParams = <String, dynamic>{};
      if (query != null) queryParams['q'] = query;
      if (tags != null && tags.isNotEmpty) queryParams['tags'] = tags;

      final response = await _dio.get(
        '$_baseUrl/projects/public',
        queryParameters: queryParams,
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      final List<dynamic> projectsJson = response.data;
      return projectsJson.map((json) => ProjectModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('공개 프로젝트 검색 중 오류가 발생했습니다: ${e.message}');
    }
  }

  @override
  Future<ProjectStats> getProjectStats(String projectId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/projects/$projectId/stats',
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      return ProjectStats.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('프로젝트 통계를 가져오는 중 오류가 발생했습니다: ${e.message}');
    }
  }

  @override
  Future<List<ProjectModel>> getOwnedProjects() async {
    try {
      final response = await _dio.get(
        '$_baseUrl/projects/owned',
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      final List<dynamic> projectsJson = response.data;
      return projectsJson.map((json) => ProjectModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('소유한 프로젝트를 가져오는 중 오류가 발생했습니다: ${e.message}');
    }
  }

  @override
  Future<List<ProjectModel>> getJoinedProjects() async {
    try {
      final response = await _dio.get(
        '$_baseUrl/projects/joined',
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      final List<dynamic> projectsJson = response.data;
      return projectsJson.map((json) => ProjectModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('참여한 프로젝트를 가져오는 중 오류가 발생했습니다: ${e.message}');
    }
  }
}

/// 멤버 역할 업데이트 요청 모델
class UpdateMemberRoleRequest {
  final ProjectRole role;
  final List<ProjectPermission> permissions;

  const UpdateMemberRoleRequest({
    required this.role,
    required this.permissions,
  });

  Map<String, dynamic> toJson() => {
    'role': role.name,
    'permissions': permissions.map((p) => p.name).toList(),
  };
}

/// 프로젝트 복제 요청 모델
class DuplicateProjectRequest {
  final String name;
  final bool includeMembers;
  final bool includeTasks;

  const DuplicateProjectRequest({
    required this.name,
    required this.includeMembers,
    required this.includeTasks,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'includeMembers': includeMembers,
    'includeTasks': includeTasks,
  };
}

/// 프로젝트 통계 모델
class ProjectStats {
  final int totalTasks;
  final int completedTasks;
  final int inProgressTasks;
  final int overdueTasks;
  final int totalMembers;
  final int activeMembers;
  final double completionRate;
  final Map<String, int> tasksByStatus;
  final Map<String, int> tasksByPriority;

  const ProjectStats({
    required this.totalTasks,
    required this.completedTasks,
    required this.inProgressTasks,
    required this.overdueTasks,
    required this.totalMembers,
    required this.activeMembers,
    required this.completionRate,
    required this.tasksByStatus,
    required this.tasksByPriority,
  });

  factory ProjectStats.fromJson(Map<String, dynamic> json) {
    return ProjectStats(
      totalTasks: json['totalTasks'],
      completedTasks: json['completedTasks'],
      inProgressTasks: json['inProgressTasks'],
      overdueTasks: json['overdueTasks'],
      totalMembers: json['totalMembers'],
      activeMembers: json['activeMembers'],
      completionRate: json['completionRate'].toDouble(),
      tasksByStatus: Map<String, int>.from(json['tasksByStatus']),
      tasksByPriority: Map<String, int>.from(json['tasksByPriority']),
    );
  }
}