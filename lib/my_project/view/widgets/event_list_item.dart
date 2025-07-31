import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../model/event_model.dart';

class EventListItem extends StatelessWidget {
  final EventModel event;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const EventListItem({
    super.key,
    required this.event,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Color indicator
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: Color(int.parse(event.color.substring(1, 7), radix: 16) + 0xFF000000),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Event content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title with priority
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            event.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _buildPriorityChip(),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Time
                    Text(
                      _formatEventTime(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    
                    if (event.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        event.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    
                    const SizedBox(height: 4),
                    
                    // Type and status
                    Row(
                      children: [
                        _buildTypeChip(),
                        const SizedBox(width: 8),
                        if (event.isRecurring)
                          const Icon(Icons.repeat, size: 14, color: Colors.grey),
                        if (event.isAllDay)
                          const Icon(Icons.all_inclusive, size: 14, color: Colors.grey),
                        const Spacer(),
                        _buildStatusIndicator(),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Actions
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 16),
                onSelected: (value) {
                  if (value == 'delete') {
                    _showDeleteConfirmation(context);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 16),
                        SizedBox(width: 8),
                        Text('수정'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 16, color: Colors.red),
                        SizedBox(width: 8),
                        Text('삭제', style: TextStyle(color: Colors.red)),
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

  Widget _buildPriorityChip() {
    Color chipColor;
    String label;
    
    switch (event.priority) {
      case EventPriority.low:
        chipColor = Colors.green;
        label = '낮음';
        break;
      case EventPriority.medium:
        chipColor = Colors.orange;
        label = '보통';
        break;
      case EventPriority.high:
        chipColor = Colors.red;
        label = '높음';
        break;
      case EventPriority.urgent:
        chipColor = Colors.deepPurple;
        label = '긴급';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: chipColor.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: chipColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTypeChip() {
    IconData icon;
    String label;
    
    switch (event.type) {
      case EventType.meeting:
        icon = Icons.people;
        label = '회의';
        break;
      case EventType.deadline:
        icon = Icons.flag;
        label = '마감일';
        break;
      case EventType.milestone:
        icon = Icons.star;
        label = '마일스톤';
        break;
      case EventType.task:
        icon = Icons.task;
        label = '작업';
        break;
      case EventType.reminder:
        icon = Icons.notification_important;
        label = '알림';
        break;
      case EventType.personal:
        icon = Icons.person;
        label = '개인';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator() {
    if (event.isPast) {
      return const Icon(Icons.check_circle, size: 14, color: Colors.grey);
    } else if (event.isToday) {
      return const Icon(Icons.schedule, size: 14, color: Colors.orange);
    } else {
      return const Icon(Icons.schedule, size: 14, color: Colors.blue);
    }
  }

  String _formatEventTime() {
    if (event.isAllDay) {
      return '종일';
    }
    
    final startFormat = DateFormat.Hm();
    final endFormat = DateFormat.Hm();
    
    return '${startFormat.format(event.startTime)} - ${endFormat.format(event.endTime)}';
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('이벤트 삭제'),
        content: Text('\'${event.title}\' 이벤트를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDelete();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}