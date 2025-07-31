import 'package:actual/common/const/data.dart';
import 'package:actual/my_project/model/task_model.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/http.dart';

part 'task_repository.g.dart';

@RestApi()
abstract class TaskRepository {
  factory TaskRepository(Dio dio, {String baseUrl}) = _TaskRepository;

  /// 프로젝트의 모든 작업 조회
  @GET('/projects/{projectId}/tasks')
  Future<List<TaskModel>> getTasksByProject(@Path('projectId') String projectId);

  /// 사용자에게 할당된 작업 조회
  @GET('/tasks/assignee/{userId}')
  Future<List<TaskModel>> getTasksByAssignee(@Path('userId') String userId);

  /// 특정 작업 조회
  @GET('/tasks/{taskId}')
  Future<TaskModel> getTask(@Path('taskId') String taskId);

  /// 새 작업 생성
  @POST('/tasks')
  Future<TaskModel> createTask(@Body() CreateTaskRequest request);

  /// 작업 업데이트
  @PUT('/tasks/{taskId}')
  Future<TaskModel> updateTask(
    @Path('taskId') String taskId,
    @Body() UpdateTaskRequest request,
  );

  /// 작업 삭제
  @DELETE('/tasks/{taskId}')
  Future<void> deleteTask(@Path('taskId') String taskId);

  /// 작업에 댓글 추가
  @POST('/tasks/{taskId}/comments')
  Future<TaskComment> addComment(
    @Path('taskId') String taskId,
    @Body() CreateCommentRequest request,
  );

  /// 작업 댓글 조회
  @GET('/tasks/{taskId}/comments')
  Future<List<TaskComment>> getComments(@Path('taskId') String taskId);

  /// 작업 히스토리 조회
  @GET('/tasks/{taskId}/history')
  Future<List<TaskHistory>> getTaskHistory(@Path('taskId') String taskId);

  /// 작업 상태별 조회
  @GET('/projects/{projectId}/tasks/status/{status}')
  Future<List<TaskModel>> getTasksByStatus(
    @Path('projectId') String projectId,
    @Path('status') TaskStatus status,
  );

  /// 우선순위별 작업 조회
  @GET('/projects/{projectId}/tasks/priority/{priority}')
  Future<List<TaskModel>> getTasksByPriority(
    @Path('projectId') String projectId,
    @Path('priority') TaskPriority priority,
  );

  /// 마감일별 작업 조회
  @GET('/tasks/due-date')
  Future<List<TaskModel>> getTasksByDueDate(
    @Query('from') String fromDate,
    @Query('to') String toDate,
  );

  /// 작업 검색
  @GET('/tasks/search')
  Future<List<TaskModel>> searchTasks(
    @Query('q') String query,
    @Query('projectId') String? projectId,
  );

  /// 칸반 보드의 작업 조회
  @GET('/boards/{boardId}/tasks')
  Future<List<TaskModel>> getTasksByBoard(@Path('boardId') String boardId);

  /// 작업 순서 변경 (칸반 보드용)
  @PUT('/tasks/{taskId}/position')
  Future<void> updateTaskPosition(
    @Path('taskId') String taskId,
    @Body() UpdateTaskPositionRequest request,
  );
}

/// TaskRepository 구현 클래스 (개발용)
class TaskRepositoryImpl implements TaskRepository {
  final Dio _dio;
  final String _baseUrl;

  TaskRepositoryImpl(this._dio, {String? baseUrl}) 
      : _baseUrl = baseUrl ?? 'http://$ip';

  @override
  Future<List<TaskModel>> getTasksByProject(String projectId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/projects/$projectId/tasks',
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      final List<dynamic> tasksJson = response.data;
      return tasksJson.map((json) => TaskModel.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('프로젝트를 찾을 수 없습니다.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('프로젝트에 접근할 권한이 없습니다.');
      } else {
        throw Exception('작업 목록을 가져오는 중 오류가 발생했습니다: ${e.message}');
      }
    }
  }

  @override
  Future<List<TaskModel>> getTasksByAssignee(String userId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/tasks/assignee/$userId',
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      final List<dynamic> tasksJson = response.data;
      return tasksJson.map((json) => TaskModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('내 작업 목록을 가져오는 중 오류가 발생했습니다: ${e.message}');
    }
  }

