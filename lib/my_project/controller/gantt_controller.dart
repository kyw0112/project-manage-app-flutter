import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../model/gantt_model.dart';
import '../model/task_model.dart';
import '../controller/task_controller.dart';
import '../../common/logger/app_logger.dart';

class GanttController extends GetxController {
  final TaskController _taskController = Get.find<TaskController>();

  // Observable variables
  final RxList<GanttItem> ganttItems = <GanttItem>[].obs;
  final RxList<GanttMilestone> milestones = <GanttMilestone>[].obs;
  final RxList<GanttDependency> dependencies = <GanttDependency>[].obs;
  final Rx<GanttViewSettings> viewSettings = GanttViewSettings(
    startDate: DateTime.now().subtract(const Duration(days: 30)),
    endDate: DateTime.now().add(const Duration(days: 90)),
  ).obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // Filter variables
  final RxList<TaskPriority> selectedPriorities = <TaskPriority>[].obs;
  final RxList<String> selectedAssignees = <String>[].obs;
  final RxBool showCompletedTasks = true.obs;
  final RxString searchQuery = ''.obs;

  // View state
  final ScrollController horizontalScrollController = ScrollController();
  final ScrollController verticalScrollController = ScrollController();
  final RxString selectedItemId = ''.obs;
  final RxBool showCriticalPath = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeFilters();
    _setupListeners();
    loadGanttData();
  }

  @override
  void onClose() {
    horizontalScrollController.dispose();
    verticalScrollController.dispose();
    super.onClose();
  }

  void _initializeFilters() {
    selectedPriorities.addAll(TaskPriority.values);
  }

  void _setupListeners() {
    // 작업 목록 변경 시 간트 차트 업데이트
    ever(_taskController.tasks, (_) => _updateGanttFromTasks());
    
    // 필터 변경 시 업데이트
    ever(selectedPriorities, (_) => _applyFilters());
    ever(selectedAssignees, (_) => _applyFilters());
    ever(showCompletedTasks, (_) => _applyFilters());
    ever(searchQuery, (_) => _applyFilters());
  }

  /// 간트 차트 데이터 로드
  Future<void> loadGanttData() async {
    try {
      isLoading.value = true;
      error.value = '';

      // 작업 데이터로부터 간트 아이템 생성
      await _updateGanttFromTasks();
      
      // 마일스톤 로드
      await _loadMilestones();
      
      // 의존성 관계 로드
      await _loadDependencies();

      AppLogger.instance.info('Gantt data loaded successfully');
    } catch (e) {
      error.value = 'Failed to load gantt data: $e';
      AppLogger.instance.error('Failed to load gantt data', e);
    } finally {
      isLoading.value = false;
    }
  }

  /// 작업 데이터로부터 간트 아이템 업데이트
  Future<void> _updateGanttFromTasks() async {
    final tasks = _taskController.tasks;
    
    final items = tasks.map((task) => GanttItem.fromTask(task)).toList();
    
    // 프로젝트별로 그룹화하고 계층 구조 생성
    _buildHierarchy(items);
    
    ganttItems.assignAll(items);
    _applyFilters();
  }

  /// 계층 구조 생성
  void _buildHierarchy(List<GanttItem> items) {
    // TODO: 프로젝트 구조에 따른 계층 구조 생성
    // 현재는 단순한 플랫 구조로 처리
    for (int i = 0; i < items.length; i++) {
      items[i] = items[i].copyWith(level: 0);
    }
  }

  /// 마일스톤 로드
  Future<void> _loadMilestones() async {
    // Mock 마일스톤 데이터
    final mockMilestones = [
      GanttMilestone(
        id: 'milestone_1',
        title: '프로젝트 시작',
        description: '프로젝트 킥오프',
        date: DateTime.now().add(const Duration(days: 7)),
        type: MilestoneType.major,
        color: Colors.green,
      ),
      GanttMilestone(
        id: 'milestone_2',
        title: '1차 리뷰',
        description: '중간 검토',
        date: DateTime.now().add(const Duration(days: 30)),
        type: MilestoneType.review,
        color: Colors.orange,
      ),
      GanttMilestone(
        id: 'milestone_3',
        title: '프로젝트 완료',
        description: '최종 완료',
        date: DateTime.now().add(const Duration(days: 60)),
        type: MilestoneType.deadline,
        color: Colors.red,
      ),
    ];
    
    milestones.assignAll(mockMilestones);
  }

  /// 의존성 관계 로드
  Future<void> _loadDependencies() async {
    // TODO: 실제 의존성 데이터 로드
    dependencies.clear();
  }

  /// 필터 적용
  void _applyFilters() {
    var filtered = ganttItems.where((item) {
      // 우선순위 필터
      if (!selectedPriorities.contains(item.priority)) return false;
      
      // 담당자 필터
      if (selectedAssignees.isNotEmpty && 
          item.assigneeId != null && 
          !selectedAssignees.contains(item.assigneeId)) return false;
      
      // 완료된 작업 필터
      if (!showCompletedTasks.value && item.progress >= 1.0) return false;
      
      // 검색 필터
      if (searchQuery.value.isNotEmpty) {
        final query = searchQuery.value.toLowerCase();
        if (!item.title.toLowerCase().contains(query) &&
            !item.description.toLowerCase().contains(query)) {
          return false;
        }
      }
      
      return true;
    }).toList();
    
    // 정렬 (시작일 기준)
    filtered.sort((a, b) => a.startDate.compareTo(b.startDate));
    
    ganttItems.assignAll(filtered);
  }

  /// 뷰 설정 업데이트
  void updateViewSettings(GanttViewSettings newSettings) {
    viewSettings.value = newSettings;
    AppLogger.instance.info('View settings updated');
  }

  /// 시간 스케일 변경
  void changeTimeScale(GanttTimeScale timeScale) {
    final settings = viewSettings.value.copyWith(timeScale: timeScale);
    updateViewSettings(settings);
  }

  /// 날짜 범위 변경
  void changeDateRange(DateTime startDate, DateTime endDate) {
    final settings = viewSettings.value.copyWith(
      startDate: startDate,
      endDate: endDate,
    );
    updateViewSettings(settings);
  }

  /// 줌 인
  void zoomIn() {
    final currentWidth = viewSettings.value.dayWidth;
    final newWidth = (currentWidth * 1.2).clamp(10.0, 100.0);
    
    final settings = viewSettings.value.copyWith(dayWidth: newWidth);
    updateViewSettings(settings);
  }

  /// 줌 아웃
  void zoomOut() {
    final currentWidth = viewSettings.value.dayWidth;
    final newWidth = (currentWidth * 0.8).clamp(10.0, 100.0);
    
    final settings = viewSettings.value.copyWith(dayWidth: newWidth);
    updateViewSettings(settings);
  }

  /// 오늘로 스크롤
  void scrollToToday() {
    final today = DateTime.now();
    final x = viewSettings.value.getXPosition(today);
    
    horizontalScrollController.animateTo(
      x - 200, // 화면 중앙에 오도록 조정
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  /// 특정 작업으로 스크롤
  void scrollToItem(String itemId) {
    final index = ganttItems.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      final item = ganttItems[index];
      
      // 수직 스크롤
      final y = index * viewSettings.value.rowHeight;
      verticalScrollController.animateTo(
        y,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      
      // 수평 스크롤
      final x = viewSettings.value.getXPosition(item.startDate);
      horizontalScrollController.animateTo(
        x - 100,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      
      // 선택 표시
      selectedItemId.value = itemId;
    }
  }

  /// 작업 항목 선택
  void selectItem(String itemId) {
    selectedItemId.value = itemId;
  }

  /// 작업 항목 편집
  void editItem(String itemId) {
    final item = ganttItems.firstWhereOrNull((item) => item.id == itemId);
    if (item != null) {
      // TODO: 작업 편집 다이얼로그 표시
      AppLogger.instance.info('Edit item: ${item.title}');
    }
  }

  /// 마일스톤 추가
  Future<void> addMilestone(GanttMilestone milestone) async {
    try {
      milestones.add(milestone);
      AppLogger.instance.info('Milestone added: ${milestone.title}');
    } catch (e) {
      AppLogger.instance.error('Failed to add milestone', e);
      Get.snackbar('오류', '마일스톤 추가에 실패했습니다.');
    }
  }

  /// 마일스톤 삭제
  Future<void> deleteMilestone(String milestoneId) async {
    try {
      milestones.removeWhere((m) => m.id == milestoneId);
      AppLogger.instance.info('Milestone deleted: $milestoneId');
    } catch (e) {
      AppLogger.instance.error('Failed to delete milestone', e);
      Get.snackbar('오류', '마일스톤 삭제에 실패했습니다.');
    }
  }

  /// 의존성 관계 추가
  Future<void> addDependency(GanttDependency dependency) async {
    try {
      if (!dependencies.contains(dependency)) {
        dependencies.add(dependency);
        AppLogger.instance.info('Dependency added: ${dependency.fromTaskId} -> ${dependency.toTaskId}');
      }
    } catch (e) {
      AppLogger.instance.error('Failed to add dependency', e);
      Get.snackbar('오류', '의존성 추가에 실패했습니다.');
    }
  }

  /// 의존성 관계 삭제
  Future<void> removeDependency(String fromTaskId, String toTaskId) async {
    try {
      dependencies.removeWhere((d) => 
        d.fromTaskId == fromTaskId && d.toTaskId == toTaskId
      );
      AppLogger.instance.info('Dependency removed: $fromTaskId -> $toTaskId');
    } catch (e) {
      AppLogger.instance.error('Failed to remove dependency', e);
      Get.snackbar('오류', '의존성 삭제에 실패했습니다.');
    }
  }

  /// 필터 토글
  void togglePriority(TaskPriority priority) {
    if (selectedPriorities.contains(priority)) {
      selectedPriorities.remove(priority);
    } else {
      selectedPriorities.add(priority);
    }
  }

  void toggleAssignee(String assigneeId) {
    if (selectedAssignees.contains(assigneeId)) {
      selectedAssignees.remove(assigneeId);
    } else {
      selectedAssignees.add(assigneeId);
    }
  }

  void toggleCompletedTasks() {
    showCompletedTasks.value = !showCompletedTasks.value;
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  void clearFilters() {
    selectedPriorities.assignAll(TaskPriority.values);
    selectedAssignees.clear();
    showCompletedTasks.value = true;
    searchQuery.value = '';
  }

  /// 통계 정보
  int get totalItems => ganttItems.length;
  int get completedItems => ganttItems.where((item) => item.progress >= 1.0).length;
  int get inProgressItems => ganttItems.where((item) => item.progress > 0 && item.progress < 1.0).length;
  int get notStartedItems => ganttItems.where((item) => item.progress == 0).length;
  int get delayedItems => ganttItems.where((item) => item.isDelayed).length;

  double get overallProgress {
    if (ganttItems.isEmpty) return 0.0;
    final totalProgress = ganttItems.fold<double>(0.0, (sum, item) => sum + item.progress);
    return totalProgress / ganttItems.length;
  }

  /// 크리티컬 패스 표시 토글
  void toggleCriticalPath() {
    showCriticalPath.value = !showCriticalPath.value;
    final settings = viewSettings.value.copyWith(showCriticalPath: showCriticalPath.value);
    updateViewSettings(settings);
  }

  /// 현재 날짜 기준으로 활성 작업 목록
  List<GanttItem> get activeItems {
    return ganttItems.where((item) => item.isActiveToday).toList();
  }

  /// 지연된 작업 목록
  List<GanttItem> get delayedItemsList {
    return ganttItems.where((item) => item.isDelayed).toList();
  }
}