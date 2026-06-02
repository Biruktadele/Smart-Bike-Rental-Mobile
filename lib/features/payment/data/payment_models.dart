class WalletBalance {
  const WalletBalance({required this.balance, required this.currency});

  final double balance;
  final String currency;

  factory WalletBalance.fromJson(Map<String, dynamic> json) {
    return WalletBalance(
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      currency: (json['currency'] ?? 'ETB').toString(),
    );
  }
}

class PaymentMethod {
  const PaymentMethod({
    required this.id,
    required this.label,
    required this.last4,
    required this.cardNumber,
    required this.cardHolderName,
    required this.expiryDate,
    required this.brand,
  });

  final String id;
  final String label;
  final String last4;
  final String cardNumber;
  final String cardHolderName;
  final String expiryDate;
  final String brand;

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: (json['id'] ?? '').toString(),
      label: (json['label'] ?? '').toString(),
      last4: (json['last4'] ?? '').toString(),
      cardNumber: (json['cardNumber'] ?? '').toString(),
      cardHolderName: (json['cardHolderName'] ?? '').toString(),
      expiryDate: (json['expiryDate'] ?? '').toString(),
      brand: (json['brand'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'last4': last4,
      'cardNumber': cardNumber,
      'cardHolderName': cardHolderName,
      'expiryDate': expiryDate,
      'brand': brand,
    };
  }
}

class PaymentTransaction {
  const PaymentTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
  });

  final String id;
  final String title;
  final double amount;
  final DateTime? date;

  factory PaymentTransaction.fromJson(Map<String, dynamic> json) {
    return PaymentTransaction(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      date: DateTime.tryParse((json['date'] ?? '').toString()),
    );
  }
}
