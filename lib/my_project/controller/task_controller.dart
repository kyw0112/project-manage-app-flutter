import 'package:actual/my_project/model/task_model.dart';
import 'package:actual/my_project/repository/task_repository.dart';
import 'package:get/get.dart';

enum TaskLoadingState { idle, loading, success, error }

class TaskController extends GetxController {
  static TaskController get to => Get.find();
  
  final TaskRepository _taskRepository = Get.find<TaskRepository>();
  
  // Reactive variables
  final RxList<TaskModel> _tasks = <TaskModel>[].obs;
  final RxList<TaskModel> _filteredTasks = <TaskModel>[].obs;
  final Rx<TaskLoadingState> _loadingState = TaskLoadingState.idle.obs;
  final RxString _errorMessage = ''.obs;
  final RxString _searchQuery = ''.obs;
  final Rxn<TaskStatus> _statusFilter = Rxn<TaskStatus>();
  final Rxn<TaskPriority> _priorityFilter = Rxn<TaskPriority>();
  final RxBool _isCreateLoading = false.obs;
  final RxBool _isUpdateLoading = false.obs;
  final RxBool _isDeleteLoading = false.obs;
  
  // Getters
  List<TaskModel> get tasks => _tasks;
  List<TaskModel> get filteredTasks => _filteredTasks;
  TaskLoadingState get loadingState => _loadingState.value;
  String get errorMessage => _errorMessage.value;
  String get searchQuery => _searchQuery.value;
  TaskStatus? get statusFilter => _statusFilter.value;
  TaskPriority? get priorityFilter => _priorityFilter.value;
  bool get isCreateLoading => _isCreateLoading.value;
  bool get isUpdateLoading => _isUpdateLoading.value;
  bool get isDeleteLoading => _isDeleteLoading.value;
  bool get isLoading => _loadingState.value == TaskLoadingState.loading;
  bool get hasError => _loadingState.value == TaskLoadingState.error;
  
  @override
  void onInit() {
    super.onInit();
    _initializeFilters();
  }
  
  /// 필터 초기화 및 검색 쿼리 감시
  void _initializeFilters() {
    // 검색 쿼리 변경 시 자동 필터링
    ever(_searchQuery, (_) => _applyFilters());
    ever(_statusFilter, (_) => _applyFilters());
    ever(_priorityFilter, (_) => _applyFilters());
  }
  
  /// 프로젝트의 모든 작업 로드
  Future<void> loadTasks(String projectId) async {
    try {
      _loadingState.value = TaskLoadingState.loading;
      _errorMessage.value = '';
      
      final tasks = await _taskRepository.getTasksByProject(projectId);
      _tasks.assignAll(tasks);
      _applyFilters();
      
      _loadingState.value = TaskLoadingState.success;
    } catch (e) {
      _loadingState.value = TaskLoadingState.error;
      _errorMessage.value = '작업 로드 중 오류가 발생했습니다: ${e.toString()}';
    }
  }
  
  /// 사용자에게 할당된 작업 로드
  Future<void> loadMyTasks(String userId) async {
    try {
      _loadingState.value = TaskLoadingState.loading;
      _errorMessage.value = '';
      
      final tasks = await _taskRepository.getTasksByAssignee(userId);
      _tasks.assignAll(tasks);
      _applyFilters();
      
      _loadingState.value = TaskLoadingState.success;
    } catch (e) {
      _loadingState.value = TaskLoadingState.error;
      _errorMessage.value = '내 작업 로드 중 오류가 발생했습니다: ${e.toString()}';
    }
  }
  
  /// 특정 작업 로드
  Future<TaskModel?> getTask(String taskId) async {
    try {
      return await _taskRepository.getTask(taskId);
    } catch (e) {
      _errorMessage.value = '작업 조회 중 오류가 발생했습니다: ${e.toString()}';
      return null;
    }
  }
  
