import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../model/event_model.dart';
import '../../common/network/dio_client.dart';
import '../../common/logger/app_logger.dart';
import '../../common/exceptions/custom_exception.dart';

class CalendarRepository {
  final DioClient _dioClient = Get.find<DioClient>();
  final AppLogger _logger = AppLogger('CalendarRepository');

  static const String _baseUrl = '/api/v1/calendar';

  Future<List<EventModel>> getEvents({
    String? projectId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (projectId != null) {
        queryParams['projectId'] = projectId;
      }
      
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }

      final response = await _dioClient.get(
        '$_baseUrl/events',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        final events = data.map((json) => EventModel.fromMap(json)).toList();
        
        _logger.info('Successfully fetched ${events.length} events');
        return events;
      } else {
        throw ServerException('Failed to fetch events');
      }
    } on DioException catch (e) {
      _logger.error('Network error while fetching events', e);
      throw NetworkException('Network error: ${e.message}');
    } catch (e) {
      _logger.error('Unexpected error while fetching events', e);
      throw UnknownException('Unexpected error occurred');
    }
  }

  Future<EventModel> getEvent(String eventId) async {
    try {
      final response = await _dioClient.get('$_baseUrl/events/$eventId');

      if (response.statusCode == 200) {
        final event = EventModel.fromMap(response.data['data']);
        _logger.info('Successfully fetched event: $eventId');
        return event;
      } else {
        throw ServerException('Failed to fetch event');
      }
    } on DioException catch (e) {
      _logger.error('Network error while fetching event', e);
      throw NetworkException('Network error: ${e.message}');
    } catch (e) {
      _logger.error('Unexpected error while fetching event', e);
      throw UnknownException('Unexpected error occurred');
    }
  }

  Future<EventModel> createEvent(EventModel event) async {
    try {
      final response = await _dioClient.post(
        '$_baseUrl/events',
        data: event.toMap(),
      );

      if (response.statusCode == 201) {
        final createdEvent = EventModel.fromMap(response.data['data']);
        _logger.info('Successfully created event: ${event.title}');
        return createdEvent;
      } else {
        throw ServerException('Failed to create event');
      }
    } on DioException catch (e) {
      _logger.error('Network error while creating event', e);
      if (e.response?.statusCode == 400) {
        throw ValidationException('Invalid event data');
      }
      throw NetworkException('Network error: ${e.message}');
    } catch (e) {
      _logger.error('Unexpected error while creating event', e);
      throw UnknownException('Unexpected error occurred');
    }
  }

  Future<EventModel> updateEvent(EventModel event) async {
    try {
      final response = await _dioClient.put(
        '$_baseUrl/events/${event.id}',
        data: event.toMap(),
      );

      if (response.statusCode == 200) {
        final updatedEvent = EventModel.fromMap(response.data['data']);
        _logger.info('Successfully updated event: ${event.id}');
        return updatedEvent;
      } else {
        throw ServerException('Failed to update event');
      }
    } on DioException catch (e) {
      _logger.error('Network error while updating event', e);
      if (e.response?.statusCode == 400) {
        throw ValidationException('Invalid event data');
      } else if (e.response?.statusCode == 404) {
        throw NotFoundException('Event not found');
      }
      throw NetworkException('Network error: ${e.message}');
    } catch (e) {
      _logger.error('Unexpected error while updating event', e);
      throw UnknownException('Unexpected error occurred');
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      final response = await _dioClient.delete('$_baseUrl/events/$eventId');

      if (response.statusCode == 200) {
        _logger.info('Successfully deleted event: $eventId');
      } else {
        throw ServerException('Failed to delete event');
      }
    } on DioException catch (e) {
      _logger.error('Network error while deleting event', e);
      if (e.response?.statusCode == 404) {
        throw NotFoundException('Event not found');
      }
      throw NetworkException('Network error: ${e.message}');
    } catch (e) {
      _logger.error('Unexpected error while deleting event', e);
      throw UnknownException('Unexpected error occurred');
    }
  }

  Future<List<EventModel>> searchEvents(String query) async {
    try {
      final response = await _dioClient.get(
        '$_baseUrl/events/search',
        queryParameters: {'q': query},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        final events = data.map((json) => EventModel.fromMap(json)).toList();
        
        _logger.info('Successfully searched events with query: $query');
        return events;
      } else {
        throw ServerException('Failed to search events');
      }
    } on DioException catch (e) {
      _logger.error('Network error while searching events', e);
      throw NetworkException('Network error: ${e.message}');
    } catch (e) {
      _logger.error('Unexpected error while searching events', e);
      throw UnknownException('Unexpected error occurred');
    }
  }

  Future<List<EventModel>> getRecurringEvents(String eventId) async {
    try {
      final response = await _dioClient.get(
        '$_baseUrl/events/$eventId/recurring',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        final events = data.map((json) => EventModel.fromMap(json)).toList();
        
        _logger.info('Successfully fetched recurring events for: $eventId');
        return events;
      } else {
        throw ServerException('Failed to fetch recurring events');
      }
    } on DioException catch (e) {
      _logger.error('Network error while fetching recurring events', e);
      throw NetworkException('Network error: ${e.message}');
    } catch (e) {
      _logger.error('Unexpected error while fetching recurring events', e);
      throw UnknownException('Unexpected error occurred');
    }
  }

  Future<EventModel> updateRecurringEventSeries(
    String eventId,
    EventModel updatedEvent,
  ) async {
    try {
      final response = await _dioClient.put(
        '$_baseUrl/events/$eventId/series',
        data: updatedEvent.toMap(),
      );

      if (response.statusCode == 200) {
        final event = EventModel.fromMap(response.data['data']);
        _logger.info('Successfully updated recurring event series: $eventId');
        return event;
      } else {
        throw ServerException('Failed to update recurring event series');
      }
    } on DioException catch (e) {
      _logger.error('Network error while updating recurring series', e);
      if (e.response?.statusCode == 400) {
        throw ValidationException('Invalid event data');
      } else if (e.response?.statusCode == 404) {
        throw NotFoundException('Event not found');
      }
      throw NetworkException('Network error: ${e.message}');
    } catch (e) {
      _logger.error('Unexpected error while updating recurring series', e);
      throw UnknownException('Unexpected error occurred');
    }
  }

  Future<void> deleteRecurringEventSeries(String eventId) async {
    try {
      final response = await _dioClient.delete(
        '$_baseUrl/events/$eventId/series',
      );

      if (response.statusCode == 200) {
        _logger.info('Successfully deleted recurring event series: $eventId');
      } else {
        throw ServerException('Failed to delete recurring event series');
      }
    } on DioException catch (e) {
      _logger.error('Network error while deleting recurring series', e);
      if (e.response?.statusCode == 404) {
        throw NotFoundException('Event not found');
      }
      throw NetworkException('Network error: ${e.message}');
    } catch (e) {
      _logger.error('Unexpected error while deleting recurring series', e);
      throw UnknownException('Unexpected error occurred');
    }
  }

  // Mock data for development/testing
  Future<List<EventModel>> getMockEvents() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    
    final now = DateTime.now();
    return [
      EventModel(
        id: '1',
        title: '팀 회의',
        description: '주간 팀 회의',
        startTime: now.add(const Duration(hours: 2)),
        endTime: now.add(const Duration(hours: 3)),
        projectId: 'project1',
        type: EventType.meeting,
        priority: EventPriority.high,
        color: '#FF5722',
        createdAt: now,
        updatedAt: now,
      ),
      EventModel(
        id: '2',
        title: '프로젝트 마감일',
        description: '1차 스프린트 마감',
        startTime: now.add(const Duration(days: 3)),
        endTime: now.add(const Duration(days: 3, hours: 1)),
        projectId: 'project1',
        type: EventType.deadline,
        priority: EventPriority.urgent,
        color: '#F44336',
        createdAt: now,
        updatedAt: now,
      ),
      EventModel(
        id: '3',
        title: '클라이언트 미팅',
        description: '프로젝트 진행상황 보고',
        startTime: now.add(const Duration(days: 1, hours: 10)),
        endTime: now.add(const Duration(days: 1, hours: 11)),
        projectId: 'project1',
        type: EventType.meeting,
        priority: EventPriority.high,
        color: '#2196F3',
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}