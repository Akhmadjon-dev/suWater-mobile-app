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
      id: json['id'] as String,
      readingValue: double.parse(json['reading_value'].toString()),
      readingDate: json['reading_date'] as String,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] as String,
    );
  }
}

class LatestReadingResponse {
  final WaterReading? latest;
  final double totalConsumption;

  const LatestReadingResponse({this.latest, this.totalConsumption = 0.0});
}

class ReadingsResponse {
  final List<WaterReading> data;
  final int total;
  final int page;
  final int totalPages;

  const ReadingsResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.totalPages,
  });
}
