import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/network/api_client.dart';
import '../../auth/data/auth_repository.dart';
import 'payment_models.dart';

class PaymentRepository {
  PaymentRepository({required this.apiClient});

  final ApiClient apiClient;

  static const String _savedCardsKey = 'saved_payment_methods';

  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  Future<WalletBalance> fetchBalance() async {
    try {
      final response = await apiClient.get('/payment/wallet');
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return WalletBalance.fromJson(decoded);
      }
      return const WalletBalance(balance: 0.0, currency: 'ETB');
    } catch (e) {
      // Mock data for UI presentation since API might not be available
      return const WalletBalance(balance: 245.50, currency: 'ETB');
    }
  }

  Future<List<PaymentMethod>> fetchMethods() async {
    try {
      final p = await prefs;
      final String? methodsJson = p.getString(_savedCardsKey);
      if (methodsJson != null) {
        final List<dynamic> decoded = jsonDecode(methodsJson);
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(PaymentMethod.fromJson)
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<void> addMethod({
    required String label,
    required String last4,
    required String cardNumber,
    required String cardHolderName,
    required String expiryDate,
    required String brand,
  }) async {
    try {
      final methods = await fetchMethods();
      final newMethod = PaymentMethod(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        label: label,
        last4: last4,
        cardNumber: cardNumber,
        cardHolderName: cardHolderName,
        expiryDate: expiryDate,
        brand: brand,
      );
      methods.add(newMethod);
      final String updatedJson = jsonEncode(methods.map((m) => m.toJson()).toList());
      final p = await prefs;
      await p.setString(_savedCardsKey, updatedJson);
    } catch (e) {
      throw AuthException('Failed to save card locally.');
    }
  }

  Future<void> removeMethod(String id) async {
    try {
      final methods = await fetchMethods();
      methods.removeWhere((m) => m.id == id);
      final String updatedJson = jsonEncode(methods.map((m) => m.toJson()).toList());
      final p = await prefs;
      await p.setString(_savedCardsKey, updatedJson);
    } catch (e) {
      throw AuthException('Failed to remove card locally.');
    }
  }

  Future<List<PaymentTransaction>> fetchTransactions() async {
    try {
      final response = await apiClient.get('/payment/transactions');
      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(PaymentTransaction.fromJson)
            .toList();
      }
      return [];
    } catch (e) {
      // Mock transactions for UI presentation
      return [
        PaymentTransaction(
          id: '1',
          title: 'Ride to University',
          amount: -25.50,
          date: DateTime.now().subtract(const Duration(days: 1)),
        ),
        PaymentTransaction(
          id: '2',
          title: 'Wallet Top-up',
          amount: 100.00,
          date: DateTime.now().subtract(const Duration(days: 2)),
        ),
        PaymentTransaction(
          id: '3',
          title: 'Ride to Mall',
          amount: -35.00,
          date: DateTime.now().subtract(const Duration(days: 5)),
        ),
      ];
    }
  }
}
