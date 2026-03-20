import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:suwater_mobile/core/theme/app_theme.dart';
import 'package:suwater_mobile/providers/citizen_provider.dart';
import 'package:suwater_mobile/repositories/citizen_repository.dart';

class CitizenHomeScreen extends ConsumerStatefulWidget {
  const CitizenHomeScreen({super.key});

  @override
  ConsumerState<CitizenHomeScreen> createState() => _CitizenHomeScreenState();
}

class _CitizenHomeScreenState extends ConsumerState<CitizenHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddReadingDialog() {
    final controller = TextEditingController();
    final notesController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          20, 20, 20,
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textMuted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Yangi ko\'rsatkich',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Hisoblagich ko\'rsatkichini kiriting',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: '0.00',
                hintStyle: TextStyle(color: AppColors.textMuted.withOpacity(0.5)),
                suffixText: 'm\u00B3',
                suffixStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
                filled: true,
                fillColor: AppColors.bgSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Izoh (ixtiyoriy)',
                hintStyle: const TextStyle(color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.bgSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  final value = double.tryParse(controller.text);
                  if (value == null || value <= 0) return;
                  final success = await ref.read(readingsProvider.notifier)
                      .addReading(value, notes: notesController.text.isNotEmpty ? notesController.text : null);
                  if (success && mounted) Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Saqlash',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final readingsState = ref.watch(readingsProvider);
    final profileState = ref.watch(citizenProfileProvider);

    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                const Icon(Icons.water_drop, color: AppColors.primary, size: 26),
                const SizedBox(width: 8),
                const Text(
                  'SuWater',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: -0.5,
                  ),
                ),
                const Spacer(),
                _HeaderIconButton(
                  icon: Icons.notifications_outlined,
                  onTap: () {},
                ),
                const SizedBox(width: 8),
                _HeaderIconButton(
                  icon: Icons.camera_alt_outlined,
                  onTap: _showAddReadingDialog,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Total consumption
          _CurrentReadingDisplay(
            totalConsumption: readingsState.totalConsumption,
            latest: readingsState.latest,
          ),

          const SizedBox(height: 24),

          // Tab toggle: Hisobim / Ma'lumotlarim
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(22),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(22),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.primary,
                labelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                dividerHeight: 0,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: const [
                  Tab(text: 'Hisobim'),
                  Tab(text: "Ma'lumotlarim"),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _ReadingsTab(
                  readingsState: readingsState,
                  onAddReading: _showAddReadingDialog,
                ),
                _ProfileTab(profileState: profileState),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Current Reading Display ────────────────────────────────────────────────

class _CurrentReadingDisplay extends StatelessWidget {
  final double totalConsumption;
  final WaterReading? latest;
  const _CurrentReadingDisplay({required this.totalConsumption, this.latest});

  @override
  Widget build(BuildContext context) {
    final parts = totalConsumption.toStringAsFixed(2).split('.');

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              parts[0],
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                height: 1,
              ),
            ),
            Text(
              '.${parts[1]}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const Text(
              ' m\u00B3',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
                height: 2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          latest != null
              ? 'Oxirgi: ${_formatDate(latest!.readingDate)}'
              : 'Hali ko\'rsatkich yo\'q',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inDays == 0) return 'Bugun';
      if (diff.inDays == 1) return 'Kecha';
      if (diff.inDays < 7) return '${diff.inDays} kun oldin';
      return DateFormat('dd.MM.yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }
}

// ─── Readings Tab ───────────────────────────────────────────────────────────

class _ReadingsTab extends StatelessWidget {
  final ReadingsState readingsState;
  final VoidCallback onAddReading;

  const _ReadingsTab({required this.readingsState, required this.onAddReading});

  @override
  Widget build(BuildContext context) {
    if (readingsState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5),
      );
    }

    if (readingsState.readings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.speed_outlined, size: 48, color: AppColors.textMuted.withOpacity(0.5)),
            const SizedBox(height: 12),
            const Text(
              'Hali ko\'rsatkich yo\'q',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: onAddReading,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Ko\'rsatkich qo\'shish'),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: readingsState.readings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) => _ReadingCard(reading: readingsState.readings[index]),
    );
  }
}

class _ReadingCard extends StatelessWidget {
  final WaterReading reading;
  const _ReadingCard({required this.reading});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Text(
            '${reading.readingValue.toStringAsFixed(2)} m\u00B3',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          Text(
            _formatRelative(reading.readingDate),
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatRelative(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inDays == 0) return 'Bugun';
      if (diff.inDays == 1) return 'Kecha';
      if (diff.inDays < 7) return '${diff.inDays} kun oldin';
      if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} hafta oldin';
      if (diff.inDays < 365) return '${(diff.inDays / 30).floor()} oy oldin';
      return DateFormat('dd.MM.yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }
}

// ─── Profile Tab ────────────────────────────────────────────────────────────

class _ProfileTab extends StatelessWidget {
  final CitizenProfileState profileState;
  const _ProfileTab({required this.profileState});

  @override
  Widget build(BuildContext context) {
    if (profileState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5),
      );
    }

    final profile = profileState.profile;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(
          children: [
            _ProfileRow(label: 'Ismi', value: profile?.fullName ?? '-'),
            _ProfileRow(label: 'Viloyat', value: profile?.region ?? '-'),
            _ProfileRow(label: 'Tuman', value: profile?.district ?? '-'),
            _ProfileRow(label: 'Uy', value: profile?.homeNumber ?? '-'),
            _ProfileRow(label: 'Abonent raqami', value: profile?.abonentNumber ?? '-'),
            _ProfileRow(label: 'Hisoblagich raqami', value: profile?.meterNumber ?? '-'),
            _ProfileRow(
              label: 'O\'rnatilgan sana',
              value: profile?.installedDate != null
                  ? _formatDate(profile!.installedDate!)
                  : '-',
            ),
            _ProfileRow(label: 'Manzil', value: profile?.address ?? '-', isLast: true),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      return DateFormat('dd.MM.yyyy').format(DateTime.parse(dateStr));
    } catch (_) {
      return dateStr;
    }
  }
}

class _ProfileRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const _ProfileRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: AppColors.border, width: 0.5),
              ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Header Icon Button ────────────────────────────────────────────────────

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
    );
  }
}
