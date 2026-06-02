import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:smbk/l10n/app_localizations.dart';

import '../../../../core/location/location_providers.dart';
import '../../../../theme.dart';
import '../../../../core/localization/locale_notifier.dart';
import '../../../../widgets/custom_buttons.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../data/ride_models.dart';
import '../ride_providers.dart';

class ActiveRideScreen extends ConsumerStatefulWidget {
  const ActiveRideScreen({super.key, required this.ride});

  final Ride ride;

  @override
  ConsumerState<ActiveRideScreen> createState() => _ActiveRideScreenState();
}

class _ActiveRideScreenState extends ConsumerState<ActiveRideScreen>
    with TickerProviderStateMixin {
  Timer? _timer;
  int _seconds = 0;
  StreamSubscription<Position>? _positionSub;
  final List<LatLng> _route = [];
  final MapController _mapController = MapController();

  late AnimationController _pulseCtrl;

  DateTime get _startTime => widget.ride.startTime ?? DateTime.now();

  double get _distanceKm {
    if (_route.length < 2) return 0.0;
    final distance = Distance();
    var total = 0.0;
    for (var i = 1; i < _route.length; i++) {
      total += distance(_route[i - 1], _route[i]);
    }
    return total / 1000.0;
  }

  double get _costEtb => (_seconds / 60.0) * 0.15;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 1, milliseconds: 500))
      ..repeat(reverse: true);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _seconds++);
    });

    ref.read(locationServiceProvider).ensurePermission();
    _positionSub = ref
        .read(locationServiceProvider)
        .positionStream()
        .listen((pos) {
      final point = LatLng(pos.latitude, pos.longitude);
      setState(() => _route.add(point));
      _mapController.move(point, 16);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseCtrl.dispose();
    _positionSub?.cancel();
    super.dispose();
  }

  String get _timeLabel {
    final m = _seconds ~/ 60;
    final s = _seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _endRide() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: CircularProgressIndicator(color: VelocityColors.primary),
      ),
    );

    try {
      final repo = ref.read(rideRepositoryProvider);
      final center = _route.isNotEmpty
          ? _route.last
          : const LatLng(8.9806, 38.7578);
      final ended = await repo.endRide(
        rideId: widget.ride.id,
        endLatitude: center.latitude,
        endLongitude: center.longitude,
      );
      final endTime = ended.endTime ?? DateTime.now();
      final startTime = ended.startTime ?? _startTime;
      final duration = endTime.difference(startTime);

      if (!mounted) return;
      Navigator.of(context).pop(); // dismiss loader

      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isDismissible: false,
        enableDrag: false,
        builder: (_) => _EndRideSheet(
          time: _formatDuration(duration),
          distance: _distanceKm.toStringAsFixed(1),
          cost: ended.cost.toStringAsFixed(2),
          checkoutUrl: ended.checkoutUrl,
          onGoHome: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          },
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // dismiss loader
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to end ride: $e'),
          backgroundColor: VelocityColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(brightnessProvider);
    ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context);
    final center = _route.isNotEmpty
        ? _route.last
        : const LatLng(8.9806, 38.7578);

    return Scaffold(
      backgroundColor: VelocityColors.background,
      body: Stack(
        children: [
          Container(color: VelocityColors.surfaceLight),
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(initialCenter: center, initialZoom: 16),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'smbk',
              ),
              PolylineLayer(
                polylines: [
                  if (_route.length >= 2)
                    Polyline(
                      points: _route,
                      strokeWidth: 5,
                      color: VelocityColors.primary,
                    ),
                ],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: center,
                    width: 44,
                    height: 44,
                    child: Icon(Icons.my_location_rounded,
                        color: VelocityColors.primary),
                  ),
                ],
              ),
            ],
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                      );
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close_rounded,
                          color: VelocityColors.primaryDarker, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  AnimatedBuilder(
                    animation: _pulseCtrl,
                    builder: (_, _) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Color.lerp(
                          VelocityColors.accent,
                          VelocityColors.primary,
                          _pulseCtrl.value,
                        ),
                        borderRadius: BorderRadius.circular(9999),
                        boxShadow: [
                          BoxShadow(
                            color: VelocityColors.primary.withValues(alpha: 0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(l10n?.activeRideTitle.toUpperCase() ?? 'RIDE ACTIVE',
                              style: VelocityText.overline(color: Colors.white)
                                  .copyWith(letterSpacing: 1.5)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _DashboardCard(
              time: _timeLabel,
              distance: _distanceKm,
              cost: _costEtb,
              onEndRide: _endRide,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hours = duration.inHours;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }
}

// ─── Dashboard Card ─────────────────────────────────────────────────────────
class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.time,
    required this.distance,
    required this.cost,
    required this.onEndRide,
  });
  final String time;
  final double distance;
  final double cost;
  final VoidCallback onEndRide;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final mins = time.split(':')[0];
    final secs = time.split(':')[1];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: VelocityColors.surfaceCard,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: VelocityColors.primary.withValues(alpha: 0.12),
            blurRadius: 40,
            spreadRadius: -8,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag pill
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: VelocityColors.divider,
              borderRadius: BorderRadius.circular(9999),
            ),
          ),

          // Ride time — large display
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.timer_outlined,
                  color: VelocityColors.secondary, size: 18),
              const SizedBox(width: 8),
              Text('RIDE TIME', style: VelocityText.overline()),
              const Spacer(),
              Text(mins,
                  style: VelocityText.displayMedium(
                          color: VelocityColors.primaryDarker)
                      .copyWith(fontSize: 56)),
              Text(':',
                  style: VelocityText.displayMedium(
                          color: VelocityColors.secondary)
                      .copyWith(fontSize: 56)),
              Text(secs,
                  style: VelocityText.displayMedium(
                          color: VelocityColors.primaryDarker)
                      .copyWith(fontSize: 56)),
            ],
          ),

          const SizedBox(height: 20),

          // Grid: distance + cost
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  icon: Icons.route_rounded,
                  label: l10n?.distanceLabel.toUpperCase() ?? 'DISTANCE',
                  value: distance.toStringAsFixed(1),
                  unit: 'km',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricTile(
                  icon: Icons.attach_money_rounded,
                  label: l10n?.currentCost.toUpperCase() ?? 'EST. COST',
                  value: cost.toStringAsFixed(2),
                  unit: 'ETB',
                  valuePrefix: '',
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          VelocityPrimaryButton(
            label: l10n?.stopRide ?? 'End Ride',
            icon: Icons.stop_circle_outlined,
            onPressed: onEndRide,
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    this.valuePrefix = '',
  });
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final String valuePrefix;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: VelocityColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: VelocityColors.cardSurface),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: VelocityColors.primary, size: 18),
              const SizedBox(width: 6),
              Text(label,
                  style: VelocityText.overline(
                      color: VelocityColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$valuePrefix$value',
                  style: VelocityText.headlineSmall(
                      color: VelocityColors.primaryDarker)),
              const SizedBox(width: 4),
              Text(unit, style: VelocityText.bodySmall()),
            ],
          ),
        ],
      ),
    );
  }
}

