import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

bool get _isMobile =>
    !kIsWeb && (Platform.isAndroid || Platform.isIOS);

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with TickerProviderStateMixin {
  final MapController _mapController = MapController();

  Position? _currentPosition;
  _LocationState _locationState = _LocationState.loading;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  StreamSubscription<Position>? _positionStream;

  static const _defaultZoom = 16.0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _initLocation();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _positionStream?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    if (!_isMobile) {
      // Desktop / web: skip permission & geolocator — not supported.
      setState(() => _locationState = _LocationState.desktopUnsupported);
      return;
    }

    final permissionStatus = await Permission.locationWhenInUse.request();

    if (!permissionStatus.isGranted) {
      if (permissionStatus.isPermanentlyDenied) {
        setState(() => _locationState = _LocationState.permanentlyDenied);
      } else {
        setState(() => _locationState = _LocationState.denied);
      }
      return;
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _locationState = _LocationState.serviceDisabled);
      return;
    }

    await _fetchPosition();
    _startPositionStream();
  }

  Future<void> _fetchPosition() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (!mounted) return;
      setState(() {
        _currentPosition = position;
        _locationState = _LocationState.ready;
      });
      _animateTo(LatLng(position.latitude, position.longitude));
    } catch (_) {
      if (mounted) setState(() => _locationState = _LocationState.error);
    }
  }

  void _startPositionStream() {
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((position) {
      if (!mounted) return;
      setState(() => _currentPosition = position);
    });
  }

  void _animateTo(LatLng target) {
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    final latTween = Tween<double>(
      begin: _mapController.camera.center.latitude,
      end: target.latitude,
    );
    final lngTween = Tween<double>(
      begin: _mapController.camera.center.longitude,
      end: target.longitude,
    );
    final zoomTween = Tween<double>(
      begin: _mapController.camera.zoom,
      end: _defaultZoom,
    );
    final animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    );
    controller.addListener(() {
      _mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });
    controller.forward();
  }

  void _recenter() {
    if (_currentPosition != null) {
      _animateTo(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: switch (_locationState) {
        _LocationState.loading => _buildLoading(colorScheme),
        _LocationState.denied => _buildPermissionDenied(
          colorScheme,
          permanent: false,
        ),
        _LocationState.permanentlyDenied => _buildPermissionDenied(
          colorScheme,
          permanent: true,
        ),
        _LocationState.serviceDisabled => _buildServiceDisabled(colorScheme),
        _LocationState.error => _buildError(colorScheme),
        _LocationState.desktopUnsupported => _buildDesktopFallback(colorScheme),
        _LocationState.ready => _buildMap(colorScheme),
      },
    );
  }

  Widget _buildMap(ColorScheme colorScheme) {
    final userLatLng = _currentPosition != null
        ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
        : const LatLng(0, 0);

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: userLatLng,
            initialZoom: _defaultZoom,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.fitxel.app',
              maxZoom: 19,
            ),
            if (_currentPosition != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: userLatLng,
                    width: 60,
                    height: 60,
                    child: _UserLocationMarker(
                      pulseAnimation: _pulseAnimation,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
          ],
        ),

        // Top header overlay
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.map_rounded,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Your Location',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const Spacer(),
                    if (_currentPosition != null)
                      Text(
                        '${_currentPosition!.latitude.toStringAsFixed(4)}, '
                        '${_currentPosition!.longitude.toStringAsFixed(4)}',
                        style: TextStyle(
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Recenter FAB
        Positioned(
          bottom: 24,
          right: 16,
          child: FloatingActionButton(
            onPressed: _recenter,
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            elevation: 6,
            child: const Icon(Icons.my_location_rounded),
          ),
        ),
      ],
    );
  }

  Widget _buildLoading(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            'Getting your location…',
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionDenied(ColorScheme colorScheme, {required bool permanent}) {
    return _InfoState(
      icon: Icons.location_off_rounded,
      title: 'Location access needed',
      message: permanent
          ? 'Location permission was permanently denied. Open Settings to enable it.'
          : 'Fitxel needs location access to show you on the map.',
      actionLabel: permanent ? 'Open Settings' : 'Grant Permission',
      onAction: permanent ? openAppSettings : _initLocation,
      colorScheme: colorScheme,
    );
  }

  Widget _buildServiceDisabled(ColorScheme colorScheme) {
    return _InfoState(
      icon: Icons.location_disabled_rounded,
      title: 'Location services off',
      message: 'Please enable location services on your device to use the map.',
      actionLabel: 'Open Location Settings',
      onAction: () async {
        await Geolocator.openLocationSettings();
      },
      colorScheme: colorScheme,
    );
  }

  Widget _buildError(ColorScheme colorScheme) {
    return _InfoState(
      icon: Icons.error_outline_rounded,
      title: 'Could not get location',
      message: 'Something went wrong while fetching your location. Please try again.',
      actionLabel: 'Retry',
      onAction: () {
        setState(() => _locationState = _LocationState.loading);
        _initLocation();
      },
      colorScheme: colorScheme,
    );
  }

  Widget _buildDesktopFallback(ColorScheme colorScheme) {
    // Render the map at a world-overview zoom without a location marker.
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: const MapOptions(
            initialCenter: LatLng(20, 0),
            initialZoom: 2,
            interactionOptions: InteractionOptions(
              flags: InteractiveFlag.all,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.fitxel.app',
              maxZoom: 19,
            ),
          ],
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.desktop_windows_rounded,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Live location unavailable on desktop',
                      style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                        fontSize: 13,
                      ),
                    ),
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

// ── User location dot marker ─────────────────────────────────────────────────

class _UserLocationMarker extends StatelessWidget {
  final Animation<double> pulseAnimation;
  final Color color;

  const _UserLocationMarker({
    required this.pulseAnimation,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseAnimation,
      builder: (context, _) {
        return Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer pulse ring
              Container(
                width: 44 * pulseAnimation.value,
                height: 44 * pulseAnimation.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(
                    alpha: 0.25 * (1 - (pulseAnimation.value - 0.6) / 0.4),
                  ),
                ),
              ),
              // Accuracy ring
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.2),
                  border: Border.all(
                    color: color.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
              ),
              // Core dot
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  border: Border.all(color: Colors.white, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.5),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Generic info/error state ──────────────────────────────────────────────────

class _InfoState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;
  final ColorScheme colorScheme;

  const _InfoState({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primary.withValues(alpha: 0.1),
              ),
              child: Icon(icon, size: 48, color: colorScheme.primary),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(actionLabel),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── State enum ───────────────────────────────────────────────────────────────

enum _LocationState {
  loading,
  denied,
  permanentlyDenied,
  serviceDisabled,
  error,
  desktopUnsupported,
  ready,
}
