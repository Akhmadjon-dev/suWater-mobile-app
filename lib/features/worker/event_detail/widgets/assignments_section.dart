import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suwater_mobile/core/theme/app_theme.dart';
import 'package:suwater_mobile/providers/events_provider.dart';
import 'package:suwater_mobile/providers/auth_provider.dart';

class AssignmentsSection extends ConsumerWidget {
  final String eventId;

  const AssignmentsSection({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignmentsAsync = ref.watch(eventAssignmentsProvider(eventId));
    final currentUser = ref.watch(authProvider).user;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Text(
              'Assigned Workers',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          assignmentsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            ),
            error: (_, __) => const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Failed to load',
                style: TextStyle(color: AppColors.textMuted),
              ),
            ),
            data: (assignments) {
              if (assignments.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Text(
                    'No workers assigned yet',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                itemCount: assignments.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, index) {
                  final a = assignments[index];
                  final isMe =
                      currentUser != null && a.userId == currentUser.id;

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe
                          ? AppColors.primary.withOpacity(0.08)
                          : AppColors.bgSurface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isMe
                            ? AppColors.primary.withOpacity(0.3)
                            : AppColors.border,
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isMe
                                ? AppColors.primary.withOpacity(0.2)
                                : AppColors.bgElevated,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              (a.workerName ?? '?')[0].toUpperCase(),
                              style: TextStyle(
                                color: isMe
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${a.workerName ?? "Worker"}${isMe ? " (You)" : ""}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isMe
                                      ? AppColors.primary
                                      : AppColors.textPrimary,
                                ),
                              ),
                              if (a.workerPhone != null ||
                                  a.workerEmail != null)
                                Text(
                                  a.workerPhone ?? a.workerEmail ?? '',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: a.role == 'lead'
                                ? AppColors.primary.withOpacity(0.15)
                                : AppColors.bgElevated,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            a.role.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: a.role == 'lead'
                                  ? AppColors.primary
                                  : AppColors.textMuted,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
