import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:appflowy_board/appflowy_board.dart';
import 'package:actual/my_project/controller/board_controller.dart';
import 'package:actual/my_project/model/board_card_model.dart';
import 'package:actual/my_project/model/task_model.dart';
import 'widgets/board_card_widget.dart';
import 'widgets/add_task_dialog.dart';
import 'widgets/task_detail_dialog.dart';

class KanbanBoardScreen extends StatefulWidget {
  final String projectId;
  
  const KanbanBoardScreen({
    Key? key,
    required this.projectId,
  }) : super(key: key);

  @override
  State<KanbanBoardScreen> createState() => _KanbanBoardScreenState();
}

class _KanbanBoardScreenState extends State<KanbanBoardScreen> {
  late BoardController boardController;

  @override
  void initState() {
    super.initState();
    boardController = Get.put(BoardController());
    _loadBoard();
  }

  Future<void> _loadBoard() async {
    await boardController.loadBoard(widget.projectId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('프로젝트 보드'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBoard,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddTaskDialog(context),
          ),
        ],
      ),
      body: Obx(() {
        if (boardController.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        if (boardController.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red[300],
                ),
                const SizedBox(height: 16),
                Text(
                  boardController.errorMessage,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadBoard,
                  child: const Text('다시 시도'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            _buildProgressHeader(),
            Expanded(
              child: AppFlowyBoard(
                controller: boardController.boardController,
                cardBuilder: _buildCard,
                boardScrollController: boardController.scrollController,
                footerBuilder: _buildColumnFooter,
                headerBuilder: _buildColumnHeader,
                groupConstraints: const BoxConstraints.tightFor(width: 280),
                config: AppFlowyBoardConfig(
                  groupBackgroundColor: Colors.grey[100]!,
                  stretchGroupHeight: false,
                  groupMargin: const EdgeInsets.symmetric(horizontal: 4),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  /// 진행률 헤더 위젯
  Widget _buildProgressHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Obx(() {
        final progress = boardController.overallProgress;
        final completed = boardController.completedTaskCount;
        final total = boardController.totalTaskCount;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '전체 진행률',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$completed / $total 완료',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 0.8 ? Colors.green : 
                progress >= 0.5 ? Colors.blue : Colors.orange,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${(progress * 100).toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        );
      }),
    );
  }

  /// 카드 빌더
  Widget _buildCard(BuildContext context, AppFlowyGroupData group, AppFlowyGroupItem item) {
    if (item is TaskGroupItem) {
      final cardModel = BoardCardModel.fromTask(item.task);
      
      return AppFlowyGroupCard(
        key: ValueKey(item.id),
        child: BoardCardWidget(
          card: cardModel,
          onTap: () => _showTaskDetail(context, item.task),
          onDelete: () => _deleteTask(item.task.id),
        ),
      );
    }
    
    return const SizedBox.shrink();
  }

  /// 컬럼 헤더 빌더
  Widget _buildColumnHeader(BuildContext context, AppFlowyGroupData columnData) {
    final column = boardController.columns.firstWhere(
      (col) => col.id == columnData.id,
      orElse: () => boardController.columns.first,
    );
    
    final taskCount = boardController.getTaskCountInColumn(columnData.id);
    
    return AppFlowyGroupHeader(
      icon: Icon(
        _getColumnIcon(column.taskStatus),
        color: _getColumnColor(column.taskStatus),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              column.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getColumnColor(column.taskStatus).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$taskCount',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _getColumnColor(column.taskStatus),
              ),
            ),
          ),
        ],
      ),
      addIcon: const Icon(Icons.add, size: 20),
      moreIcon: const Icon(Icons.more_horiz, size: 20),
      height: 56,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      onAddButtonClick: () => _showAddTaskDialog(context, columnData.id),
    );
  }

  /// 컬럼 푸터 빌더
  Widget _buildColumnFooter(BuildContext context, AppFlowyGroupData columnData) {
    return AppFlowyGroupFooter(
      icon: const Icon(Icons.add, size: 20),
      title: const Text('새 작업 추가'),
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      onAddButtonClick: () => _showAddTaskDialog(context, columnData.id),
    );
  }

  /// 컬럼별 아이콘 반환
  IconData _getColumnIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return Icons.list_alt;
      case TaskStatus.inProgress:
        return Icons.play_circle_filled;
      case TaskStatus.review:
        return Icons.rate_review;
      case TaskStatus.done:
        return Icons.check_circle;
      case TaskStatus.blocked:
        return Icons.block;
    }
  }

  /// 컬럼별 색상 반환
  Color _getColumnColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return Colors.grey;
      case TaskStatus.inProgress:
        return Colors.blue;
      case TaskStatus.review:
        return Colors.orange;
      case TaskStatus.done:
        return Colors.green;
      case TaskStatus.blocked:
        return Colors.red;
    }
  }

  /// 새 작업 추가 다이얼로그
  Future<void> _showAddTaskDialog(BuildContext context, [String? columnId]) async {
    TaskStatus? initialStatus;
    
    if (columnId != null) {
      final column = boardController.columns.firstWhereOrNull(
        (col) => col.id == columnId,
      );
      initialStatus = column?.taskStatus;
    }
    
    final result = await showDialog<CreateTaskRequest>(
      context: context,
      builder: (context) => AddTaskDialog(
        projectId: widget.projectId,
        initialStatus: initialStatus,
      ),
    );
    
    if (result != null) {
      final success = await boardController.addTask(result, columnId ?? 'todo');
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('작업이 추가되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(boardController.errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 작업 상세 다이얼로그
  Future<void> _showTaskDetail(BuildContext context, TaskModel task) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => TaskDetailDialog(task: task),
    );
    
    if (result == true) {
      await boardController.refreshBoard();
    }
  }

  /// 작업 삭제
  Future<void> _deleteTask(String taskId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('작업 삭제'),
        content: const Text('정말로 이 작업을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      final success = await boardController.deleteTask(taskId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('작업이 삭제되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(boardController.errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    Get.delete<BoardController>();
    super.dispose();
  }
}