import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suwater_mobile/models/document.dart';
import 'package:suwater_mobile/repositories/documents_repository.dart';

final documentsRepositoryProvider = Provider<DocumentsRepository>((ref) {
  return DocumentsRepository();
});

class UploadState {
  final bool isUploading;
  final String? error;
  final EventDocument? lastUploaded;

  const UploadState({
    this.isUploading = false,
    this.error,
    this.lastUploaded,
  });
}

class UploadNotifier extends StateNotifier<UploadState> {
  final DocumentsRepository _repo;

  UploadNotifier(this._repo) : super(const UploadState());

  Future<EventDocument?> upload({
    required String filePath,
    required String fileName,
    String? eventId,
  }) async {
    state = const UploadState(isUploading: true);
    try {
      final doc = await _repo.uploadFile(
        filePath: filePath,
        fileName: fileName,
        eventId: eventId,
      );
      state = UploadState(isUploading: false, lastUploaded: doc);
      return doc;
    } catch (e) {
      debugPrint('UploadNotifier.upload failed: $e');
      state = const UploadState(error: 'Upload failed');
      return null;
    }
  }
}

final uploadProvider =
    StateNotifierProvider<UploadNotifier, UploadState>((ref) {
  return UploadNotifier(ref.read(documentsRepositoryProvider));
});

// Event documents list
final eventDocumentsProvider =
    FutureProvider.family<List<EventDocument>, String>((ref, eventId) async {
  final repo = ref.read(documentsRepositoryProvider);
  return repo.getEventDocuments(eventId);
});
