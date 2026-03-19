import 'package:flutter/material.dart';
import 'package:suwater_mobile/core/theme/app_theme.dart';
import 'package:suwater_mobile/core/theme/status_helpers.dart';
import 'package:suwater_mobile/models/event.dart';

class SectionHeader extends StatelessWidget {
  final EventStatus status;
  final int count;

  const SectionHeader({
    super.key,
    required this.status,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final color = StatusHelpers.statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.bgDark,
        border: Border(
          bottom: BorderSide(color: color.withOpacity(0.2), width: 1),
        ),
      ),
      child: Row(
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
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            status.label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          Text(
            '$count event${count == 1 ? '' : 's'}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
