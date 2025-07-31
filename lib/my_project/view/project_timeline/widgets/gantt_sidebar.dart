import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/gantt_controller.dart';
import '../../../model/gantt_model.dart';

class GanttSidebar extends StatelessWidget {
  final GanttController controller;

  const GanttSidebar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 헤더
        _buildHeader(),
        
        // 작업 목록
        Expanded(
          child: Obx(() {
            final items = controller.ganttItems;
            final selectedId = controller.selectedItemId.value;
            
            if (items.isEmpty) {
              return const Center(
                child: Text(
                  '표시할 작업이 없습니다',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }
            
            return ListView.builder(
              controller: controller.verticalScrollController,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return GanttSidebarItem(
                  item: item,
                  isSelected: item.id == selectedId,
                  onTap: () => controller.selectItem(item.id),
                  onEdit: () => controller.editItem(item.id),
                );
              },
            );
          }),
        ),
        
        // 통계 정보
        _buildStatistics(),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: const Row(
        children: [
          Icon(Icons.task_alt, size: 20),
          SizedBox(width: 8),
          Text(
            '작업 목록',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    return Obx(() => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '프로젝트 현황',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          // 전체 진행률
          Row(
            children: [
              const Icon(Icons.trending_up, size: 16, color: Colors.blue),
              const SizedBox(width: 8),
              Text('전체 진행률: ${(controller.overallProgress * 100).toInt()}%'),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: controller.overallProgress,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          
          const SizedBox(height: 12),
          
          // 작업 개수 통계
          _buildStatItem('전체 작업', controller.totalItems, Icons.task),
          _buildStatItem('완료', controller.completedItems, Icons.check_circle, Colors.green),
          _buildStatItem('진행 중', controller.inProgressItems, Icons.play_circle, Colors.orange),
          _buildStatItem('미시작', controller.notStartedItems, Icons.radio_button_unchecked, Colors.grey),
          if (controller.delayedItems > 0)
            _buildStatItem('지연', controller.delayedItems, Icons.warning, Colors.red),
        ],
      ),
    ));
  }

  Widget _buildStatItem(String label, int count, IconData icon, [Color? color]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color ?? Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: $count',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}

class GanttSidebarItem extends StatelessWidget {
  final GanttItem item;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  const GanttSidebarItem({
    super.key,
    required this.item,
    this.isSelected = false,
    this.onTap,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40, // GanttViewSettings.rowHeight와 동일
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue[50] : null,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
          left: isSelected 
            ? const BorderSide(color: Colors.blue, width: 3)
            : BorderSide.none,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.only(
            left: item.level * 20.0 + 16, // 계층 구조 들여쓰기
            right: 16,
            top: 8,
            bottom: 8,
          ),
          child: Row(
            children: [
              // 타입 아이콘
              _buildTypeIcon(),
              
              const SizedBox(width: 8),
              
              // 작업 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: item.isDelayed ? Colors.red[700] : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.assigneeName.isNotEmpty)
                      Text(
                        item.assigneeName,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              
              // 진행률 표시
              _buildProgressIndicator(),
              
              // 우선순위 표시
              _buildPriorityChip(),
              
              // 메뉴 버튼
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 16),
                onSelected: (value) {
                  if (value == 'edit' && onEdit != null) {
                    onEdit!();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 16),
                        SizedBox(width: 8),
                        Text('편집'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeIcon() {
    IconData iconData;
    Color iconColor;
    
    switch (item.type) {
      case GanttItemType.project:
        iconData = Icons.folder;
        iconColor = Colors.blue;
        break;
      case GanttItemType.phase:
        iconData = Icons.layers;
        iconColor = Colors.orange;
        break;
      case GanttItemType.task:
        iconData = Icons.task;
        iconColor = Colors.green;
        break;
      case GanttItemType.milestone:
        iconData = Icons.flag;
        iconColor = Colors.red;
        break;
    }
    
    return Icon(
      iconData,
      size: 14,
      color: iconColor,
    );
  }

  Widget _buildProgressIndicator() {
    if (item.isMilestone) {
      return Icon(
        item.progress >= 1.0 ? Icons.check_circle : Icons.radio_button_unchecked,
        size: 16,
        color: item.progress >= 1.0 ? Colors.green : Colors.grey,
      );
    }
    
    return SizedBox(
      width: 30,
      height: 4,
      child: LinearProgressIndicator(
        value: item.progress,
        backgroundColor: Colors.grey[300],
        valueColor: AlwaysStoppedAnimation<Color>(item.color),
      ),
    );
  }

  Widget _buildPriorityChip() {
    if (item.priority == TaskPriority.medium) {
      return const SizedBox.shrink(); // 보통 우선순위는 표시하지 않음
    }
    
    Color chipColor;
    String label;
    
    switch (item.priority) {
      case TaskPriority.veryLow:
        chipColor = Colors.blue;
        label = '매우낮음';
        break;
      case TaskPriority.low:
        chipColor = Colors.green;
        label = '낮음';
        break;
      case TaskPriority.medium:
        chipColor = Colors.orange;
        label = '보통';
        break;
      case TaskPriority.high:
        chipColor = Colors.red;
        label = '높음';
        break;
      case TaskPriority.veryHigh:
        chipColor = Colors.purple;
        label = '매우높음';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: chipColor.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          color: chipColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}