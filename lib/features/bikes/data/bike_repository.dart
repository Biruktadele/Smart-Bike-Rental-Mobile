import 'dart:convert';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../auth/data/auth_repository.dart';
import 'bike_models.dart';

class BikeRepository {
  BikeRepository({required this.apiClient});

  final ApiClient apiClient;

  Future<List<Bike>> fetchBikes() async {
    try {
      final response = await apiClient.get('/bikes');
      final decoded = jsonDecode(response.body);
      
      // Handle the wrapped response format: { "data": [...], "message": "...", "success": true, ... }
      if (decoded is Map<String, dynamic>) {
        final bikesList = decoded['data'];
        if (bikesList is List) {
          return bikesList
              .whereType<Map<String, dynamic>>()
              .map(Bike.fromJson)
              .toList();
        }
      }
      
      // Fallback for direct list response
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(Bike.fromJson)
            .toList();
      }
      
      return [];
    } on ApiException catch (e) {
      throw AuthException(e.message);
    }
  }

  Future<void> unlockBike(String bikeId) async {
    try {
      await apiClient.post('/bikes/$bikeId/unlock');
    } on ApiException catch (e) {
      throw AuthException(e.message);
    }
  }

  Future<void> lockBike(String bikeId) async {
    try {
      await apiClient.post('/bikes/$bikeId/lock');
    } on ApiException catch (e) {
      throw AuthException(e.message);
    }
  }
}
