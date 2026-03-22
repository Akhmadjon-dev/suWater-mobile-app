import 'package:flutter/foundation.dart';
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
    try {
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
    } catch (e) {
      debugPrint('EventsRepository.getEvents failed: $e');
      rethrow;
    }
  }

  Future<WaterEvent> getEvent(String id) async {
    try {
      final response = await _dio.get(Endpoints.event(id));
      return WaterEvent.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('EventsRepository.getEvent($id) failed: $e');
      rethrow;
    }
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
    try {
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
    } catch (e) {
      debugPrint('EventsRepository.createEvent failed: $e');
      rethrow;
    }
  }

  Future<void> transitionEvent(
    String id, {
    required String status,
    String? cancellationReason,
    String? completionNotes,
  }) async {
    try {
      await _dio.patch(
        Endpoints.eventTransition(id),
        data: {
          'status': status,
          if (cancellationReason != null)
            'cancellation_reason': cancellationReason,
          if (completionNotes != null) 'completion_notes': completionNotes,
        },
      );
    } catch (e) {
      debugPrint('EventsRepository.transitionEvent($id) failed: $e');
      rethrow;
    }
  }

  // ─── Generic list/item helpers ──────────────────────────────────────────────

  Future<List<T>> _fetchList<T>(
    String endpoint,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final response = await _dio.get(endpoint);
      return (response.data as List)
          .map((e) => fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('EventsRepository._fetchList($endpoint) failed: $e');
      rethrow;
    }
  }

  Future<T> _postItem<T>(
    String endpoint,
    Map<String, dynamic> data,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('EventsRepository._postItem($endpoint) failed: $e');
      rethrow;
    }
  }

  Future<void> _deleteItem(String endpoint) async {
    try {
      await _dio.delete(endpoint);
    } catch (e) {
      debugPrint('EventsRepository._deleteItem($endpoint) failed: $e');
      rethrow;
    }
  }

  // ─── Assignments ────────────────────────────────────────────────────────────

  Future<List<EventAssignment>> getAssignments(String eventId) =>
      _fetchList(Endpoints.assignments(eventId), EventAssignment.fromJson);

  // ─── Comments ───────────────────────────────────────────────────────────────

  Future<List<EventComment>> getComments(String eventId) =>
      _fetchList(Endpoints.comments(eventId), EventComment.fromJson);

  Future<EventComment> addComment(String eventId, String content) =>
      _postItem(Endpoints.comments(eventId), {'content': content}, EventComment.fromJson);

  // ─── Labor ──────────────────────────────────────────────────────────────────

  Future<List<EventLabor>> getLabor(String eventId) =>
      _fetchList(Endpoints.labor(eventId), EventLabor.fromJson);

  Future<EventLabor> addLabor(String eventId, Map<String, dynamic> data) =>
      _postItem(Endpoints.labor(eventId), data, EventLabor.fromJson);

  Future<void> deleteLabor(String eventId, String laborId) =>
      _deleteItem(Endpoints.laborById(eventId, laborId));

  // ─── Equipment ──────────────────────────────────────────────────────────────

  Future<List<EventEquipment>> getEquipment(String eventId) =>
      _fetchList(Endpoints.equipment(eventId), EventEquipment.fromJson);

  Future<EventEquipment> addEquipment(String eventId, Map<String, dynamic> data) =>
      _postItem(Endpoints.equipment(eventId), data, EventEquipment.fromJson);

  Future<void> deleteEquipment(String eventId, String equipmentId) =>
      _deleteItem(Endpoints.equipmentById(eventId, equipmentId));

  // ─── Materials ──────────────────────────────────────────────────────────────

  Future<List<EventMaterial>> getMaterials(String eventId) =>
      _fetchList(Endpoints.materials(eventId), EventMaterial.fromJson);

  Future<EventMaterial> addMaterial(String eventId, Map<String, dynamic> data) =>
      _postItem(Endpoints.materials(eventId), data, EventMaterial.fromJson);

  Future<void> deleteMaterial(String eventId, String materialId) =>
      _deleteItem(Endpoints.materialById(eventId, materialId));
}