  @override
  Future<TaskModel> getTask(String taskId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/tasks/$taskId',
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      return TaskModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('작업을 찾을 수 없습니다.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('작업에 접근할 권한이 없습니다.');
      } else {
        throw Exception('작업 정보를 가져오는 중 오류가 발생했습니다: ${e.message}');
      }
    }
  }

  @override
  Future<TaskModel> createTask(CreateTaskRequest request) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/tasks',
        data: request.toJson(),
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      return TaskModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final message = e.response?.data['message'] ?? '잘못된 입력값입니다.';
        throw Exception(message);
      } else if (e.response?.statusCode == 403) {
        throw Exception('작업을 생성할 권한이 없습니다.');
      } else {
        throw Exception('작업 생성 중 오류가 발생했습니다: ${e.message}');
      }
    }
  }

  @override
  Future<TaskModel> updateTask(String taskId, UpdateTaskRequest request) async {
    try {
      final response = await _dio.put(
        '$_baseUrl/tasks/$taskId',
        data: request.toJson(),
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      return TaskModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('작업을 찾을 수 없습니다.');
      } else if (e.response?.statusCode == 400) {
        final message = e.response?.data['message'] ?? '잘못된 입력값입니다.';
        throw Exception(message);
      } else if (e.response?.statusCode == 403) {
        throw Exception('작업을 수정할 권한이 없습니다.');
      } else {
        throw Exception('작업 수정 중 오류가 발생했습니다: ${e.message}');
      }
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    try {
      await _dio.delete(
        '$_baseUrl/tasks/$taskId',
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('작업을 찾을 수 없습니다.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('작업을 삭제할 권한이 없습니다.');
      } else {
        throw Exception('작업 삭제 중 오류가 발생했습니다: ${e.message}');
      }
    }
  }

  @override
  Future<TaskComment> addComment(String taskId, CreateCommentRequest request) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/tasks/$taskId/comments',
        data: request.toJson(),
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      return TaskComment.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('작업을 찾을 수 없습니다.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('댓글을 작성할 권한이 없습니다.');
      } else {
        throw Exception('댓글 작성 중 오류가 발생했습니다: ${e.message}');
      }
    }
  }

  @override
  Future<List<TaskComment>> getComments(String taskId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/tasks/$taskId/comments',
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      final List<dynamic> commentsJson = response.data;
      return commentsJson.map((json) => TaskComment.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('댓글을 가져오는 중 오류가 발생했습니다: ${e.message}');
    }
  }

  @override
  Future<List<TaskHistory>> getTaskHistory(String taskId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/tasks/$taskId/history',
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      final List<dynamic> historyJson = response.data;
      return historyJson.map((json) => TaskHistory.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('작업 히스토리를 가져오는 중 오류가 발생했습니다: ${e.message}');
    }
  }

  @override
  Future<List<TaskModel>> getTasksByStatus(String projectId, TaskStatus status) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/projects/$projectId/tasks/status/${status.name}',
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      final List<dynamic> tasksJson = response.data;
      return tasksJson.map((json) => TaskModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('상태별 작업을 가져오는 중 오류가 발생했습니다: ${e.message}');
    }
  }

  @override
  Future<List<TaskModel>> getTasksByPriority(String projectId, TaskPriority priority) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/projects/$projectId/tasks/priority/${priority.name}',
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      final List<dynamic> tasksJson = response.data;
      return tasksJson.map((json) => TaskModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('우선순위별 작업을 가져오는 중 오류가 발생했습니다: ${e.message}');
    }
  }

  @override
  Future<List<TaskModel>> getTasksByDueDate(String fromDate, String toDate) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/tasks/due-date',
        queryParameters: {
          'from': fromDate,
          'to': toDate,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      final List<dynamic> tasksJson = response.data;
      return tasksJson.map((json) => TaskModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('마감일별 작업을 가져오는 중 오류가 발생했습니다: ${e.message}');
    }
  }

  @override
  Future<List<TaskModel>> searchTasks(String query, String? projectId) async {
    try {
      final queryParams = <String, dynamic>{'q': query};
      if (projectId != null) {
        queryParams['projectId'] = projectId;
      }

      final response = await _dio.get(
        '$_baseUrl/tasks/search',
        queryParameters: queryParams,
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      final List<dynamic> tasksJson = response.data;
      return tasksJson.map((json) => TaskModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('작업 검색 중 오류가 발생했습니다: ${e.message}');
    }
  }

  @override
  Future<List<TaskModel>> getTasksByBoard(String boardId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/boards/$boardId/tasks',
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      final List<dynamic> tasksJson = response.data;
      return tasksJson.map((json) => TaskModel.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('보드를 찾을 수 없습니다.');
      } else {
        throw Exception('보드의 작업을 가져오는 중 오류가 발생했습니다: ${e.message}');
      }
    }
  }

  @override
  Future<void> updateTaskPosition(String taskId, UpdateTaskPositionRequest request) async {
    try {
      await _dio.put(
        '$_baseUrl/tasks/$taskId/position',
        data: request.toJson(),
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('작업을 찾을 수 없습니다.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('작업 위치를 변경할 권한이 없습니다.');
      } else {
        throw Exception('작업 위치 변경 중 오류가 발생했습니다: ${e.message}');
      }
    }
  }
}

/// 댓글 생성 요청 모델
class CreateCommentRequest {
  final String content;

  const CreateCommentRequest({
    required this.content,
  });

  Map<String, dynamic> toJson() => {
    'content': content,
  };
}

/// 작업 위치 변경 요청 모델
class UpdateTaskPositionRequest {
  final String? newBoardId;
  final String? newStatus;
  final int position;

  const UpdateTaskPositionRequest({
    this.newBoardId,
    this.newStatus,
    required this.position,
  });

  Map<String, dynamic> toJson() => {
    if (newBoardId != null) 'newBoardId': newBoardId,
    if (newStatus != null) 'newStatus': newStatus,
    'position': position,
  };
}