import 'package:get/get.dart';
import '../model/event_model.dart';
import '../repository/calendar_repository.dart';
import '../../common/logger/app_logger.dart';

class CalendarController extends GetxController {
  final CalendarRepository _repository = Get.find<CalendarRepository>();

  // Observable variables
  final RxList<EventModel> events = <EventModel>[].obs;
  final RxList<EventModel> filteredEvents = <EventModel>[].obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final Rx<DateTime> focusedDate = DateTime.now().obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // Filter variables
  final RxList<EventType> selectedEventTypes = <EventType>[].obs;
  final RxList<EventPriority> selectedPriorities = <EventPriority>[].obs;
  final RxString searchQuery = ''.obs;
  final RxBool showOnlyUpcoming = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeFilters();
    _setupListeners();
    loadEvents();
  }

  void _initializeFilters() {
    selectedEventTypes.addAll(EventType.values);
    selectedPriorities.addAll(EventPriority.values);
  }

  void _setupListeners() {
    // Listen to filter changes
    ever(selectedEventTypes, (_) => _applyFilters());
    ever(selectedPriorities, (_) => _applyFilters());
    ever(searchQuery, (_) => _applyFilters());
    ever(showOnlyUpcoming, (_) => _applyFilters());
  }

  Future<void> loadEvents() async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final loadedEvents = await _repository.getEvents();
      events.assignAll(loadedEvents);
      _applyFilters();
      
      AppLogger.instance.info('Loaded ${loadedEvents.length} events');
    } catch (e) {
      error.value = 'Failed to load events: $e';
      AppLogger.instance.error('Failed to load events', error: e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createEvent(EventModel event) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final createdEvent = await _repository.createEvent(event);
      events.add(createdEvent);
      _applyFilters();
      
      Get.snackbar('Success', 'Event created successfully');
      AppLogger.instance.info('Created event: ${event.title}');
    } catch (e) {
      error.value = 'Failed to create event: $e';
      Get.snackbar('Error', 'Failed to create event');
      AppLogger.instance.error('Failed to create event', error: e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateEvent(EventModel event) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final updatedEvent = await _repository.updateEvent(event);
      final index = events.indexWhere((e) => e.id == event.id);
      if (index != -1) {
        events[index] = updatedEvent;
        _applyFilters();
      }
      
      Get.snackbar('Success', 'Event updated successfully');
      AppLogger.instance.info('Updated event: ${event.title}');
    } catch (e) {
      error.value = 'Failed to update event: $e';
      Get.snackbar('Error', 'Failed to update event');
      AppLogger.instance.error('Failed to update event', error: e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      await _repository.deleteEvent(eventId);
      events.removeWhere((e) => e.id == eventId);
      _applyFilters();
      
      Get.snackbar('Success', 'Event deleted successfully');
      AppLogger.instance.info('Deleted event: $eventId');
    } catch (e) {
      error.value = 'Failed to delete event: $e';
      Get.snackbar('Error', 'Failed to delete event');
      AppLogger.instance.error('Failed to delete event', error: e);
    } finally {
      isLoading.value = false;
    }
  }

  void _applyFilters() {
    var filtered = events.where((event) {
      // Type filter
      if (!selectedEventTypes.contains(event.type)) return false;
      
      // Priority filter
      if (!selectedPriorities.contains(event.priority)) return false;
      
      // Search filter
      if (searchQuery.value.isNotEmpty) {
        final query = searchQuery.value.toLowerCase();
        if (!event.title.toLowerCase().contains(query) &&
            !event.description.toLowerCase().contains(query)) {
          return false;
        }
      }
      
      // Upcoming only filter
      if (showOnlyUpcoming.value && event.isPast) return false;
      
      return true;
    }).toList();
    
    // Sort by start time
    filtered.sort((a, b) => a.startTime.compareTo(b.startTime));
    
    filteredEvents.assignAll(filtered);
  }

  // Calendar navigation
  void selectDate(DateTime date) {
    selectedDate.value = date;
  }

  void goToToday() {
    final today = DateTime.now();
    selectedDate.value = today;
    focusedDate.value = today;
  }

  void goToPreviousMonth() {
    focusedDate.value = DateTime(
      focusedDate.value.year,
      focusedDate.value.month - 1,
    );
  }

  void goToNextMonth() {
    focusedDate.value = DateTime(
      focusedDate.value.year,
      focusedDate.value.month + 1,
    );
  }

  // Event queries
  List<EventModel> getEventsForDate(DateTime date) {
    final targetDate = DateTime(date.year, date.month, date.day);
    return filteredEvents.where((event) {
      final eventDate = DateTime(
        event.startTime.year,
        event.startTime.month,
        event.startTime.day,
      );
      return eventDate == targetDate;
    }).toList();
  }

  List<EventModel> getTodayEvents() {
    return getEventsForDate(DateTime.now());
  }

  List<EventModel> getUpcomingEvents({int days = 7}) {
    final now = DateTime.now();
    final endDate = now.add(Duration(days: days));
    
    return filteredEvents.where((event) {
      return event.startTime.isAfter(now) && 
             event.startTime.isBefore(endDate);
    }).toList();
  }

  List<EventModel> getOverdueEvents() {
    return filteredEvents.where((event) => 
      event.type == EventType.deadline && event.isPast
    ).toList();
  }

  // Filter methods
  void toggleEventType(EventType type) {
    if (selectedEventTypes.contains(type)) {
      selectedEventTypes.remove(type);
    } else {
      selectedEventTypes.add(type);
    }
  }

  void togglePriority(EventPriority priority) {
    if (selectedPriorities.contains(priority)) {
      selectedPriorities.remove(priority);
    } else {
      selectedPriorities.add(priority);
    }
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  void toggleShowOnlyUpcoming() {
    showOnlyUpcoming.value = !showOnlyUpcoming.value;
  }

  void clearFilters() {
    selectedEventTypes.assignAll(EventType.values);
    selectedPriorities.assignAll(EventPriority.values);
    searchQuery.value = '';
    showOnlyUpcoming.value = false;
  }

  // Statistics
  int get totalEventsCount => events.length;
  int get todayEventsCount => getTodayEvents().length;
  int get upcomingEventsCount => getUpcomingEvents().length;
  int get overdueEventsCount => getOverdueEvents().length;

  Map<EventType, int> get eventTypeDistribution {
    final distribution = <EventType, int>{};
    for (final type in EventType.values) {
      distribution[type] = events.where((e) => e.type == type).length;
    }
    return distribution;
  }

  Map<EventPriority, int> get priorityDistribution {
    final distribution = <EventPriority, int>{};
    for (final priority in EventPriority.values) {
      distribution[priority] = events.where((e) => e.priority == priority).length;
    }
    return distribution;
  }
}