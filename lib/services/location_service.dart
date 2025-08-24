// services/advanced_location_service.dart
import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../features/rides/models/place_suggestion.dart';

class LocationService {
  static const String _googleApiKey = 'AIzaSyCmAnZmoJqH-Pq3ZwjE3D359IFw0B4LjRk';
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api';

  // Get current location
  Future<Position?> getCurrentLocation() async {
    try {
      var status = await Permission.location.request();
      if (status != PermissionStatus.granted) {
        return null;
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      );
      return position;
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  // FIXED: Enhanced place search with optional location parameter
  Future<List<PlaceSuggestion>> searchPlaces(
    String query, {
    LatLng? location,
  }) async {
    if (query.isEmpty) return [];

    try {
      String locationBias = '';
      if (location != null) {
        locationBias =
            '&location=${location.latitude},${location.longitude}&radius=50000';
      }

      final String url =
          '$_baseUrl/place/autocomplete/json?'
          'input=${Uri.encodeComponent(query)}&'
          'key=$_googleApiKey'
          '$locationBias&'
          'components=country:in&'
          'types=geocode|establishment|sublocality|transit_station|point_of_interest&'
          'strictbounds=true&'
          'language=en';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final predictions = data['predictions'] as List;
          return predictions
              .map(
                (prediction) => PlaceSuggestion(
                  placeId: prediction['place_id'],
                  description: prediction['description'],
                  mainText: prediction['structured_formatting']['main_text'],
                  secondaryText:
                      prediction['structured_formatting']['secondary_text'] ??
                      '',
                  types: List<String>.from(prediction['types'] ?? []),
                  distanceMeters: prediction['distance_meters'],
                ),
              )
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error searching places: $e');
      return [];
    }
  }

  // Get place details
  Future<PlaceDetails?> getPlaceDetails(String placeId) async {
    try {
      final String url =
          '$_baseUrl/place/details/json?'
          'place_id=$placeId&'
          'fields=geometry,name,formatted_address,address_components,photos&'
          'key=$_googleApiKey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final result = data['result'];
          final geometry = result['geometry']['location'];

          return PlaceDetails(
            placeId: placeId,
            name: result['name'] ?? '',
            address: result['formatted_address'] ?? '',
            latitude: geometry['lat'].toDouble(),
            longitude: geometry['lng'].toDouble(),
            addressComponents: _parseAddressComponents(
              result['address_components'],
            ),
            photoReference: _getPhotoReference(result['photos']),
          );
        }
      }
      return null;
    } catch (e) {
      print('Error getting place details: $e');
      return null;
    }
  }

  // Calculate route between two points
  Future<RouteInfo?> calculateRoute(LatLng origin, LatLng destination) async {
    try {
      final String url =
          '$_baseUrl/directions/json?'
          'origin=${origin.latitude},${origin.longitude}&'
          'destination=${destination.latitude},${destination.longitude}&'
          'key=$_googleApiKey&'
          'mode=driving&'
          'traffic_model=best_guess&'
          'departure_time=now';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final leg = route['legs'][0];

          return RouteInfo(
            distance: leg['distance']['text'],
            duration: leg['duration']['text'],
            distanceValue: leg['distance']['value'],
            durationValue: leg['duration']['value'],
            polylinePoints: _decodePolyline(
              route['overview_polyline']['points'],
            ),
            steps: _parseSteps(leg['steps']),
          );
        }
      }
      return null;
    } catch (e) {
      print('Error calculating route: $e');
      return null;
    }
  }

  // Helper methods
  List<LatLng> _decodePolyline(String polyline) {
    List<LatLng> points = [];
    int index = 0, len = polyline.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  Map<String, String> _parseAddressComponents(List? components) {
    Map<String, String> result = {};
    if (components != null) {
      for (var component in components) {
        List<String> types = List<String>.from(component['types']);
        if (types.contains('locality')) {
          result['city'] = component['long_name'];
        }
        if (types.contains('administrative_area_level_1')) {
          result['state'] = component['short_name'];
        }
        if (types.contains('postal_code')) {
          result['zipCode'] = component['long_name'];
        }
      }
    }
    return result;
  }

  String? _getPhotoReference(List? photos) {
    if (photos != null && photos.isNotEmpty) {
      return photos[0]['photo_reference'];
    }
    return null;
  }

  List<RouteStep> _parseSteps(List steps) {
    return steps
        .map(
          (step) => RouteStep(
            instruction: step['html_instructions'].replaceAll(
              RegExp(r'<[^>]*>'),
              '',
            ),
            distance: step['distance']['text'],
            duration: step['duration']['text'],
            startLocation: LatLng(
              step['start_location']['lat'].toDouble(),
              step['start_location']['lng'].toDouble(),
            ),
            endLocation: LatLng(
              step['end_location']['lat'].toDouble(),
              step['end_location']['lng'].toDouble(),
            ),
          ),
        )
        .toList();
  }

  double calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2) / 1000;
  }

  double calculateEstimatedFare(double distance, int durationMinutes) {
    double baseFare = 5.0;
    double ratePerKm = 2.0;
    double timeRate = 0.5;
    double surgeFactor = _getSurgeFactor();

    return (baseFare + (distance * ratePerKm) + (durationMinutes * timeRate)) *
        surgeFactor;
  }

  double _getSurgeFactor() {
    DateTime now = DateTime.now();
    int hour = now.hour;

    if ((hour >= 7 && hour <= 9) || (hour >= 17 && hour <= 19)) {
      return 1.5;
    }
    if (hour >= 22 || hour <= 6) {
      return 1.3;
    }
    return 1.0;
  }
}

class RideLocation {
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String placeId;
  final String type;
  final Map<String, dynamic> additionalInfo;

  RideLocation({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.placeId,
    required this.type,
    required this.additionalInfo,
  });

  factory RideLocation.fromMap(Map<String, dynamic> map) {
    return RideLocation(
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      placeId: map['placeId'] ?? '',
      type: map['type'] ?? 'other',
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

  // Calculate distance using Haversine formula (returns distance in meters)
  double distanceTo(double lat, double lng) {
    const double earthRadius = 6371000; // Earth radius in meters

    final double dLat = (lat - latitude) * (math.pi / 180);
    final double dLng = (lng - longitude) * (math.pi / 180);
    final double lat1Rad = latitude * (math.pi / 180);
    final double lat2Rad = lat * (math.pi / 180);

    final double a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1Rad) *
            math.cos(lat2Rad) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  // Calculate distance to another RideLocation
  double distanceToLocation(RideLocation other) {
    return distanceTo(other.latitude, other.longitude);
  }

  // Get distance in a human-readable format
  String getDistanceString(double lat, double lng) {
    final distance = distanceTo(lat, lng);
    if (distance >= 1000) {
      return '${(distance / 1000).toStringAsFixed(1)} km';
    } else {
      return '${distance.toInt()} m';
    }
  }

  // Check if location is within a certain radius
  bool isWithinRadius(double lat, double lng, double radiusInMeters) {
    return distanceTo(lat, lng) <= radiusInMeters;
  }

  @override
  String toString() => '$name ($address)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RideLocation &&
          runtimeType == other.runtimeType &&
          placeId == other.placeId;

  @override
  int get hashCode => placeId.hashCode;
}
