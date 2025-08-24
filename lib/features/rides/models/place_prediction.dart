// lib/services/google_places_service.dart (or wherever the model lives)
/// Model representing a single place suggestion.
class PlaceSuggestion {
  final String placeId;
  final String mainText;
  final String secondaryText;

  PlaceSuggestion({
    required this.placeId,
    required this.mainText,
    required this.secondaryText,
  });
}

/// Signature all controllers must expose to supply suggestions.
typedef SuggestionCallback = Future<List<PlaceSuggestion>> Function(String query);

/// Signature the parent widget must implement to handle a tapped suggestion.
typedef SuggestionSelectCallback = void Function(PlaceSuggestion suggestion);
