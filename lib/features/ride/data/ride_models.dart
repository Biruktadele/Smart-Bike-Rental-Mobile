class RideUser {
  const RideUser({
    required this.id,
    required this.email,
    required this.name,
  });

  final int id;
  final String email;
  final String name;

  factory RideUser.fromJson(Map<String, dynamic> json) {
    return RideUser(
      id: (json['id'] as num?)?.toInt() ?? 0,
      email: (json['email'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
    );
  }
}

class RideBike {
  const RideBike({
    required this.id,
    required this.bikeId,
    required this.status,
    required this.qrCode,
    this.bikeType,
    this.bikeSize,
  });

  final int id;
  final String bikeId;
  final String status;
  final String? qrCode;
  final String? bikeType;
  final String? bikeSize;

  factory RideBike.fromJson(Map<String, dynamic> json) {
    return RideBike(
      id: (json['id'] as num?)?.toInt() ?? 0,
      bikeId: (json['bikeId'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      qrCode: json['qrCode']?.toString(),
      bikeType: json['bikeType']?.toString(),
      bikeSize: json['bikeSize']?.toString(),
    );
  }
}

class Ride {
  const Ride({
    required this.id,
    required this.user,
    required this.bike,
    required this.startTime,
    required this.endTime,
    required this.cost,
    required this.active,
    this.checkoutUrl,
  });

  final int id;
  final RideUser user;
  final RideBike bike;
  final DateTime? startTime;
  final DateTime? endTime;
  final double cost;
  final bool active;
  final String? checkoutUrl;

  factory Ride.fromJson(Map<String, dynamic> json) {
    final idVal = (json['id'] ?? json['rideId'] as num?)?.toInt() ?? 0;

    // Parse user with nested or flat fallback
    Map<String, dynamic> userMap = {};
    if (json['user'] is Map<String, dynamic>) {
      userMap = json['user'] as Map<String, dynamic>;
    } else {
      userMap = {
        'id': json['userId'],
        'email': json['userEmail'],
        'name': json['userName'],
      };
    }

    // Parse bike with nested or flat fallback
    Map<String, dynamic> bikeMap = {};
    if (json['bike'] is Map<String, dynamic>) {
      bikeMap = json['bike'] as Map<String, dynamic>;
    } else {
      bikeMap = {
        'bikeId': json['bikeId'],
        'qrCode': json['qrCode'],
        'status': json['bikeStatus'],
      };
    }

    return Ride(
      id: idVal,
      user: RideUser.fromJson(userMap),
      bike: RideBike.fromJson(bikeMap),
      startTime: DateTime.tryParse((json['startTime'] ?? '').toString()),
      endTime: DateTime.tryParse((json['endTime'] ?? '').toString()),
      cost: (json['cost'] as num?)?.toDouble() ?? 0.0,
      active: (json['active'] as bool?) ?? false,
      checkoutUrl: json['checkoutUrl']?.toString(),
    );
  }
}
