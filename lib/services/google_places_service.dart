import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

class GooglePlacesService {
  static const String _apiKey = "AIzaSyCmAnZmoJqH-Pq3ZwjE3D359IFw0B4LjRk";
  static const String _baseUrl = "https://maps.googleapis.com/maps/api/place";

  // Search nearby locations
  static Future<List<LocationSuggestion>> searchLocations({
    required String query,
    Position? currentLocation,
    double radius = 50000, // 50km radius
  }) async {
    if (query.isEmpty) return [];

    try {
      String locationBias = "";
      if (currentLocation != null) {
        locationBias =
            "&location=${currentLocation.latitude},${currentLocation.longitude}&radius=$radius";
      }

      final String url =
          "$_baseUrl/autocomplete/json"
          "?input=${Uri.encodeComponent(query)}"
          "&key=$_apiKey"
          "&components=country:pk"
          "&types=establishment|geocode"
          "$locationBias";

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final predictions = data['predictions'] as List;
          return predictions
              .map((prediction) => LocationSuggestion.fromJson(prediction))
              .toList();
        }
      }
    } catch (e) {
      print('Error searching locations: $e');
    }

    return [];
  }

  // Get place details
  static Future<LocationDetails?> getPlaceDetails(String placeId) async {
    try {
      final String url =
          "$_baseUrl/details/json"
          "?place_id=$placeId"
          "&key=$_apiKey"
          "&fields=name,geometry,formatted_address,types,vicinity";

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          return LocationDetails.fromJson(data['result']);
        }
      }
    } catch (e) {
      print('Error getting place details: $e');
    }

    return null;
  }

  // Reverse geocoding
  static Future<String> getAddressFromCoordinates(
    double lat,
    double lng,
  ) async {
    try {
      final String url =
          "https://maps.googleapis.com/maps/api/geocode/json"
          "?latlng=$lat,$lng"
          "&key=$_apiKey";

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          return data['results'][0]['formatted_address'];
        }
      }
    } catch (e) {
      print('Error reverse geocoding: $e');
    }

    return 'Unknown location';
  }
}

class LocationSuggestion {
  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;
  final List<String> types;

  LocationSuggestion({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
    required this.types,
  });

  factory LocationSuggestion.fromJson(Map<String, dynamic> json) {
    final structuredFormatting = json['structured_formatting'] ?? {};

    return LocationSuggestion(
      placeId: json['place_id'] ?? '',
      description: json['description'] ?? '',
      mainText: structuredFormatting['main_text'] ?? '',
      secondaryText: structuredFormatting['secondary_text'] ?? '',
      types: List<String>.from(json['types'] ?? []),
    );
  }
}

class LocationDetails {
  final String name;
  final double latitude;
  final double longitude;
  final String formattedAddress;
  final List<String> types;

  LocationDetails({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.formattedAddress,
    required this.types,
  });

  factory LocationDetails.fromJson(Map<String, dynamic> json) {
    final geometry = json['geometry']?['location'] ?? {};

    return LocationDetails(
      name: json['name'] ?? '',
      latitude: (geometry['lat'] ?? 0.0).toDouble(),
      longitude: (geometry['lng'] ?? 0.0).toDouble(),
      formattedAddress: json['formatted_address'] ?? '',
      types: List<String>.from(json['types'] ?? []),
    );
  }
}
