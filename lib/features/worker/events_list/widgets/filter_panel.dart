import 'package:flutter/material.dart';
import 'package:suwater_mobile/core/theme/app_theme.dart';
import 'package:suwater_mobile/core/theme/status_helpers.dart';
import 'package:suwater_mobile/models/event.dart';

class FilterPanel extends StatelessWidget {
  final EventStatus? selectedStatus;
  final EventType? selectedType;
  final EventPriority? selectedPriority;
  final bool hasActiveFilters;
  final ValueChanged<EventStatus?> onStatusChanged;
  final ValueChanged<EventType?> onTypeChanged;
  final ValueChanged<EventPriority?> onPriorityChanged;
  final VoidCallback onClear;

  const FilterPanel({
    super.key,
    this.selectedStatus,
    this.selectedType,
    this.selectedPriority,
    required this.hasActiveFilters,
    required this.onStatusChanged,
    required this.onTypeChanged,
    required this.onPriorityChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status chips
          const Text(
            'STATUS',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _StatusChip(
                  label: 'All',
                  color: AppColors.textSecondary,
                  isSelected: selectedStatus == null,
                  onTap: () => onStatusChanged(null),
                ),
                const SizedBox(width: 6),
                ...EventStatus.values
                    .where((s) => s != EventStatus.archived)
                    .map((s) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _StatusChip(
                      label: s.label,
                      color: StatusHelpers.statusColor(s),
                      isSelected: selectedStatus == s,
                      onTap: () => onStatusChanged(
                          selectedStatus == s ? null : s),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Type + Priority row
          Row(
            children: [
              Expanded(
                child: _DropdownChip<EventType>(
                  label: 'Type',
                  value: selectedType,
                  items: EventType.values,
                  itemLabel: (t) => t.label,
                  onChanged: onTypeChanged,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DropdownChip<EventPriority>(
                  label: 'Priority',
                  value: selectedPriority,
                  items: EventPriority.values,
                  itemLabel: (p) => p.label,
                  onChanged: onPriorityChanged,
                ),
              ),
            ],
          ),

          // Clear button
          if (hasActiveFilters) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: onClear,
              child: const Text(
                'Clear all filters',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusChip({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : AppColors.bgSurface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? color.withOpacity(0.4) : AppColors.border,
            width: isSelected ? 1 : 0.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? color : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _DropdownChip<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;

  const _DropdownChip({
    required this.label,
    this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: AppColors.bgCard,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          ),
          builder: (ctx) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text(
                      'All ${label}s',
                      style: TextStyle(
                        color: value == null
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                    ),
                    trailing: value == null
                        ? const Icon(Icons.check, color: AppColors.primary, size: 18)
                        : null,
                    onTap: () {
                      onChanged(null);
                      Navigator.pop(ctx);
                    },
                  ),
                  ...items.map((item) {
                    final isSelected = item == value;
                    return ListTile(
                      title: Text(
                        itemLabel(item),
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check, color: AppColors.primary, size: 18)
                          : null,
                      onTap: () {
                        onChanged(item);
                        Navigator.pop(ctx);
                      },
                    );
                  }),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: value != null
              ? AppColors.primary.withOpacity(0.08)
              : AppColors.bgSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: value != null
                ? AppColors.primary.withOpacity(0.3)
                : AppColors.border,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value != null ? '$label: ${itemLabel(value as T)}' : '$label: All',
                style: TextStyle(
                  fontSize: 13,
                  color: value != null
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: value != null
                  ? AppColors.primary
                  : AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
