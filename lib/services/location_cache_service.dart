import 'package:get_storage/get_storage.dart';
import '../features/rides/models/place_suggestion.dart';

class LocationCacheService {
  static final GetStorage _storage = GetStorage();
  static const String _searchCacheKey = 'location_search_cache';
  static const String _recentLocationsKey = 'recent_locations';
  static const int _maxRecentLocations = 10;
  static const Duration _cacheExpiry = Duration(days: 7);

  // Cache search results
  static void cacheSearchResults(String query, List<PlaceSuggestion> results) {
    final cache = _storage.read(_searchCacheKey) ?? {};
    cache[query] = {
      'timestamp': DateTime.now().toIso8601String(),
      'results': results.map((r) => r.toJson()).toList(),
    };
    _storage.write(_searchCacheKey, cache);
  }

  // Get cached search results
  static List<PlaceSuggestion>? getCachedSearchResults(String query) {
    final cache = _storage.read(_searchCacheKey) ?? {};
    if (!cache.containsKey(query)) return null;

    final cacheEntry = cache[query];
    final timestamp = DateTime.parse(cacheEntry['timestamp']);
    if (DateTime.now().difference(timestamp) > _cacheExpiry) {
      // Cache expired, remove it
      cache.remove(query);
      _storage.write(_searchCacheKey, cache);
      return null;
    }

    return (cacheEntry['results'] as List)
        .map((json) => PlaceSuggestion.fromJson(json))
        .toList();
  }

  // Add a location to recent locations
  static void addRecentLocation(Map<String, dynamic> location) {
    List<Map<String, dynamic>> recentLocations =
        (_storage.read(_recentLocationsKey) ?? []).cast<Map<String, dynamic>>();

    // Remove if already exists
    recentLocations.removeWhere((loc) => loc['placeId'] == location['placeId']);

    // Add to beginning
    recentLocations.insert(0, location);

    // Limit size
    if (recentLocations.length > _maxRecentLocations) {
      recentLocations = recentLocations.sublist(0, _maxRecentLocations);
    }

    _storage.write(_recentLocationsKey, recentLocations);
  }

  // Get recent locations
  static List<Map<String, dynamic>> getRecentLocations() {
    return (_storage.read(_recentLocationsKey) ?? [])
        .cast<Map<String, dynamic>>();
  }

  // Clear expired cache entries
  static void clearExpiredCache() {
    final cache = _storage.read(_searchCacheKey) ?? {};
    final now = DateTime.now();

    cache.removeWhere((_, value) {
      final timestamp = DateTime.parse(value['timestamp']);
      return now.difference(timestamp) > _cacheExpiry;
    });

    _storage.write(_searchCacheKey, cache);
  }

  // Clear all cache
  static void clearAllCache() {
    _storage.remove(_searchCacheKey);
    _storage.remove(_recentLocationsKey);
  }
}
