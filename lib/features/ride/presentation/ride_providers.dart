import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_providers.dart';
import '../data/ride_repository.dart';
import '../data/ride_models.dart';

final rideRepositoryProvider = Provider<RideRepository>((ref) {
  return RideRepository(
    apiClient: ref.watch(apiClientProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

final rideHistoryProvider = FutureProvider<List<Ride>>((ref) {
  return ref.watch(rideRepositoryProvider).fetchRideHistory();
});
