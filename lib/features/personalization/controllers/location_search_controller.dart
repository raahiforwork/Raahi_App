import 'package:get/get.dart';
import 'dart:async';

class LocationSearchController extends GetxController {
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

      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Mock search results
      final mockResults = _getMockResults(searchQuery);
      searchResults.value = mockResults;

    } catch (e) {
      print('Search error: $e');
    } finally {
      isSearching.value = false;
    }
  }

  List<Map<String, dynamic>> _getMockResults(String query) {
    final allLocations = [
      {
        'name': 'LUMS University',
        'address': 'DHA Phase 5, Lahore',
        'latitude': 31.5204,
        'longitude': 74.3587,
        'placeId': 'lums_university',
        'type': 'university',
        'additionalInfo': {},
      },
      {
        'name': 'University of Central Punjab',
        'address': 'Johar Town, Lahore',
        'latitude': 31.4504,
        'longitude': 74.3022,
        'placeId': 'ucp_university',
        'type': 'university',
        'additionalInfo': {},
      },
      {
        'name': 'Emporium Mall',
        'address': 'Johar Town, Lahore',
        'latitude': 31.4697,
        'longitude': 74.2728,
        'placeId': 'emporium_mall',
        'type': 'mall',
        'additionalInfo': {},
      },
      {
        'name': 'Liberty Market',
        'address': 'Gulberg III, Lahore',
        'latitude': 31.5497,
        'longitude': 74.3436,
        'placeId': 'liberty_market',
        'type': 'market',
        'additionalInfo': {},
      },
      {
        'name': 'Fortress Stadium',
        'address': 'Cantt, Lahore',
        'latitude': 31.5656,
        'longitude': 74.3210,
        'placeId': 'fortress_stadium',
        'type': 'stadium',
        'additionalInfo': {},
      },
    ];

    // ✅ Fixed: Cast to String before calling toLowerCase()
    return allLocations
        .where((location) =>
    (location['name'] as String).toLowerCase().contains(query.toLowerCase()) ||
        (location['address'] as String).toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }
}
