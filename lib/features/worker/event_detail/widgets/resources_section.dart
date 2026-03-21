import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suwater_mobile/core/theme/app_theme.dart';
import 'package:suwater_mobile/models/event.dart';
import 'package:suwater_mobile/providers/events_provider.dart';

class ResourcesSection extends ConsumerWidget {
  final String eventId;

  const ResourcesSection({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LaborSubSection(eventId: eventId),
        const SizedBox(height: 16),
        _EquipmentSubSection(eventId: eventId),
        const SizedBox(height: 16),
        _MaterialsSubSection(eventId: eventId),
      ],
    );
  }
}

class _LaborSubSection extends ConsumerWidget {
  final String eventId;
  const _LaborSubSection({required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final laborAsync = ref.watch(eventLaborProvider(eventId));

    return _ResourceCard(
      title: 'Labor',
      icon: Icons.engineering,
      child: laborAsync.when(
        loading: () => const _LoadingRow(),
        error: (e, _) => _ErrorRow(message: '$e'),
        data: (labor) => labor.isEmpty
            ? const _EmptyRow(text: 'No labor records')
            : Column(
                children: labor.map((l) => _LaborTile(labor: l)).toList(),
              ),
      ),
    );
  }
}

class _EquipmentSubSection extends ConsumerWidget {
  final String eventId;
  const _EquipmentSubSection({required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final equipAsync = ref.watch(eventEquipmentProvider(eventId));

    return _ResourceCard(
      title: 'Equipment',
      icon: Icons.construction,
      child: equipAsync.when(
        loading: () => const _LoadingRow(),
        error: (e, _) => _ErrorRow(message: '$e'),
        data: (equipment) => equipment.isEmpty
            ? const _EmptyRow(text: 'No equipment records')
            : Column(
                children:
                    equipment.map((e) => _EquipmentTile(equipment: e)).toList(),
              ),
      ),
    );
  }
}

class _MaterialsSubSection extends ConsumerWidget {
  final String eventId;
  const _MaterialsSubSection({required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matsAsync = ref.watch(eventMaterialsProvider(eventId));

    return _ResourceCard(
      title: 'Materials',
      icon: Icons.inventory_2,
      child: matsAsync.when(
        loading: () => const _LoadingRow(),
        error: (e, _) => _ErrorRow(message: '$e'),
        data: (materials) => materials.isEmpty
            ? const _EmptyRow(text: 'No material records')
            : Column(
                children:
                    materials.map((m) => _MaterialTile(material: m)).toList(),
              ),
      ),
    );
  }
}

class _ResourceCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _ResourceCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          child,
        ],
      ),
    );
  }
}

class _LaborTile extends StatelessWidget {
  final EventLabor labor;
  const _LaborTile({required this.labor});

  @override
  Widget build(BuildContext context) {
    final name = labor.assignedWorkerName ?? labor.workerName ?? 'Unknown';
    return _TileRow(
      leading: Icons.person,
      title: name,
      subtitle: [
        if (labor.hoursType != null) labor.hoursType!,
        if (labor.workDate != null) labor.workDate!,
      ].join(' | '),
      trailing: labor.workedHours != null ? '${labor.workedHours}h' : null,
    );
  }
}

class _EquipmentTile extends StatelessWidget {
  final EventEquipment equipment;
  const _EquipmentTile({required this.equipment});

  @override
  Widget build(BuildContext context) {
    return _TileRow(
      leading: Icons.build,
      title: equipment.name,
      subtitle: [
        if (equipment.workDate != null) equipment.workDate!,
        if (equipment.units != null) '${equipment.units} units',
      ].join(' | '),
      trailing:
          equipment.hoursUsed != null ? '${equipment.hoursUsed}h' : null,
    );
  }
}

class _MaterialTile extends StatelessWidget {
  final EventMaterial material;
  const _MaterialTile({required this.material});

  @override
  Widget build(BuildContext context) {
    return _TileRow(
      leading: Icons.category,
      title: material.name,
      subtitle: [
        if (material.workDate != null) material.workDate!,
        if (material.unit != null) material.unit!,
      ].join(' | '),
      trailing: material.size,
    );
  }
}

class _TileRow extends StatelessWidget {
  final IconData leading;
  final String title;
  final String subtitle;
  final String? trailing;

  const _TileRow({
    required this.leading,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(leading, size: 16, color: AppColors.textMuted),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
              ],
            ),
          ),
          if (trailing != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                trailing!,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LoadingRow extends StatelessWidget {
  const _LoadingRow();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
        ),
      ),
    );
  }
}

class _ErrorRow extends StatelessWidget {
  final String message;
  const _ErrorRow({required this.message});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(message, style: const TextStyle(color: AppColors.error, fontSize: 12)),
    );
  }
}

class _EmptyRow extends StatelessWidget {
  final String text;
  const _EmptyRow({required this.text});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(text, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
    );
  }
}
