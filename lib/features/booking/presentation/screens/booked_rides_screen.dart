import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:smbk/l10n/app_localizations.dart';

import '../../../../theme.dart';
import '../../../../core/localization/locale_notifier.dart';
import '../../../bikes/presentation/bike_providers.dart';
import '../../../bikes/data/bike_models.dart';
import '../../../scan/presentation/screens/scan_screen.dart';
import '../../../ride/presentation/ride_providers.dart';
import '../../../ride/presentation/screens/active_ride_screen.dart';
import '../../data/booking_models.dart';

class BookedRidesScreen extends ConsumerWidget {
  const BookedRidesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(brightnessProvider);
    ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context);
    final bookings = ref.watch(bookedRidesProvider);
    final bikesAsync = ref.watch(bikesProvider);
    final bikeList = bikesAsync.valueOrNull ?? [];

    return Scaffold(
      backgroundColor: VelocityColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dashboard Top Header Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n?.reservationsTitle ?? 'Reservations',
                          style: VelocityText.headlineMedium(
                            color: VelocityColors.primaryDarker,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n?.reservationsSubtitle ?? 'Your reserved rides',
                          style: VelocityText.bodyMedium(
                            color: VelocityColors.secondaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Pulse active badge
                  bookings.maybeWhen(
                    data: (items) {
                      if (items.isEmpty) return const SizedBox.shrink();
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(
                            color: Colors.orange.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${items.length} Reserved',
                              style: VelocityText.overline(color: Colors.orange),
                            ),
                          ],
                        ),
                      );
                    },
                    orElse: () => const SizedBox.shrink(),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Interactive dashboard body
              Expanded(
                child: bookings.when(
                  skipLoadingOnRefresh: true,
                  data: (items) {
                    if (items.isEmpty) {
                      return RefreshIndicator(
                        color: VelocityColors.primary,
                        onRefresh: () async {
                          ref.invalidate(bookedRidesProvider);
                          ref.invalidate(bikesProvider);
                          try {
                            await ref.read(bookedRidesProvider.future);
                            await ref.read(bikesProvider.future);
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
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: VelocityColors.primary.withValues(alpha: 0.05),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.bookmark_border_rounded,
                                      size: 54,
                                      color: VelocityColors.primary.withValues(alpha: 0.4),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                   Text(
                                    l10n != null ? (l10n!.localeName == 'am' ? 'ምንም ገቢር ማስያዣዎች የሉም' : 'No Active Bookings') : 'No Active Bookings',
                                    style: VelocityText.headlineSmall(
                                      color: VelocityColors.primaryDarker,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 32),
                                    child: Text(
                                      l10n != null ? (l10n!.localeName == 'am' ? 'ጉዞ ይፈልጋሉ? ከዋናው የካርታ ዳሽቦርድ ላይ ብስክሌቶችን ያግኙ እና ያስይዙ።' : 'Need a ride? Discover and reserve bikes directly from the main map dashboard.') : 'Need a ride? Discover and reserve bikes directly from the main map dashboard.',
                                      style: VelocityText.bodyMedium(
                                        color: VelocityColors.textMuted,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  // Quick discover button
                                  GestureDetector(
                                    onTap: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(l10n != null ? (l10n!.localeName == 'am' ? 'ብስክሌት ለማስያዝ ወደ ካርታው ገጽ ይሂዱ!' : 'Navigate to the Map tab to book a bike!') : 'Navigate to the Map tab to book a bike!'),
                                          backgroundColor: VelocityColors.primary,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 14,
                                      ),
                                      decoration: BoxDecoration(
                                        color: VelocityColors.primary,
                                        borderRadius: BorderRadius.circular(99),
                                        boxShadow: [
                                          BoxShadow(
                                            color: VelocityColors.primary.withValues(alpha: 0.2),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        l10n != null ? (l10n!.localeName == 'am' ? 'አቅራቢያ ያሉ ብስክሌቶችን ፈልግ' : 'Explore Nearby Bikes') : 'Explore Nearby Bikes',
                                        style: VelocityText.labelMedium(color: Colors.white),
                                      ),
                                    ),
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
                        ref.invalidate(bookedRidesProvider);
                        ref.invalidate(bikesProvider);
                        try {
                          await ref.read(bookedRidesProvider.future);
                          await ref.read(bikesProvider.future);
                        } catch (_) {}
                      },
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 120),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final booking = items[index];
                          // Match with loaded bike list to fetch real time status
                          final matchingBike = bikeList.firstWhere(
                            (b) => b.bikeId == booking.bikeId || b.id.toString() == booking.bikeId,
                            orElse: () => Bike(
                              id: 0,
                              bikeId: booking.bikeId,
                              status: booking.status,
                              qrCode: booking.qrCode,
                              batteryLevel: 100,
                              isAvailable: false,
                              isUsable: true,
                            ),
                          );

                          return _BookingDashboardCard(
                            booking: booking,
                            bike: matchingBike,
                          );
                        },
                      ),
                    );
                  },
                  error: (e, _) => RefreshIndicator(
                    color: VelocityColors.primary,
                    onRefresh: () async {
                      ref.invalidate(bookedRidesProvider);
                      ref.invalidate(bikesProvider);
                      try {
                        await ref.read(bookedRidesProvider.future);
                        await ref.read(bikesProvider.future);
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
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: VelocityColors.error.withValues(alpha: 0.05),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.error_outline_rounded,
                                  size: 48,
                                  color: VelocityColors.error,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Failed to load bookings',
                                style: VelocityText.headlineSmall(
                                  color: VelocityColors.primaryDarker,
                                ),
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
                          'Synchronizing bookings...',
                          style: VelocityText.bodyMedium(
                            color: VelocityColors.primaryDarker,
                          ),
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

// Booking Dashboard Card Widget
class _BookingDashboardCard extends ConsumerWidget {
  const _BookingDashboardCard({
    required this.booking,
    required this.bike,
  });

  final Booking booking;
  final Bike bike;

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return 'Unknown Time';
    return DateFormat('MMM dd, yyyy • hh:mm a').format(dateTime.toLocal());
  }

  void _showBookingDetailsSheet(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.58,
        minChildSize: 0.4,
        maxChildSize: 0.8,
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
                  // Handle
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

                  // Header Block
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.bookmark_added_rounded,
                          color: Colors.orange,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bike.bikeType ?? 'Smart City Cruiser',
                              style: VelocityText.titleLarge(),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n?.reservationsSubtitle ?? 'Reserved Bike',
                              style: VelocityText.bodySmall(
                                color: VelocityColors.textMuted,
                              ),
                              overflow: TextOverflow.ellipsis,
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
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          l10n?.reservationsTitle != null ? (l10n!.localeName == 'am' ? 'የተያዘ' : 'RESERVED') : 'RESERVED',
                          style: VelocityText.labelMedium(color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Metadata Cards
                  Row(
                    children: [
                      // Battery Card
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
                                l10n != null ? (l10n!.localeName == 'am' ? 'የባትሪ ደረጃ' : 'BATTERY LEVEL') : 'BATTERY LEVEL',
                                style: VelocityText.overline(
                                  color: VelocityColors.secondaryDark,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    Icons.battery_3_bar_rounded,
                                    color: bike.batteryLevel >= 50
                                        ? VelocityColors.primary
                                        : Colors.orange,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${bike.batteryLevel}%',
                                    style: VelocityText.titleLarge(
                                      color: VelocityColors.primaryDarker,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Status Card
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
                                l10n?.lockStatus ?? 'LOCK STATUS',
                                style: VelocityText.overline(
                                  color: VelocityColors.secondaryDark,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    Icons.lock_rounded,
                                    color: VelocityColors.primary,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    bike.status,
                                    style: VelocityText.titleLarge(
                                      color: VelocityColors.primaryDarker,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Container(
                    height: 1,
                    color: VelocityColors.divider.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 24),

                  // Detail Rows
                  Text(l10n != null ? (l10n!.localeName == 'am' ? 'የማስያዣ ዝርዝሮች' : 'Booking Details') : 'Booking Details', style: VelocityText.titleLarge()),
                  const SizedBox(height: 16),

                  _BottomSheetRow(
                    icon: Icons.access_time_filled_rounded,
                    label: l10n?.timeLabel ?? 'Booking Time',
                    value: _formatDate(booking.bookingTime),
                  ),
                  const SizedBox(height: 14),

                  _BottomSheetRow(
                    icon: Icons.person_rounded,
                    label: l10n != null ? (l10n!.localeName == 'am' ? 'የተያዘለት ስም' : 'Reserved For') : 'Reserved For',
                    value: booking.userName,
                  ),
                  const SizedBox(height: 14),

                  _BottomSheetRow(
                    icon: Icons.qr_code_2_rounded,
                    label: 'QR Reference',
                    value: booking.qrCode,
                  ),
                  
                  if (bike.bikeType != null) ...[
                    const SizedBox(height: 14),
                    _BottomSheetRow(
                      icon: Icons.pedal_bike_rounded,
                      label: l10n != null ? (l10n!.localeName == 'am' ? 'የብስክሌት ሞዴል' : 'Bike Model') : 'Bike Model',
                      value: '${bike.bikeType} (${bike.bikeSize ?? "26"}")',
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Unlock & Ride action within bottom sheet
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ScanScreen(isStartRide: true),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        gradient: VelocityColors.primaryButtonGradient,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                            color: VelocityColors.primary.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.qr_code_scanner_rounded, color: Colors.white),
                          const SizedBox(width: 10),
                          Text(
                            l10n?.startNow ?? 'Scan & Unlock to Ride',
                            style: VelocityText.labelLarge(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleCancelBooking(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(l10n?.cancelConfirmTitle ?? 'Cancel Reservation?', style: VelocityText.titleLarge()),
        content: Text(
          l10n?.cancelConfirmMessage ?? 'This will cancel your reservation for Bike #${booking.bikeId}. Other users will be able to book it.',
          style: VelocityText.bodyMedium(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              l10n?.noKeep ?? 'Keep Reserved',
              style: VelocityText.labelMedium(color: VelocityColors.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: VelocityColors.error,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n?.yesCancel ?? 'Yes, Cancel', style: VelocityText.labelMedium(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Show loader
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => Center(
            child: CircularProgressIndicator(color: VelocityColors.primary),
          ),
        );
      }

      try {
        final repo = ref.read(bookingRepositoryProvider);
        await repo.clearBookedBike();
        
        // Invalidate providers so dashboard refreshes automatically
        ref.invalidate(bookedBikeProvider);
        ref.invalidate(bookedRidesProvider);

        if (context.mounted) {
          Navigator.of(context).pop(); // pop loader
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white),
                  const SizedBox(width: 10),
                  Text('Reservation cancelled successfully for Bike #${booking.bikeId}'),
                ],
              ),
              backgroundColor: VelocityColors.primaryDark,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.of(context).pop(); // pop loader
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to cancel: ${e.toString()}'),
              backgroundColor: VelocityColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleStartRide(BuildContext context, WidgetRef ref) async {
    // Show loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: CircularProgressIndicator(color: VelocityColors.primary),
      ),
    );

    try {
      final rideRepo = ref.read(rideRepositoryProvider);
      final bookingRepo = ref.read(bookingRepositoryProvider);

      final startLatitude = bike.latitude ?? 9.0;
      final startLongitude = bike.longitude ?? 39.0;

      final ride = await rideRepo.startBookedRide(
        userId: booking.userId,
        bookingId: booking.bookingId,
        startLatitude: startLatitude,
        startLongitude: startLongitude,
      );

      // Clear the local booking info
      await bookingRepo.clearBookedBike();

      // Invalidate providers
      ref.invalidate(bookedBikeProvider);
      ref.invalidate(bookedRidesProvider);

      if (context.mounted) {
        Navigator.of(context).pop(); // pop loader

        // Show success snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(child: Text('Ride started successfully for ${bike.bikeType ?? "Bike"}!')),
              ],
            ),
            backgroundColor: VelocityColors.primaryDark,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );

        // Transition directly to Active Ride Screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ActiveRideScreen(ride: ride),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // pop loader
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start ride: ${e.toString()}'),
            backgroundColor: VelocityColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: VelocityColors.surfaceCard,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: VelocityColors.primary.withValues(alpha: 0.06),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showBookingDetailsSheet(context, ref),
          borderRadius: BorderRadius.circular(28),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.orange.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top header of reservation card
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.bookmark_rounded,
                              color: Colors.orange,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  bike.bikeType ?? 'Smart City Cruiser',
                                  style: VelocityText.titleLarge(
                                    color: VelocityColors.primaryDarker,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  l10n?.reservationsSubtitle ?? 'Reserved Bike',
                                  style: VelocityText.bodySmall(
                                    color: VelocityColors.textMuted,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Battery indicator pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: VelocityColors.surfaceLight.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.battery_4_bar_rounded,
                            color: bike.batteryLevel >= 50
                                ? VelocityColors.primary
                                : Colors.orange,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${bike.batteryLevel}%',
                            style: VelocityText.overline(
                              color: VelocityColors.primaryDarker,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                Container(
                  height: 1,
                  color: VelocityColors.divider.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),

                // Booking time detailed row
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 16,
                      color: VelocityColors.secondaryDark,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n != null ? (l10n!.localeName == 'am' ? 'የተያዘበት ቀን:' : 'Reserved:') : 'Reserved:',
                      style: VelocityText.bodySmall(
                        color: VelocityColors.secondaryDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _formatDate(booking.bookingTime),
                        style: VelocityText.bodySmall(
                          color: VelocityColors.textPrimary,
                        ),
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // CTA Action Buttons
                GestureDetector(
                  onTap: () => _handleStartRide(context, ref),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: VelocityColors.primaryButtonGradient,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: VelocityColors.primary.withValues(alpha: 0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.play_circle_fill_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n?.startNow ?? 'Start Now',
                          style: VelocityText.labelMedium(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Bottom Sheet Row Widget
class _BottomSheetRow extends StatelessWidget {
  const _BottomSheetRow({
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
