import 'package:actual/my_project/model/task_model.dart';
import 'package:actual/my_project/controller/task_controller.dart';
import 'package:get/get.dart';
import 'package:appflowy_board/appflowy_board.dart';

enum BoardLoadingState { idle, loading, success, error }

class BoardController extends GetxController {
  static BoardController get to => Get.find();
  
  final TaskController _taskController = Get.find<TaskController>();
  
  // AppFlowy Board Controller
  late AppFlowyBoardController boardController;
  late AppFlowyBoardScrollController scrollController;
  
  // Reactive variables
  final Rx<BoardLoadingState> _loadingState = BoardLoadingState.idle.obs;
  final RxString _errorMessage = ''.obs;
  final RxString _currentProjectId = ''.obs;
  final RxList<BoardColumn> _columns = <BoardColumn>[].obs;
  final RxMap<String, List<TaskModel>> _tasksByColumn = <String, List<TaskModel>>{}.obs;
  
  // Getters
  BoardLoadingState get loadingState => _loadingState.value;
  String get errorMessage => _errorMessage.value;
  String get currentProjectId => _currentProjectId.value;
  List<BoardColumn> get columns => _columns;
  Map<String, List<TaskModel>> get tasksByColumn => _tasksByColumn;
  bool get isLoading => _loadingState.value == BoardLoadingState.loading;
  bool get hasError => _loadingState.value == BoardLoadingState.error;
  
  @override
  void onInit() {
    super.onInit();
    _initializeBoardController();
    _initializeDefaultColumns();
  }
  
  /// 보드 컨트롤러 초기화
  void _initializeBoardController() {
    boardController = AppFlowyBoardController(
      onMoveGroup: _onMoveColumn,
      onMoveGroupItem: _onMoveCardWithinColumn,
      onMoveGroupItemToGroup: _onMoveCardBetweenColumns,
    );
    
    scrollController = AppFlowyBoardScrollController();
  }
  
  /// 기본 컬럼 초기화
  void _initializeDefaultColumns() {
    _columns.assignAll([
      BoardColumn(
        id: 'todo',
        title: 'To Do',
        taskStatus: TaskStatus.todo,
        color: '#E3F2FD',
        order: 0,
      ),
      BoardColumn(
        id: 'in_progress',
        title: 'In Progress',
        taskStatus: TaskStatus.inProgress,
        color: '#FFF3E0',
        order: 1,
      ),
      BoardColumn(
        id: 'in_review',
        title: 'In Review',
        taskStatus: TaskStatus.inReview,
        color: '#F3E5F5',
        order: 2,
      ),
      BoardColumn(
        id: 'completed',
        title: 'Completed',
        taskStatus: TaskStatus.completed,
        color: '#E8F5E8',
        order: 3,
      ),
    ]);
  }
  
  /// 프로젝트 보드 로드
  Future<void> loadBoard(String projectId) async {
    try {
      _loadingState.value = BoardLoadingState.loading;
      _errorMessage.value = '';
      _currentProjectId.value = projectId;
      
      // 프로젝트의 모든 작업 로드
      await _taskController.loadTasks(projectId);
      
      // 상태별로 작업 분류
      _categorizeTasksByStatus();
      
      // 보드에 컬럼 및 카드 추가
      _buildBoardFromData();
      
      _loadingState.value = BoardLoadingState.success;
    } catch (e) {
      _loadingState.value = BoardLoadingState.error;
      _errorMessage.value = '보드 로드 중 오류가 발생했습니다: ${e.toString()}';
    }
  }
  
  /// 상태별로 작업 분류
  void _categorizeTasksByStatus() {
    final tasks = _taskController.tasks;
    _tasksByColumn.clear();
    
    for (final column in _columns) {
      _tasksByColumn[column.id] = tasks
          .where((task) => task.status == column.taskStatus)
          .toList();
    }
  }
  
  /// 데이터로부터 보드 구성
  void _buildBoardFromData() {
    // 기존 보드 초기화
    boardController.clear();
    
    for (final column in _columns) {
      final tasks = _tasksByColumn[column.id] ?? [];
      final groupItems = tasks.map((task) => TaskGroupItem(task)).toList();
      
      final groupData = AppFlowyGroupData(
        id: column.id,
        name: column.title,
        items: groupItems,
      );
      
      boardController.addGroup(groupData);
    }
  }
  
  /// 새 작업 추가
  Future<bool> addTask(CreateTaskRequest request, String columnId) async {
    try {
      // TaskController를 통해 작업 생성
      final success = await _taskController.createTask(request);
      
      if (success) {
        // 보드 새로고침
        await refreshBoard();
        return true;
      }
      
      return false;
    } catch (e) {
      _errorMessage.value = '작업 추가 중 오류가 발생했습니다: ${e.toString()}';
      return false;
    }
  }
  
  /// 작업 삭제
  Future<bool> deleteTask(String taskId) async {
    try {
      final success = await _taskController.deleteTask(taskId);
      
      if (success) {
        await refreshBoard();
        return true;
      }
      
      return false;
    } catch (e) {
      _errorMessage.value = '작업 삭제 중 오류가 발생했습니다: ${e.toString()}';
      return false;
    }
  }
  
  /// 컬럼 이동 처리
  void _onMoveColumn(String fromGroupId, int fromIndex, String toGroupId, int toIndex) {
    // 컬럼 순서 변경 로직 (향후 구현)
    print('Move column from $fromIndex to $toIndex');
  }
  
  /// 같은 컬럼 내에서 카드 이동 처리
  void _onMoveCardWithinColumn(String groupId, int fromIndex, int toIndex) {
    // 같은 컬럼 내에서의 순서 변경은 UI에서만 처리
    print('Move card within column $groupId: $fromIndex to $toIndex');
  }
  
