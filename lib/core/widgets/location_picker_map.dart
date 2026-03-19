import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:suwater_mobile/core/theme/app_theme.dart';
import 'package:suwater_mobile/core/config/region.dart';

class LocationPickerMap extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final ValueChanged<LatLng> onLocationChanged;
  final double height;

  const LocationPickerMap({
    super.key,
    this.latitude,
    this.longitude,
    required this.onLocationChanged,
    this.height = 200,
  });

  @override
  State<LocationPickerMap> createState() => _LocationPickerMapState();
}

class _LocationPickerMapState extends State<LocationPickerMap> {
  late final MapController _mapController;
  LatLng? _pinLocation;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    if (widget.latitude != null && widget.longitude != null) {
      _pinLocation = LatLng(widget.latitude!, widget.longitude!);
    }
  }

  @override
  void didUpdateWidget(LocationPickerMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When parent sets new coordinates (from address search or GPS),
    // move the map and pin
    if (widget.latitude != null &&
        widget.longitude != null &&
        (widget.latitude != oldWidget.latitude ||
            widget.longitude != oldWidget.longitude)) {
      final newPos = LatLng(widget.latitude!, widget.longitude!);
      setState(() => _pinLocation = newPos);
      _mapController.move(newPos, 16);
    }
  }

  void _onTap(TapPosition tapPosition, LatLng point) {
    setState(() => _pinLocation = point);
    widget.onLocationChanged(point);
  }

  @override
  Widget build(BuildContext context) {
    final region = activeRegion;
    final center = _pinLocation ??
        LatLng(region.centerLat, region.centerLng);
    final zoom = _pinLocation != null ? 16.0 : region.zoom.toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            height: widget.height,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: center,
                initialZoom: zoom,
                onTap: _onTap,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'uz.waterflow.suwater_mobile',
                ),
                if (_pinLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _pinLocation!,
                        width: 40,
                        height: 40,
                        child: const _MapPin(),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _pinLocation != null
              ? 'Tap the map to adjust pin location'
              : 'Search an address or tap the map to set location',
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textMuted,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _MapPin extends StatelessWidget {
  const _MapPin();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.error,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.error.withOpacity(0.4),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.location_on,
            color: Colors.white,
            size: 18,
          ),
        ),
        Container(
          width: 2,
          height: 6,
          color: AppColors.error.withOpacity(0.6),
        ),
      ],
    );
  }
}
