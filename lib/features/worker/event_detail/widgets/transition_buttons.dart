import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suwater_mobile/core/theme/app_theme.dart';
import 'package:suwater_mobile/models/event.dart';
import 'package:suwater_mobile/providers/events_provider.dart';

class TransitionButtons extends ConsumerStatefulWidget {
  final WaterEvent event;
  final String eventId;

  const TransitionButtons({
    super.key,
    required this.event,
    required this.eventId,
  });

  @override
  ConsumerState<TransitionButtons> createState() => _TransitionButtonsState();
}

class _TransitionButtonsState extends ConsumerState<TransitionButtons> {
  bool _isTransitioning = false;

  Future<void> _doTransition(String status, {String? completionNotes}) async {
    setState(() => _isTransitioning = true);

    try {
      final repo = ref.read(eventsRepositoryProvider);
      await repo.transitionEvent(
        widget.eventId,
        status: status,
        completionNotes: completionNotes,
      );
      ref.invalidate(eventDetailProvider(widget.eventId));
      ref.read(eventsProvider.notifier).refresh();
    } catch (e) {
      debugPrint('TransitionButtons._doTransition failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update event status')),
        );
      }
    } finally {
      if (mounted) setState(() => _isTransitioning = false);
    }
  }

  Future<void> _showCompletionDialog() async {
    final controller = TextEditingController();
    final notes = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border),
        ),
        title: const Text(
          'Complete Event',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            labelText: 'Completion notes',
            hintText: 'Describe what was done...',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.success,
            ),
            child: const Text('Complete'),
          ),
        ],
      ),
    );

    if (notes != null) {
      _doTransition('COMPLETED', completionNotes: notes);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.event.status;

    if (status == EventStatus.completed ||
        status == EventStatus.cancelled ||
        status == EventStatus.archived) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        if (status == EventStatus.createdAssigned)
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isTransitioning ? null : () => _doTransition('IN_PROGRESS'),
              icon: _isTransitioning
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.play_arrow_rounded),
              label: const Text('START WORK'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        if (status == EventStatus.inProgress)
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isTransitioning ? null : _showCompletionDialog,
              icon: _isTransitioning
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check_circle_rounded),
              label: const Text('MARK COMPLETE'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.success,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
      ],
    );
  }
}