  /// 다른 컬럼으로 카드 이동 처리
  void _onMoveCardBetweenColumns(String fromGroupId, int fromIndex, String toGroupId, int toIndex) async {
    try {
      // 이동할 작업 찾기
      final fromTasks = _tasksByColumn[fromGroupId] ?? [];
      if (fromIndex >= fromTasks.length) return;
      
      final task = fromTasks[fromIndex];
      final targetColumn = _columns.firstWhere((col) => col.id == toGroupId);
      
      // 작업 상태 변경
      final success = await _taskController.changeTaskStatus(task.id, targetColumn.taskStatus);
      
      if (success) {
        // 로컬 상태 업데이트
        _categorizeTasksByStatus();
        print('Task ${task.title} moved from $fromGroupId to $toGroupId');
      } else {
        // 실패 시 보드 새로고침하여 원상복구
        await refreshBoard();
      }
    } catch (e) {
      _errorMessage.value = '작업 이동 중 오류가 발생했습니다: ${e.toString()}';
      await refreshBoard();
    }
  }
  
  /// 새 컬럼 추가
  Future<bool> addColumn(String title, TaskStatus status, String color) async {
    try {
      final newColumn = BoardColumn(
        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        taskStatus: status,
        color: color,
        order: _columns.length,
      );
      
      _columns.add(newColumn);
      _tasksByColumn[newColumn.id] = [];
      
      // 보드에 컬럼 추가
      final groupData = AppFlowyGroupData(
        id: newColumn.id,
        name: newColumn.title,
        items: [],
      );
      
      boardController.addGroup(groupData);
      return true;
    } catch (e) {
      _errorMessage.value = '컬럼 추가 중 오류가 발생했습니다: ${e.toString()}';
      return false;
    }
  }
  
  /// 컬럼 삭제
  Future<bool> removeColumn(String columnId) async {
    try {
      // 기본 컬럼은 삭제 불가
      final defaultColumnIds = ['todo', 'in_progress', 'in_review', 'completed'];
      if (defaultColumnIds.contains(columnId)) {
        _errorMessage.value = '기본 컬럼은 삭제할 수 없습니다.';
        return false;
      }
      
      // 컬럼에 작업이 있는지 확인
      final tasks = _tasksByColumn[columnId] ?? [];
      if (tasks.isNotEmpty) {
        _errorMessage.value = '컬럼에 작업이 있어 삭제할 수 없습니다. 먼저 작업을 이동해주세요.';
        return false;
      }
      
      _columns.removeWhere((col) => col.id == columnId);
      _tasksByColumn.remove(columnId);
      boardController.removeGroup(columnId);
      
      return true;
    } catch (e) {
      _errorMessage.value = '컬럼 삭제 중 오류가 발생했습니다: ${e.toString()}';
      return false;
    }
  }
  
  /// 컬럼 제목 변경
  Future<bool> updateColumnTitle(String columnId, String newTitle) async {
    try {
      final columnIndex = _columns.indexWhere((col) => col.id == columnId);
      if (columnIndex == -1) return false;
      
      final updatedColumn = _columns[columnIndex].copyWith(title: newTitle);
      _columns[columnIndex] = updatedColumn;
      
      // 보드 컨트롤러 업데이트
      boardController.getGroupController(columnId)?.updateGroupName(newTitle);
      
      return true;
    } catch (e) {
      _errorMessage.value = '컬럼 제목 변경 중 오류가 발생했습니다: ${e.toString()}';
      return false;
    }
  }
  
  /// 보드 새로고침
  Future<void> refreshBoard() async {
    if (_currentProjectId.value.isNotEmpty) {
      await loadBoard(_currentProjectId.value);
    }
  }
  
  /// 특정 컬럼으로 스크롤
  void scrollToColumn(String columnId) {
    scrollController.scrollToBottom(columnId);
  }
  
  /// 에러 메시지 클리어
  void clearError() {
    _errorMessage.value = '';
  }
  
  /// 특정 컬럼의 작업 수 반환
  int getTaskCountInColumn(String columnId) {
    return _tasksByColumn[columnId]?.length ?? 0;
  }
  
  /// 전체 작업 수 반환
  int get totalTaskCount {
    return _tasksByColumn.values
        .fold(0, (sum, tasks) => sum + tasks.length);
  }
  
  /// 완료된 작업 수 반환
  int get completedTaskCount {
    return _tasksByColumn['completed']?.length ?? 0;
  }
  
  /// 진행률 계산
  double get overallProgress {
    final total = totalTaskCount;
    if (total == 0) return 0.0;
    return completedTaskCount / total;
  }
}

/// 보드 컬럼 모델
class BoardColumn {
  final String id;
  final String title;
  final TaskStatus taskStatus;
  final String color;
  final int order;
  
  BoardColumn({
    required this.id,
    required this.title,
    required this.taskStatus,
    required this.color,
    required this.order,
  });
  
  BoardColumn copyWith({
    String? id,
    String? title,
    TaskStatus? taskStatus,
    String? color,
    int? order,
  }) {
    return BoardColumn(
      id: id ?? this.id,
      title: title ?? this.title,
      taskStatus: taskStatus ?? this.taskStatus,
      color: color ?? this.color,
      order: order ?? this.order,
    );
  }
}

/// AppFlowy Board용 작업 아이템
class TaskGroupItem extends AppFlowyGroupItem {
  final TaskModel task;
  
  TaskGroupItem(this.task);
  
  @override
  String get id => task.id;
}