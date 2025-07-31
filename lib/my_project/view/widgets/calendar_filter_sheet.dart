import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/calendar_controller.dart';
import '../../model/event_model.dart';

class CalendarFilterSheet extends StatelessWidget {
  final CalendarController controller;

  const CalendarFilterSheet({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.filter_list, size: 24),
              const SizedBox(width: 8),
              const Text(
                '필터',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  controller.clearFilters();
                  Navigator.of(context).pop();
                },
                child: const Text('초기화'),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Types
                  _buildEventTypesSection(),
                  
                  const SizedBox(height: 24),
                  
                  // Priorities
                  _buildPrioritiesSection(),
                  
                  const SizedBox(height: 24),
                  
                  // Show options
                  _buildShowOptionsSection(),
                  
                  const SizedBox(height: 24),
                  
                  // Statistics
                  _buildStatisticsSection(),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Apply button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('적용'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventTypesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '이벤트 타입',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Obx(() => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: EventType.values.map((type) {
            final isSelected = controller.selectedEventTypes.contains(type);
            return FilterChip(
              label: Text(_getTypeLabel(type)),
              selected: isSelected,
              onSelected: (selected) {
                controller.toggleEventType(type);
              },
              avatar: Icon(
                _getTypeIcon(type),
                size: 16,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
            );
          }).toList(),
        )),
      ],
    );
  }

  Widget _buildPrioritiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '우선순위',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Obx(() => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: EventPriority.values.map((priority) {
            final isSelected = controller.selectedPriorities.contains(priority);
            return FilterChip(
              label: Text(_getPriorityLabel(priority)),
              selected: isSelected,
              onSelected: (selected) {
                controller.togglePriority(priority);
              },
              backgroundColor: _getPriorityColor(priority).withOpacity(0.1),
              selectedColor: _getPriorityColor(priority),
            );
          }).toList(),
        )),
      ],
    );
  }

  Widget _buildShowOptionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '표시 옵션',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Obx(() => SwitchListTile(
          title: const Text('예정된 이벤트만 표시'),
          subtitle: const Text('과거 이벤트 숨기기'),
          value: controller.showOnlyUpcoming.value,
          onChanged: (value) => controller.toggleShowOnlyUpcoming(),
        )),
      ],
    );
  }

  Widget _buildStatisticsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '통계',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Obx(() => Column(
          children: [
            _buildStatItem('전체 이벤트', '${controller.totalEventsCount}개'),
            _buildStatItem('오늘 이벤트', '${controller.todayEventsCount}개'),
            _buildStatItem('예정된 이벤트', '${controller.upcomingEventsCount}개'),
            _buildStatItem('지난 마감일', '${controller.overdueEventsCount}개'),
          ],
        )),
        
        const SizedBox(height: 16),
        
        // Type distribution
        const Text(
          '타입별 분포',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Obx(() {
          final distribution = controller.eventTypeDistribution;
          return Column(
            children: distribution.entries.map((entry) {
              if (entry.value == 0) return const SizedBox.shrink();
              return _buildDistributionItem(
                _getTypeLabel(entry.key),
                entry.value,
                _getTypeIcon(entry.key),
              );
            }).toList(),
          );
        }),
        
        const SizedBox(height: 16),
        
        // Priority distribution
        const Text(
          '우선순위별 분포',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Obx(() {
          final distribution = controller.priorityDistribution;
          return Column(
            children: distribution.entries.map((entry) {
              if (entry.value == 0) return const SizedBox.shrink();
              return _buildDistributionItem(
                _getPriorityLabel(entry.key),
                entry.value,
                Icons.priority_high,
                color: _getPriorityColor(entry.key),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionItem(
    String label,
    int count,
    IconData icon, {
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color ?? Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 12)),
          ),
          Text(
            '$count개',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _getTypeLabel(EventType type) {
    switch (type) {
      case EventType.meeting:
        return '회의';
      case EventType.deadline:
        return '마감일';
      case EventType.milestone:
        return '마일스톤';
      case EventType.task:
        return '작업';
      case EventType.reminder:
        return '알림';
      case EventType.personal:
        return '개인';
    }
  }

  IconData _getTypeIcon(EventType type) {
    switch (type) {
      case EventType.meeting:
        return Icons.people;
      case EventType.deadline:
        return Icons.flag;
      case EventType.milestone:
        return Icons.star;
      case EventType.task:
        return Icons.task;
      case EventType.reminder:
        return Icons.notification_important;
      case EventType.personal:
        return Icons.person;
    }
  }

  String _getPriorityLabel(EventPriority priority) {
    switch (priority) {
      case EventPriority.low:
        return '낮음';
      case EventPriority.medium:
        return '보통';
      case EventPriority.high:
        return '높음';
      case EventPriority.urgent:
        return '긴급';
    }
  }

  Color _getPriorityColor(EventPriority priority) {
    switch (priority) {
      case EventPriority.low:
        return Colors.green;
      case EventPriority.medium:
        return Colors.orange;
      case EventPriority.high:
        return Colors.red;
      case EventPriority.urgent:
        return Colors.deepPurple;
    }
  }
}