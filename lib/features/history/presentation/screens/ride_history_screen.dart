import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smbk/l10n/app_localizations.dart';

import '../../../../theme.dart';
import '../../../../core/localization/locale_notifier.dart';
import '../../../ride/presentation/ride_providers.dart';
import '../../../ride/data/ride_models.dart';
import '../../../../core/location/location_providers.dart';

class RideHistoryScreen extends ConsumerWidget {
  const RideHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(brightnessProvider);
    ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context);
    final history = ref.watch(rideHistoryProvider);

    return Scaffold(
      backgroundColor: VelocityColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n?.rideHistoryTitle ?? 'Ride History', style: VelocityText.headlineMedium()),
              const SizedBox(height: 8),
              Text(
                l10n?.rideHistorySubtitle ?? 'Your recent rides',
                style: VelocityText.bodyMedium(
                  color: VelocityColors.secondary,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: history.when(
                  skipLoadingOnRefresh: true,
                  data: (rides) {
                    if (rides.isEmpty) {
                      return RefreshIndicator(
                        color: VelocityColors.primary,
                        onRefresh: () async {
                          ref.invalidate(rideHistoryProvider);
                          try {
                            await ref.read(rideHistoryProvider.future);
                          } catch (_) {}
                        },
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Container(
                            constraints: BoxConstraints(
                              minHeight: MediaQuery.of(context).size.height * 0.6,
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.pedal_bike_rounded,
                                    size: 64,
                                    color: VelocityColors.secondary.withValues(alpha: 0.3),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    l10n != null ? (l10n!.localeName == 'am' ? 'እስካሁን ምንም ጉዞዎች የሉም' : 'No rides yet') : 'No rides yet',
                                    style: VelocityText.headlineSmall(),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    l10n != null ? (l10n!.localeName == 'am' ? 'ታሪክዎን እዚህ ለማየት የመጀመሪያውን ጉዞዎን ይጀምሩ' : 'Start your first ride to see history here') : 'Start your first ride to see history here',
                                    style: VelocityText.bodyMedium(
                                      color: VelocityColors.textMuted,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    return RefreshIndicator(
                      color: VelocityColors.primary,
                      onRefresh: () async {
                        ref.invalidate(rideHistoryProvider);
                        try {
                          await ref.read(rideHistoryProvider.future);
                        } catch (_) {}
                      },
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 120),
                        itemCount: rides.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final ride = rides[index];
                          return _RideCard(ride: ride);
                        },
                      ),
                    );
                  },
                  error: (e, _) => RefreshIndicator(
                    color: VelocityColors.primary,
                    onRefresh: () async {
                      ref.invalidate(rideHistoryProvider);
                      try {
                        await ref.read(rideHistoryProvider.future);
                      } catch (_) {}
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Container(
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height * 0.6,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                size: 64,
                                color: VelocityColors.error,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Failed to load rides',
                                style: VelocityText.headlineSmall(),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                e.toString(),
                                style: VelocityText.bodySmall(
                                  color: VelocityColors.textMuted,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  loading: () => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: VelocityColors.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n?.rideHistoryTitle != null ? '${l10n!.rideHistoryTitle}...' : 'Loading rides...',
                          style: VelocityText.bodyMedium(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Ride Card Widget
// Ride Card Widget
class _RideCard extends ConsumerWidget {
  const _RideCard({required this.ride});

  final Ride ride;

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return 'Unknown';
    return DateFormat('MMM dd, yyyy • hh:mm a').format(dateTime.toLocal());
  }

  String _formatDuration(DateTime? start, DateTime? end) {
    if (start == null || end == null) return '--';
    final duration = end.difference(start);
    final minutes = duration.inMinutes;
    if (minutes < 60) {
      return '$minutes min';
    }
    final hours = duration.inHours;
    final mins = minutes % 60;
    return '${hours}h ${mins}m';
  }

  Future<void> _handleStopRide(BuildContext context, WidgetRef ref) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(
            color: VelocityColors.primary,
          ),
        );
      },
    );

    try {
      final locationService = ref.read(locationServiceProvider);
      Position? position;
      try {
        position = await locationService.currentPosition();
      } catch (_) {}

      final lat = position?.latitude ?? 0.0;
      final lng = position?.longitude ?? 0.0;

      final repo = ref.read(rideRepositoryProvider);
      final ended = await repo.endRide(
        rideId: ride.id,
        endLatitude: lat,
        endLongitude: lng,
      );

      if (context.mounted) {
        Navigator.of(context).pop(); // pop loading
      }

      if (context.mounted) {
        final duration = (ended.endTime ?? DateTime.now()).difference(ended.startTime ?? DateTime.now());
        final durationMins = duration.inMinutes;
        
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (context) => Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            decoration: BoxDecoration(
              color: VelocityColors.surfaceCard,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: VelocityColors.divider,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),
                const Icon(
                  Icons.check_circle_outline_rounded,
                  color: Colors.green,
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text('Ride Completed!', style: VelocityText.headlineSmall()),
                const SizedBox(height: 12),
                Text(
                  'Ride duration: $durationMins min • Cost: ${ended.cost.toStringAsFixed(2)} ETB',
                  style: VelocityText.bodySmall(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: VelocityColors.primary,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Done',
                      style: VelocityText.labelLarge(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      ref.invalidate(rideHistoryProvider);
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // pop loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to end ride: ${e.toString()}'),
            backgroundColor: VelocityColors.error,
          ),
        );
      }
    }
  }

  void _showRideDetailsBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.62,
        minChildSize: 0.45,
        maxChildSize: 0.85,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: VelocityColors.surfaceCard,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pull Handle
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: VelocityColors.divider.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(9999),
                      ),
                    ),
                  ),
                  
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: ride.active
                              ? Colors.orange.withValues(alpha: 0.1)
                              : VelocityColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.pedal_bike_rounded,
                          color: ride.active ? Colors.orange : VelocityColors.primary,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ride.bike.bikeType ?? 'Smart City Cruiser',
                              style: VelocityText.titleLarge(),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(ride.startTime),
                              style: VelocityText.bodySmall(
                                color: VelocityColors.textMuted,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: ride.active
                              ? Colors.orange.withValues(alpha: 0.1)
                              : VelocityColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          ride.active ? 'ACTIVE' : 'COMPLETED',
                          style: VelocityText.labelMedium(
                            color: ride.active ? Colors.orange : VelocityColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Quick Summary Box
                  Row(
                    children: [
                      // Cost Summary Card
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: VelocityColors.surfaceLight.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: VelocityColors.primary.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TOTAL COST',
                                style: VelocityText.overline(
                                  color: VelocityColors.secondaryDark,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${ride.cost.toStringAsFixed(2)} ETB',
                                style: VelocityText.titleLarge(
                                  color: VelocityColors.primaryDarker,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Duration Summary Card
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: VelocityColors.surfaceLight.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: VelocityColors.primary.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'DURATION',
                                style: VelocityText.overline(
                                  color: VelocityColors.secondaryDark,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _formatDuration(ride.startTime, ride.endTime ?? DateTime.now()),
                                style: VelocityText.titleLarge(
                                  color: VelocityColors.primaryDarker,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Divider
                  Container(
                    height: 1,
                    color: VelocityColors.divider.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 24),

                  // Ride Details
                  Text(
                    'Ride Details',
                    style: VelocityText.titleLarge(),
                  ),
                  const SizedBox(height: 16),
                  
                  _BottomSheetDetailRow(
                    icon: Icons.tag,
                    label: 'Ride ID',
                    value: '#${ride.id}',
                  ),
                  const SizedBox(height: 14),
                  
                  _BottomSheetDetailRow(
                    icon: Icons.access_time_rounded,
                    label: 'Start Time',
                    value: _formatDate(ride.startTime),
                  ),
                  
                  if (ride.endTime != null) ...[
                    const SizedBox(height: 14),
                    _BottomSheetDetailRow(
                      icon: Icons.stop_circle_rounded,
                      label: 'End Time',
                      value: _formatDate(ride.endTime),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Bike Details if available
                  if (ride.bike.bikeType != null || ride.bike.bikeSize != null || ride.bike.qrCode != null) ...[
                    Container(
                      height: 1,
                      color: VelocityColors.divider.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Bike Specifications',
                      style: VelocityText.titleLarge(),
                    ),
                    const SizedBox(height: 16),
                    if (ride.bike.bikeType != null) ...[
                      _BottomSheetDetailRow(
                        icon: Icons.pedal_bike_rounded,
                        label: 'Type',
                        value: ride.bike.bikeType!,
                      ),
                      const SizedBox(height: 14),
                    ],
                    if (ride.bike.bikeSize != null) ...[
                      _BottomSheetDetailRow(
                        icon: Icons.straighten_rounded,
                        label: 'Wheel Size',
                        value: '${ride.bike.bikeSize}"',
                      ),
                      const SizedBox(height: 14),
                    ],
                    if (ride.bike.qrCode != null) ...[
                      _BottomSheetDetailRow(
                        icon: Icons.qr_code_rounded,
                        label: 'QR Code',
                        value: ride.bike.qrCode!,
                      ),
                    ],
                    const SizedBox(height: 24),
                  ],

                  // Actions
                  if (ride.active) ...[
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        _handleStopRide(context, ref);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          color: VelocityColors.error,
                          borderRadius: BorderRadius.circular(9999),
                          boxShadow: [
                            BoxShadow(
                              color: VelocityColors.error.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Stop Ride',
                          style: VelocityText.labelLarge(color: Colors.white),
                        ),
                      ),
                    ),
                  ] else ...[
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          color: VelocityColors.primary,
                          borderRadius: BorderRadius.circular(9999),
                          boxShadow: [
                            BoxShadow(
                              color: VelocityColors.primary.withValues(alpha: 0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Close',
                          style: VelocityText.labelLarge(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardContent = Container(
      decoration: BoxDecoration(
        color: VelocityColors.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ride.active
              ? Colors.orange.withValues(alpha: 0.6)
              : VelocityColors.primary.withValues(alpha: 0.1),
          width: ride.active ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Bike ID and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: ride.active
                              ? Colors.orange.withValues(alpha: 0.1)
                              : VelocityColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.pedal_bike_rounded,
                          color: ride.active ? Colors.orange : VelocityColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ride.bike.bikeType != null
                                  ? '${ride.bike.bikeType}${ride.bike.bikeSize != null ? ' · ${ride.bike.bikeSize}"' : ''}'
                                  : 'Smart City Cruiser',
                              style: VelocityText.bodyMedium(
                                color: VelocityColors.primaryDarker,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              ride.active ? 'Active Ride' : 'Completed Ride',
                              style: VelocityText.bodySmall(
                                color: ride.active
                                    ? Colors.orange
                                    : VelocityColors.textMuted,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
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
                    color: ride.active
                        ? Colors.orange.withValues(alpha: 0.1)
                        : VelocityColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${ride.cost.toStringAsFixed(2)} ETB',
                    style: VelocityText.bodyMedium(
                      color: ride.active ? Colors.orange : VelocityColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Divider
            Container(
              height: 1,
              color: VelocityColors.divider.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),
            // Time and Duration
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _DetailRow(
                    icon: Icons.access_time_rounded,
                    label: 'Start Time',
                    value: _formatDate(ride.startTime),
                  ),
                ),
                if (ride.endTime != null)
                  Expanded(
                    child: _DetailRow(
                      icon: Icons.stop_circle_rounded,
                      label: 'End Time',
                      value: _formatDate(ride.endTime),
                    ),
                  ),
              ],
            ),
            if (ride.endTime != null) ...[
              const SizedBox(height: 8),
              _DetailRow(
                icon: Icons.timer_rounded,
                label: 'Duration',
                value: _formatDuration(ride.startTime, ride.endTime),
              ),
            ],
          ],
        ),
      ),
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: VelocityColors.primary.withValues(alpha: 0.08),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showRideDetailsBottomSheet(context, ref),
          borderRadius: BorderRadius.circular(20),
          child: ride.active
              ? Stack(
                  children: [
                    cardContent,
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Active',
                              style: VelocityText.overline(color: Colors.orange),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : cardContent,
        ),
      ),
    );
  }
}

// Detail Row Widget
class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: VelocityColors.secondary,
        ),
        const SizedBox(width: 8),
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
                style: VelocityText.bodySmall(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Bottom Sheet Detail Row Widget
class _BottomSheetDetailRow extends StatelessWidget {
  const _BottomSheetDetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: VelocityColors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: VelocityColors.primary,
          ),
        ),
        const SizedBox(width: 14),
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
                style: VelocityText.bodyMedium(
                  color: VelocityColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


