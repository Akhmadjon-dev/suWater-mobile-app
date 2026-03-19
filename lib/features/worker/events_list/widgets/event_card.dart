import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:suwater_mobile/core/theme/app_theme.dart';
import 'package:suwater_mobile/core/theme/status_helpers.dart';
import 'package:suwater_mobile/models/event.dart';
import 'package:intl/intl.dart';

class EventCard extends StatelessWidget {
  final WaterEvent event;
  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final statusColor = StatusHelpers.statusColor(event.status);

    return GestureDetector(
      onTap: () => context.go('/worker/events/${event.id}'),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(
          children: [
            // Status color bar
            Container(
              height: 3,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Priority + Time row
                  Row(
                    children: [
                      PriorityDot(priority: event.priority),
                      const Spacer(),
                      Text(
                        _formatDate(event.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Title + chevron
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: AppColors.textMuted,
                      ),
                    ],
                  ),

                  // Description excerpt
                  if (event.description != null &&
                      event.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      event.description!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                        height: 1.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  // Address
                  if (event.address != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 14, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.address!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Bottom: type badge + supervisor
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      StatusBadge(
                        label: event.type.label,
                        color: AppColors.textSecondary,
                        icon: StatusHelpers.typeIcon(event.type),
                      ),
                      if (event.supervisorName != null) ...[
                        const Spacer(),
                        Icon(Icons.person_outlined,
                            size: 13, color: AppColors.textMuted),
                        const SizedBox(width: 3),
                        Text(
                          event.supervisorName!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      final now = DateTime.now();
      final diff = now.difference(dt);

      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return DateFormat('MMM d').format(dt);
    } catch (_) {
      return iso;
    }
  }
}
