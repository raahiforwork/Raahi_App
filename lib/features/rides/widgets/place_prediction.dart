class PlacePrediction {
  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;
  final List<String> types;
  final int? distanceMeters;
  final String? reference;

  PlacePrediction({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
    required this.types,
    this.distanceMeters,
    this.reference,
  });

  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    final structuredFormatting = json['structured_formatting'] ?? {};

    return PlacePrediction(
      placeId: json['place_id'] ?? '',
      description: json['description'] ?? '',
      mainText: structuredFormatting['main_text'] ?? '',
      secondaryText: structuredFormatting['secondary_text'] ?? '',
      types: List<String>.from(json['types'] ?? []),
      distanceMeters: json['distance_meters'],
      reference: json['reference'],
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
      'reference': reference,
    };
  }

  @override
  String toString() {
    return 'PlacePrediction(placeId: $placeId, description: $description, types: $types)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlacePrediction && other.placeId == placeId;
  }

  @override
  int get hashCode => placeId.hashCode;
}
