import 'package:flutter/material.dart';
import 'package:suwater_mobile/core/theme/app_theme.dart';
import 'package:suwater_mobile/models/event.dart';

class StatsRow extends StatelessWidget {
  final Map<EventStatus, int> counts;
  final int total;
  final EventStatus? activeFilter;
  final ValueChanged<EventStatus?> onTap;

  const StatsRow({
    super.key,
    required this.counts,
    required this.total,
    required this.activeFilter,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pills = [
      _PillData(
        label: 'In Progress',
        count: counts[EventStatus.inProgress] ?? 0,
        color: AppColors.statusInProgress,
        status: EventStatus.inProgress,
      ),
      _PillData(
        label: 'Assigned',
        count: counts[EventStatus.createdAssigned] ?? 0,
        color: AppColors.statusAssigned,
        status: EventStatus.createdAssigned,
      ),
      _PillData(
        label: 'Reported',
        count: counts[EventStatus.reported] ?? 0,
        color: AppColors.statusReported,
        status: EventStatus.reported,
      ),
      _PillData(
        label: 'Completed',
        count: counts[EventStatus.completed] ?? 0,
        color: AppColors.statusCompleted,
        status: EventStatus.completed,
      ),
    ];

    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: pills.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final pill = pills[index];
          final isActive = activeFilter == pill.status;

          return GestureDetector(
            onTap: () => onTap(isActive ? null : pill.status),
            child: Container(
              width: 84,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isActive
                    ? pill.color.withOpacity(0.15)
                    : AppColors.bgCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isActive
                      ? pill.color.withOpacity(0.4)
                      : AppColors.border,
                  width: isActive ? 1 : 0.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 3,
                    height: 28,
                    decoration: BoxDecoration(
                      color: pill.color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${pill.count}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isActive ? pill.color : AppColors.textPrimary,
                          height: 1.2,
                        ),
                      ),
                      Text(
                        pill.label,
                        style: const TextStyle(
                          fontSize: 9,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PillData {
  final String label;
  final int count;
  final Color color;
  final EventStatus status;

  const _PillData({
    required this.label,
    required this.count,
    required this.color,
    required this.status,
  });
}
