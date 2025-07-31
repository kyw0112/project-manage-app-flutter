import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/gantt_controller.dart';
import '../project_timeline.dart';

class GanttChartWidget extends StatelessWidget {
  final GanttController controller;

  const GanttChartWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 헤더 (날짜)
        GanttHeader(controller: controller),
        
        // 차트 본문
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (controller.error.value.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      '데이터를 불러올 수 없습니다',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      controller.error.value,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: controller.loadGanttData,
                      child: const Text('다시 시도'),
                    ),
                  ],
                ),
              );
            }
            
            if (controller.ganttItems.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.timeline, size: 48, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      '표시할 작업이 없습니다',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }
            
            return _buildGanttChart();
          }),
        ),
        
        // 범례
        const GanttLegend(),
      ],
    );
  }

  Widget _buildGanttChart() {
    return Obx(() {
      final items = controller.ganttItems;
      final settings = controller.viewSettings.value;
      final selectedId = controller.selectedItemId.value;
      
      return SingleChildScrollView(
        controller: controller.verticalScrollController,
        child: SizedBox(
          height: items.length * settings.rowHeight,
          width: settings.totalWidth,
          child: SingleChildScrollView(
            controller: controller.horizontalScrollController,
            scrollDirection: Axis.horizontal,
            child: Stack(
              children: [
                // 배경 그리드
                _buildBackgroundGrid(settings),
                
                // 오늘 표시선
                if (settings.showToday) _buildTodayLine(settings),
                
                // 간트 아이템들
                ...items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  
                  return Positioned(
                    top: index * settings.rowHeight,
                    left: 0,
                    right: 0,
                    child: GanttItemRow(
                      item: item,
                      settings: settings,
                      isSelected: item.id == selectedId,
                      onTap: () => controller.selectItem(item.id),
                    ),
                  );
                }),
                
                // 마일스톤들
                ...controller.milestones.map((milestone) {
                  return _buildMilestoneMarker(milestone, settings);
                }),
                
                // 의존성 화살표
                if (settings.showDependencies)
                  ...controller.dependencies.map((dependency) {
                    return _buildDependencyArrow(dependency, settings);
                  }),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildBackgroundGrid(GanttViewSettings settings) {
    final List<Widget> verticalLines = [];
    DateTime currentDate = settings.startDate;
    
    while (currentDate.isBefore(settings.endDate) || 
           currentDate.isAtSameMomentAs(settings.endDate)) {
      final x = settings.getXPosition(currentDate);
      final isWeekend = currentDate.weekday == DateTime.saturday || 
                       currentDate.weekday == DateTime.sunday;
      
      verticalLines.add(
        Positioned(
          left: x,
          top: 0,
          bottom: 0,
          child: Container(
            width: 1,
            color: isWeekend ? Colors.grey[300]! : Colors.grey[200]!,
          ),
        ),
      );
      
      currentDate = currentDate.add(const Duration(days: 1));
    }
    
    return Stack(children: verticalLines);
  }

  Widget _buildTodayLine(GanttViewSettings settings) {
    final today = DateTime.now();
    final x = settings.getXPosition(today);
    
    return Positioned(
      left: x,
      top: 0,
      bottom: 0,
      child: Container(
        width: 2,
        color: Colors.red,
        child: const Positioned(
          top: 0,
          child: Icon(
            Icons.arrow_drop_down,
            color: Colors.red,
            size: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildMilestoneMarker(GanttMilestone milestone, GanttViewSettings settings) {
    final x = settings.getXPosition(milestone.date);
    
    return Positioned(
      left: x - 1,
      top: 0,
      bottom: 0,
      child: Container(
        width: 2,
        color: milestone.color,
        child: Positioned(
          top: -8,
          left: -10,
          child: Container(
            width: 20,
            height: 16,
            decoration: BoxDecoration(
              color: milestone.color,
              borderRadius: BorderRadius.circular(2),
            ),
            child: Center(
              child: Text(
                'M',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDependencyArrow(GanttDependency dependency, GanttViewSettings settings) {
    // TODO: 의존성 화살표 구현
    // 복잡한 계산이 필요하므로 추후 구현
    return const SizedBox.shrink();
  }
}