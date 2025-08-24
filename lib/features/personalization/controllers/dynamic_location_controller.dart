import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';

class DynamicLocationController extends GetxController {
  static DynamicLocationController get instance => Get.find();

  final searchController = TextEditingController();
  final fromLocation = Rxn<PlaceDetails>();
  final toLocation = Rxn<PlaceDetails>();
  final searchResults = <LocationPrediction>[].obs; // ✅ Fixed: Made observable
  final isSearching = false.obs; // ✅ Fixed: Made observable

  // Mock data for testing
  final List<LocationPrediction> mockLocations = [
    LocationPrediction(
      placeId: '1',
      description: 'LUMS - Lahore University of Management Sciences',
      mainText: 'LUMS',
      secondaryText: 'DHA Phase 5, Lahore',
      types: ['university'],
    ),
    LocationPrediction(
      placeId: '2',
      description: 'University of Central Punjab',
      mainText: 'UCP',
      secondaryText: 'Johar Town, Lahore',
      types: ['university'],
    ),
    LocationPrediction(
      placeId: '3',
      description: 'Emporium Mall',
      mainText: 'Emporium Mall',
      secondaryText: 'Johar Town, Lahore',
      types: ['shopping_mall'],
    ),
    LocationPrediction(
      placeId: '4',
      description: 'Liberty Market',
      mainText: 'Liberty Market',
      secondaryText: 'Gulberg III, Lahore',
      types: ['market'],
    ),
    LocationPrediction(
      placeId: '5',
      description: 'Punjab University',
      mainText: 'PU',
      secondaryText: 'New Campus, Lahore',
      types: ['university'],
    ),
  ];

  Future<void> searchLocations(String query) async {
    if (query.trim().isEmpty) {
      searchResults.clear(); // ✅ Fixed: Clear observable list
      isSearching.value = false;
      return;
    }

    isSearching.value = true; // ✅ Fixed: Set observable

    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      // Filter mock locations
      final results = mockLocations
          .where((location) =>
      location.description.toLowerCase().contains(query.toLowerCase()) ||
          location.mainText.toLowerCase().contains(query.toLowerCase()) ||
          location.secondaryText.toLowerCase().contains(query.toLowerCase()))
          .toList();

      searchResults.value = results; // ✅ Fixed: Update observable list
    } catch (e) {
      print('Search error: $e');
      searchResults.clear();
    } finally {
      isSearching.value = false; // ✅ Fixed: Update observable
    }
  }

  // Update the selectLocation method to return a Map instead of RideLocation

  void selectLocation(LocationPrediction prediction, bool isPickup) {
    try {
      // Create a Map to return instead of RideLocation
      final locationData = {
        'name': prediction.mainText,
        'address': prediction.secondaryText,
        'latitude': _getMockLatitude(prediction.placeId),
        'longitude': _getMockLongitude(prediction.placeId),
        'placeId': prediction.placeId,
      };

      Get.snackbar(
        'Location Selected',
        '${prediction.mainText} selected as ${isPickup ? 'pickup' : 'destination'}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );

      // Return the Map instead of RideLocation
      Get.back(result: locationData);
    } catch (e) {
      Get.snackbar('Error', 'Failed to select location: $e');
    }
  }

// Helper methods for mock coordinates
  double _getMockLatitude(String placeId) {
    switch (placeId) {
      case '1': return 31.5204; // LUMS
      case '2': return 31.4504; // UCP
      case '3': return 31.4697; // Emporium Mall
      case '4': return 31.5497; // Liberty Market
      case '5': return 31.5497; // PU
      default: return 31.5204;
    }
  }

  double _getMockLongitude(String placeId) {
    switch (placeId) {
      case '1': return 74.3587; // LUMS
      case '2': return 74.3022; // UCP
      case '3': return 74.2728; // Emporium Mall
      case '4': return 74.3587; // Liberty Market
      case '5': return 74.3436; // PU
      default: return 74.3587;
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchAndSetCurrentLocation();
  }

  Future<void> fetchAndSetCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar('Location Denied', 'Location permissions are denied');
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        Get.snackbar('Location Denied', 'Location permissions are permanently denied');
        return;
      }
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      fromLocation.value = PlaceDetails(
        name: 'Current Location',
        latitude: position.latitude,
        longitude: position.longitude,
        formattedAddress: 'Your current location',
        types: ['current_location'],
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to get current location: $e');
    }
  }

  Future<void> setCurrentLocationAsPickup() async {
    await fetchAndSetCurrentLocation();
    if (fromLocation.value != null) {
      Get.snackbar(
        'Current Location',
        'Current location set as pickup point',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      Get.back();
    }
  }

  void swapLocations() {
    final temp = fromLocation.value;
    fromLocation.value = toLocation.value;
    toLocation.value = temp;

    Get.snackbar(
      'Locations Swapped',
      'Pickup and destination locations have been swapped',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );
  }

  void clearSelections() {
    fromLocation.value = null;
    toLocation.value = null;
    searchController.clear();
    searchResults.clear();
  }

  // Helper methods for mock coordinates


  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}

class LocationPrediction {
  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;
  final List<String> types;

  LocationPrediction({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
    required this.types,
  });
}

class PlaceDetails {
  final String name;
  final double latitude;
  final double longitude;
  final String formattedAddress;
  final List<String> types;

  PlaceDetails({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.formattedAddress,
    required this.types,
  });
}
