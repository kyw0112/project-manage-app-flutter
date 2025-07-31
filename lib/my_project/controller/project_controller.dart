import 'package:actual/my_project/model/project_model.dart';
import 'package:actual/my_project/repository/project_repository.dart';
import 'package:get/get.dart';

enum ProjectLoadingState { idle, loading, success, error }

class ProjectController extends GetxController {
  static ProjectController get to => Get.find();
  
  final ProjectRepository _projectRepository = Get.find<ProjectRepository>();
  
  // Reactive variables
  final RxList<ProjectModel> _projects = <ProjectModel>[].obs;
  final RxList<ProjectModel> _filteredProjects = <ProjectModel>[].obs;
  final Rxn<ProjectModel> _currentProject = Rxn<ProjectModel>();
  final Rx<ProjectLoadingState> _loadingState = ProjectLoadingState.idle.obs;
  final RxString _errorMessage = ''.obs;
  final RxString _searchQuery = ''.obs;
  final Rxn<ProjectStatus> _statusFilter = Rxn<ProjectStatus>();
  final Rxn<ProjectPriority> _priorityFilter = Rxn<ProjectPriority>();
  final RxBool _showArchived = false.obs;
  final RxBool _isCreateLoading = false.obs;
  final RxBool _isUpdateLoading = false.obs;
  final RxBool _isDeleteLoading = false.obs;
  
