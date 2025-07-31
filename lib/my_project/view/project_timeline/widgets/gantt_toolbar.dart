import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/gantt_controller.dart';
import '../../../model/gantt_model.dart';

class GanttToolbar extends StatelessWidget {
  final GanttController controller;

  const GanttToolbar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // 제목
          const Text(
            '프로젝트 타임라인',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(width: 24),
          
          // 시간 스케일 선택
          _buildTimeScaleSelector(),
          
          const SizedBox(width: 16),
          
          // 줌 컨트롤
          _buildZoomControls(),
          
          const Spacer(),
          
          // 검색
          _buildSearchField(),
          
          const SizedBox(width: 16),
          
          // 필터 버튼
          _buildFilterButton(),
          
          const SizedBox(width: 16),
          
          // 오늘로 이동 버튼
          _buildTodayButton(),
          
          const SizedBox(width: 16),
          
          // 설정 메뉴
          _buildSettingsMenu(),
        ],
      ),
    );
  }

  Widget _buildTimeScaleSelector() {
    return Obx(() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(6),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<GanttTimeScale>(
          value: controller.viewSettings.value.timeScale,
          onChanged: (scale) {
            if (scale != null) {
              controller.changeTimeScale(scale);
            }
          },
          items: GanttTimeScale.values.map((scale) {
            return DropdownMenuItem(
              value: scale,
              child: Text(_getTimeScaleLabel(scale)),
            );
          }).toList(),
        ),
      ),
    ));
  }

  Widget _buildZoomControls() {
    return Row(
      children: [
        IconButton(
          onPressed: controller.zoomOut,
          icon: const Icon(Icons.zoom_out),
          tooltip: '축소',
        ),
        IconButton(
          onPressed: controller.zoomIn,
          icon: const Icon(Icons.zoom_in),
          tooltip: '확대',
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return SizedBox(
      width: 200,
      child: TextField(
        decoration: const InputDecoration(
          hintText: '작업 검색...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 8),
        ),
        onChanged: controller.setSearchQuery,
      ),
    );
  }

  Widget _buildFilterButton() {
    return Obx(() {
      final hasActiveFilters = controller.selectedPriorities.length != TaskPriority.values.length ||
                               controller.selectedAssignees.isNotEmpty ||
                               !controller.showCompletedTasks.value ||
                               controller.searchQuery.value.isNotEmpty;
      
      return OutlinedButton.icon(
        onPressed: () => _showFilterDialog(),
        icon: Icon(
          Icons.filter_list,
          color: hasActiveFilters ? Colors.blue : null,
        ),
        label: Text(
          '필터',
          style: TextStyle(
            color: hasActiveFilters ? Colors.blue : null,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: hasActiveFilters ? Colors.blue : Colors.grey[300]!,
          ),
        ),
      );
    });
  }

  Widget _buildTodayButton() {
    return ElevatedButton.icon(
      onPressed: controller.scrollToToday,
      icon: const Icon(Icons.today, size: 16),
      label: const Text('오늘'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildSettingsMenu() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        switch (value) {
          case 'refresh':
            controller.loadGanttData();
            break;
          case 'export':
            _exportGanttChart();
            break;
          case 'print':
            _printGanttChart();
            break;
          case 'critical_path':
            controller.toggleCriticalPath();
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'refresh',
          child: Row(
            children: [
              Icon(Icons.refresh, size: 20),
              SizedBox(width: 8),
              Text('새로고침'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'critical_path',
          child: Row(
            children: [
              Obx(() => Icon(
                controller.showCriticalPath.value
                  ? Icons.timeline
                  : Icons.timeline_outlined,
                size: 20,
              )),
              const SizedBox(width: 8),
              const Text('크리티컬 패스'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'export',
          child: Row(
            children: [
              Icon(Icons.download, size: 20),
              SizedBox(width: 8),
              Text('내보내기'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'print',
          child: Row(
            children: [
              Icon(Icons.print, size: 20),
              SizedBox(width: 8),
              Text('인쇄'),
            ],
          ),
        ),
      ],
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: const Text('필터 설정'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 우선순위 필터
              const Text('우선순위', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Obx(() => Wrap(
                spacing: 8,
                children: TaskPriority.values.map((priority) {
                  final isSelected = controller.selectedPriorities.contains(priority);
                  return FilterChip(
                    label: Text(_getPriorityLabel(priority)),
                    selected: isSelected,
                    onSelected: (selected) {
                      controller.togglePriority(priority);
                    },
                  );
                }).toList(),
              )),
              
              const SizedBox(height: 16),
              
              // 완료된 작업 표시
              Obx(() => SwitchListTile(
                title: const Text('완료된 작업 표시'),
                value: controller.showCompletedTasks.value,
                onChanged: (value) => controller.toggleCompletedTasks(),
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.clearFilters();
              Navigator.of(context).pop();
            },
            child: const Text('초기화'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('적용'),
          ),
        ],
      ),
    );
  }

  void _exportGanttChart() {
    // TODO: 간트 차트 내보내기 구현
    Get.snackbar('알림', '내보내기 기능은 준비 중입니다.');
  }

  void _printGanttChart() {
    // TODO: 간트 차트 인쇄 구현
    Get.snackbar('알림', '인쇄 기능은 준비 중입니다.');
  }

  String _getTimeScaleLabel(GanttTimeScale scale) {
    switch (scale) {
      case GanttTimeScale.days:
        return '일별';
      case GanttTimeScale.weeks:
        return '주별';
      case GanttTimeScale.months:
        return '월별';
      case GanttTimeScale.quarters:
        return '분기별';
    }
  }

  String _getPriorityLabel(TaskPriority priority) {
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