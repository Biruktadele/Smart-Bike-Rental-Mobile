import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/auth/token_storage.dart';
import '../../../core/network/api_client.dart';
import '../../booking/data/booking_models.dart';

class BookingRepository {
  BookingRepository(this._apiClient, this._tokenStorage);

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  static const _bookedBikeKey = 'booked_bike_qr';

  /// Books a bike by its QR code.
  Future<void> bookBike({required String qrCode}) async {
    final session = await _tokenStorage.loadSession();
    if (session == null) {
      throw Exception('User not logged in');
    }

    await _apiClient.post(
      '/booking/scan',
      query: {
        'userId': session.userId.toString().padLeft(2, '0'),
        'qrCode': qrCode.padLeft(2, '0'),
      },
      // Pass empty string so Content-Type isn't blindly set correctly
      body: '',
    );

    // Save booked bike locally
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_bookedBikeKey, qrCode);
  }

  /// Retrieves the currently booked bike QR code from local storage.
  Future<String?> getBookedBike() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_bookedBikeKey);
  }

  /// Fetch bookings for the current user.
  Future<List<Booking>> fetchUserBookings() async {
    final userId = await _tokenStorage.readUserId();
    if (userId == null || userId == 0) {
      return [];
    }

    final response = await _apiClient.get(
      '/booking/user/${userId.toString().padLeft(2, '0')}',
    );

    final decoded = response.body;
    try {
      final json = jsonDecode(decoded);
      if (json is Map<String, dynamic>) {
        final data = json['data'];
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map(Booking.fromJson)
              .toList();
        }
      }
      if (json is List) {
        return json
            .whereType<Map<String, dynamic>>()
            .map(Booking.fromJson)
            .toList();
      }
    } catch (_) {}

    return [];
  }

  /// Clears the currently booked bike when the ride actually starts, or if cancelled.
  Future<void> clearBookedBike() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_bookedBikeKey);
  }
}
