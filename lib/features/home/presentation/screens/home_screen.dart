import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:smbk/l10n/app_localizations.dart';

import '../../../../theme.dart';
import '../../../../core/localization/locale_notifier.dart';
import '../../../../widgets/bottom_nav.dart';
import '../../../../widgets/custom_buttons.dart';
import '../../../bikes/data/bike_models.dart';
import '../../../bikes/presentation/bike_providers.dart';
import '../../../booking/presentation/screens/booked_rides_screen.dart';
import '../../../history/presentation/screens/ride_history_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../bikes/presentation/screens/bike_details_screen.dart';
import '../../../scan/presentation/screens/scan_screen.dart';
import '../../../auth/presentation/auth_providers.dart';
import '../../../../core/location/location_providers.dart';

const _defaultMapCenter = LatLng(9.033204, 38.74318);

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  int _navIndex = 0;
  bool _cardExpanded = false;
  late AnimationController _pulseCtrl;
  late AnimationController _floatCtrl;
  Timer? _backgroundRefreshTimer;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _floatCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);
    
    // Request location permission when home screen loads
    _requestLocationPermission();

    // Setup background refresh every 30 seconds
    _backgroundRefreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _refreshBackgroundly();
    });
  }

  void _refreshBackgroundly() {
    if (mounted) {
      ref.invalidate(bikesProvider);
      ref.invalidate(bookedRidesProvider);
      ref.invalidate(bookedBikeProvider);
    }
  }

  Future<void> _requestLocationPermission() async {
    try {
      await ref.read(locationServiceProvider).ensurePermission();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Location permission is required to show nearby bikes.'),
            backgroundColor: VelocityColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _backgroundRefreshTimer?.cancel();
    _pulseCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  void _handleNavTap(int index) {
    if (index == 2) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ScanScreen()),
      );
      return;
    }
    setState(() => _navIndex = index);
  }

  // Helper method to calculate distance for use in build method
  double _calculateDistanceHelper(LatLng point1, LatLng point2) {
    const earthRadius = 6371; // Radius of the earth in km
    final dLat = _toRadian(point2.latitude - point1.latitude);
    final dLng = _toRadian(point2.longitude - point1.longitude);
    final a = (sin(dLat / 2) * sin(dLat / 2)) +
        (cos(_toRadian(point1.latitude)) *
            cos(_toRadian(point2.latitude)) *
            sin(dLng / 2) *
            sin(dLng / 2));
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c; // Distance in km
  }

  double _toRadian(double degree) {
    return degree * pi / 180;
  }

  int _pageIndex() {
    switch (_navIndex) {
      case 1:
        return 1;
      case 3:
        return 2;
      case 4:
        return 3;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(brightnessProvider);
    ref.watch(localeProvider);
    final pageIndex = _pageIndex();
    final bikes = ref.watch(bikesProvider);
    final position = ref.watch(locationStreamProvider);
    final userLocation = position.maybeWhen(
      data: (pos) => LatLng(pos.latitude, pos.longitude),
      orElse: () => _defaultMapCenter,
    );

    // Find nearest bike and calculate distance
    Bike? nearestBike;
    double nearestDistance = 0.0;
    final bikeList = bikes.maybeWhen(
      data: (list) => list,
      orElse: () => <Bike>[],
    );
    if (bikeList.isNotEmpty) {
      // Find nearest available bike
      double minDistance = double.infinity;
      for (final bike in bikeList) {
        if (bike.isAvailable &&
            bike.latitude != null &&
            bike.longitude != null) {
          final bikeLocation = LatLng(bike.latitude!, bike.longitude!);
          final distance = _calculateDistanceHelper(userLocation, bikeLocation);
          if (distance < minDistance) {
            minDistance = distance;
            nearestBike = bike;
          }
        }
      }
      if (nearestBike != null) {
        nearestDistance = minDistance;
      }
    }
    
    // Check if there are bikes available
    final hasBikes = bikes.maybeWhen(
      data: (bikeList) => bikeList.isNotEmpty,
      orElse: () => false,
    );
    
    return Scaffold(
      backgroundColor: VelocityColors.background,
      body: Stack(
        children: [
          IndexedStack(
            index: pageIndex,
            children: const [
              _HomeMapTab(),
              BookedRidesScreen(),
              RideHistoryScreen(),
              ProfileScreen(),
            ],
          ),
          if (_navIndex == 0) ...[
            SafeArea(
              child: Column(
                children: [
                  _TopHeader(),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Only show bike card if bikes are available
                  if (hasBikes)
                    _FloatingBikeCard(
                      expanded: _cardExpanded,
                      onExpand: () =>
                          setState(() => _cardExpanded = !_cardExpanded),
                      onUnlock: () => _handleNavTap(2),
                      nearestBike: nearestBike,
                      distance: nearestDistance,
                    ),
                  VelocityBottomNav(
                    currentIndex: _navIndex,
                    onTap: _handleNavTap,
                  ),
                ],
              ),
            ),
          ] else
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: VelocityBottomNav(
                currentIndex: _navIndex,
                onTap: _handleNavTap,
              ),
            ),
        ],
      ),
    );
  }
}

