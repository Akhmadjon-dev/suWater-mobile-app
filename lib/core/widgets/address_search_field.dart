import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:suwater_mobile/core/theme/app_theme.dart';
import 'package:suwater_mobile/core/config/region.dart';

class AddressResult {
  final String displayName;
  final String shortName;
  final double lat;
  final double lon;
  final String? state; // region/viloyat from Nominatim
  final String? county; // district/tuman from Nominatim
  final String? city;

  const AddressResult({
    required this.displayName,
    required this.shortName,
    required this.lat,
    required this.lon,
    this.state,
    this.county,
    this.city,
  });

  factory AddressResult.fromNominatim(Map<String, dynamic> json) {
    final display = json['display_name'] as String;
    final parts = display.split(', ');
    final short = parts.length > 2
        ? parts.take(3).join(', ')
        : display;

    final address = json['address'] as Map<String, dynamic>? ?? {};

    return AddressResult(
      displayName: display,
      shortName: short,
      lat: double.parse(json['lat'] as String),
      lon: double.parse(json['lon'] as String),
      state: address['state'] as String?,
      county: address['county'] as String?,
      city: address['city'] as String? ?? address['town'] as String?,
    );
  }
}

class AddressSearchField extends StatefulWidget {
  final String? initialValue;
  final ValueChanged<AddressResult> onSelected;
  final String hintText;

  const AddressSearchField({
    super.key,
    this.initialValue,
    required this.onSelected,
    this.hintText = 'Street address or nearby landmark',
  });

  @override
  State<AddressSearchField> createState() => _AddressSearchFieldState();
}

class _AddressSearchFieldState extends State<AddressSearchField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _dio = Dio();
  Timer? _debounce;
  List<AddressResult> _results = [];
  AddressResult? _selected;
  bool _showDropdown = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    _dio.close();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus && _results.isNotEmpty) {
      setState(() => _showDropdown = true);
    }
  }

  void _onTextChanged(String query) {
    // If user types after selecting, clear selection
    if (_selected != null) {
      _selected = null;
    }

    _debounce?.cancel();

    if (query.trim().length < 3) {
      setState(() {
        _results = [];
        _showDropdown = false;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 400), () {
      _search(query.trim());
    });
  }

  Future<void> _search(String query) async {
    setState(() => _isSearching = true);

    try {
      final region = activeRegion;
      // Prepend city name for local bias
      final searchQuery = '${region.city} $query';

      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q': searchQuery,
          'format': 'json',
          'addressdetails': '1',
          'limit': '6',
          'countrycodes': region.countryCode,
          'viewbox': region.viewboxParam,
          'bounded': '0',
        },
        options: Options(
          headers: {
            'Accept-Language': 'en',
            'User-Agent': 'WaterFlowMobile/1.0',
          },
        ),
      );

      final data = response.data as List;
      final results = data
          .map((item) =>
              AddressResult.fromNominatim(item as Map<String, dynamic>))
          .toList();

      if (mounted) {
        setState(() {
          _results = results;
          _showDropdown = results.isNotEmpty;
          _isSearching = false;
        });
      }
    } catch (e) {
      debugPrint('AddressSearchField._search failed: $e');
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  void _selectResult(AddressResult result) {
    setState(() {
      _selected = result;
      _controller.text = result.shortName;
      _showDropdown = false;
    });
    _focusNode.unfocus();
    widget.onSelected(result);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Input field
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          onChanged: _onTextChanged,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: widget.hintText,
            prefixIcon: const Icon(Icons.search, color: AppColors.textMuted, size: 20),
            suffixIcon: _isSearching
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18,
                            color: AppColors.textMuted),
                        onPressed: () {
                          _controller.clear();
                          _selected = null;
                          setState(() {
                            _results = [];
                            _showDropdown = false;
                          });
                        },
                      )
                    : null,
          ),
        ),

        // Dropdown results
        if (_showDropdown) ...[
          const SizedBox(height: 4),
          Container(
            constraints: const BoxConstraints(maxHeight: 240),
            decoration: BoxDecoration(
              color: AppColors.bgElevated,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border, width: 0.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _results.length,
                separatorBuilder: (_, __) => const Divider(
                  height: 1,
                  color: AppColors.border,
                ),
                itemBuilder: (context, index) {
                  final result = _results[index];
                  final isSelected = _selected == result;

                  return InkWell(
                    onTap: () => _selectResult(result),
                    child: Container(
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.1)
                          : null,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 18,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textMuted,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  result.shortName,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  result.displayName,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textMuted,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ],
    );
  }
}
