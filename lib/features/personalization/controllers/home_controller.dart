import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../location/controller/location_controller.dart';

class HomeController extends GetxController {
  static HomeController get instance => Get.find();

  final selectedService = 'Carpool'.obs;
  final markers = <Marker>[].obs;
  final polylines = <Polyline>[].obs;
  final isMapLoading = true.obs;
  final isLoadingLocation = false.obs;
  final locationError = ''.obs;
  final mapType = MapType.normal.obs; // ✅ Added missing mapType
  final recentRides = <Map<String, dynamic>>[].obs;

  GoogleMapController? mapController;
  final LocationController locationController = LocationController.instance;

  // ✅ Added missing dark map style
  String? darkMapStyle = '''
  [
    {
      "elementType": "geometry",
      "stylers": [{"color": "#242f3e"}]
    },
    {
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#746855"}]
    },
    {
      "elementType": "labels.text.stroke",
      "stylers": [{"color": "#242f3e"}]
    },
    {
      "featureType": "administrative.locality",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#d59563"}]
    },
    {
      "featureType": "poi",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#d59563"}]
    },
    {
      "featureType": "poi.park",
      "elementType": "geometry",
      "stylers": [{"color": "#263c3f"}]
    },
    {
      "featureType": "poi.park",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#6b9a76"}]
    },
    {
      "featureType": "road",
      "elementType": "geometry",
      "stylers": [{"color": "#38414e"}]
    },
    {
      "featureType": "road",
      "elementType": "geometry.stroke",
      "stylers": [{"color": "#212a37"}]
    },
    {
      "featureType": "road",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#9ca5b3"}]
    },
    {
      "featureType": "road.highway",
      "elementType": "geometry",
      "stylers": [{"color": "#746855"}]
    },
    {
      "featureType": "road.highway",
      "elementType": "geometry.stroke",
      "stylers": [{"color": "#1f2835"}]
    },
    {
      "featureType": "road.highway",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#f3d19c"}]
    },
    {
      "featureType": "transit",
      "elementType": "geometry",
      "stylers": [{"color": "#2f3948"}]
    },
    {
      "featureType": "transit.station",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#d59563"}]
    },
    {
      "featureType": "water",
      "elementType": "geometry",
      "stylers": [{"color": "#17263c"}]
    },
    {
      "featureType": "water",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#515c6d"}]
    },
    {
      "featureType": "water",
      "elementType": "labels.text.stroke",
      "stylers": [{"color": "#17263c"}]
    }
  ]
  ''';

  @override
  void onInit() {
    super.onInit();
    _initializeMap();
    fetchRecentRides();
  }

  void _initializeMap() async {
    await Future.delayed(const Duration(seconds: 2));
    _loadNearbyPlaces();
    _addCurrentLocationMarker();
    isMapLoading.value = false;
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _updateCameraToCurrentLocation();
  }

