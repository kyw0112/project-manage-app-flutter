import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../controller/calendar_controller.dart';
import '../model/event_model.dart';
import 'widgets/event_dialog.dart';
import 'widgets/event_list_item.dart';
import 'widgets/calendar_filter_sheet.dart';

class ProjectCalendar extends StatelessWidget {
  const ProjectCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    final CalendarController controller = Get.put(CalendarController());
    
    return Scaffold(
      body: Column(
        children: [
          // Header
          _buildHeader(controller),
          
          // Calendar and Events
          Expanded(
            child: Row(
              children: [
                // Calendar Section
                Expanded(
                  flex: 2,
                  child: _buildCalendarSection(controller),
                ),
                
                // Events Section
                Expanded(
                  flex: 1,
                  child: _buildEventsSection(controller),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEventDialog(context, controller),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader(CalendarController controller) {
    return Container(
      padding: const EdgeInsets.all(16.0),
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
          const Icon(Icons.calendar_today, size: 24),
          const SizedBox(width: 8),
          const Text(
            '캘린더',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          
          // Search
          SizedBox(
            width: 200,
            child: Obx(() => TextField(
              decoration: const InputDecoration(
                hintText: '이벤트 검색...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: controller.setSearchQuery,
            )),
          ),
          
          const SizedBox(width: 16),
          
          // Filter button
          OutlinedButton.icon(
            onPressed: () => _showFilterSheet(Get.context!, controller),
            icon: const Icon(Icons.filter_list),
            label: const Text('필터'),
          ),
          
          const SizedBox(width: 16),
          
          // Today button
          ElevatedButton(
            onPressed: controller.goToToday,
            child: const Text('오늘'),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarSection(CalendarController controller) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Obx(() => TableCalendar<EventModel>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: controller.focusedDate.value,
        selectedDayPredicate: (day) => isSameDay(controller.selectedDate.value, day),
        calendarFormat: CalendarFormat.month,
        
        // Events
        eventLoader: controller.getEventsForDate,
        
        // Styling
        calendarStyle: const CalendarStyle(
          outsideDaysVisible: false,
          weekendTextStyle: TextStyle(color: Colors.red),
          holidayTextStyle: TextStyle(color: Colors.red),
          selectedDecoration: BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: Colors.orange,
            shape: BoxShape.circle,
          ),
          markerDecoration: BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
        ),
        
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          leftChevronIcon: const Icon(Icons.chevron_left),
          rightChevronIcon: const Icon(Icons.chevron_right),
          titleTextFormatter: (date, locale) => DateFormat.yMMMM(locale).format(date),
        ),
        
        // Callbacks
        onDaySelected: (selectedDay, focusedDay) {
          controller.selectDate(selectedDay);
          controller.focusedDate.value = focusedDay;
        },
        
        onPageChanged: (focusedDay) {
          controller.focusedDate.value = focusedDay;
        },
        
        // Event markers
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, day, events) {
            if (events.isEmpty) return null;
            
            return Positioned(
              right: 1,
              bottom: 1,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                width: 16.0,
                height: 16.0,
                child: Center(
                  child: Text(
                    '${events.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      )),
    );
  }

  Widget _buildEventsSection(CalendarController controller) {
    return Container(
      margin: const EdgeInsets.only(top: 16, right: 16, bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Events header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(Icons.event, size: 20),
                const SizedBox(width: 8),
                Obx(() => Text(
                  DateFormat('M월 d일').format(controller.selectedDate.value),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                )),
                const Spacer(),
                Obx(() {
                  final eventsCount = controller.getEventsForDate(controller.selectedDate.value).length;
                  return Text(
                    '$eventsCount개',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  );
                }),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Events list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final selectedEvents = controller.getEventsForDate(controller.selectedDate.value);
              
              if (selectedEvents.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_note, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        '이벤트가 없습니다',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => _showEventDialog(Get.context!, controller),
                        child: const Text('이벤트 추가'),
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: selectedEvents.length,
                itemBuilder: (context, index) {
                  final event = selectedEvents[index];
                  return EventListItem(
                    event: event,
                    onTap: () => _showEventDialog(context, controller, event: event),
                    onDelete: () => controller.deleteEvent(event.id),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showEventDialog(BuildContext context, CalendarController controller, {EventModel? event}) {
    showDialog(
      context: context,
      builder: (context) => EventDialog(
        event: event,
        selectedDate: controller.selectedDate.value,
        onSave: (eventToSave) {
          if (event == null) {
            controller.createEvent(eventToSave);
          } else {
            controller.updateEvent(eventToSave);
          }
        },
      ),
    );
  }

  void _showFilterSheet(BuildContext context, CalendarController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CalendarFilterSheet(controller: controller),
    );
  }
}
