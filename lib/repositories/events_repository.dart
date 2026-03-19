import 'package:suwater_mobile/core/api/dio_client.dart';
import 'package:suwater_mobile/core/api/endpoints.dart';
import 'package:suwater_mobile/models/event.dart';
import 'package:suwater_mobile/models/comment.dart';

class EventsRepository {
  final _dio = DioClient().dio;

  Future<EventsResponse> getEvents({
    int page = 1,
    int limit = 20,
    String? status,
    String? type,
    String? priority,
  }) async {
    final response = await _dio.get(
      Endpoints.events,
      queryParameters: {
        'page': page,
        'limit': limit,
        if (status != null) 'status': status,
        if (type != null) 'type': type,
        if (priority != null) 'priority': priority,
      },
    );

    return EventsResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<WaterEvent> getEvent(String id) async {
    final response = await _dio.get(Endpoints.event(id));
    return WaterEvent.fromJson(response.data as Map<String, dynamic>);
  }

  Future<WaterEvent> createEvent({
    required String type,
    required String title,
    String? description,
    double? latitude,
    double? longitude,
    String? address,
    String priority = 'MEDIUM',
  }) async {
    final response = await _dio.post(
      Endpoints.events,
      data: {
        'type': type,
        'title': title,
        if (description != null) 'description': description,
        'latitude': latitude ?? 0,
        'longitude': longitude ?? 0,
        if (address != null) 'address': address,
        'priority': priority,
      },
    );

    return WaterEvent.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> transitionEvent(
    String id, {
    required String status,
    String? cancellationReason,
    String? completionNotes,
  }) async {
    await _dio.patch(
      Endpoints.eventTransition(id),
      data: {
        'status': status,
        if (cancellationReason != null)
          'cancellation_reason': cancellationReason,
        if (completionNotes != null) 'completion_notes': completionNotes,
      },
    );
  }

  // Assignments
  Future<List<EventAssignment>> getAssignments(String eventId) async {
    final response = await _dio.get(Endpoints.assignments(eventId));
    return (response.data as List)
        .map((e) => EventAssignment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Comments
  Future<List<EventComment>> getComments(String eventId) async {
    final response = await _dio.get(Endpoints.comments(eventId));
    return (response.data as List)
        .map((e) => EventComment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<EventComment> addComment(String eventId, String content) async {
    final response = await _dio.post(
      Endpoints.comments(eventId),
      data: {'content': content},
    );

    return EventComment.fromJson(response.data as Map<String, dynamic>);
  }
}
