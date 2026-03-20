import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:suwater_mobile/core/theme/app_theme.dart';
import 'package:suwater_mobile/core/data/uzbekistan_regions.dart';
import 'package:suwater_mobile/core/widgets/address_search_field.dart';
import 'package:suwater_mobile/providers/auth_provider.dart';
import 'package:suwater_mobile/providers/citizen_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _homeNumberController = TextEditingController();
  final _meterNumberController = TextEditingController();
  final _abonentNumberController = TextEditingController();
  bool _obscurePassword = true;
  String? _selectedRegion;
  String? _selectedDistrict;
  String? _address;
  int _step = 0; // 0 = account, 1 = profile

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _homeNumberController.dispose();
    _meterNumberController.dispose();
    _abonentNumberController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authProvider.notifier).register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          phone: _phoneController.text.trim().isNotEmpty
              ? _phoneController.text.trim()
              : null,
        );

    if (success && mounted) {
      // After successful registration, save profile data
      final profileData = <String, dynamic>{};
      if (_nameController.text.trim().isNotEmpty) {
        profileData['full_name'] = _nameController.text.trim();
      }
      if (_homeNumberController.text.trim().isNotEmpty) {
        profileData['home_number'] = _homeNumberController.text.trim();
      }
      if (_meterNumberController.text.trim().isNotEmpty) {
        profileData['meter_number'] = _meterNumberController.text.trim();
      }
      if (_abonentNumberController.text.trim().isNotEmpty) {
        profileData['abonent_number'] = _abonentNumberController.text.trim();
      }
      if (_selectedRegion != null) {
        profileData['region'] = _selectedRegion;
      }
      if (_selectedDistrict != null) {
        profileData['district'] = _selectedDistrict;
      }
      if (_address != null && _address!.isNotEmpty) {
        profileData['address'] = _address;
      }

      if (profileData.isNotEmpty) {
        try {
          await ref.read(citizenProfileProvider.notifier).updateProfile(profileData);
        } catch (_) {}
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final districts = _selectedRegion != null
        ? getDistricts(_selectedRegion!)
        : <String>[];

    return Scaffold(
      backgroundColor: AppColors.bgCard,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () {
            if (_step == 1) {
              setState(() => _step = 0);
            } else {
              context.go('/login');
            }
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StepDot(active: _step == 0, done: _step > 0),
            Container(width: 24, height: 2, color: AppColors.border),
            _StepDot(active: _step == 1, done: false),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Icon(
                  _step == 0 ? Icons.person_add_outlined : Icons.home_outlined,
                  size: 40,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  _step == 0 ? 'Ro\'yxatdan o\'tish' : 'Ma\'lumotlaringiz',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  _step == 0
                      ? 'Hududingizdagi suv muammolarini xabar bering'
                      : 'Hisoblagich va manzil ma\'lumotlarini kiriting',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                if (authState.error != null && _step == 0) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.error.withOpacity(0.3)),
                    ),
                    child: Text(
                      authState.error!,
                      style: const TextStyle(color: AppColors.error, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ─── Step 1: Account info ──────────────────────────────
                if (_step == 0) ...[
                  _buildField(
                    controller: _nameController,
                    label: 'To\'liq ism',
                    icon: Icons.person_outlined,
                    action: TextInputAction.next,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Ismingizni kiriting' : null,
                  ),
                  const SizedBox(height: 14),
                  _buildField(
                    controller: _emailController,
                    label: 'Email',
                    icon: Icons.email_outlined,
                    keyboard: TextInputType.emailAddress,
                    action: TextInputAction.next,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Email kiriting' : null,
                  ),
                  const SizedBox(height: 14),
                  _buildField(
                    controller: _phoneController,
                    label: 'Telefon (ixtiyoriy)',
                    icon: Icons.phone_outlined,
                    keyboard: TextInputType.phone,
                    action: TextInputAction.next,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Parol',
                      prefixIcon: const Icon(Icons.lock_outlined, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Parol kiriting';
                      if (v.length < 6) return 'Kamida 6 ta belgi';
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          setState(() => _step = 1);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Davom etish',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],

                // ─── Step 2: Profile info ──────────────────────────────
                if (_step == 1) ...[
                  _buildField(
                    controller: _homeNumberController,
                    label: 'Uy raqami',
                    icon: Icons.home_outlined,
                    action: TextInputAction.next,
                  ),
                  const SizedBox(height: 14),
                  _buildField(
                    controller: _meterNumberController,
                    label: 'Hisoblagich raqami',
                    icon: Icons.speed_outlined,
                    action: TextInputAction.next,
                  ),
                  const SizedBox(height: 14),
                  _buildField(
                    controller: _abonentNumberController,
                    label: 'Abonent raqami',
                    icon: Icons.badge_outlined,
                    action: TextInputAction.next,
                  ),
                  const SizedBox(height: 14),

                  // Region dropdown
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
                        style: const TextStyle(
                            color: AppColors.textPrimary, fontSize: 14),
                        icon: const Icon(Icons.keyboard_arrow_down,
                            color: AppColors.textMuted),
                        items: regionNames
                            .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                            .toList(),
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
                          style: const TextStyle(
                              color: AppColors.textMuted, fontSize: 14),
                        ),
                        dropdownColor: AppColors.bgElevated,
                        style: const TextStyle(
                            color: AppColors.textPrimary, fontSize: 14),
                        icon: const Icon(Icons.keyboard_arrow_down,
                            color: AppColors.textMuted),
                        items: districts
                            .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                            .toList(),
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
                    height: 50,
                    child: ElevatedButton(
                      onPressed: authState.isLoading ? null : _handleRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: authState.isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Ro\'yxatdan o\'tish',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _handleRegister,
                    child: const Text(
                      'Keyinroq to\'ldiraman',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ],

                const SizedBox(height: 16),
                if (_step == 0)
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text(
                      'Hisobingiz bormi? Kirish',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboard,
    TextInputAction? action,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      textInputAction: action,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
      ),
      validator: validator,
    );
  }
}

class _StepDot extends StatelessWidget {
  final bool active;
  final bool done;

  const _StepDot({required this.active, required this.done});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: (active || done) ? AppColors.primary : AppColors.bgSurface,
        border: Border.all(
          color: (active || done) ? AppColors.primary : AppColors.border,
          width: 2,
        ),
      ),
      child: Center(
        child: done
            ? const Icon(Icons.check, size: 16, color: Colors.white)
            : Text(
                active ? '2' : '1',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: (active || done) ? Colors.white : AppColors.textMuted,
                ),
              ),
      ),
    );
  }
}
