import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:suwater_mobile/core/theme/app_theme.dart';
import 'package:suwater_mobile/models/event.dart';
import 'package:suwater_mobile/providers/events_provider.dart';
import 'package:suwater_mobile/providers/upload_provider.dart';
import 'package:suwater_mobile/core/widgets/address_search_field.dart';
import 'dart:io';

class CitizenReportScreen extends ConsumerStatefulWidget {
  const CitizenReportScreen({super.key});

  @override
  ConsumerState<CitizenReportScreen> createState() =>
      _CitizenReportScreenState();
}

class _CitizenReportScreenState extends ConsumerState<CitizenReportScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  int _selectedTypeIndex = 0;
  final List<XFile> _photos = [];
  double? _latitude;
  double? _longitude;
  bool _isSubmitting = false;
  bool _isLocating = false;
  final _picker = ImagePicker();

  static const _issueTypes = [
    _IssueType('Pipe Burst', Icons.water_drop, EventType.pipeBurst, Color(0xFF4A90D9)),
    _IssueType('Water Leak', Icons.opacity, EventType.leak, Color(0xFF6BA5E7)),
    _IssueType('Contamination', Icons.warning_amber, EventType.contamination, Color(0xFFFF8C42)),
    _IssueType('Valve Failure', Icons.build, EventType.valveFailure, Color(0xFF8B949E)),
    _IssueType('Hydrant Damage', Icons.local_fire_department, EventType.hydrantDamage, Color(0xFFDA3633)),
    _IssueType('Other', Icons.report_problem_outlined, EventType.other, Color(0xFF6E7681)),
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _getLocation() async {
    setState(() => _isLocating = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied')),
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not get location')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  Future<void> _pickMedia() async {
    if (_photos.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 3 files')),
      );
      return;
    }

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text('Take Photo',
                  style: TextStyle(color: AppColors.textPrimary)),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading:
                  const Icon(Icons.photo_library, color: AppColors.primary),
              title: const Text('Choose from Gallery',
                  style: TextStyle(color: AppColors.textPrimary)),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );

    if (source == null) return;

    final file = await _picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (file != null) {
      setState(() => _photos.add(file));
    }
  }

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }
    if (_photos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one photo as proof')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final eventsRepo = ref.read(eventsRepositoryProvider);
      final uploadNotifier = ref.read(uploadProvider.notifier);

      final selectedType = _issueTypes[_selectedTypeIndex].type;

      final event = await eventsRepo.createEvent(
        type: selectedType.value,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        latitude: _latitude,
        longitude: _longitude,
        address: _addressController.text.trim().isNotEmpty
            ? _addressController.text.trim()
            : null,
      );

      for (final photo in _photos) {
        await uploadNotifier.upload(
          filePath: photo.path,
          fileName: photo.name,
          eventId: event.id,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Report submitted successfully!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        ref.read(eventsProvider.notifier).refresh();
        context.go('/citizen');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/citizen'),
        ),
        title: const Text('Report Emergency'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            const SizedBox(height: 16),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.error,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Report Water Emergency',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Help us fix water issues faster by reporting\nproblems in your area',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Form card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Issue type
                  const Text(
                    "What's the issue?",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _IssueTypeGrid(
                    types: _issueTypes,
                    selectedIndex: _selectedTypeIndex,
                    onSelected: (i) =>
                        setState(() => _selectedTypeIndex = i),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  const _FieldLabel(label: 'Title'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _titleController,
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'e.g. Broken pipe on Main Street',
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Description
                  const _FieldLabel(label: 'Description', optional: true),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _descriptionController,
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 14),
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Any additional details that can help our team...',
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Address search
                  Row(
                    children: [
                      const _FieldLabel(label: 'Address'),
                      const Spacer(),
                      GestureDetector(
                        onTap: _isLocating ? null : _getLocation,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.4),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_isLocating)
                                const SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                )
                              else
                                const Icon(Icons.gps_fixed,
                                    size: 14, color: AppColors.primary),
                              const SizedBox(width: 5),
                              const Text(
                                'Use GPS',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  AddressSearchField(
                    hintText: 'Search address or nearby landmark',
                    onSelected: (result) {
                      setState(() {
                        _addressController.text = result.shortName;
                        _latitude = result.lat;
                        _longitude = result.lon;
                      });
                    },
                  ),

                  // Location status
                  if (_latitude != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.success.withOpacity(0.2),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle,
                              size: 15, color: AppColors.success),
                          const SizedBox(width: 8),
                          Text(
                            '${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Photo proof
                  Row(
                    children: [
                      const Text(
                        'Photo/Video Proof',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Text(
                        ' *',
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Photo thumbnails
                  if (_photos.isNotEmpty) ...[
                    SizedBox(
                      height: 80,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _photos.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 8),
                        itemBuilder: (_, index) {
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(_photos[index].path),
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => setState(
                                      () => _photos.removeAt(index)),
                                  child: Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      color: AppColors.bgDark.withOpacity(0.8),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close,
                                        size: 14, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  // Upload button
                  if (_photos.length < 3)
                    GestureDetector(
                      onTap: _pickMedia,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.border,
                            style: BorderStyle.solid,
                          ),
                          color: AppColors.bgSurface,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.upload_outlined,
                                size: 18, color: AppColors.textSecondary),
                            const SizedBox(width: 8),
                            Text(
                              _photos.isEmpty
                                  ? 'Tap to upload photo or video'
                                  : 'Add more (${_photos.length}/3)',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Submit button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.error,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Submit Emergency Report',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  final bool optional;

  const _FieldLabel({required this.label, this.optional = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        if (optional)
          const Text(
            ' (optional)',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
      ],
    );
  }
}

class _IssueTypeGrid extends StatelessWidget {
  final List<_IssueType> types;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _IssueTypeGrid({
    required this.types,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.1,
      ),
      itemCount: types.length,
      itemBuilder: (context, index) {
        final type = types[index];
        final isSelected = index == selectedIndex;

        return GestureDetector(
          onTap: () => onSelected(index),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? type.color.withOpacity(0.1)
                  : AppColors.bgSurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? type.color.withOpacity(0.5)
                    : AppColors.border,
                width: isSelected ? 1.5 : 0.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  type.icon,
                  size: 28,
                  color: isSelected ? type.color : AppColors.textMuted,
                ),
                const SizedBox(height: 6),
                Text(
                  type.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? type.color
                        : AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _IssueType {
  final String label;
  final IconData icon;
  final EventType type;
  final Color color;

  const _IssueType(this.label, this.icon, this.type, this.color);
}
