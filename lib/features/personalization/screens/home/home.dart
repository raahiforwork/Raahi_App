import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:lottie/lottie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../controllers/dynamic_location_controller.dart';
import '../../controllers/ride_matching_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../../../common/widgets/home/home_header.dart';
import '../../../../common/widgets/home/action_button.dart';
import '../../../../common/widgets/home/active_ride_card.dart';
import '../../../../data/repositories/ride/ride_repository.dart';
import '../../../../features/rides/screens/chat_screen.dart';

class RaahiHomeScreen extends StatefulWidget {
  const RaahiHomeScreen({super.key});

  @override
  State<RaahiHomeScreen> createState() => _RaahiHomeScreenState();
}

class _RaahiHomeScreenState extends State<RaahiHomeScreen> {
  final _locationController = Get.find<DynamicLocationController>();
  final _rideController = RideMatchingController.instance;
  final _authController = AuthController.instance;
  final _rideRepository = RideRepository.instance;

  gmaps.GoogleMapController? _mapController;
  Timer? _nearbyTimer;
  RxList<Map<String, dynamic>> _activeRides = <Map<String, dynamic>>[].obs;
  RxBool _isLoadingRides = false.obs;
  RxString _ridesError = ''.obs;
  StreamSubscription<List<Map<String, dynamic>>>? _ridesSubscription;
  final ScrollController _scrollController = ScrollController();

  // Google Maps dark style applied when theme is dark
  static const String _darkMapStyle =
      '[{"elementType":"geometry","stylers":[{"color":"#1d1f23"}]},{"elementType":"labels.text.fill","stylers":[{"color":"#e0e0e0"}]},{"elementType":"labels.text.stroke","stylers":[{"color":"#1d1f23"}]},{"featureType":"poi","elementType":"geometry","stylers":[{"color":"#2a2d33"}]},{"featureType":"road","elementType":"geometry","stylers":[{"color":"#2a2d33"}]},{"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"#1d1f23"}]},{"featureType":"transit","elementType":"geometry","stylers":[{"color":"#2a2d33"}]},{"featureType":"water","elementType":"geometry","stylers":[{"color":"#0e1114"}]}]';

  @override
  void initState() {
    super.initState();
    _loadActiveRides();
  }

  @override
  void dispose() {
    _nearbyTimer?.cancel();
    _ridesSubscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadActiveRides() async {
    try {
      _isLoadingRides.value = true;
      _ridesError.value = '';

      // Get current user location
      final userLoc = _locationController.fromLocation.value;
      if (userLoc == null) {
        _ridesError.value = 'Location not available';
        _isLoadingRides.value = false;
        return;
      }

      print(
        '📍 Loading rides from location: ${userLoc.latitude}, ${userLoc.longitude}',
      );

      // Subscribe to active rides within 40km radius
      _ridesSubscription?.cancel();
      _ridesSubscription = _rideRepository
          .getActiveRidesWithinRadius(
            userLat: userLoc.latitude,
            userLng: userLoc.longitude,
            radiusKm: 40.0, // Increased to 40km
          )
          .listen(
            (rides) {
              print('📱 Received ${rides.length} rides in UI');
              _activeRides.value = rides;
              _isLoadingRides.value = false;
              if (rides.isEmpty) {
                _ridesError.value = 'No active rides found within 40km';
              } else {
                _ridesError.value = '';
              }
            },
            onError: (error) {
              print('❌ Error loading rides: $error');
              _ridesError.value = 'Failed to load rides';
              _isLoadingRides.value = false;
            },
          );
    } catch (e) {
      print('❌ Error in _loadActiveRides: $e');
      _ridesError.value = 'Error loading rides';
      _isLoadingRides.value = false;
    }
  }

  void _handleBookNow(Map<String, dynamic> ride) async {
    try {
      final currentUser = _authController.currentUser.value;
      if (currentUser == null) {
        Get.snackbar('Error', 'Please login to book rides');
        return;
      }

      // Show loading dialog
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: Colors.white)),
        barrierDismissible: false,
      );

      // Create ride request
      final requestId = await _rideRepository.createRideRequest(
        rideId: ride['id'],
        passengerId: currentUser.uid.value,
        passengerName:
            '${currentUser.firstName.value} ${currentUser.lastName.value}',
        passengerPhone: currentUser.phoneNumber.value,
        passengerEmail: currentUser.email.value,
        passengerProfileImage: currentUser.profileImageUrl.value,
        message: 'Hi! I would like to book a seat for your ride.',
      );

      // Close loading dialog
      Get.back();