class _EndRideSheet extends StatelessWidget {
  const _EndRideSheet({
    required this.time,
    required this.distance,
    required this.cost,
    required this.onGoHome,
    this.checkoutUrl,
  });
  final String time;
  final String distance;
  final String cost;
  final String? checkoutUrl;
  final VoidCallback onGoHome;

  Future<void> _launchCheckout(BuildContext context) async {
    if (checkoutUrl == null) return;
    
    // Ensure URL has a scheme
    String urlString = checkoutUrl!;
    if (!urlString.startsWith('http://') && !urlString.startsWith('https://')) {
      urlString = 'https://$urlString';
    }
    
    final uri = Uri.parse(urlString);
    
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Could not open payment page.'),
            backgroundColor: VelocityColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error launching payment page: $e'),
            backgroundColor: VelocityColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom +
        MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: VelocityColors.surfaceCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(24, 20, 24, bottomPadding > 0 ? bottomPadding + 8 : 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: VelocityColors.divider,
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),

              // Success icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: VelocityColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: VelocityColors.primary,
                  size: 36,
                ),
              ),
              const SizedBox(height: 14),

              Text(l10n?.statusCompleted != null ? '${l10n!.statusCompleted}!' : 'Ride Complete!', style: VelocityText.headlineSmall()),
              const SizedBox(height: 4),
              Text(
                'Great ride! Here is your trip summary.',
                style: VelocityText.bodySmall(color: VelocityColors.textMuted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Trip stats row
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: VelocityColors.surfaceLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: VelocityColors.primary.withValues(alpha: 0.08),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatPill(
                      icon: Icons.timer_rounded,
                      label: l10n?.duration ?? 'Duration',
                      value: time,
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: VelocityColors.divider,
                    ),
                    _StatPill(
                      icon: Icons.route_rounded,
                      label: l10n?.distanceLabel ?? 'Distance',
                      value: '$distance km',
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: VelocityColors.divider,
                    ),
                    _StatPill(
                      icon: Icons.payments_rounded,
                      label: l10n?.costLabel ?? 'Cost',
                      value: '$cost ETB',
                      valueColor: VelocityColors.primary,
                    ),
                  ],
                ),
              ),

              if (checkoutUrl != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          color: Colors.orange, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Payment pending. Complete checkout to confirm your ride.',
                          style: VelocityText.bodySmall(color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Pay Now button (shown only if checkoutUrl exists)
              if (checkoutUrl != null)
                GestureDetector(
                  onTap: () => _launchCheckout(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 17),
                    decoration: BoxDecoration(
                      gradient: VelocityColors.primaryButtonGradient,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: VelocityColors.primary.withValues(alpha: 0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.payment_rounded,
                            color: Colors.white, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          'Pay Now via Chapa',
                          style: VelocityText.labelLarge(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),

              if (checkoutUrl != null) const SizedBox(height: 12),

              // Done / Go Home button
              GestureDetector(
                onTap: onGoHome,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: checkoutUrl != null
                        ? VelocityColors.inputBg
                        : null,
                    gradient: checkoutUrl == null
                        ? VelocityColors.primaryButtonGradient
                        : null,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: checkoutUrl == null
                        ? [
                            BoxShadow(
                              color: VelocityColors.primary.withValues(alpha: 0.25),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    checkoutUrl != null ? 'Pay Later · Go Home' : (l10n?.noKeep != null ? (l10n!.noKeep == 'No, Keep' ? 'Done' : 'ጨርስ') : 'Done'),
                    style: VelocityText.labelLarge(
                      color: checkoutUrl != null
                          ? VelocityColors.textSecondary
                          : Colors.white,
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

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: valueColor ?? VelocityColors.secondary, size: 18),
        const SizedBox(height: 6),
        Text(
          value,
          style: VelocityText.labelMedium(
            color: valueColor ?? VelocityColors.primaryDarker,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: VelocityText.overline(color: VelocityColors.textMuted),
        ),
      ],
    );
  }
}
