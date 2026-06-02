import 'dart:convert';
import 'lib/features/bikes/data/bike_models.dart';

void main() {
  const jsonString = '''{"data":[{"id":5,"bikeId":"05","bikeType":"phonex","bikeSize":"28","qrCode":"05","status":"MAINTENANCE","isUsable":false,"isAvailable":false,"batteryLevel":100,"latitude":null,"longitude":null,"lastUpdated":"2026-05-20T20:51:03.088412","currentUserEmail":null},{"id":1,"bikeId":"01","bikeType":"Phoenix","bikeSize":"26","qrCode":"01","status":"LOCKED","isUsable":true,"isAvailable":true,"batteryLevel":95,"latitude":9.03,"longitude":38.74,"lastUpdated":"2026-05-20T20:52:53.419373","currentUserEmail":null}]}''';
  final decoded = jsonDecode(jsonString);
  final bikesList = decoded['data'] as List;
  final bikes = bikesList.whereType<Map<String, dynamic>>().map(Bike.fromJson).toList();
  print(bikes.length);
}