  /// 새 작업 생성
  Future<bool> createTask(CreateTaskRequest request) async {
    try {
      _isCreateLoading.value = true;
      _errorMessage.value = '';
      
      // 유효성 검사
      if (request.title.trim().isEmpty) {
        _errorMessage.value = '작업 제목을 입력해주세요.';
        return false;
      }
      
      if (request.description.trim().isEmpty) {
        _errorMessage.value = '작업 설명을 입력해주세요.';
        return false;
      }
      
      final newTask = await _taskRepository.createTask(request);
      _tasks.add(newTask);
      _applyFilters();
      
      return true;
    } catch (e) {
      _errorMessage.value = '작업 생성 중 오류가 발생했습니다: ${e.toString()}';
      return false;
    } finally {
      _isCreateLoading.value = false;
    }
  }
  
  /// 작업 업데이트
  Future<bool> updateTask(String taskId, UpdateTaskRequest request) async {
    try {
      _isUpdateLoading.value = true;
      _errorMessage.value = '';
      
      final updatedTask = await _taskRepository.updateTask(taskId, request);
      final index = _tasks.indexWhere((task) => task.id == taskId);
      
      if (index != -1) {
        _tasks[index] = updatedTask;
        _applyFilters();
      }
      
      return true;
    } catch (e) {
      _errorMessage.value = '작업 업데이트 중 오류가 발생했습니다: ${e.toString()}';
      return false;
    } finally {
      _isUpdateLoading.value = false;
    }
  }
  
  /// 작업 삭제
  Future<bool> deleteTask(String taskId) async {
    try {
      _isDeleteLoading.value = true;
      _errorMessage.value = '';
      
      await _taskRepository.deleteTask(taskId);
      _tasks.removeWhere((task) => task.id == taskId);
      _applyFilters();
      
      return true;
    } catch (e) {
      _errorMessage.value = '작업 삭제 중 오류가 발생했습니다: ${e.toString()}';
      return false;
    } finally {
      _isDeleteLoading.value = false;
    }
  }
  
  /// 작업 상태 변경 (빠른 업데이트)
  Future<bool> changeTaskStatus(String taskId, TaskStatus newStatus) async {
    try {
      final request = UpdateTaskRequest(status: newStatus);
      return await updateTask(taskId, request);
    } catch (e) {
      _errorMessage.value = '작업 상태 변경 중 오류가 발생했습니다: ${e.toString()}';
      return false;
    }
  }
  
  /// 작업 우선순위 변경 (빠른 업데이트)
  Future<bool> changeTaskPriority(String taskId, TaskPriority newPriority) async {
    try {
      final request = UpdateTaskRequest(priority: newPriority);
      return await updateTask(taskId, request);
    } catch (e) {
      _errorMessage.value = '작업 우선순위 변경 중 오류가 발생했습니다: ${e.toString()}';
      return false;
    }
  }
  
  /// 작업 할당자 변경
  Future<bool> assignTask(String taskId, String assigneeId) async {
    try {
      final request = UpdateTaskRequest(assigneeId: assigneeId);
      return await updateTask(taskId, request);
    } catch (e) {
      _errorMessage.value = '작업 할당 중 오류가 발생했습니다: ${e.toString()}';
      return false;
    }
  }
  
  /// 작업 진행률 업데이트
  Future<bool> updateProgress(String taskId, int progress) async {
    try {
      if (progress < 0 || progress > 100) {
        _errorMessage.value = '진행률은 0-100 사이의 값이어야 합니다.';
        return false;
      }
      
      final request = UpdateTaskRequest(progressPercentage: progress);
      return await updateTask(taskId, request);
    } catch (e) {
      _errorMessage.value = '진행률 업데이트 중 오류가 발생했습니다: ${e.toString()}';
      return false;
    }
  }
  
  /// 검색 쿼리 설정
  void setSearchQuery(String query) {
    _searchQuery.value = query;
  }
  
  /// 상태 필터 설정
  void setStatusFilter(TaskStatus? status) {
    _statusFilter.value = status;
  }
  
  /// 우선순위 필터 설정
  void setPriorityFilter(TaskPriority? priority) {
    _priorityFilter.value = priority;
  }
  
