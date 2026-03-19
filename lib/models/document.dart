class EventDocument {
  final String id;
  final String? eventId;
  final String? fileType;
  final String fileName;
  final int fileSizeBytes;
  final String? mimeType;
  final String url;

  const EventDocument({
    required this.id,
    this.eventId,
    this.fileType,
    required this.fileName,
    required this.fileSizeBytes,
    this.mimeType,
    required this.url,
  });

  factory EventDocument.fromJson(Map<String, dynamic> json) {
    return EventDocument(
      id: json['id'] as String,
      eventId: json['event_id'] as String?,
      fileType: json['file_type'] as String?,
      fileName: json['file_name'] as String,
      fileSizeBytes: json['file_size_bytes'] as int,
      mimeType: json['mime_type'] as String?,
      url: json['url'] as String? ?? '/api/v1/documents/${json['id']}/file',
    );
  }

  bool get isImage =>
      mimeType?.startsWith('image/') ?? false;

  bool get isVideo =>
      mimeType?.startsWith('video/') ?? false;

  bool get isPdf =>
      mimeType == 'application/pdf';
}
