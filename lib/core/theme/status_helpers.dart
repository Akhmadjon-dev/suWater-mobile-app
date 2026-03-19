import 'package:flutter/material.dart';
import 'package:suwater_mobile/core/theme/app_theme.dart';
import 'package:suwater_mobile/models/event.dart';

class StatusHelpers {
  StatusHelpers._();

  static Color statusColor(EventStatus status) {
    switch (status) {
      case EventStatus.reported:
        return AppColors.statusReported;
      case EventStatus.createdAssigned:
        return AppColors.statusAssigned;
      case EventStatus.inProgress:
        return AppColors.statusInProgress;
      case EventStatus.completed:
        return AppColors.statusCompleted;
      case EventStatus.cancelled:
        return AppColors.statusCancelled;
      case EventStatus.archived:
        return AppColors.statusArchived;
    }
  }

  static Color priorityColor(EventPriority priority) {
    switch (priority) {
      case EventPriority.low:
        return AppColors.priorityLow;
      case EventPriority.medium:
        return AppColors.priorityMedium;
      case EventPriority.high:
        return AppColors.priorityHigh;
      case EventPriority.critical:
        return AppColors.priorityCritical;
    }
  }

  static IconData typeIcon(EventType type) {
    switch (type) {
      case EventType.leak:
        return Icons.opacity;
      case EventType.pipeBurst:
        return Icons.water_drop;
      case EventType.contamination:
        return Icons.warning_amber;
      case EventType.valveFailure:
        return Icons.build;
      case EventType.hydrantDamage:
        return Icons.local_fire_department;
      case EventType.other:
        return Icons.report_problem;
    }
  }
}

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class PriorityDot extends StatelessWidget {
  final EventPriority priority;
  final bool showLabel;

  const PriorityDot({
    super.key,
    required this.priority,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = StatusHelpers.priorityColor(priority);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        if (showLabel) ...[
          const SizedBox(width: 6),
          Text(
            priority.label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
