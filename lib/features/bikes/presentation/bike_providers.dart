import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_providers.dart';
import '../../booking/data/booking_models.dart';
import '../data/bike_repository.dart';
import '../data/bike_models.dart';
import '../data/booking_repository.dart';

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepository(
    ref.watch(apiClientProvider),
    ref.watch(tokenStorageProvider),
  );
});

final bookedBikeProvider = FutureProvider<String?>((ref) async {
  return ref.watch(bookingRepositoryProvider).getBookedBike();
});

final bookedRidesProvider = FutureProvider<List<Booking>>((ref) async {
  return ref.watch(bookingRepositoryProvider).fetchUserBookings();
});

final bikeRepositoryProvider = Provider<BikeRepository>((ref) {
  return BikeRepository(apiClient: ref.watch(apiClientProvider));
});

final bikesProvider = FutureProvider<List<Bike>>((ref) async {
  return ref.watch(bikeRepositoryProvider).fetchBikes();
});
