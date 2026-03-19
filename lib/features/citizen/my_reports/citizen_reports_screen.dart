import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suwater_mobile/core/theme/app_theme.dart';
import 'package:suwater_mobile/core/theme/status_helpers.dart';
import 'package:suwater_mobile/models/event.dart';
import 'package:suwater_mobile/providers/events_provider.dart';

class CitizenReportsScreen extends ConsumerStatefulWidget {
  const CitizenReportsScreen({super.key});

  @override
  ConsumerState<CitizenReportsScreen> createState() =>
      _CitizenReportsScreenState();
}

class _CitizenReportsScreenState extends ConsumerState<CitizenReportsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(eventsProvider.notifier).loadEvents());
  }

  @override
  Widget build(BuildContext context) {
    final eventsState = ref.watch(eventsProvider);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Row(
              children: [
                const Icon(Icons.water_drop, color: AppColors.primary, size: 28),
                const SizedBox(width: 10),
                const Text(
                  'WaterFlow',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Text(
              'My Reports',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ),
          const Divider(height: 1),

          // Content
          Expanded(
            child: eventsState.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2.5,
                    ),
                  )
                : eventsState.events.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: AppColors.bgSurface,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.water_drop_outlined,
                                size: 36,
                                color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No reports yet',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Tap the report button to submit an emergency',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: AppColors.primary,
                        backgroundColor: AppColors.bgCard,
                        onRefresh: () =>
                            ref.read(eventsProvider.notifier).refresh(),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: eventsState.events.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            return _ReportCard(
                                event: eventsState.events[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final WaterEvent event;
  const _ReportCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final statusColor = StatusHelpers.statusColor(event.status);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        children: [
          Container(
            height: 3,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    StatusBadge(
                      label: event.status.label,
                      color: statusColor,
                    ),
                    const Spacer(),
                    Text(
                      event.type.label,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (event.address != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 15, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.address!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                if (event.supervisorName != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.person_outlined,
                          size: 15, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        'Assigned: ${event.supervisorName}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 14),
                _StatusProgress(status: event.status),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusProgress extends StatelessWidget {
  final EventStatus status;
  const _StatusProgress({required this.status});

  int get _step {
    switch (status) {
      case EventStatus.reported:
        return 0;
      case EventStatus.createdAssigned:
        return 1;
      case EventStatus.inProgress:
        return 2;
      case EventStatus.completed:
        return 3;
      case EventStatus.cancelled:
        return -1;
      case EventStatus.archived:
        return 4;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (status == EventStatus.cancelled) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text(
          'CANCELLED',
          style: TextStyle(
            color: AppColors.error,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      );
    }

    final labels = ['Reported', 'Assigned', 'In Progress', 'Completed'];
    final step = _step;

    return Row(
      children: List.generate(labels.length, (i) {
        final done = i <= step;
        return Expanded(
          child: Column(
            children: [
              Container(
                height: 3,
                margin: EdgeInsets.only(right: i < labels.length - 1 ? 4 : 0),
                decoration: BoxDecoration(
                  color: done ? AppColors.success : AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                labels[i],
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: done ? AppColors.success : AppColors.textMuted,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
