// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:permission_handler/permission_handler.dart';
// import '../../../services/google_places_service.dart';
// import 'dart:async';
//
// class RealTimeLocationController extends GetxController {
//   static RealTimeLocationController get instance => Get.find();
//
//   // Current location
//   final currentPosition = Rxn<Position>();
//   final currentAddress = ''.obs;
//   final isLocationEnabled = false.obs;
//   final isLoadingLocation = false.obs;
//   final locationError = ''.obs;
//
//   // Search functionality
//   final searchQuery = ''.obs;
//   final searchResults = <LocationSuggestion>[].obs;
//   final isSearching = false.obs;
//   final nearbyPlaces = <LocationSuggestion>[].obs;
//
//   // Selected locations
//   final selectedPickupLocation = Rxn<LocationDetails>();
//   final selectedDestinationLocation = Rxn<LocationDetails>();
//
//   // Stream subscriptions
//   StreamSubscription<Position>? _positionStreamSubscription;
//   Timer? _searchDebounceTimer;
//
//   @override
//   void onInit() {
//     super.onInit();
//     _initializeLocation();
//   }
//
//   @override
//   void onClose() {
//     _positionStreamSubscription?.cancel();
//     _searchDebounceTimer?.cancel();
//     super.onClose();
//   }
//
//   Future<void> _initializeLocation() async {
//     await checkLocationPermissions();
//     if (isLocationEnabled.value) {
//       await getCurrentLocation();
//       _startLocationTracking();
//     }
//   }
//
//   // Permission and service checks
//   Future<void> checkLocationPermissions() async {
//     try {
//       // Check if location services are enabled
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         locationError.value = 'Location services are disabled';
//         isLocationEnabled.value = false;
//         return;
//       }
//
//       // Check permissions
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           locationError.value = 'Location permissions are denied';
//           isLocationEnabled.value = false;
//           return;
//         }
//       }
//
//       if (permission == LocationPermission.deniedForever) {
//         locationError.value = 'Location permissions are permanently denied';
//         isLocationEnabled.value = false;
//         return;
//       }
//
//       isLocationEnabled.value = true;
//       locationError.value = '';
//     } catch (e) {
//       locationError.value = 'Error checking permissions: $e';
//       isLocationEnabled.value = false;
//     }
//   }
//
//   Future<void> requestLocationPermission() async {
//     try {
//       // Try to open location settings
//       bool opened = await Geolocator.openLocationSettings();
//       if (opened) {
//         // Wait a bit for user to enable location
//         await Future.delayed(const Duration(seconds: 2));
//         await checkLocationPermissions();
//       } else {
//         // Fallback to app settings
//         await openAppSettings();
//       }
//     } catch (e) {
//       Get.snackbar('Error', 'Failed to open location settings: $e');
//     }
//   }
//
//   // Get current location
//   Future<void> getCurrentLocation() async {
//     if (!isLocationEnabled.value) {
//       await checkLocationPermissions();
//       if (!isLocationEnabled.value) return;
//     }
//
//     try {
//       isLoadingLocation.value = true;
//       locationError.value = '';
//
//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//         timeLimit: const Duration(seconds: 10),
//       );
//
//       currentPosition.value = position;
//
//       // Get address for current location
//       currentAddress.value = await GooglePlacesService.getAddressFromCoordinates(
//           position.latitude,
//           position.longitude
//       );
//
//       // Load nearby places
//       await loadNearbyPlaces();
//
//       print('📍 Current location: ${position.latitude}, ${position.longitude}');
//
//     } catch (e) {
//       locationError.value = 'Failed to get location: $e';
//       print('❌ Location error: $e');
//
//       // Try to get last known position
//       try {
//         Position? lastKnown = await Geolocator.getLastKnownPosition();
//         if (lastKnown != null) {
//           currentPosition.value = lastKnown;
//           currentAddress.value = await GooglePlacesService.getAddressFromCoordinates(
//               lastKnown.latitude,
//               lastKnown.longitude
//           );
//         }
//       } catch (e) {
//         print('❌ Failed to get last known location: $e');
//       }
//     } finally {
//       isLoadingLocation.value = false;
//     }
//   }
//
//   void _startLocationTracking() {
//     try {
//       _positionStreamSubscription?.cancel();
//
//       _positionStreamSubscription = Geolocator.getPositionStream(
//         locationSettings: const LocationSettings(
//           accuracy: LocationAccuracy.high,
//           distanceFilter: 50, // Update every 50 meters
//           timeLimit: Duration(seconds: 15),
//         ),
//       ).listen(
//             (Position position) {
//           currentPosition.value = position;
//           print('🔄 Location updated: ${position.latitude}, ${position.longitude}');
//         },
//         onError: (error) {
//           locationError.value = 'Location tracking error: $error';
//           print('❌ Location stream error: $error');
//         },
//       );
//
//     } catch (e) {
//       locationError.value = 'Failed to start location tracking: $e';
//       print('❌ Error starting location tracking: $e');
//     }
//   }
//
//   // Search functionality with debouncing
//   void searchLocations(String query) {
//     searchQuery.value = query;
//
//     // Cancel previous timer
//     _searchDebounceTimer?.cancel();
//
//     if (query.trim().isEmpty) {
//       searchResults.clear();
//       isSearching.value = false;
//       return;
//     }
//
//     // Debounce search for 300ms
//     _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () {
//       _performSearch(query);
//     });
//   }
//
//   Future<void> _performSearch(String query) async {
//     try {
//       isSearching.value = true;
//
//       final results = await GooglePlacesService.searchLocations(
//         query: query,
//         currentLocation: currentPosition.value,
//         radius: 50000, // 50km radius
//       );
//
//       searchResults.value = results;
//
//     } catch (e) {
//       print('Search error: $e');
//       Get.snackbar('Search Error', 'Failed to search locations');
//     } finally {
//       isSearching.value = false;
//     }
//   }
//
//   // Load nearby places (universities, popular spots)
//   Future<void> loadNearbyPlaces() async {
//     if (currentPosition.value == null) return;
//
//     try {
//       final universities = await GooglePlacesService.getNearbyPlaces(
//         location: currentPosition.value!,
//         radius: 10000, // 10km radius
//         type: 'university',
//       );
//
//       final establishments = await GooglePlacesService.getNearbyPlaces(
//         location: currentPosition.value!,
//         radius: 5000, // 5km radius
//         type: 'establishment',
//       );
//
//       // Combine and limit results
//       final combined = [...universities, ...establishments];
//       nearbyPlaces.value = combined.take(10).toList();
//
//     } catch (e) {
//       print('Error loading nearby places: $e');
//     }
//   }
//
//   // Select location from search results
//   Future<void> selectLocation(LocationSuggestion suggestion, bool isPickup) async {
//     try {
//       final details = await GooglePlacesService.getPlaceDetails(suggestion.placeId);
//
//       if (details != null) {
//         if (isPickup) {
//           selectedPickupLocation.value = details;
//           Get.snackbar(
//             'Pickup Selected',
//             details.name,
//             snackPosition: SnackPosition.BOTTOM,
//             duration: const Duration(seconds: 2),
//           );
//         } else {
//           selectedDestinationLocation.value = details;
//           Get.snackbar(
//             'Destination Selected',
//             details.name,
//             snackPosition: SnackPosition.BOTTOM,
//             duration: const Duration(seconds: 2),
//           );
//         }
//
//         // Clear search
//         searchResults.clear();
//         searchQuery.value = '';
//       }
//     } catch (e) {
//       Get.snackbar('Error', 'Failed to select location: $e');
//     }
//   }
//
//   // Set current location as pickup
//   Future<void> setCurrentLocationAsPickup() async {
//     if (currentPosition.value == null) {
//       await getCurrentLocation();
//       if (currentPosition.value == null) {
//         Get.snackbar('Error', 'Could not get current location');
//         return;
//       }
//     }
//
//     final position = currentPosition.value!;
//     final address = currentAddress.value.isNotEmpty
//         ? currentAddress.value
//         : await GooglePlacesService.getAddressFromCoordinates(
//         position.latitude,
//         position.longitude
//     );
//
//     selectedPickupLocation.value = LocationDetails(
//       name: 'Current Location',
//       latitude: position.latitude,
//       longitude: position.longitude,
//       formattedAddress: address,
//       types: ['current_location'],
//     );
//
//     Get.snackbar(
//       'Current Location Set',
//       'Using your current location as pickup',
//       snackPosition: SnackPosition.BOTTOM,
//       duration: const Duration(seconds: 2),
//     );
//   }
//
//   // Clear selections
//   void clearSelections() {
//     selectedPickupLocation.value = null;
//     selectedDestinationLocation.value = null;
//     searchResults.clear();
//     searchQuery.value = '';
//   }
//
//   void clearSearch() {
//     searchResults.clear();
//     searchQuery.value = '';
//     isSearching.value = false;
//   }
//
//   // Getters
//   bool get hasCurrentLocation => currentPosition.value != null;
//   double get currentLatitude => currentPosition.value?.latitude ?? 31.5204;
//   double get currentLongitude => currentPosition.value?.longitude ?? 74.3587;
//   String get currentLocationString => hasCurrentLocation
//       ? '${currentLatitude.toStringAsFixed(4)}, ${currentLongitude.toStringAsFixed(4)}'
//       : 'Location not available';
// }