class _HomeMapTab extends ConsumerStatefulWidget {
  const _HomeMapTab();

  @override
  ConsumerState<_HomeMapTab> createState() => _HomeMapTabState();
}

class _HomeMapTabState extends ConsumerState<_HomeMapTab> {
  final MapController _mapController = MapController();
  bool _hasMovedToBikes = false;

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);
    final bikes = ref.watch(bikesProvider);
    final position = ref.watch(locationStreamProvider);
    final center = position.maybeWhen(
      data: (pos) => LatLng(pos.latitude, pos.longitude),
      orElse: () => _defaultMapCenter,
    );
    final isLocationLoading = position.isLoading;
    final hasLocationError = position.hasError;

    ref.listen(bikesProvider, (previous, next) {
      if (!_hasMovedToBikes && next.value != null && next.value!.isNotEmpty) {
        final pos = position.value;
        if (pos != null) {
          final center = LatLng(pos.latitude, pos.longitude);
          final nearestBike = _findNearestBike(next.value!, center);
          if (nearestBike != null && nearestBike.latitude != null && nearestBike.longitude != null) {
            _hasMovedToBikes = true;
            _mapController.move(LatLng(nearestBike.latitude!, nearestBike.longitude!), 14.5);
          }
        }
      }
    });

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: center,
            initialZoom: 14.5,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'smbk',
              tileProvider: FMTCTileProvider(
                stores: const {'smbkMapStore': BrowseStoreStrategy.readUpdateCreate},
              ),
            ),
            MarkerLayer(
              markers: [
                // User location marker
                Marker(
                  point: center,
                  width: 48,
                  height: 48,
                  child: Icon(
                    Icons.my_location_rounded,
                    color: VelocityColors.primary,
                    size: 28,
                  ),
                ),
                // Bike markers (only if bikes exist)
                ...bikes.maybeWhen(
                  data: (bikeList) => _buildBikeMarkers(
                    context,
                    bikeList,
                    center,
                    _findNearestBike(bikeList, center)?.id,
                  ),
                  orElse: () => [],
                ),
              ],
            ),
          ],
        ),
        if (isLocationLoading || hasLocationError)
          Positioned(
            top: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: hasLocationError
                      ? VelocityColors.errorBg
                      : VelocityColors.background.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isLocationLoading)
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: VelocityColors.primary,
                        ),
                      )
                    else
                      const Icon(Icons.location_off_rounded,
                          color: VelocityColors.error, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      isLocationLoading
                          ? 'Getting your location...'
                          : 'Using default location',
                      style: VelocityText.bodySmall(
                        color: hasLocationError
                            ? VelocityColors.error
                            : VelocityColors.primaryDarker,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        // Loading and Error overlays (only if no data has been cached yet)
        if (bikes.isLoading && !bikes.hasValue)
          Positioned(
            top: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: VelocityColors.background.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: VelocityColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('Finding bikes...', style: VelocityText.bodySmall(color: VelocityColors.primaryDarker)),
                  ],
                ),
              ),
            ),
          ),
        if (bikes.hasError && !bikes.hasValue)
          Positioned(
            top: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: VelocityColors.errorBg,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline_rounded, color: VelocityColors.error, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Error: ${bikes.error.toString()}', 
                        style: VelocityText.bodySmall(color: VelocityColors.error),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Bike? _findNearestBike(List<Bike> bikes, LatLng userLocation) {
    if (bikes.isEmpty) return null;

    Bike? nearestBike;
    double nearestDistance = double.infinity;

    for (final bike in bikes) {
      // Only consider available bikes with valid location data
      if (bike.isAvailable && bike.latitude != null && bike.longitude != null) {
        final bikeLocation = LatLng(bike.latitude!, bike.longitude!);
        // Calculate distance between user and bike in kilometers
        final distance = _calculateDistance(userLocation, bikeLocation);

        if (distance < nearestDistance) {
          nearestDistance = distance;
          nearestBike = bike;
        }
      }
    }

    return nearestBike;
  }

  /// Calculate distance between two points using Haversine formula (in km)
  double _calculateDistance(LatLng point1, LatLng point2) {
    const earthRadius = 6371; // Radius of the earth in km
    final dLat = _toRadian(point2.latitude - point1.latitude);
    final dLng = _toRadian(point2.longitude - point1.longitude);
    final a = (sin(dLat / 2) * sin(dLat / 2)) +
        (cos(_toRadian(point1.latitude)) *
            cos(_toRadian(point2.latitude)) *
            sin(dLng / 2) *
            sin(dLng / 2));
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c; // Distance in km
  }

  double _toRadian(double degree) {
    return degree * pi / 180;
  }

  List<Marker> _buildBikeMarkers(BuildContext context, List<Bike> bikes, LatLng center, int? nearestBikeId) {
    final markers = <Marker>[];
    
    for (final bike in bikes) {
      // Only show bikes that have valid location data from the API
      if (bike.latitude != null && bike.longitude != null) {
        // Determine color based on availability and distance
        Color bikeColor;
        if (!bike.isAvailable) {
          // Grey for unavailable bikes
          bikeColor = Colors.grey[400] ?? Colors.grey;
        } else if (bike.id == nearestBikeId) {
          // Deep green for nearest available bike
          bikeColor = VelocityColors.primary; // Deep green
        } else {
          // Light green for other available bikes
          bikeColor = VelocityColors.accentBright; // Light green
        }

        markers.add(
          Marker(
            point: LatLng(bike.latitude!, bike.longitude!),
            width: 50,
            height: 50,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BikeDetailsScreen(
                          bike: bike,
                          userLocation: center,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      Icons.pedal_bike_rounded,
                      color: bikeColor,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
    
    return markers;
  }
}

// ─── Top Header ────────────────────────────────────────────────────────────
class _TopHeader extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionFuture = ref.watch(sessionProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        children: [
          Expanded(
            child: sessionFuture.when(
              data: (session) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, ${session?.name ?? 'Guest'} 👋',
                    style: VelocityText.headlineSmall(),
                  ),
                ],
              ),
              loading: () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hello 👋', style: VelocityText.headlineSmall()),
                  const SizedBox(height: 2),
                  Text('Ready to ride?',
                      style: VelocityText.bodySmall(
                          color: VelocityColors.secondaryDark)),
                ],
              ),
              error: (_, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hello 👋', style: VelocityText.headlineSmall()),
                  const SizedBox(height: 2),
                  Text('Ready to ride?',
                      style: VelocityText.bodySmall(
                          color: VelocityColors.secondaryDark)),
                ],
              ),
            ),
          ),
          const SizedBox.shrink(),
        ],
      ),
    );
  }
}

