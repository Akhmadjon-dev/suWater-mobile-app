import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:suwater_mobile/core/theme/app_theme.dart';
import 'package:suwater_mobile/providers/upload_provider.dart';

class DocumentsSection extends ConsumerStatefulWidget {
  final String eventId;

  const DocumentsSection({super.key, required this.eventId});

  @override
  ConsumerState<DocumentsSection> createState() => _DocumentsSectionState();
}

class _DocumentsSectionState extends ConsumerState<DocumentsSection> {
  final _picker = ImagePicker();

  Future<void> _pickAndUpload(ImageSource source) async {
    final file = await _picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (file == null) return;

    final doc = await ref.read(uploadProvider.notifier).upload(
          filePath: file.path,
          fileName: file.name,
          eventId: widget.eventId,
        );

    if (doc != null) {
      ref.invalidate(eventDocumentsProvider(widget.eventId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final docsAsync = ref.watch(eventDocumentsProvider(widget.eventId));
    final uploadState = ref.watch(uploadProvider);
    final docsRepo = ref.read(documentsRepositoryProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 0),
            child: Row(
              children: [
                const Text(
                  'Evidence & Media',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.camera_alt_outlined, size: 20),
                  color: AppColors.primary,
                  onPressed: uploadState.isUploading
                      ? null
                      : () => _pickAndUpload(ImageSource.camera),
                ),
                IconButton(
                  icon: const Icon(Icons.photo_library_outlined, size: 20),
                  color: AppColors.primary,
                  onPressed: uploadState.isUploading
                      ? null
                      : () => _pickAndUpload(ImageSource.gallery),
                ),
              ],
            ),
          ),

          if (uploadState.isUploading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: LinearProgressIndicator(
                color: AppColors.primary,
                backgroundColor: AppColors.bgSurface,
              ),
            ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: docsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
              error: (_, __) => const Text(
                'Failed to load',
                style: TextStyle(color: AppColors.textMuted),
              ),
              data: (docs) {
                if (docs.isEmpty) {
                  return const Text(
                    'No files attached',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
                  );
                }

                final images = docs.where((d) => d.isImage).toList();
                final others = docs.where((d) => !d.isImage).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (images.isNotEmpty)
                      SizedBox(
                        height: 100,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: images.length + 1,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            // Add photo button at the end
                            if (index == images.length) {
                              return GestureDetector(
                                onTap: () =>
                                    _pickAndUpload(ImageSource.camera),
                                child: Container(
                                  width: 100,
                                  decoration: BoxDecoration(
                                    color: AppColors.bgSurface,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.border,
                                      width: 1,
                                    ),
                                  ),
                                  child: const Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_a_photo_outlined,
                                        color: AppColors.textMuted,
                                        size: 24,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'ADD PHOTO',
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: AppColors.textMuted,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            final doc = images[index];
                            final url = docsRepo.getFileUrl(doc.id);
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: url,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Container(
                                  width: 100,
                                  color: AppColors.bgSurface,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                errorWidget: (_, __, ___) => Container(
                                  width: 100,
                                  color: AppColors.bgSurface,
                                  child: const Icon(
                                    Icons.broken_image,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                    // Other files
                    ...others.map((doc) => Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.bgSurface,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: doc.isPdf
                                        ? Colors.red.withOpacity(0.15)
                                        : AppColors.bgElevated,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(
                                    doc.isVideo
                                        ? Icons.videocam
                                        : doc.isPdf
                                            ? Icons.picture_as_pdf
                                            : Icons.insert_drive_file,
                                    color: doc.isPdf
                                        ? Colors.red
                                        : AppColors.textSecondary,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        doc.fileName,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textPrimary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        _formatFileSize(doc.fileSizeBytes),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.download_outlined,
                                  color: AppColors.textMuted,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        )),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
