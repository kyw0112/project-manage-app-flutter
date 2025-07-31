import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controller/gantt_controller.dart';
import '../../model/gantt_model.dart';
import 'widgets/gantt_chart_widget.dart';
import 'widgets/gantt_toolbar.dart';
import 'widgets/gantt_sidebar.dart';

class ProjectTimeline extends StatelessWidget {
  const ProjectTimeline({super.key});

  @override
  Widget build(BuildContext context) {
    final GanttController controller = Get.put(GanttController());
    
    return Scaffold(
      body: Column(
        children: [
          // 툴바
          GanttToolbar(controller: controller),
          
          // 메인 콘텐츠
          Expanded(
            child: Row(
              children: [
                // 사이드바 (작업 목록)
                Container(
                  width: 300,
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: GanttSidebar(controller: controller),
                ),
                
                // 간트 차트
                Expanded(
                  child: GanttChartWidget(controller: controller),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 간트 차트 헤더 (날짜 표시)
class GanttHeader extends StatelessWidget {
  final GanttController controller;

  const GanttHeader({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final settings = controller.viewSettings.value;
      final startDate = settings.startDate;
      final endDate = settings.endDate;
      
      return Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          border: Border(
            bottom: BorderSide(color: Colors.grey[300]!),
          ),
        ),
        child: CustomScrollView(
          controller: controller.horizontalScrollController,
          scrollDirection: Axis.horizontal,
          slivers: [
            SliverToBoxAdapter(
              child: _buildDateHeaders(startDate, endDate, settings),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildDateHeaders(DateTime startDate, DateTime endDate, GanttViewSettings settings) {
    final List<Widget> headers = [];
    DateTime currentDate = startDate;
    
    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      final isWeekend = currentDate.weekday == DateTime.saturday || 
                       currentDate.weekday == DateTime.sunday;
      final isToday = _isSameDay(currentDate, DateTime.now());
      
      headers.add(
        Container(
          width: settings.dayWidth,
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(color: Colors.grey[200]!),
            ),
            color: isToday 
              ? Colors.blue[100] 
              : isWeekend 
                ? Colors.grey[100] 
                : Colors.white,
          ),
          child: Column(
            children: [
              // 월/년 표시
              if (currentDate.day == 1 || currentDate == startDate)
                Container(
                  height: 20,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    DateFormat('yyyy.MM').format(currentDate),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              
              // 일 표시
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        currentDate.day.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                          color: isToday 
                            ? Colors.blue[800]
                            : isWeekend 
                              ? Colors.red[600] 
                              : Colors.black87,
                        ),
                      ),
                      Text(
                        _getWeekdayName(currentDate.weekday),
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      
      currentDate = currentDate.add(const Duration(days: 1));
    }
    
    return Row(
      children: headers,
    );
  }

  String _getWeekdayName(int weekday) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return weekdays[weekday - 1];
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
}

/// 간트 차트 아이템 행
class GanttItemRow extends StatelessWidget {
  final GanttItem item;
  final GanttViewSettings settings;
  final bool isSelected;
  final VoidCallback? onTap;

  const GanttItemRow({
    super.key,
    required this.item,
    required this.settings,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final startX = settings.getXPosition(item.startDate);
    final endX = settings.getXPosition(item.endDate.add(const Duration(days: 1)));
    final width = endX - startX;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: settings.rowHeight,
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[50] : null,
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!),
          ),
        ),
        child: Stack(
          children: [
            // 그리드 라인
            _buildGridLines(),
            
            // 간트 바
            Positioned(
              left: startX,
              top: 8,
              child: _buildGanttBar(width),
            ),
            
            // 마일스톤 (해당하는 경우)
            if (item.isMilestone) _buildMilestone(startX),
          ],
        ),
      ),
    );
  }

  Widget _buildGridLines() {
    final List<Widget> lines = [];
    DateTime currentDate = settings.startDate;
    
    while (currentDate.isBefore(settings.endDate)) {
      final x = settings.getXPosition(currentDate);
      final isWeekend = currentDate.weekday == DateTime.saturday || 
                       currentDate.weekday == DateTime.sunday;
      
      lines.add(
        Positioned(
          left: x,
          top: 0,
          bottom: 0,
          child: Container(
            width: 1,
            color: isWeekend ? Colors.grey[300] : Colors.grey[200],
          ),
        ),
      );
      
      currentDate = currentDate.add(const Duration(days: 1));
    }
    
    return Stack(children: lines);
  }

  Widget _buildGanttBar(double width) {
    if (item.isMilestone) return const SizedBox.shrink();
    
    return Container(
      width: width,
      height: 24,
      decoration: BoxDecoration(
        color: item.color.withOpacity(0.3),
        border: Border.all(color: item.color),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Stack(
        children: [
          // 진행률 표시
          if (item.progress > 0)
            Container(
              width: width * item.progress,
              height: 24,
              decoration: BoxDecoration(
                color: item.color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          
          // 텍스트 (작업 제목)
          if (width > 80)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 11,
                    color: item.progress > 0.5 ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMilestone(double x) {
    return Positioned(
      left: x - 8,
      top: 12,
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: item.color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: item.progress >= 1.0 
          ? const Icon(Icons.check, size: 10, color: Colors.white)
          : null,
      ),
    );
  }
}

/// 간트 차트 범례
class GanttLegend extends StatelessWidget {
  const GanttLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Wrap(
        spacing: 24,
        runSpacing: 8,
        children: [
          _buildLegendItem('계획된 작업', Colors.blue[300]!),
          _buildLegendItem('진행 중', Colors.orange[400]!),
          _buildLegendItem('완료됨', Colors.green[400]!),
          _buildLegendItem('지연됨', Colors.red[400]!),
          _buildLegendItem('마일스톤', Colors.purple[400]!),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}