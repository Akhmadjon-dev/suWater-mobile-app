import 'package:flutter/foundation.dart';
import 'package:suwater_mobile/core/api/dio_client.dart';
import 'package:suwater_mobile/core/api/endpoints.dart';
import 'package:suwater_mobile/models/citizen_profile.dart';
import 'package:suwater_mobile/models/water_reading.dart';

export 'package:suwater_mobile/models/citizen_profile.dart';
export 'package:suwater_mobile/models/water_reading.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final citizenRepositoryProvider = Provider<CitizenRepository>((ref) {
  return CitizenRepository();
});

class CitizenRepository {
  final _dio = DioClient().dio;

  // ─── Profile ─────────────────────────────────────────────────────────────

  Future<CitizenProfile> getProfile() async {
    try {
      final response = await _dio.get(Endpoints.citizenProfile);
      return CitizenProfile.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('CitizenRepository.getProfile failed: $e');
      rethrow;
    }
  }

  Future<CitizenProfile> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(Endpoints.citizenProfile, data: data);
      return CitizenProfile.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('CitizenRepository.updateProfile failed: $e');
      rethrow;
    }
  }

  // ─── Water Readings ──────────────────────────────────────────────────────

  Future<LatestReadingResponse> getLatestReading() async {
    try {
      final response = await _dio.get(Endpoints.citizenReadingsLatest);
      final data = response.data;
      if (data == null || data is String) {
        return const LatestReadingResponse();
      }
      return LatestReadingResponse(
        latest: data['latest'] != null
            ? WaterReading.fromJson(data['latest'] as Map<String, dynamic>)
            : null,
        totalConsumption:
            double.tryParse(data['total_consumption'].toString()) ?? 0.0,
      );
    } catch (e) {
      debugPrint('CitizenRepository.getLatestReading failed: $e');
      rethrow;
    }
  }

  Future<ReadingsResponse> getReadings({int page = 1, int limit = 20}) async {
    try {
      final response = await _dio.get(
        Endpoints.citizenReadings,
        queryParameters: {'page': page, 'limit': limit},
      );
      final data = response.data as Map<String, dynamic>;
      return ReadingsResponse(
        data: (data['data'] as List)
            .map((e) => WaterReading.fromJson(e as Map<String, dynamic>))
            .toList(),
        total: data['total'] as int,
        page: data['page'] as int,
        totalPages: data['totalPages'] as int,
      );
    } catch (e) {
      debugPrint('CitizenRepository.getReadings failed: $e');
      rethrow;
    }
  }

  Future<WaterReading> createReading({
    required double readingValue,
    String? readingDate,
    String? notes,
  }) async {
    try {
      final response = await _dio.post(
        Endpoints.citizenReadings,
        data: {
          'reading_value': readingValue,
          if (readingDate != null) 'reading_date': readingDate,
          if (notes != null) 'notes': notes,
        },
      );
      return WaterReading.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('CitizenRepository.createReading failed: $e');
      rethrow;
    }
  }

  Future<void> deleteReading(String id) async {
    try {
      await _dio.delete(Endpoints.citizenReading(id));
    } catch (e) {
      debugPrint('CitizenRepository.deleteReading failed: $e');
      rethrow;
    }
  }
}