  /// 모든 필터 초기화
  void clearFilters() {
    _searchQuery.value = '';
    _statusFilter.value = null;
    _priorityFilter.value = null;
  }
  
  /// 필터 적용
  void _applyFilters() {
    var filtered = _tasks.toList();
    
    // 검색 쿼리 필터
    if (_searchQuery.value.isNotEmpty) {
      final query = _searchQuery.value.toLowerCase();
      filtered = filtered.where((task) =>
          task.title.toLowerCase().contains(query) ||
          task.description.toLowerCase().contains(query) ||
          task.assigneeName.toLowerCase().contains(query)
      ).toList();
    }
    
    // 상태 필터
    if (_statusFilter.value != null) {
      filtered = filtered.where((task) => task.status == _statusFilter.value).toList();
    }
    
    // 우선순위 필터
    if (_priorityFilter.value != null) {
      filtered = filtered.where((task) => task.priority == _priorityFilter.value).toList();
    }
    
    _filteredTasks.assignAll(filtered);
  }
  
  /// 상태별 작업 수 반환
  Map<TaskStatus, int> getTaskCountByStatus() {
    final counts = <TaskStatus, int>{};
    for (final status in TaskStatus.values) {
      counts[status] = _tasks.where((task) => task.status == status).length;
    }
    return counts;
  }
  
  /// 우선순위별 작업 수 반환
  Map<TaskPriority, int> getTaskCountByPriority() {
    final counts = <TaskPriority, int>{};
    for (final priority in TaskPriority.values) {
      counts[priority] = _tasks.where((task) => task.priority == priority).length;
    }
    return counts;
  }
  
  /// 지연된 작업 목록
  List<TaskModel> get overdueTasks =>
      _tasks.where((task) => task.isOverdue).toList();
  
  /// 오늘 마감인 작업 목록
  List<TaskModel> get tasksDueToday {
    final today = DateTime.now();
    return _tasks.where((task) {
      final dueDate = task.dueDate;
      if (dueDate == null) return false;
      return dueDate.year == today.year &&
          dueDate.month == today.month &&
          dueDate.day == today.day;
    }).toList();
  }
  
  /// 내가 담당한 작업 목록
  List<TaskModel> getMyTasks(String userId) =>
      _tasks.where((task) => task.assigneeId == userId).toList();
  
  /// 완료된 작업 목록
  List<TaskModel> get completedTasks =>
      _tasks.where((task) => task.isCompleted).toList();
  
  /// 진행 중인 작업 목록
  List<TaskModel> get inProgressTasks =>
      _tasks.where((task) => task.isInProgress).toList();
  
  /// 에러 메시지 클리어
  void clearError() {
    _errorMessage.value = '';
  }
  
  /// 작업 새로고침
  Future<void> refreshTasks(String projectId) async {
    await loadTasks(projectId);
  }
  
  /// 특정 ID의 작업을 찾아 반환
  TaskModel? findTaskById(String id) {
    try {
      return _tasks.firstWhere((task) => task.id == id);
    } catch (e) {
      return null;
    }
  }
  
  /// 작업 정렬 (우선순위 → 마감일 → 생성일 순)
  void sortTasks() {
    _tasks.sort((a, b) {
      // 1. 우선순위 순
      final priorityComparison = b.priority.value.compareTo(a.priority.value);
      if (priorityComparison != 0) return priorityComparison;
      
      // 2. 마감일 순 (마감일이 없으면 뒤로)
      if (a.dueDate == null && b.dueDate == null) {
        return b.createdAt.compareTo(a.createdAt);
      }
      if (a.dueDate == null) return 1;
      if (b.dueDate == null) return -1;
      
      final dueDateComparison = a.dueDate!.compareTo(b.dueDate!);
      if (dueDateComparison != 0) return dueDateComparison;
      
      // 3. 생성일 순 (최신순)
      return b.createdAt.compareTo(a.createdAt);
    });
    
    _applyFilters();
  }
}