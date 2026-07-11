import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/features/tracking/models/tracking_model.dart';

class TrackingMap extends StatefulWidget {
  const TrackingMap({super.key, required this.tracking});

  final TrackingModel tracking;

  @override
  State<TrackingMap> createState() => _TrackingMapState();
}

class _TrackingMapState extends State<TrackingMap> {
  final MapController _mapController = MapController();

  TrackingModel get tracking => widget.tracking;

  void _changeZoom(double amount) {
    final camera = _mapController.camera;
    _mapController.move(camera.center, (camera.zoom + amount).clamp(3.0, 19.0));
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final routePoints =
        tracking.routePoints.isNotEmpty
            ? tracking.routePoints
            : [
              tracking.pickupLocation,
              tracking.courierLocation,
              tracking.destinationLocation,
            ];

    return Stack(
      fit: StackFit.expand,
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: tracking.courierLocation,
            initialZoom: 15,
            initialCameraFit: CameraFit.coordinates(
              coordinates: routePoints,
              padding: const EdgeInsets.fromLTRB(44, 120, 44, 300),
              maxZoom: 16.5,
            ),
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.zayrova',
              maxNativeZoom: 19,
            ),
            PolylineLayer(
              polylines: [
                Polyline(
                  points: routePoints,
                  strokeWidth: 5,
                  color: ZayColors.primary,
                  borderStrokeWidth: 8,
                  borderColor: Colors.white.withAlpha(190),
                ),
              ],
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: tracking.pickupLocation,
                  width: 54,
                  height: 54,
                  child: _MapMarker(
                    icon: Icons.storefront_outlined,
                    backgroundColor: ZayColors.primary,
                    foregroundColor: ZayColors.white,
                  ),
                ),
                Marker(
                  point: tracking.destinationLocation,
                  width: 56,
                  height: 56,
                  child: _MapMarker(
                    icon: Icons.home_outlined,
                    backgroundColor: ZayColors.white,
                    foregroundColor: ZayColors.primary,
                    borderColor: ZayColors.primary,
                  ),
                ),
                Marker(
                  point: tracking.courierLocation,
                  width: 92,
                  height: 90,
                  child: _CourierMarker(
                    name: tracking.courierName,
                    avatarUrl: tracking.courierAvatarUrl,
                  ),
                ),
              ],
            ),
          ],
        ),
        Positioned(
          top: MediaQuery.paddingOf(context).top + 72,
          right: 18,
          child: _ZoomControls(
            onZoomIn: () => _changeZoom(1),
            onZoomOut: () => _changeZoom(-1),
          ),
        ),
        Positioned(
          left: 18,
          bottom: 18,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(220),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Text(
                  'OpenStreetMap',
                  style: TextStyle(
                    color: ZayColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withAlpha(30),
                    Colors.transparent,
                    Colors.white.withAlpha(20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ZoomControls extends StatelessWidget {
  const _ZoomControls({required this.onZoomIn, required this.onZoomOut});

  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withAlpha(235),
      elevation: 4,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onZoomIn,
            tooltip: 'Zoom in',
            icon: const Icon(Icons.add),
          ),
          const SizedBox(width: 34, child: Divider(height: 1)),
          IconButton(
            onPressed: onZoomOut,
            tooltip: 'Zoom out',
            icon: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}

class _MapMarker extends StatelessWidget {
  const _MapMarker({
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    this.borderColor,
  });

  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border:
            borderColor == null
                ? null
                : Border.all(color: borderColor!, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(icon, color: foregroundColor, size: 24),
    );
  }
}

class _CourierMarker extends StatelessWidget {
  const _CourierMarker({required this.name, required this.avatarUrl});

  final String name;
  final String avatarUrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 88,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(18),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: ZayColors.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 52,
          height: 52,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F6FA),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(30),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipOval(
            child: ColoredBox(
              color: const Color(0xFFF5F6FA),
              child: Image.network(
                avatarUrl,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) => const Icon(
                      Icons.person,
                      color: ZayColors.textSecondary,
                      size: 24,
                    ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