      // Show success message
      Get.snackbar(
        'Booking Request Sent',
        'Your request has been sent to ${ride['createdByName'] ?? 'Ride Creator'}. You will be notified when they respond.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      // Listen for response
      _listenForBookingResponse(requestId, ride);
    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar(
        'Error',
        'Failed to send booking request: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _listenForBookingResponse(String requestId, Map<String, dynamic> ride) {
    // Listen for changes to the ride request
    FirebaseFirestore.instance
        .collection('ride_requests')
        .doc(requestId)
        .snapshots()
        .listen((snapshot) {
          if (snapshot.exists) {
            final data = snapshot.data()!;
            final status = data['status'] as String?;

            if (status == 'accepted') {
              // Navigate to chat screen
              Get.to(
                () => ChatScreen(
                  otherUserId: ride['createdBy'] ?? '',
                  otherUserName: ride['createdByName'] ?? 'Ride Creator',
                  rideInfo: {
                    'rideId': ride['id'],
                    'pickup': ride['from'] ?? '',
                    'destination': ride['to'] ?? '',
                    'departureTime': ride['time'] ?? '',
                    'date': ride['date'] ?? '',
                  },
                ),
              );
            } else if (status == 'rejected') {
              final reason =
                  data['rejectionReason'] as String? ?? 'No reason provided';
              Get.snackbar(
                'Request Rejected',
                'Your booking request was rejected: $reason',
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            }
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Header
            SliverToBoxAdapter(child: RHomeHeader(onNotifications: () {})),

            // Map Section
            SliverToBoxAdapter(
              child: Container(
                height: 200,
                margin: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: const Color(0xFF1A1A1A),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      _buildMap(),
                      // Map overlay icons
                      Positioned(
                        top: 16,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.shopping_cart,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Action Buttons
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    RActionButton(
                      title: 'Find Rides',
                      subtitle: '',
                      icon: Icons.location_on,
                      backgroundColor: const Color(
                        0xFF4CAF50,
                      ), // Green color for Find Rides
                      onTap: _rideController.findRides,
                    ),
                    RActionButton(
                      title: 'Create a ride',
                      subtitle: '',
                      icon: Icons.add,
                      backgroundColor: const Color(0xFF8B5CF6),
                      onTap: _rideController.offerRide,
                      trailingWidget: const Icon(
                        Icons.directions_car,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Active Rides Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Active Rides',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Obx(
                      () => Text(
                        '${_activeRides.length} rides',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Rides List
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: Obx(() {
                if (_isLoadingRides.value) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
                  );
                }

                if (_ridesError.value.isNotEmpty) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.white70,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _ridesError.value,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadActiveRides,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                if (_activeRides.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Lottie.asset(
                              'assets/images/animations/110052-paper-plane.json',
                              width: 120,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No active rides found',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final ride = _activeRides[index];
                    return RActiveRideCard(
                      driverName:
                          ride['createdByName']?.toString().isNotEmpty == true
                              ? ride['createdByName'].toString()
                              : 'Unknown User',
                      pickup:
                          ride['from']?.toString().isNotEmpty == true
                              ? ride['from'].toString()
                              : 'Unknown Location',
                      destination:
                          ride['to']?.toString().isNotEmpty == true
                              ? ride['to'].toString()
                              : 'Unknown Destination',
                      time: _formatTime(ride['time'] ?? ''),
                      avatarImage: 'assets/images/content/user.png',
                      onBookNow: () => _handleBookNow(ride),
                    );
                  }, childCount: _activeRides.length),
                );
              }),
            ),

            // Bottom padding for better scrolling
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  Widget _buildMap() {
    return Obx(() {
      final markers = <gmaps.Marker>{};
      final userLoc = _locationController.fromLocation.value;
      if (userLoc != null) {
        markers.add(
          gmaps.Marker(
            markerId: const gmaps.MarkerId('current_location'),
            position: gmaps.LatLng(userLoc.latitude, userLoc.longitude),
            icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(
              gmaps.BitmapDescriptor.hueGreen,
            ),
            infoWindow: const gmaps.InfoWindow(title: 'You'),
          ),
        );
      }

      // Add ride markers (for now, we'll use a default location since we don't have lat/lng)
      for (final ride in _activeRides) {
        // Use a default location for now - in a real app, you'd store lat/lng in the ride document
        final defaultLat = 31.5204 + (Random().nextDouble() - 0.5) * 0.01;
        final defaultLng = 74.3587 + (Random().nextDouble() - 0.5) * 0.01;

        markers.add(
          gmaps.Marker(
            markerId: gmaps.MarkerId('ride_${ride['id']}'),
            position: gmaps.LatLng(defaultLat, defaultLng),
            icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(
              gmaps.BitmapDescriptor.hueBlue,
            ),
            infoWindow: gmaps.InfoWindow(
              title: ride['createdByName']?.toString() ?? 'User',
              snippet: '${ride['from']} → ${ride['to']}',
            ),
          ),
        );
      }

      return gmaps.GoogleMap(
        initialCameraPosition: gmaps.CameraPosition(
          target:
              userLoc != null
                  ? gmaps.LatLng(userLoc.latitude, userLoc.longitude)
                  : const gmaps.LatLng(31.5204, 74.3587),
          zoom: 15,
        ),
        markers: markers,
        myLocationEnabled: true,
        onMapCreated: (c) {
          _mapController = c;
          _mapController!.setMapStyle(_darkMapStyle);
          if (userLoc != null) {
            _mapController!.animateCamera(
              gmaps.CameraUpdate.newCameraPosition(
                gmaps.CameraPosition(
                  target: gmaps.LatLng(userLoc.latitude, userLoc.longitude),
                  zoom: 15,
                ),
              ),
            );
          }
        },
        zoomControlsEnabled: false,
        mapType: gmaps.MapType.normal,
      );
    });
  }

  String _formatTime(String time) {
    if (time.isEmpty) return 'Unknown Time';
    return time;
  }
}