  void _updateCameraToCurrentLocation() async {
    if (mapController != null && locationController.hasValidLocation) {
      await mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              locationController.currentLatitude,
              locationController.currentLongitude,
            ),
            zoom: 15,
          ),
        ),
      );
    }
  }

  void _loadNearbyPlaces() {
    // Add sample university and location markers
    markers.addAll([
      const Marker(
        markerId: MarkerId('lums'),
        position: LatLng(31.5204, 74.3587),
        infoWindow: InfoWindow(
          title: 'LUMS',
          snippet: 'Lahore University of Management Sciences',
        ),
      ),
      const Marker(
        markerId: MarkerId('ucp'),
        position: LatLng(31.4504, 74.3022),
        infoWindow: InfoWindow(
          title: 'UCP',
          snippet: 'University of Central Punjab',
        ),
      ),
      const Marker(
        markerId: MarkerId('pu'),
        position: LatLng(31.5497, 74.3436),
        infoWindow: InfoWindow(
          title: 'PU',
          snippet: 'University of the Punjab',
        ),
      ),
      const Marker(
        markerId: MarkerId('fast'),
        position: LatLng(31.4697, 74.2728),
        infoWindow: InfoWindow(
          title: 'FAST',
          snippet: 'National University of Computer Sciences',
        ),
      ),
      const Marker(
        markerId: MarkerId('emporium'),
        position: LatLng(31.4697, 74.2728),
        infoWindow: InfoWindow(
          title: 'Emporium Mall',
          snippet: 'Shopping Center',
        ),
      ),
    ]);
  }

  void _addCurrentLocationMarker() {
    // Listen to location changes and update marker
    ever(locationController.currentPosition, (Position? position) {
      if (position != null) {
        _updateCurrentLocationMarker(position);
      }
    });
  }

  void _updateCurrentLocationMarker(Position position) {
    // Remove old current location marker
    markers.removeWhere((marker) => marker.markerId.value == 'current_location');

    // Add new current location marker
    markers.add(
      Marker(
        markerId: const MarkerId('current_location'),
        position: LatLng(position.latitude, position.longitude),
        infoWindow: const InfoWindow(
          title: 'Your Location',
          snippet: 'Current position',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );
  }

  // ✅ Added missing moveToCurrentLocation method
  void moveToCurrentLocation() async {
    isLoadingLocation.value = true;
    locationError.value = '';

    try {
      await locationController.getCurrentLocation();

      if (locationController.hasValidLocation) {
        _updateCameraToCurrentLocation();
        locationError.value = '';
      } else {
        locationError.value = 'Unable to get current location';
      }
    } catch (e) {
      locationError.value = 'Failed to get location: $e';
      print('❌ Error getting location: $e');
    } finally {
      isLoadingLocation.value = false;
    }
  }

  // ✅ Added missing toggleMapType method
  void toggleMapType() {
    mapType.value = mapType.value == MapType.normal
        ? MapType.satellite
        : MapType.normal;
  }

  // ✅ Added missing onMapTapped method
  void onMapTapped(LatLng location) {
    // Add marker at tapped location
    final markerId = 'tapped_${DateTime.now().millisecondsSinceEpoch}';

    markers.add(
      Marker(
        markerId: MarkerId(markerId),
        position: location,
        infoWindow: InfoWindow(
          title: 'Selected Location',
          snippet: '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      ),
    );

    print('📍 Map tapped at: ${location.latitude}, ${location.longitude}');
  }

  void drawRoute(LatLng start, LatLng end) {
    // Simple straight line polyline (in real app, use Google Directions API)
    polylines.clear(); // Clear existing routes

    polylines.add(
      Polyline(
        polylineId: const PolylineId('route'),
        points: [start, end],
        color: const Color(0xFF08B783), // Your primary color
        width: 5,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      ),
    );

    // Add markers for start and end points
    markers.addAll([
      Marker(
        markerId: const MarkerId('route_start'),
        position: start,
        infoWindow: const InfoWindow(title: 'Start'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
      Marker(
        markerId: const MarkerId('route_end'),
        position: end,
        infoWindow: const InfoWindow(title: 'Destination'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    ]);
  }

  void clearRoute() {
    polylines.clear();
    markers.removeWhere((marker) =>
    marker.markerId.value == 'route_start' ||
        marker.markerId.value == 'route_end');
  }

  void findRide() {
    if (!locationController.hasValidLocation) {
      Get.snackbar(
        'Location Required',
        'Please enable location to find rides near you',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.snackbar(
      'Find Ride',
      'Searching for ${selectedService.value.toLowerCase()}s near you...',
      snackPosition: SnackPosition.BOTTOM,
    );
    // Navigate to find ride screens
  }

  void postRide() {
    if (!locationController.hasValidLocation) {
      Get.snackbar(
        'Location Required',
        'Please enable location to post a ride',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.snackbar(
      'Post Ride',
      'Creating a new ${selectedService.value.toLowerCase()} from your current location...',
      snackPosition: SnackPosition.BOTTOM,
    );
    // Navigate to post ride screens
  }

  void refreshLocation() {
    moveToCurrentLocation();
  }

  // ✅ Added missing requestLocationPermission method
  void requestLocationPermission() {
    locationController.requestLocationPermission();
  }

  void fetchRecentRides() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final userId = user.uid;
    // Listen for rides where the user is a driver or passenger
    FirebaseFirestore.instance
        .collection('rides')
        .where('status', isGreaterThanOrEqualTo: 'completed')
        .orderBy('departureTime', descending: true)
        .limit(10)
        .snapshots()
        .listen((snapshot) {
      final List<Map<String, dynamic>> rides = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final isDriver = data['userId'] == userId;
        final isPassenger = (data['passengers'] as List?)?.any((p) => p['userId'] == userId) ?? false;
        if (isDriver || isPassenger) {
          rides.add({
            'from': data['pickup']?['name'] ?? '',
            'to': data['destination']?['name'] ?? '',
            'date': (data['departureTime'] as Timestamp?)?.toDate().toLocal().toString().substring(0, 16) ?? '',
            'price': data['pricePerSeat'] != null ? '₹${data['pricePerSeat']}' : '',
            'id': doc.id,
            'isDriver': isDriver,
          });
        }
      }
      recentRides.value = rides;
    });
  }

  // Getters
  double get currentLatitude => locationController.currentLatitude;
  double get currentLongitude => locationController.currentLongitude;
  bool get hasValidLocation => locationController.hasValidLocation;

  @override
  void onClose() {
    mapController?.dispose();
    super.onClose();
  }
}
