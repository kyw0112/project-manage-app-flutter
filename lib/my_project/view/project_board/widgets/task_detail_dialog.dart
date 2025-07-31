import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:actual/my_project/model/task_model.dart';
import 'package:actual/my_project/controller/task_controller.dart';

class TaskDetailDialog extends StatefulWidget {
  final TaskModel task;

  const TaskDetailDialog({
    Key? key,
    required this.task,
  }) : super(key: key);

  @override
  State<TaskDetailDialog> createState() => _TaskDetailDialogState();
}

class _TaskDetailDialogState extends State<TaskDetailDialog> {
  final TaskController _taskController = Get.find<TaskController>();
  late TaskModel _currentTask;
  bool _isEditing = false;
  bool _isLoading = false;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  TaskStatus _selectedStatus = TaskStatus.todo;
  TaskPriority _selectedPriority = TaskPriority.medium;
  int _progressPercentage = 0;

  @override
  void initState() {
    super.initState();
    _currentTask = widget.task;
    _initializeControllers();
  }

  void _initializeControllers() {
    _titleController.text = _currentTask.title;
    _descriptionController.text = _currentTask.description;
    _selectedStatus = _currentTask.status;
    _selectedPriority = _currentTask.priority;
    _progressPercentage = _currentTask.progressPercentage;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _isEditing ? _buildEditForm() : _buildDetailView(),
              ),
            ),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getStatusColor(_currentTask.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getStatusIcon(_currentTask.status),
              color: _getStatusColor(_currentTask.status),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditing ? '작업 편집' : '작업 상세',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _getStatusText(_currentTask.status),
                  style: TextStyle(
                    color: _getStatusColor(_currentTask.status),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
                if (_isEditing) {
                  _initializeControllers();
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDetailView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoCard('제목', _currentTask.title, Icons.title),
        const SizedBox(height: 16),
        _buildInfoCard('설명', _currentTask.description, Icons.description),
        const SizedBox(height: 16),
        _buildStatusPriorityInfo(),
        const SizedBox(height: 16),
        _buildProgressInfo(),
        const SizedBox(height: 16),
        _buildAssigneeInfo(),
        if (_currentTask.dueDate != null) ...[
          const SizedBox(height: 16),
          _buildDueDateInfo(),
        ],
        if (_currentTask.labels.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildTagsInfo(),
        ],
        const SizedBox(height: 16),
        _buildDatesInfo(),
      ],
    );
  }

  Widget _buildEditForm() {
    return Column(
      children: [
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: '작업 제목',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.title),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: '작업 설명',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.description),
            alignLabelWithHint: true,
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<TaskStatus>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: '상태',
                  border: OutlineInputBorder(),
                ),
                items: TaskStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(_getStatusText(status)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedStatus = value;
                    });
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<TaskPriority>(
                value: _selectedPriority,
                decoration: const InputDecoration(
                  labelText: '우선순위',
                  border: OutlineInputBorder(),
                ),
                items: TaskPriority.values.map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Text(_getPriorityText(priority)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedPriority = value;
                    });
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildProgressSlider(),
      ],
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPriorityInfo() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getStatusColor(_currentTask.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _getStatusColor(_currentTask.status).withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  _getStatusIcon(_currentTask.status),
                  color: _getStatusColor(_currentTask.status),
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  _getStatusText(_currentTask.status),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(_currentTask.status),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getPriorityColor(_currentTask.priority).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _getPriorityColor(_currentTask.priority).withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.flag,
                  color: _getPriorityColor(_currentTask.priority),
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  _getPriorityText(_currentTask.priority),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getPriorityColor(_currentTask.priority),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '진행률',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
              Text(
                '${_currentTask.progressPercentage}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _currentTask.progressPercentage / 100,
            backgroundColor: Colors.blue[100],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('진행률'),
            Text('${_progressPercentage}%'),
          ],
        ),
        Slider(
          value: _progressPercentage.toDouble(),
          min: 0,
          max: 100,
          divisions: 20,
          onChanged: (value) {
            setState(() {
              _progressPercentage = value.round();
            });
          },
        ),
      ],
    );
  }

  Widget _buildAssigneeInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.green[100],
            child: _currentTask.assignee?.profileImage != null
                ? ClipOval(
                    child: Image.network(
                      _currentTask.assignee?.profileImage ?? '',
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildAvatarFallback(),
                    ),
                  )
                : _buildAvatarFallback(),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '담당자',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _currentTask.assigneeName.isEmpty 
                    ? '할당되지 않음' 
                    : _currentTask.assigneeName,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarFallback() {
    return Text(
      _currentTask.assigneeName.isNotEmpty 
          ? _currentTask.assigneeName[0].toUpperCase()
          : '?',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.green[700],
      ),
    );
  }

  Widget _buildDueDateInfo() {
    final isOverdue = _currentTask.isOverdue;
    final isDueToday = _currentTask.dueDate != null && _currentTask.dueDate!.day == DateTime.now().day;
    
    Color backgroundColor = Colors.grey[50]!;
    Color borderColor = Colors.grey[200]!;
    Color textColor = Colors.grey[700]!;
    
    if (isOverdue) {
      backgroundColor = Colors.red[50]!;
      borderColor = Colors.red[200]!;
      textColor = Colors.red[700]!;
    } else if (isDueToday) {
      backgroundColor = Colors.orange[50]!;
      borderColor = Colors.orange[200]!;
      textColor = Colors.orange[700]!;
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(
            Icons.schedule,
            color: textColor,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '마감일',
                style: TextStyle(
                  fontSize: 12,
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _formatDate(_currentTask.dueDate!),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const Spacer(),
          if (isOverdue)
            const Text(
              '지연됨',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            )
          else if (isDueToday)
            const Text(
              '오늘',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTagsInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '태그',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _currentTask.labels.map((tag) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Text(
                tag,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDatesInfo() {
    return Row(
      children: [
        Expanded(
          child: _buildDateInfo('생성일', _currentTask.createdAt),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildDateInfo('수정일', _currentTask.updatedAt),
        ),
      ],
    );
  }

  Widget _buildDateInfo(String label, DateTime date) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatDateTime(date),
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_isEditing) ...[
            TextButton(
              onPressed: () {
                setState(() {
                  _isEditing = false;
                  _initializeControllers();
                });
              },
              child: const Text('취소'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('저장'),
            ),
          ] else ...[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('닫기'),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _saveChanges() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final request = UpdateTaskRequest(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        status: _selectedStatus,
        priority: _selectedPriority,
        progressPercentage: _progressPercentage,
      );

      final success = await _taskController.updateTask(_currentTask.id, request);
      
      if (success) {
        // 업데이트된 작업 정보 새로고침
        final updatedTask = await _taskController.getTask(_currentTask.id);
        if (updatedTask != null) {
          setState(() {
            _currentTask = updatedTask;
            _isEditing = false;
          });
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('작업이 성공적으로 업데이트되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_taskController.errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('오류가 발생했습니다: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime date) {
    return '${_formatDate(date)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  // Helper methods for status and priority
  IconData _getStatusIcon(TaskStatus status) {
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

  Color _getStatusColor(TaskStatus status) {
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

  String _getStatusText(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return '할 일';
      case TaskStatus.inProgress:
        return '진행 중';
      case TaskStatus.review:
        return '검토';
      case TaskStatus.done:
        return '완료';
      case TaskStatus.blocked:
        return '차단됨';
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.veryLow:
        return Colors.blue;
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.veryHigh:
        return Colors.purple;
    }
  }

  String _getPriorityText(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.veryLow:
        return '매우 낮음';
      case TaskPriority.low:
        return '낮음';
      case TaskPriority.medium:
        return '보통';
      case TaskPriority.high:
        return '높음';
      case TaskPriority.veryHigh:
        return '매우 높음';
    }
  }
}