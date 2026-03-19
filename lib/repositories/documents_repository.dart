import 'package:dio/dio.dart';
import 'package:suwater_mobile/core/api/dio_client.dart';
import 'package:suwater_mobile/core/api/endpoints.dart';
import 'package:suwater_mobile/models/document.dart';

class DocumentsRepository {
  final _dio = DioClient().dio;

  Future<EventDocument> uploadFile({
    required String filePath,
    required String fileName,
    String? eventId,
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });

    final response = await _dio.post(
      Endpoints.documentsUpload,
      data: formData,
      queryParameters: {
        if (eventId != null) 'event_id': eventId,
      },
    );

    return EventDocument.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<EventDocument>> getEventDocuments(String eventId) async {
    final response = await _dio.get(Endpoints.eventDocuments(eventId));
    return (response.data as List)
        .map((e) => EventDocument.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> linkDocument(String documentId, String eventId) async {
    await _dio.patch(
      Endpoints.documentLink(documentId),
      data: {'event_id': eventId},
    );
  }

  /// Returns the full URL for a document file
  String getFileUrl(String documentId) {
    final baseUrl = _dio.options.baseUrl;
    return '$baseUrl${Endpoints.documentFile(documentId)}';
  }
}
