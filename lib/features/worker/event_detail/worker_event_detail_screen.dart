import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:suwater_mobile/core/theme/app_theme.dart';
import 'package:suwater_mobile/core/theme/status_helpers.dart';
import 'package:suwater_mobile/core/utils/date_formatter.dart';
import 'package:suwater_mobile/models/event.dart';
import 'package:suwater_mobile/providers/events_provider.dart';
import 'package:suwater_mobile/providers/upload_provider.dart';
import 'package:suwater_mobile/features/worker/event_detail/widgets/assignments_section.dart';
import 'package:suwater_mobile/features/worker/event_detail/widgets/comments_section.dart';
import 'package:suwater_mobile/features/worker/event_detail/widgets/documents_section.dart';
import 'package:suwater_mobile/features/worker/event_detail/widgets/transition_buttons.dart';
import 'package:suwater_mobile/features/worker/event_detail/widgets/resources_section.dart';

class WorkerEventDetailScreen extends ConsumerWidget {
  final String eventId;

  const WorkerEventDetailScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventDetailProvider(eventId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/worker'),
        ),
        title: const Text('Event Detail'),
      ),
      body: eventAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2.5,
          ),
        ),
        error: (err, _) => Center(
          child: Text('Error: $err',
              style: const TextStyle(color: AppColors.error)),
        ),
        data: (event) => RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.bgCard,
          onRefresh: () async {
            ref.invalidate(eventDetailProvider(eventId));
            ref.invalidate(eventAssignmentsProvider(eventId));
            ref.invalidate(eventCommentsProvider(eventId));
            ref.invalidate(eventDocumentsProvider(eventId));
            ref.invalidate(eventLaborProvider(eventId));
            ref.invalidate(eventEquipmentProvider(eventId));
            ref.invalidate(eventMaterialsProvider(eventId));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status header bar
                _StatusHeader(event: event),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title + description
                      Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          height: 1.2,
                        ),
                      ),
                      if (event.description != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          event.description!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),

                      // Info cards row
                      _InfoCardsRow(event: event),
                      const SizedBox(height: 16),

                      // Supervisor
                      if (event.supervisorName != null) ...[
                        _AssignedToCard(name: event.supervisorName!),
                        const SizedBox(height: 16),
                      ],

                      // Location
                      if (event.address != null) ...[
                        _LocationCard(event: event),
                        const SizedBox(height: 16),
                      ],

                      // Details
                      if (event.details != null) ...[
                        _SectionTitle(title: 'Details'),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.bgCard,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.border,
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            event.details!,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Completion notes
                      if (event.completionNotes != null) ...[
                        _SectionTitle(title: 'Completion Notes'),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.success.withOpacity(0.3),
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.check_circle, size: 18, color: AppColors.success),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  event.completionNotes!,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Created at timestamp
                      _MetaRow(
                        label: 'Created',
                        value: DateFormatter.relative(event.createdAt),
                      ),
                      if (event.completedAt != null)
                        _MetaRow(
                          label: 'Completed',
                          value: DateFormatter.relative(event.completedAt!),
                        ),
                      const SizedBox(height: 16),

                      // Transition buttons
                      TransitionButtons(event: event, eventId: eventId),
                      const SizedBox(height: 16),

                      // Documents
                      DocumentsSection(eventId: eventId),
                      const SizedBox(height: 16),

                      // Resources (Labor, Equipment, Materials)
                      ResourcesSection(eventId: eventId),
                      const SizedBox(height: 16),

                      // Assignments
                      AssignmentsSection(eventId: eventId),
                      const SizedBox(height: 16),

                      // Comments
                      CommentsSection(eventId: eventId),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusHeader extends StatelessWidget {
  final WaterEvent event;
  const _StatusHeader({required this.event});

  @override
  Widget build(BuildContext context) {
    final color = StatusHelpers.statusColor(event.status);
    final priorityColor = StatusHelpers.priorityColor(event.priority);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.25), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(
          bottom: BorderSide(color: color.withOpacity(0.3), width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            event.priority == EventPriority.critical
                ? Icons.warning_amber_rounded
                : StatusHelpers.typeIcon(event.type),
            color: color,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${event.status.label.toUpperCase()} - ${event.type.label.toUpperCase()}',
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: priorityColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: priorityColor.withOpacity(0.4),
                width: 0.5,
              ),
            ),
            child: Text(
              event.priority.label.toUpperCase(),
              style: TextStyle(
                color: priorityColor,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCardsRow extends StatelessWidget {
  final WaterEvent event;
  const _InfoCardsRow({required this.event});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _InfoCard(
            label: 'PRIORITY',
            child: PriorityDot(priority: event.priority),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _InfoCard(
            label: 'SCHEDULED',
            child: Text(
              DateFormatter.scheduled(event.scheduledDate),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final Widget child;
  const _InfoCard({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _AssignedToCard extends StatelessWidget {
  final String name;
  const _AssignedToCard({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                name[0].toUpperCase(),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ASSIGNED TO',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chat_bubble_outline,
            color: AppColors.textMuted,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  final WaterEvent event;
  const _LocationCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Location',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                'OPEN IN MAPS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.location_on,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  event.address!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          if (event.latitude != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.gps_fixed,
                  size: 14,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 6),
                Text(
                  '${event.latitude!.toStringAsFixed(4)}, ${event.longitude!.toStringAsFixed(4)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final String label;
  final String value;
  const _MetaRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            label == 'Completed' ? Icons.check_circle_outline : Icons.access_time,
            size: 14,
            color: AppColors.textMuted,
          ),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
