import 'dart:math' as math;

class RideLocation {
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String placeId;
  final String type; // ✅ Required parameter
  final Map<String, dynamic> additionalInfo;

  RideLocation({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.placeId,
    required this.type, // ✅ Added required parameter
    this.additionalInfo = const {},
  });

  factory RideLocation.fromMap(Map<String, dynamic> map) {
    return RideLocation(
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      placeId: map['placeId'] ?? '',
      type: map['type'] ?? 'other', // ✅ Added type handling
      additionalInfo: Map<String, dynamic>.from(map['additionalInfo'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'placeId': placeId,
      'type': type,
      'additionalInfo': additionalInfo,
    };
  }

  // Calculate distance using Haversine formula
  double distanceTo(double lat, double lng) {
    const double earthRadius = 6371000; // Earth radius in meters

    final double dLat = (lat - latitude) * (math.pi / 180);
    final double dLng = (lng - longitude) * (math.pi / 180);
    final double lat1Rad = latitude * (math.pi / 180);
    final double lat2Rad = lat * (math.pi / 180);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1Rad) * math.cos(lat2Rad) *
            math.sin(dLng / 2) * math.sin(dLng / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  @override
  String toString() => '$name ($address)';
}
