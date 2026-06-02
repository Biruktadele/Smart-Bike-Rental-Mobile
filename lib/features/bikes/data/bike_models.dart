class Bike {
  const Bike({
    required this.id,
    required this.bikeId,
    required this.status,
    required this.qrCode,
    this.bikeType,
    this.bikeSize,
    this.latitude,
    this.longitude,
    this.isUsable = true,
    this.isAvailable = true,
    this.batteryLevel = 100,
    this.lastUpdated,
    this.currentUserEmail,
  });

  final int id;
  final String bikeId;
  final String status;
  final String? qrCode;
  final String? bikeType;
  final String? bikeSize;
  final double? latitude;
  final double? longitude;
  final bool isUsable;
  final bool isAvailable;
  final int batteryLevel;
  final String? lastUpdated;
  final String? currentUserEmail;

  factory Bike.fromJson(Map<String, dynamic> json) {
    // Default location (Addis Ababa, Ethiopia)
    const defaultLatitude = 9.033204;
    const defaultLongitude = 38.74318;

    return Bike(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      bikeId: (json['bikeId'] ?? '').toString(),
      status: (json['status'] ?? 'LOCKED').toString(),
      qrCode: json['qrCode']?.toString(),
      bikeType: json['bikeType']?.toString(),
      bikeSize: json['bikeSize']?.toString(),
      latitude: double.tryParse(json['latitude']?.toString() ?? '') ?? defaultLatitude,
      longitude: double.tryParse(json['longitude']?.toString() ?? '') ?? defaultLongitude,
      isUsable: json['isUsable'] == true || json['isUsable'] == 'true',
      isAvailable: json['isAvailable'] == true || json['isAvailable'] == 'true',
      batteryLevel: int.tryParse(json['batteryLevel']?.toString() ?? '') ?? 100,
      lastUpdated: json['lastUpdated']?.toString(),
      currentUserEmail: json['currentUserEmail']?.toString(),
    );
  }
}
