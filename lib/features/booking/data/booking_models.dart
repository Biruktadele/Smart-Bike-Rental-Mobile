class Booking {
  const Booking({
    required this.bookingId,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.bikeId,
    required this.qrCode,
    required this.bookingTime,
    required this.status,
    required this.message,
  });

  final int bookingId;
  final int userId;
  final String userName;
  final String userEmail;
  final String bikeId;
  final String qrCode;
  final DateTime? bookingTime;
  final String status;
  final String? message;

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      bookingId: (json['bookingId'] as num?)?.toInt() ?? 0,
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      userName: (json['userName'] ?? '').toString(),
      userEmail: (json['userEmail'] ?? '').toString(),
      bikeId: (json['bikeId'] ?? '').toString(),
      qrCode: (json['qrCode'] ?? '').toString(),
      bookingTime: DateTime.tryParse((json['bookingTime'] ?? '').toString()),
      status: (json['status'] ?? '').toString(),
      message: json['message']?.toString(),
    );
  }
}
