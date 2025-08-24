import 'package:get/get.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geocoding/geocoding.dart';

class LocationSearchController extends GetxController {
  static const String _googleApiKey = 'AIzaSyCcNfXHfRM1DqF-Z3w82bwfCcux9EL_L7s';
  final query = ''.obs;
  final searchResults = <Map<String, dynamic>>[].obs;
  final isSearching = false.obs;

  Timer? _debounceTimer;

  void searchLocations(String searchQuery) {
    query.value = searchQuery;
    _debounceTimer?.cancel();
    if (searchQuery.trim().isEmpty) {
      searchResults.clear();
      isSearching.value = false;
      return;
    }
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(searchQuery);
    });
  }

  Future<void> _performSearch(String searchQuery) async {
    try {
      isSearching.value = true;
      // Use Google Places API for real search
      final url =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?'
          'input=${Uri.encodeComponent(searchQuery)}&'
          'key=$_googleApiKey&'
          'components=country:in&'
          'types=geocode|establishment&'
          'language=en';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final predictions = data['predictions'] as List;
          searchResults.value =
              predictions
                  .map(
                    (prediction) => {
                      'placeId': prediction['place_id'],
                      'name':
                          prediction['structured_formatting']?['main_text'] ??
                          '',
                      'address': prediction['description'] ?? '',
                    },
                  )
                  .toList();
        } else {
          searchResults.clear();
        }
      } else {
        searchResults.clear();
      }
    } catch (e) {
      searchResults.clear();
    } finally {
      isSearching.value = false;
    }
  }

  // Fetch place details (including state)
  Future<Map<String, dynamic>?> getPlaceDetails(
    String placeId, {
    String? fallbackName,
    String? fallbackAddress,
  }) async {
    try {
      final url =
          'https://maps.googleapis.com/maps/api/place/details/json?'
          'place_id=$placeId&'
          'fields=name,geometry,formatted_address,address_components&'
          'key=$_googleApiKey';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final result = data['result'];
          final geometry = result['geometry']['location'];
          String? state;
          if (result['address_components'] != null) {
            for (var comp in result['address_components']) {
              if ((comp['types'] as List).contains(
                'administrative_area_level_1',
              )) {
                state = comp['short_name'];
                break;
              }
            }
          }
          return {
            'name': result['name'] ?? '',
            'address': result['formatted_address'] ?? '',
            'latitude': geometry['lat']?.toDouble() ?? 0.0,
            'longitude': geometry['lng']?.toDouble() ?? 0.0,
            'placeId': placeId,
            'type': 'other',
            'additionalInfo': {'state': state ?? ''},
          };
        } else {
          // Fall through to fallback below
          // print('Place details error: ${data['status']} - ${data['error_message']}');
        }
      }
    } catch (e) {}

    // Fallback: try to geocode the provided address when Places Details fails
    try {
      if (fallbackAddress != null && fallbackAddress.trim().isNotEmpty) {
        final locations = await locationFromAddress(fallbackAddress);
        if (locations.isNotEmpty) {
          final loc = locations.first;
          return {
            'name': fallbackName ?? fallbackAddress,
            'address': fallbackAddress,
            'latitude': loc.latitude,
            'longitude': loc.longitude,
            'placeId': placeId,
            'type': 'other',
            'additionalInfo': {},
          };
        }
      }
    } catch (e) {
      // ignore and return null
    }
    return null;
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }
}