// ─── Floating Bike Card ────────────────────────────────────────────────────
class _FloatingBikeCard extends StatelessWidget {
  const _FloatingBikeCard({
    required this.expanded,
    required this.onExpand,
    required this.onUnlock,
    this.nearestBike,
    this.distance = 0.0,
  });
  final bool expanded;
  final VoidCallback onExpand;
  final VoidCallback onUnlock;
  final Bike? nearestBike;
  final double distance;

  @override
  Widget build(BuildContext context) {
    // Format distance display
    String distanceText = 'Loading...';
    if (nearestBike != null) {
      if (distance < 1) {
        distanceText = '${(distance * 1000).toStringAsFixed(0)} m';
      } else {
        distanceText = '${distance.toStringAsFixed(1)} km';
      }
    }

    // Battery color based on level
    Color getBatteryColor(int level) {
      if (level >= 75) return VelocityColors.primary;
      if (level >= 50) return const Color(0xFFFFA500);
      return VelocityColors.error;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: VelocityColors.primary.withOpacity(0.2),
            blurRadius: 30,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: VelocityColors.primary.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              VelocityColors.background.withOpacity(0.3),
            ],
          ),
          border: Border.all(
            color: VelocityColors.primary.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header: Collapse/Expand
              GestureDetector(
                onTap: onExpand,
                child: Row(
                  children: [
                    // Animated bike icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: VelocityColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.two_wheeler_rounded,
                        color: VelocityColors.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nearestBike != null &&
                                    nearestBike!.bikeType != null
                                ? '${nearestBike!.bikeType}${nearestBike!.bikeSize != null ? ' · ${nearestBike!.bikeSize}"' : ''}'
                                : 'Bike Available',
                            style: VelocityText.headlineSmall(
                              color: VelocityColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                size: 14,
                                color: VelocityColors.secondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$distanceText away',
                                style: VelocityText.bodySmall(
                                  color: VelocityColors.secondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      expanded
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      color: VelocityColors.primary,
                      size: 24,
                    ),
                  ],
                ),
              ),
              // Expanded details
              if (expanded && nearestBike != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: VelocityColors.background,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Bike type & size
                      if (nearestBike!.bikeType != null) ...[
                        _DetailStat(
                          icon: Icons.two_wheeler_rounded,
                          label: 'Type · Size',
                          value:
                              '${nearestBike!.bikeType}${nearestBike!.bikeSize != null ? '  ${nearestBike!.bikeSize}"' : ''}',
                          color: VelocityColors.primaryDarker,
                          backgroundColor:
                              VelocityColors.primary.withOpacity(0.08),
                        ),
                        const SizedBox(height: 12),
                      ],
                      // Battery stat
                      _DetailStat(
                        icon: Icons.battery_full_rounded,
                        label: 'Battery Level',
                        value: '${nearestBike!.batteryLevel}%',
                        color: getBatteryColor(nearestBike!.batteryLevel),
                        backgroundColor:
                            getBatteryColor(nearestBike!.batteryLevel)
                                .withOpacity(0.1),
                      ),
                      const SizedBox(height: 12),
                      // Status stat
                      _DetailStat(
                        icon: Icons.lock_rounded,
                        label: 'Status',
                        value: nearestBike!.status == 'LOCKED'
                            ? 'Locked & Ready'
                            : nearestBike!.status,
                        color: nearestBike!.status == 'LOCKED'
                            ? VelocityColors.primary
                            : Colors.orange,
                        backgroundColor: (nearestBike!.status == 'LOCKED'
                                ? VelocityColors.primary
                                : Colors.orange)
                            .withOpacity(0.1),
                      ),
                      const SizedBox(height: 12),
                      // Distance stat
                      _DetailStat(
                        icon: Icons.route_rounded,
                        label: 'Distance',
                        value: distanceText,
                        color: VelocityColors.accent,
                        backgroundColor: VelocityColors.accent.withOpacity(0.1),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              VelocityPrimaryButton(
                label: 'Scan to Unlock',
                icon: Icons.qr_code_scanner_rounded,
                onPressed: onUnlock,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Detail stat widget for expanded view
class _DetailStat extends StatelessWidget {
  const _DetailStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.backgroundColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: VelocityText.bodySmall(
                  color: VelocityColors.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: VelocityText.headlineSmall(
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
