import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../model/event_model.dart';

class EventDialog extends StatefulWidget {
  final EventModel? event;
  final DateTime selectedDate;
  final Function(EventModel) onSave;

  const EventDialog({
    super.key,
    this.event,
    required this.selectedDate,
    required this.onSave,
  });

  @override
  State<EventDialog> createState() => _EventDialogState();
}

class _EventDialogState extends State<EventDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  late DateTime _startDate;
  late TimeOfDay _startTime;
  late DateTime _endDate;
  late TimeOfDay _endTime;
  
  EventType _selectedType = EventType.meeting;
  EventPriority _selectedPriority = EventPriority.medium;
  bool _isAllDay = false;
  bool _isRecurring = false;
  RecurrenceFrequency _recurrenceFrequency = RecurrenceFrequency.daily;
  int _recurrenceInterval = 1;
  DateTime? _recurrenceEndDate;
  
  String _selectedColor = '#2196F3';
  final List<String> _colorOptions = [
    '#2196F3', // Blue
    '#4CAF50', // Green
    '#FF9800', // Orange
    '#F44336', // Red
    '#9C27B0', // Purple
    '#607D8B', // Blue Grey
    '#795548', // Brown
    '#E91E63', // Pink
  ];

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    if (widget.event != null) {
      // Edit mode
      final event = widget.event!;
      _titleController.text = event.title;
      _descriptionController.text = event.description;
      _startDate = DateTime(event.startTime.year, event.startTime.month, event.startTime.day);
      _startTime = TimeOfDay.fromDateTime(event.startTime);
      _endDate = DateTime(event.endTime.year, event.endTime.month, event.endTime.day);
      _endTime = TimeOfDay.fromDateTime(event.endTime);
      _selectedType = event.type;
      _selectedPriority = event.priority;
      _isAllDay = event.isAllDay;
      _isRecurring = event.isRecurring;
      _selectedColor = event.color;
      
      if (event.recurrenceRule != null) {
        _recurrenceFrequency = event.recurrenceRule!.frequency;
        _recurrenceInterval = event.recurrenceRule!.interval;
        _recurrenceEndDate = event.recurrenceRule!.endDate;
      }
    } else {
      // Create mode
      _startDate = widget.selectedDate;
      _endDate = widget.selectedDate;
      _startTime = TimeOfDay.now();
      _endTime = TimeOfDay.fromDateTime(DateTime.now().add(const Duration(hours: 1)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        height: 700,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  widget.event == null ? Icons.add_circle : Icons.edit,
                  size: 28,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 12),
                Text(
                  widget.event == null ? '새 이벤트' : '이벤트 수정',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Form
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: '제목',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '제목을 입력해주세요';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: '설명',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Type and Priority
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<EventType>(
                              value: _selectedType,
                              decoration: const InputDecoration(
                                labelText: '타입',
                                border: OutlineInputBorder(),
                              ),
                              items: EventType.values.map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Text(_getTypeLabel(type)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedType = value!;
                                });
                              },
                            ),
                          ),
                          
                          const SizedBox(width: 16),
                          
                          Expanded(
                            child: DropdownButtonFormField<EventPriority>(
                              value: _selectedPriority,
                              decoration: const InputDecoration(
                                labelText: '우선순위',
                                border: OutlineInputBorder(),
                              ),
                              items: EventPriority.values.map((priority) {
                                return DropdownMenuItem(
                                  value: priority,
                                  child: Text(_getPriorityLabel(priority)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedPriority = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // All day toggle
                      SwitchListTile(
                        title: const Text('종일'),
                        value: _isAllDay,
                        onChanged: (value) {
                          setState(() {
                            _isAllDay = value;
                          });
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Date and Time
                      _buildDateTimeSection(),
                      
                      const SizedBox(height: 16),
                      
                      // Color selection
                      _buildColorSection(),
                      
                      const SizedBox(height: 16),
                      
                      // Recurring toggle
                      SwitchListTile(
                        title: const Text('반복'),
                        value: _isRecurring,
                        onChanged: (value) {
                          setState(() {
                            _isRecurring = value;
                          });
                        },
                      ),
                      
                      if (_isRecurring) ...[
                        const SizedBox(height: 16),
                        _buildRecurrenceSection(),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('취소'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _saveEvent,
                  child: Text(widget.event == null ? '생성' : '수정'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('날짜 및 시간', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        
        // Start date and time
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _selectDate(context, true),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: '시작 날짜',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(DateFormat('yyyy-MM-dd').format(_startDate)),
                ),
              ),
            ),
            
            if (!_isAllDay) ...[
              const SizedBox(width: 16),
              Expanded(
                child: InkWell(
                  onTap: () => _selectTime(context, true),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: '시작 시간',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(_startTime.format(context)),
                  ),
                ),
              ),
            ],
          ],
        ),
        
        const SizedBox(height: 16),
        
        // End date and time
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _selectDate(context, false),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: '종료 날짜',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(DateFormat('yyyy-MM-dd').format(_endDate)),
                ),
              ),
            ),
            
            if (!_isAllDay) ...[
              const SizedBox(width: 16),
              Expanded(
                child: InkWell(
                  onTap: () => _selectTime(context, false),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: '종료 시간',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(_endTime.format(context)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildColorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('색상', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _colorOptions.map((color) {
            final isSelected = _selectedColor == color;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedColor = color;
                });
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Color(int.parse(color.substring(1, 7), radix: 16) + 0xFF000000),
                  shape: BoxShape.circle,
                  border: isSelected ? Border.all(color: Colors.black, width: 3) : null,
                ),
                child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRecurrenceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('반복 설정', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<RecurrenceFrequency>(
                value: _recurrenceFrequency,
                decoration: const InputDecoration(
                  labelText: '반복 주기',
                  border: OutlineInputBorder(),
                ),
                items: RecurrenceFrequency.values.map((freq) {
                  return DropdownMenuItem(
                    value: freq,
                    child: Text(_getFrequencyLabel(freq)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _recurrenceFrequency = value!;
                  });
                },
              ),
            ),
            
            const SizedBox(width: 16),
            
            SizedBox(
              width: 100,
              child: TextFormField(
                initialValue: _recurrenceInterval.toString(),
                decoration: const InputDecoration(
                  labelText: '간격',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _recurrenceInterval = int.tryParse(value) ?? 1;
                },
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        InkWell(
          onTap: () => _selectRecurrenceEndDate(context),
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: '반복 종료일 (선택사항)',
              border: OutlineInputBorder(),
            ),
            child: Text(
              _recurrenceEndDate != null 
                ? DateFormat('yyyy-MM-dd').format(_recurrenceEndDate!)
                : '종료일 없음',
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );
    
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _selectRecurrenceEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _recurrenceEndDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    
    if (picked != null) {
      setState(() {
        _recurrenceEndDate = picked;
      });
    }
  }

  void _saveEvent() {
    if (!_formKey.currentState!.validate()) return;

    final startDateTime = _isAllDay 
        ? DateTime(_startDate.year, _startDate.month, _startDate.day)
        : DateTime(_startDate.year, _startDate.month, _startDate.day, _startTime.hour, _startTime.minute);
    
    final endDateTime = _isAllDay 
        ? DateTime(_endDate.year, _endDate.month, _endDate.day, 23, 59, 59)
        : DateTime(_endDate.year, _endDate.month, _endDate.day, _endTime.hour, _endTime.minute);

    final recurrenceRule = _isRecurring ? RecurrenceRule(
      frequency: _recurrenceFrequency,
      interval: _recurrenceInterval,
      endDate: _recurrenceEndDate,
    ) : null;

    final event = EventModel(
      id: widget.event?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      description: _descriptionController.text,
      startTime: startDateTime,
      endTime: endDateTime,
      projectId: 'current_project', // TODO: Get from current project
      type: _selectedType,
      priority: _selectedPriority,
      isAllDay: _isAllDay,
      isRecurring: _isRecurring,
      recurrenceRule: recurrenceRule,
      color: _selectedColor,
      createdAt: widget.event?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    widget.onSave(event);
    Navigator.of(context).pop();
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

  String _getFrequencyLabel(RecurrenceFrequency frequency) {
    switch (frequency) {
      case RecurrenceFrequency.daily:
        return '매일';
      case RecurrenceFrequency.weekly:
        return '매주';
      case RecurrenceFrequency.monthly:
        return '매월';
      case RecurrenceFrequency.yearly:
        return '매년';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}