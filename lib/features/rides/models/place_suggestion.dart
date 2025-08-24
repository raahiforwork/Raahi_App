// models/location_models.dart
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlaceSuggestion {
  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;
  final List<String> types;
  final int? distanceMeters;

  PlaceSuggestion({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
    required this.types,
    this.distanceMeters,
  });

  factory PlaceSuggestion.fromJson(Map<String, dynamic> json) {
    return PlaceSuggestion(
      placeId: json['place_id'] ?? '',
      description: json['description'] ?? '',
      mainText: json['structured_formatting']?['main_text'] ?? '',
      secondaryText: json['structured_formatting']?['secondary_text'] ?? '',
      types: List<String>.from(json['types'] ?? []),
      distanceMeters: json['distance_meters'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'place_id': placeId,
      'description': description,
      'main_text': mainText,
      'secondary_text': secondaryText,
      'types': types,
      'distance_meters': distanceMeters,
    };
  }
}

class PlaceDetails {
  final String placeId;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final Map<String, String> addressComponents;
  final String? photoReference;

  PlaceDetails({
    required this.placeId,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.addressComponents,
    this.photoReference,
  });

  factory PlaceDetails.fromJson(Map<String, dynamic> json) {
    final geometry = json['geometry']?['location'];
    return PlaceDetails(
      placeId: json['place_id'] ?? '',
      name: json['name'] ?? '',
      address: json['formatted_address'] ?? '',
      latitude: geometry?['lat']?.toDouble() ?? 0.0,
      longitude: geometry?['lng']?.toDouble() ?? 0.0,
      addressComponents: _parseAddressComponents(json['address_components']),
      photoReference: _getPhotoReference(json['photos']),
    );
  }

  static Map<String, String> _parseAddressComponents(List? components) {
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

  static String? _getPhotoReference(List? photos) {
    if (photos != null && photos.isNotEmpty) {
      return photos[0]['photo_reference'];
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'place_id': placeId,
      'name': name,
      'formatted_address': address,
      'geometry': {
        'location': {
          'lat': latitude,
          'lng': longitude,
        }
      },
      'address_components': addressComponents,
      'photo_reference': photoReference,
    };
  }
}

class RouteInfo {
  final String distance;
  final String duration;
  final int distanceValue;
  final int durationValue;
  final List<LatLng> polylinePoints;
  final List<RouteStep> steps;

  RouteInfo({
    required this.distance,
    required this.duration,
    required this.distanceValue,
    required this.durationValue,
    required this.polylinePoints,
    required this.steps,
  });

  factory RouteInfo.fromJson(Map<String, dynamic> json) {
    final leg = json['legs'][0];
    return RouteInfo(
      distance: leg['distance']['text'],
      duration: leg['duration']['text'],
      distanceValue: leg['distance']['value'],
      durationValue: leg['duration']['value'],
      polylinePoints: _decodePolyline(json['overview_polyline']['points']),
      steps: (leg['steps'] as List).map((step) => RouteStep.fromJson(step)).toList(),
    );
  }

  static List<LatLng> _decodePolyline(String polyline) {
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
}

class RouteStep {
  final String instruction;
  final String distance;
  final String duration;
  final LatLng startLocation;
  final LatLng endLocation;

  RouteStep({
    required this.instruction,
    required this.distance,
    required this.duration,
    required this.startLocation,
    required this.endLocation,
  });

  factory RouteStep.fromJson(Map<String, dynamic> json) {
    return RouteStep(
      instruction: json['html_instructions'].replaceAll(RegExp(r'<[^>]*>'), ''),
      distance: json['distance']['text'],
      duration: json['duration']['text'],
      startLocation: LatLng(
        json['start_location']['lat'].toDouble(),
        json['start_location']['lng'].toDouble(),
      ),
      endLocation: LatLng(
        json['end_location']['lat'].toDouble(),
        json['end_location']['lng'].toDouble(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'html_instructions': instruction,
      'distance': {'text': distance},
      'duration': {'text': duration},
      'start_location': {
        'lat': startLocation.latitude,
        'lng': startLocation.longitude,
      },
      'end_location': {
        'lat': endLocation.latitude,
        'lng': endLocation.longitude,
      },
    };
  }
}
