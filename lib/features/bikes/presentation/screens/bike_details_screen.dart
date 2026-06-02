import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math';

import '../../../../theme.dart';
import '../../../../widgets/custom_buttons.dart';
import '../../data/bike_models.dart';
import '../../presentation/bike_providers.dart';
import '../../../scan/presentation/screens/scan_screen.dart';

class BikeDetailsScreen extends ConsumerWidget {
  const BikeDetailsScreen({
    super.key,
    required this.bike,
    required this.userLocation,
  });

  final Bike bike;
  final LatLng userLocation;

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
    return earthRadius * c;
  }

  double _toRadian(double degree) {
    return degree * pi / 180;
  }

  String get _distanceText {
    if (bike.latitude == null || bike.longitude == null) return 'Unknown';
    final bikeLocation = LatLng(bike.latitude!, bike.longitude!);
    final distance = _calculateDistance(userLocation, bikeLocation);
    if (distance < 1) {
      return '${(distance * 1000).toStringAsFixed(0)} m';
    }
    return '${distance.toStringAsFixed(1)} km';
  }

  Color _getBatteryColor(int level) {
    if (level >= 75) return VelocityColors.primary;
    if (level >= 50) return const Color(0xFFFFA500); // Orange
    return VelocityColors.error;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookedBikeAsync = ref.watch(bookedBikeProvider);
    final bookedBikeQr = bookedBikeAsync.valueOrNull;
    final isThisBikeBooked = bookedBikeQr != null && (bookedBikeQr == bike.qrCode || bookedBikeQr == bike.id.toString() || bookedBikeQr == bike.bikeId);

    return Scaffold(
      backgroundColor: VelocityColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: VelocityColors.background,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: VelocityIconButton(
                icon: Icons.arrow_back_rounded,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  color: VelocityColors.surfaceLight,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(40),
                  ),
                ),
                child: Center(
                  child: Hero(
                    tag: 'bike_${bike.id}',
                    child: Icon(
                      Icons.pedal_bike_rounded,
                      size: 120,
                      color: bike.isAvailable
                          ? VelocityColors.primary
                          : Colors.grey[400],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bike.bikeType != null
                                  ? '${bike.bikeType}${bike.bikeSize != null ? ' · ${bike.bikeSize}"' : ''}'
                                  : 'City Bike',
                              style: VelocityText.displayMedium(),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Bike #${bike.bikeId}',
                              style: VelocityText.bodyLarge(
                                color: VelocityColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: bike.isAvailable
                              ? VelocityColors.primary.withValues(alpha: 0.1)
                              : Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          bike.isAvailable ? 'Available' : 'Unavailable',
                          style: VelocityText.labelMedium(
                            color: bike.isAvailable
                                ? VelocityColors.primary
                                : Colors.grey[600]!,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Stats Grid
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.battery_full_rounded,
                          label: 'Battery',
                          value: '${bike.batteryLevel}%',
                          valueColor: _getBatteryColor(bike.batteryLevel),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.route_rounded,
                          label: 'Distance',
                          value: _distanceText,
                          valueColor: VelocityColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.lock_rounded,
                          label: 'Status',
                          value: bike.status == 'LOCKED'
                              ? 'Locked'
                              : bike.status,
                          valueColor: bike.status == 'LOCKED'
                              ? VelocityColors.primary
                              : Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.qr_code_rounded,
                          label: 'QR Code',
                          value: bike.qrCode != null && bike.qrCode!.isNotEmpty
                              ? 'Ready'
                              : 'Missing',
                          valueColor: bike.qrCode != null && bike.qrCode!.isNotEmpty
                              ? VelocityColors.textPrimary
                              : VelocityColors.error,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Info section
                  Text(
                    'Bike Details',
                    style: VelocityText.headlineSmall(),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: VelocityColors.cardSurface),
                    ),
                    child: Column(
                      children: [
                        _DetailRow(
                          label: 'Usable',
                          value: bike.isUsable ? 'Yes' : 'No',
                        ),
                        const Divider(height: 24),
                        _DetailRow(
                          label: 'Location',
                          value: bike.latitude != null && bike.longitude != null
                              ? '${bike.latitude!.toStringAsFixed(4)}, ${bike.longitude!.toStringAsFixed(4)}'
                              : 'Unknown',
                        ),
                        if (bike.lastUpdated != null) ...[
                          const Divider(height: 24),
                          _DetailRow(
                            label: 'Last Updated',
                            value: _formatDate(bike.lastUpdated!),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Action Button
                  VelocityPrimaryButton(
                    label: isThisBikeBooked 
                        ? 'Start Ride' 
                        : (bike.isAvailable ? 'Scan to Book' : 'Bike Unavailable'),
                    icon: Icons.qr_code_scanner_rounded,
                    onPressed: bike.isAvailable || isThisBikeBooked
                        ? () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ScanScreen(
                                  isStartRide: isThisBikeBooked,
                                ),
                              ),
                            );
                          }
                        : null,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: VelocityColors.cardSurface),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: VelocityColors.secondary),
              const SizedBox(width: 8),
              Text(
                label,
                style: VelocityText.bodySmall(color: VelocityColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: VelocityText.headlineSmall(color: valueColor),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: VelocityText.bodyMedium(color: VelocityColors.textSecondary),
        ),
        Text(
          value,
          style: VelocityText.bodyMedium(color: VelocityColors.textPrimary),
        ),
      ],
    );
  }
}
