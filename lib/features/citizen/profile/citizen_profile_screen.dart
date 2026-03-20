import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suwater_mobile/core/theme/app_theme.dart';
import 'package:suwater_mobile/core/data/uzbekistan_regions.dart' show regionNames, getDistricts, matchRegion, matchDistrict;
import 'package:suwater_mobile/core/widgets/address_search_field.dart';
import 'package:suwater_mobile/providers/auth_provider.dart';
import 'package:suwater_mobile/providers/citizen_provider.dart';

class CitizenProfileScreen extends ConsumerStatefulWidget {
  const CitizenProfileScreen({super.key});

  @override
  ConsumerState<CitizenProfileScreen> createState() => _CitizenProfileScreenState();
}

class _CitizenProfileScreenState extends ConsumerState<CitizenProfileScreen> {
  void _showEditDialog() {
    final profile = ref.read(citizenProfileProvider).profile;
    final user = ref.read(authProvider).user;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _EditProfileSheet(
        profile: profile,
        userName: user?.name ?? '',
        onSave: (data) async {
          final ok = await ref
              .read(citizenProfileProvider.notifier)
              .updateProfile(data);
          if (ok && mounted) Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final profileState = ref.watch(citizenProfileProvider);
    final profile = profileState.profile;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  (profile?.fullName ?? user?.name ?? '?')[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              profile?.fullName ?? user?.name ?? 'User',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user?.email ?? '',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _showEditDialog,
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Tahrirlash'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary, width: 0.5),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Column(
                children: [
                  _InfoRow(label: 'Telefon', value: user?.phone ?? '-'),
                  _InfoRow(label: 'Uy raqami', value: profile?.homeNumber ?? '-'),
                  _InfoRow(label: 'Hisoblagich', value: profile?.meterNumber ?? '-'),
                  _InfoRow(label: 'Abonent', value: profile?.abonentNumber ?? '-'),
                  _InfoRow(label: 'Viloyat', value: profile?.region ?? '-'),
                  _InfoRow(label: 'Tuman', value: profile?.district ?? '-'),
                  _InfoRow(label: 'Manzil', value: profile?.address ?? '-', isLast: true),
                ],
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => ref.read(authProvider.notifier).logout(),
                icon: const Icon(Icons.logout, color: AppColors.error, size: 18),
                label: const Text('Chiqish', style: TextStyle(color: AppColors.error)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error, width: 0.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Edit Profile Sheet ─────────────────────────────────────────────────────

class _EditProfileSheet extends StatefulWidget {
  final dynamic profile;
  final String userName;
  final Future<void> Function(Map<String, dynamic>) onSave;

  const _EditProfileSheet({
    required this.profile,
    required this.userName,
    required this.onSave,
  });

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late TextEditingController _fullNameC;
  late TextEditingController _homeNumberC;
  late TextEditingController _meterNumberC;
  late TextEditingController _abonentNumberC;

  String? _selectedRegion;
  String? _selectedDistrict;
  String? _address;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _fullNameC = TextEditingController(text: p?.fullName ?? widget.userName);
    _homeNumberC = TextEditingController(text: p?.homeNumber ?? '');
    _meterNumberC = TextEditingController(text: p?.meterNumber ?? '');
    _abonentNumberC = TextEditingController(text: p?.abonentNumber ?? '');
    _selectedRegion = (p?.region != null && regionNames.contains(p.region))
        ? p.region
        : null;
    _selectedDistrict = (p?.district != null &&
            _selectedRegion != null &&
            getDistricts(_selectedRegion!).contains(p.district))
        ? p.district
        : null;
    _address = p?.address;
  }

  @override
  void dispose() {
    _fullNameC.dispose();
    _homeNumberC.dispose();
    _meterNumberC.dispose();
    _abonentNumberC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final districts = _selectedRegion != null
        ? getDistricts(_selectedRegion!)
        : <String>[];

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scrollController) => Padding(
        padding: EdgeInsets.fromLTRB(
          20, 12, 20,
          MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: ListView(
          controller: scrollController,
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
              'Ma\'lumotlarni tahrirlash',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),

            _EditField(label: 'To\'liq ism', controller: _fullNameC),
            _EditField(label: 'Uy raqami', controller: _homeNumberC),
            _EditField(label: 'Hisoblagich raqami', controller: _meterNumberC),
            _EditField(label: 'Abonent raqami', controller: _abonentNumberC),

            // Region dropdown
            const SizedBox(height: 2),
            const Text(
              'Viloyat',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedRegion,
                  hint: const Text(
                    'Viloyatni tanlang',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                  ),
                  dropdownColor: AppColors.bgElevated,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                  icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted),
                  items: regionNames.map((r) => DropdownMenuItem(
                    value: r,
                    child: Text(r),
                  )).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedRegion = val;
                      _selectedDistrict = null;
                    });
                  },
                ),
              ),
            ),

            // District dropdown
            const SizedBox(height: 14),
            const Text(
              'Tuman',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedDistrict,
                  hint: Text(
                    _selectedRegion == null
                        ? 'Avval viloyatni tanlang'
                        : 'Tumanni tanlang',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
                  ),
                  dropdownColor: AppColors.bgElevated,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                  icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted),
                  items: districts.map((d) => DropdownMenuItem(
                    value: d,
                    child: Text(d),
                  )).toList(),
                  onChanged: _selectedRegion == null
                      ? null
                      : (val) => setState(() => _selectedDistrict = val),
                ),
              ),
            ),

            // Address search
            const SizedBox(height: 14),
            const Text(
              'Manzil',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            AddressSearchField(
              initialValue: _address,
              hintText: 'Ko\'cha nomi yoki mo\'ljal',
              onSelected: (result) {
                _address = result.shortName;
                // Auto-fill region and district from Nominatim
                final matched = matchRegion(result.state);
                if (matched != null) {
                  setState(() {
                    _selectedRegion = matched;
                    final matchedDistrict = matchDistrict(
                      result.county ?? result.city, matched,
                    );
                    _selectedDistrict = matchedDistrict;
                  });
                }
              },
            ),

            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saving
                    ? null
                    : () async {
                        setState(() => _saving = true);
                        await widget.onSave({
                          'full_name': _fullNameC.text,
                          'home_number': _homeNumberC.text,
                          'meter_number': _meterNumberC.text,
                          'abonent_number': _abonentNumberC.text,
                          'region': _selectedRegion ?? '',
                          'district': _selectedDistrict ?? '',
                          'address': _address ?? '',
                        });
                        if (mounted) setState(() => _saving = false);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white,
                        ),
                      )
                    : const Text(
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
}

// ─── Shared Widgets ─────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const _InfoRow({required this.label, required this.value, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
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
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _EditField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const _EditField({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          filled: true,
          fillColor: AppColors.bgSurface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