  // Getters
  List<ProjectModel> get projects => _projects;
  List<ProjectModel> get filteredProjects => _filteredProjects;
  ProjectModel? get currentProject => _currentProject.value;
  ProjectLoadingState get loadingState => _loadingState.value;
  String get errorMessage => _errorMessage.value;
  String get searchQuery => _searchQuery.value;
  ProjectStatus? get statusFilter => _statusFilter.value;
  ProjectPriority? get priorityFilter => _priorityFilter.value;
  bool get showArchived => _showArchived.value;
  bool get isCreateLoading => _isCreateLoading.value;
  bool get isUpdateLoading => _isUpdateLoading.value;
  bool get isDeleteLoading => _isDeleteLoading.value;
  bool get isLoading => _loadingState.value == ProjectLoadingState.loading;
  bool get hasError => _loadingState.value == ProjectLoadingState.error;
  
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
    ever(_showArchived, (_) => _applyFilters());
  }
  
  /// 모든 프로젝트 로드
  Future<void> loadProjects() async {
    try {
      _loadingState.value = ProjectLoadingState.loading;
      _errorMessage.value = '';
      
      final projects = await _projectRepository.getProjects();
      _projects.assignAll(projects);
      _applyFilters();
      
      _loadingState.value = ProjectLoadingState.success;
    } catch (e) {
      _loadingState.value = ProjectLoadingState.error;
      _errorMessage.value = '프로젝트 로드 중 오류가 발생했습니다: ${e.toString()}';
    }
  }
  
  /// 소유한 프로젝트 로드
  Future<void> loadOwnedProjects() async {
    try {
      _loadingState.value = ProjectLoadingState.loading;
      _errorMessage.value = '';
      
      final projects = await _projectRepository.getOwnedProjects();
      _projects.assignAll(projects);
      _applyFilters();
      
      _loadingState.value = ProjectLoadingState.success;
    } catch (e) {
      _loadingState.value = ProjectLoadingState.error;
      _errorMessage.value = '내 프로젝트 로드 중 오류가 발생했습니다: ${e.toString()}';
    }
  }
  
  /// 참여한 프로젝트 로드
  Future<void> loadJoinedProjects() async {
    try {
      _loadingState.value = ProjectLoadingState.loading;
      _errorMessage.value = '';
      
      final projects = await _projectRepository.getJoinedProjects();
      _projects.assignAll(projects);
      _applyFilters();
      
      _loadingState.value = ProjectLoadingState.success;
    } catch (e) {
      _loadingState.value = ProjectLoadingState.error;
      _errorMessage.value = '참여 프로젝트 로드 중 오류가 발생했습니다: ${e.toString()}';
    }
  }
  
  /// 특정 프로젝트 로드
  Future<ProjectModel?> getProject(String projectId) async {
    try {
      final project = await _projectRepository.getProject(projectId);
      _currentProject.value = project;
      return project;
    } catch (e) {
      _errorMessage.value = '프로젝트 조회 중 오류가 발생했습니다: ${e.toString()}';
      return null;
    }
  }
  
  /// 현재 프로젝트 설정
  void setCurrentProject(ProjectModel project) {
    _currentProject.value = project;
  }
  
  /// 새 프로젝트 생성
  Future<bool> createProject(CreateProjectRequest request) async {
    try {
      _isCreateLoading.value = true;
      _errorMessage.value = '';
      
      // 유효성 검사
      if (request.name.trim().isEmpty) {
        _errorMessage.value = '프로젝트 이름을 입력해주세요.';
        return false;
      }
      
      if (request.description.trim().isEmpty) {
        _errorMessage.value = '프로젝트 설명을 입력해주세요.';
        return false;
      }
      
      final newProject = await _projectRepository.createProject(request);
      _projects.add(newProject);
      _applyFilters();
      
      return true;
    } catch (e) {
      _errorMessage.value = '프로젝트 생성 중 오류가 발생했습니다: ${e.toString()}';
      return false;
    } finally {
      _isCreateLoading.value = false;
    }
  }
  
  /// 프로젝트 업데이트
  Future<bool> updateProject(String projectId, UpdateProjectRequest request) async {
    try {
      _isUpdateLoading.value = true;
      _errorMessage.value = '';
      
      final updatedProject = await _projectRepository.updateProject(projectId, request);
      final index = _projects.indexWhere((project) => project.id == projectId);
      
      if (index != -1) {
        _projects[index] = updatedProject;
        _applyFilters();
      }
      
      // 현재 프로젝트 업데이트
      if (_currentProject.value?.id == projectId) {
        _currentProject.value = updatedProject;
      }
      
      return true;
    } catch (e) {
      _errorMessage.value = '프로젝트 업데이트 중 오류가 발생했습니다: ${e.toString()}';
      return false;
    } finally {
      _isUpdateLoading.value = false;
    }
  }
  
  /// 프로젝트 삭제
  Future<bool> deleteProject(String projectId) async {
    try {
      _isDeleteLoading.value = true;
      _errorMessage.value = '';
      
      await _projectRepository.deleteProject(projectId);
      _projects.removeWhere((project) => project.id == projectId);
      _applyFilters();
      
      // 현재 프로젝트가 삭제된 경우 초기화
      if (_currentProject.value?.id == projectId) {
        _currentProject.value = null;
      }
      
      return true;
    } catch (e) {
      _errorMessage.value = '프로젝트 삭제 중 오류가 발생했습니다: ${e.toString()}';
      return false;
    } finally {
      _isDeleteLoading.value = false;
    }
  }
  
  /// 프로젝트 상태 변경 (빠른 업데이트)
  Future<bool> changeProjectStatus(String projectId, ProjectStatus newStatus) async {
    try {
      final request = UpdateProjectRequest(status: newStatus);
      return await updateProject(projectId, request);
    } catch (e) {
      _errorMessage.value = '프로젝트 상태 변경 중 오류가 발생했습니다: ${e.toString()}';
      return false;
    }
  }
  
  /// 프로젝트 우선순위 변경 (빠른 업데이트)
  Future<bool> changeProjectPriority(String projectId, ProjectPriority newPriority) async {
    try {
      final request = UpdateProjectRequest(priority: newPriority);
      return await updateProject(projectId, request);
    } catch (e) {
      _errorMessage.value = '프로젝트 우선순위 변경 중 오류가 발생했습니다: ${e.toString()}';
      return false;
    }
  }
  
  /// 프로젝트 진행률 업데이트
  Future<bool> updateProgress(String projectId, int progress) async {
    try {
      if (progress < 0 || progress > 100) {
        _errorMessage.value = '진행률은 0-100 사이의 값이어야 합니다.';
        return false;
      }
      
      final request = UpdateProjectRequest(progressPercentage: progress);
      return await updateProject(projectId, request);
    } catch (e) {
      _errorMessage.value = '진행률 업데이트 중 오류가 발생했습니다: ${e.toString()}';
      return false;
    }
  }
  
  /// 프로젝트 아카이브
  Future<bool> archiveProject(String projectId) async {
    try {
      final archivedProject = await _projectRepository.archiveProject(projectId);
      final index = _projects.indexWhere((project) => project.id == projectId);
      
      if (index != -1) {
        _projects[index] = archivedProject;
        _applyFilters();
      }
      
      return true;
    } catch (e) {
      _errorMessage.value = '프로젝트 아카이브 중 오류가 발생했습니다: ${e.toString()}';
      return false;
    }
  }
  
  /// 프로젝트 아카이브 해제
  Future<bool> unarchiveProject(String projectId) async {
    try {
      final unarchivedProject = await _projectRepository.unarchiveProject(projectId);
      final index = _projects.indexWhere((project) => project.id == projectId);
      
      if (index != -1) {
        _projects[index] = unarchivedProject;
        _applyFilters();
      }
      
      return true;
    } catch (e) {
      _errorMessage.value = '프로젝트 아카이브 해제 중 오류가 발생했습니다: ${e.toString()}';
      return false;
    }
  }
  
  /// 프로젝트 복제
  Future<bool> duplicateProject(String projectId, DuplicateProjectRequest request) async {
    try {
      final duplicatedProject = await _projectRepository.duplicateProject(projectId, request);
      _projects.add(duplicatedProject);
      _applyFilters();
      
      return true;
    } catch (e) {
      _errorMessage.value = '프로젝트 복제 중 오류가 발생했습니다: ${e.toString()}';
      return false;
    }
  }
  
  /// 프로젝트 멤버 조회
  Future<List<ProjectMember>?> getProjectMembers(String projectId) async {
    try {
      return await _projectRepository.getProjectMembers(projectId);
    } catch (e) {
      _errorMessage.value = '프로젝트 멤버 조회 중 오류가 발생했습니다: ${e.toString()}';
      return null;
    }
  }
  
  /// 멤버 초대
  Future<bool> inviteMember(String projectId, InviteMemberRequest request) async {
    try {
      await _projectRepository.inviteMember(projectId, request);
      return true;
    } catch (e) {
      _errorMessage.value = '멤버 초대 중 오류가 발생했습니다: ${e.toString()}';
      return false;
    }
  }
  
  /// 멤버 제거
  Future<bool> removeMember(String projectId, String userId) async {
    try {
      await _projectRepository.removeMember(projectId, userId);
      return true;
    } catch (e) {
      _errorMessage.value = '멤버 제거 중 오류가 발생했습니다: ${e.toString()}';
      return false;
    }
  }
  
  /// 프로젝트 통계 조회
  Future<ProjectStats?> getProjectStats(String projectId) async {
    try {
      return await _projectRepository.getProjectStats(projectId);
    } catch (e) {
      _errorMessage.value = '프로젝트 통계 조회 중 오류가 발생했습니다: ${e.toString()}';
      return null;
    }
  }
  
  /// 공개 프로젝트 검색
  Future<List<ProjectModel>?> searchPublicProjects(String? query, List<String>? tags) async {
    try {
      return await _projectRepository.getPublicProjects(query, tags);
    } catch (e) {
      _errorMessage.value = '공개 프로젝트 검색 중 오류가 발생했습니다: ${e.toString()}';
      return null;
    }
  }
  
  /// 검색 쿼리 설정
  void setSearchQuery(String query) {
    _searchQuery.value = query;
  }
  
  /// 상태 필터 설정
  void setStatusFilter(ProjectStatus? status) {
    _statusFilter.value = status;
  }
  
  /// 우선순위 필터 설정
  void setPriorityFilter(ProjectPriority? priority) {
    _priorityFilter.value = priority;
  }
  
  /// 아카이브 표시 토글
  void toggleShowArchived() {
    _showArchived.value = !_showArchived.value;
  }
  
  /// 모든 필터 초기화
  void clearFilters() {
    _searchQuery.value = '';
    _statusFilter.value = null;
    _priorityFilter.value = null;
    _showArchived.value = false;
  }
  
  /// 필터 적용
  void _applyFilters() {
    var filtered = _projects.toList();
    
    // 아카이브 필터
    if (!_showArchived.value) {
      filtered = filtered.where((project) => !project.isArchived).toList();
    }
    
    // 검색 쿼리 필터
    if (_searchQuery.value.isNotEmpty) {
      final query = _searchQuery.value.toLowerCase();
      filtered = filtered.where((project) =>
          project.name.toLowerCase().contains(query) ||
          project.description.toLowerCase().contains(query) ||
          project.ownerName.toLowerCase().contains(query) ||
          project.tags.any((tag) => tag.toLowerCase().contains(query))
      ).toList();
    }
    
    // 상태 필터
    if (_statusFilter.value != null) {
      filtered = filtered.where((project) => project.status == _statusFilter.value).toList();
    }
    
    // 우선순위 필터
    if (_priorityFilter.value != null) {
      filtered = filtered.where((project) => project.priority == _priorityFilter.value).toList();
    }
    
    _filteredProjects.assignAll(filtered);
  }
  
  /// 상태별 프로젝트 수 반환
  Map<ProjectStatus, int> getProjectCountByStatus() {
    final counts = <ProjectStatus, int>{};
    for (final status in ProjectStatus.values) {
      counts[status] = _projects.where((project) => project.status == status).length;
    }
    return counts;
  }
  
  /// 우선순위별 프로젝트 수 반환
  Map<ProjectPriority, int> getProjectCountByPriority() {
    final counts = <ProjectPriority, int>{};
    for (final priority in ProjectPriority.values) {
      counts[priority] = _projects.where((project) => project.priority == priority).length;
    }
    return counts;
  }
  
  /// 지연된 프로젝트 목록
  List<ProjectModel> get overdueProjects =>
      _projects.where((project) => project.isOverdue).toList();
  
  /// 오늘 마감인 프로젝트 목록
  List<ProjectModel> get projectsDueToday {
    final today = DateTime.now();
    return _projects.where((project) {
      final dueDate = project.dueDate;
      if (dueDate == null) return false;
      return dueDate.year == today.year &&
          dueDate.month == today.month &&
          dueDate.day == today.day;
    }).toList();
  }
  
  /// 내가 소유한 프로젝트 목록
  List<ProjectModel> getMyProjects(String userId) =>
      _projects.where((project) => project.ownerId == userId).toList();
  
  /// 완료된 프로젝트 목록
  List<ProjectModel> get completedProjects =>
      _projects.where((project) => project.isCompleted).toList();
  
  /// 진행 중인 프로젝트 목록
  List<ProjectModel> get activeProjects =>
      _projects.where((project) => project.isInProgress).toList();
  
  /// 아카이브된 프로젝트 목록
  List<ProjectModel> get archivedProjects =>
      _projects.where((project) => project.isArchived).toList();
  
  /// 에러 메시지 클리어
  void clearError() {
    _errorMessage.value = '';
  }
  
  /// 프로젝트 새로고침
  Future<void> refreshProjects() async {
    await loadProjects();
  }
  
  /// 특정 ID의 프로젝트를 찾아 반환
  ProjectModel? findProjectById(String id) {
    try {
      return _projects.firstWhere((project) => project.id == id);
    } catch (e) {
      return null;
    }
  }
  
  /// 프로젝트 정렬 (우선순위 → 마감일 → 생성일 순)
  void sortProjects() {
    _projects.sort((a, b) {
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
  
  /// 특정 사용자가 멤버인지 확인
  bool isProjectMember(String projectId, String userId) {
    final project = findProjectById(projectId);
    if (project == null) return false;
    return project.isMember(userId);
  }
  
  /// 특정 사용자가 프로젝트 관리자인지 확인
  bool isProjectAdmin(String projectId, String userId) {
    final project = findProjectById(projectId);
    if (project == null) return false;
    return project.isAdmin(userId);
  }
  
  /// 특정 권한을 가지고 있는지 확인
  bool hasProjectPermission(String projectId, String userId, ProjectPermission permission) {
    final project = findProjectById(projectId);
    if (project == null) return false;
    return project.hasPermission(userId, permission);
  }
}