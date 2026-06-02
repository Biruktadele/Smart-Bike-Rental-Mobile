import 'dart:convert';

import '../../../core/auth/token_storage.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../auth/data/auth_repository.dart';
import 'ride_models.dart';

class RideRepository {
  RideRepository({
    required this.apiClient,
    required this.tokenStorage,
  });

  final ApiClient apiClient;
  final TokenStorage tokenStorage;

  Future<Ride> startRide({required String qrCode}) async {
    final userId = await tokenStorage.readUserId();
    if (userId == null || userId == 0) {
      throw AuthException('User not authenticated.');
    }
    try {
      final response = await apiClient.post(
        '/rides/start',
        query: {
          'userId': userId.toString().padLeft(2, '0'),
          'qrCode': qrCode.padLeft(2, '0'),
        },
        body: '',
      );
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return Ride.fromJson(decoded);
      }
      throw AuthException('Invalid ride response.');
    } on ApiException catch (e) {
      throw AuthException(e.message);
    }
  }

  Future<Ride> startBookedRide({
    required int userId,
    required int bookingId,
    required double startLatitude,
    required double startLongitude,
  }) async {
    try {
      final response = await apiClient.post(
        '/rides/start',
        body: jsonEncode({
          'userId': userId,
          'bookingId': bookingId,
          'startLatitude': startLatitude,
          'startLongitude': startLongitude,
        }),
      );
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey('data') && decoded['data'] is Map<String, dynamic>) {
          return Ride.fromJson(decoded['data'] as Map<String, dynamic>);
        }
        return Ride.fromJson(decoded);
      }
      throw AuthException('Invalid ride response.');
    } on ApiException catch (e) {
      throw AuthException(e.message);
    }
  }

  Future<Ride> endRide({
    required int rideId,
    double endLatitude = 0.0,
    double endLongitude = 0.0,
  }) async {
    try {
      final response = await apiClient.post(
        '/rides/end',
        body: jsonEncode({
          'rideId': rideId,
          'endLatitude': endLatitude,
          'endLongitude': endLongitude,
        }),
      );
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey('data') && decoded['data'] is Map<String, dynamic>) {
          return Ride.fromJson(decoded['data'] as Map<String, dynamic>);
        }
        return Ride.fromJson(decoded);
      }
      throw AuthException('Invalid ride response.');
    } on ApiException catch (e) {
      throw AuthException(e.message);
    }
  }

  Future<List<Ride>> fetchRideHistory() async {
    final userId = await tokenStorage.readUserId();
    if (userId == null || userId == 0) {
      throw AuthException('User not authenticated.');
    }
    try {
      final response = await apiClient.get('/rides/user/$userId');
      final decoded = jsonDecode(response.body);
      
      // Handle wrapped response format: { "data": [...], "message": "...", "success": true, ... }
      if (decoded is Map<String, dynamic>) {
        final ridesList = decoded['data'];
        if (ridesList is List) {
          return ridesList
              .whereType<Map<String, dynamic>>()
              .map(Ride.fromJson)
              .toList();
        }
      }
      
      // Fallback for direct list response
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(Ride.fromJson)
            .toList();
      }
      
      return [];
    } on ApiException catch (e) {
      throw AuthException(e.message);
    }
  }
}
