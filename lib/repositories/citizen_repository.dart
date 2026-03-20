import 'package:suwater_mobile/core/api/dio_client.dart';
import 'package:suwater_mobile/core/api/endpoints.dart';

class CitizenProfile {
  final String id;
  final String userId;
  final String? fullName;
  final String? homeNumber;
  final String? meterNumber;
  final String? abonentNumber;
  final String? installedDate;
  final String? meterPhotoUrl;
  final String? region;
  final String? district;
  final String? address;

  CitizenProfile({
    required this.id,
    required this.userId,
    this.fullName,
    this.homeNumber,
    this.meterNumber,
    this.abonentNumber,
    this.installedDate,
    this.meterPhotoUrl,
    this.region,
    this.district,
    this.address,
  });

  factory CitizenProfile.fromJson(Map<String, dynamic> json) {
    return CitizenProfile(
      id: json['id'],
      userId: json['user_id'],
      fullName: json['full_name'],
      homeNumber: json['home_number'],
      meterNumber: json['meter_number'],
      abonentNumber: json['abonent_number'],
      installedDate: json['installed_date'],
      meterPhotoUrl: json['meter_photo_url'],
      region: json['region'],
      district: json['district'],
      address: json['address'],
    );
  }
}

class WaterReading {
  final String id;
  final double readingValue;
  final String readingDate;
  final String? notes;
  final String createdAt;

  WaterReading({
    required this.id,
    required this.readingValue,
    required this.readingDate,
    this.notes,
    required this.createdAt,
  });

  factory WaterReading.fromJson(Map<String, dynamic> json) {
    return WaterReading(
      id: json['id'],
      readingValue: double.parse(json['reading_value'].toString()),
      readingDate: json['reading_date'],
      notes: json['notes'],
      createdAt: json['created_at'],
    );
  }
}

class CitizenRepository {
  final _dio = DioClient().dio;

  // ─── Profile ─────────────────────────────────────────────────────────────

  Future<CitizenProfile> getProfile() async {
    final response = await _dio.get(Endpoints.citizenProfile);
    return CitizenProfile.fromJson(response.data);
  }

  Future<CitizenProfile> updateProfile(Map<String, dynamic> data) async {
    final response = await _dio.put(Endpoints.citizenProfile, data: data);
    return CitizenProfile.fromJson(response.data);
  }

  // ─── Water Readings ──────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getLatestReading() async {
    final response = await _dio.get(Endpoints.citizenReadingsLatest);
    final data = response.data;
    if (data == null || data is String) {
      return {'latest': null, 'total_consumption': 0.0};
    }
    return {
      'latest': data['latest'] != null ? WaterReading.fromJson(data['latest']) : null,
      'total_consumption': double.tryParse(data['total_consumption'].toString()) ?? 0.0,
    };
  }

  Future<Map<String, dynamic>> getReadings({int page = 1, int limit = 20}) async {
    final response = await _dio.get(
      Endpoints.citizenReadings,
      queryParameters: {'page': page, 'limit': limit},
    );
    final data = response.data;
    return {
      'data': (data['data'] as List).map((e) => WaterReading.fromJson(e)).toList(),
      'total': data['total'],
      'page': data['page'],
      'totalPages': data['totalPages'],
    };
  }

  Future<WaterReading> createReading({
    required double readingValue,
    String? readingDate,
    String? notes,
  }) async {
    final response = await _dio.post(
      Endpoints.citizenReadings,
      data: {
        'reading_value': readingValue,
        if (readingDate != null) 'reading_date': readingDate,
        if (notes != null) 'notes': notes,
      },
    );
    return WaterReading.fromJson(response.data);
  }

  Future<void> deleteReading(String id) async {
    await _dio.delete(Endpoints.citizenReading(id));
  }
}
