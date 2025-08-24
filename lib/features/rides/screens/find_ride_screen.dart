import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../controllers/find_ride_controller.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../common/widgets/appbar/appbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../models/ride_location.dart';
import '../screens/location_search_screen.dart';
import '../screens/chat_screen.dart';
import 'package:intl/intl.dart';

class FindRideScreen extends StatelessWidget {
  const FindRideScreen({Key? key}) : super(key: key);

  // Dark map style for Google Maps in dark theme
  static const String _darkMapStyle =
      '[{"elementType":"geometry","stylers":[{"color":"#1d1f23"}]},{"elementType":"labels.text.fill","stylers":[{"color":"#e0e0e0"}]},{"elementType":"labels.text.stroke","stylers":[{"color":"#1d1f23"}]},{"featureType":"poi","elementType":"geometry","stylers":[{"color":"#2a2d33"}]},{"featureType":"road","elementType":"geometry","stylers":[{"color":"#2a2d33"}]},{"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"#1d1f23"}]},{"featureType":"transit","elementType":"geometry","stylers":[{"color":"#2a2d33"}]},{"featureType":"water","elementType":"geometry","stylers":[{"color":"#0e1114"}]}]';
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FindRideController());

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: RAppBar(
        title: Text(
          'Find a Ride',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        showBackArrow: true,
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Add filter functionality
              Get.snackbar('Coming Soon', 'Filters will be available soon!');
            },
            icon: const Icon(Iconsax.filter),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (controller.fromLocation.value != null &&
              controller.toLocation.value != null) {
            await controller.refreshRides();
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  kToolbarHeight,
            ),
            child: Column(
              children: [
                // Fixed height map container
                Container(
                  height: 200,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Obx(() {
                      final userLoc = controller.fromLocation.value;
                      final destLoc = controller.toLocation.value;
                      final route = controller.routeInfo.value;

                      if (userLoc == null) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      // Custom marker icons
                      final pickupIcon = gmaps
                          .BitmapDescriptor.defaultMarkerWithHue(
                        gmaps.BitmapDescriptor.hueGreen,
                      );
                      final destIcon = gmaps
                          .BitmapDescriptor.defaultMarkerWithHue(
                        gmaps.BitmapDescriptor.hueRed,
                      );

                      // Create markers set
                      final markers = <gmaps.Marker>{
                        gmaps.Marker(
                          markerId: const gmaps.MarkerId('pickup'),
                          position: gmaps.LatLng(
                            userLoc.latitude,
                            userLoc.longitude,
                          ),
                          icon: pickupIcon,
                          infoWindow: gmaps.InfoWindow(
                            title: userLoc.name,
                            snippet: userLoc.address,
                          ),
                        ),
                      };

                      // Add destination marker if selected
                      if (destLoc != null) {
                        markers.add(
                          gmaps.Marker(
                            markerId: const gmaps.MarkerId('destination'),
                            position: gmaps.LatLng(
                              destLoc.latitude,
                              destLoc.longitude,
                            ),
                            icon: destIcon,
                            infoWindow: gmaps.InfoWindow(
                              title: destLoc.name,
                              snippet: destLoc.address,
                            ),
                          ),
                        );
                      }

                      // Create polylines if route exists
                      Set<gmaps.Polyline> polylines = {};
                      gmaps.LatLngBounds? bounds;

                      if (route != null && destLoc != null) {
                        // Decode polyline points
                        final List<gmaps.LatLng> points = _decodePolyline(
                          route.polyline,
                        );

                        // Create Google Directions polyline (API path)
                        polylines.add(
                          gmaps.Polyline(
                            polylineId: const gmaps.PolylineId('route'),
                            points: points,
                            color: RColors.primary,
                            width: 4,
                            startCap: gmaps.Cap.roundCap,
                            endCap: gmaps.Cap.roundCap,
                          ),
                        );

                        // Create Dijkstra shortest path polyline (computed)
                        final dijkstraPts =
                            controller.dijkstraPath
                                .map(
                                  (p) => gmaps.LatLng(p.latitude, p.longitude),
                                )
                                .toList();
                        if (dijkstraPts.length >= 2) {
                          polylines.add(
                            gmaps.Polyline(
                              polylineId: const gmaps.PolylineId('dijkstra'),
                              points: dijkstraPts,
                              color: Colors.indigo,
                              width: 4,
                              startCap: gmaps.Cap.roundCap,
                              endCap: gmaps.Cap.roundCap,
                            ),
                          );
                        }

                        // Set bounds for camera
                        bounds = gmaps.LatLngBounds(
                          southwest: gmaps.LatLng(
                            route.bounds.southwest.latitude,
                            route.bounds.southwest.longitude,
                          ),
                          northeast: gmaps.LatLng(
                            route.bounds.northeast.latitude,
                            route.bounds.northeast.longitude,
                          ),
                        );
                      }

                      return Stack(
                        children: [
                          gmaps.GoogleMap(
                            initialCameraPosition: gmaps.CameraPosition(
                              target: gmaps.LatLng(
                                userLoc.latitude,
                                userLoc.longitude,
                              ),
                              zoom: 14,
                            ),
                            markers: markers,
                            polylines: polylines,
                            myLocationEnabled: true,
                            myLocationButtonEnabled: false,
                            zoomControlsEnabled: false,
                            mapToolbarEnabled: false,
                            compassEnabled: false,
                            onMapCreated: (mapController) {
                              final isDark =
                                  Theme.of(context).brightness ==
                                  Brightness.dark;
                              mapController.setMapStyle(
                                isDark ? _darkMapStyle : null,
                              );
                              if (bounds != null) {
                                mapController.animateCamera(
                                  gmaps.CameraUpdate.newLatLngBounds(
                                    bounds,
                                    50, // padding
                                  ),
                                );
                              }
                            },
                            onCameraMove: (position) {
                              // Update marker position while moving
                              if (destLoc == null) {
                                // Only allow moving pickup location if destination isn't set
                                markers.clear();
                                markers.add(
                                  gmaps.Marker(
                                    markerId: const gmaps.MarkerId('pickup'),
                                    position: position.target,
                                    icon: pickupIcon,
                                    draggable: true,
                                  ),
                                );
                              }
                            },
                            onCameraIdle: () async {
                              // Update location details when camera stops moving
                              if (destLoc == null) {
                                try {
                                  final newPosition = markers.first.position;
                                  final placemarks =
                                      await placemarkFromCoordinates(
                                        newPosition.latitude,
                                        newPosition.longitude,
                                      );

                                  if (placemarks.isNotEmpty) {
                                    final place = placemarks.first;
                                    final address = [
                                          place.name,
                                          place.subLocality,
                                          place.locality,
                                          place.administrativeArea,
                                          place.country,
                                        ]
                                        .where((e) => e != null && e.isNotEmpty)
                                        .join(', ');

                                    // Update the fromLocation with new coordinates and address
                                    controller.setFromLocation(
                                      RideLocation(
                                        name: place.name ?? 'Selected Location',
                                        address: address,
                                        latitude: newPosition.latitude,
                                        longitude: newPosition.longitude,
                                        placeId: '',
                                        type: 'pickup',
                                        additionalInfo: {
                                          'state': place.administrativeArea,
                                          'country': place.country,
                                        },
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  print('Error updating location: $e');
                                }
                              }
                            },
                          ),
                          // Center indicator (only show when moving map for pickup)
                          if (destLoc == null)
                            const Positioned(
                              top: 0,
                              bottom: 25, // Offset to account for marker height
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Icon(
                                  Icons.location_on,
                                  color: RColors.primary,
                                  size: 36,
                                ),
                              ),
                            ),
                          // Add via markers along computed Dijkstra path
                          if (controller.dijkstraPath.isNotEmpty)
                            Builder(
                              builder: (_) {
                                final pts = controller.dijkstraPath;
                                if (pts.length >= 4) {
                                  final idxs = [
                                    (pts.length * 0.25).floor(),
                                    (pts.length * 0.50).floor(),
                                    (pts.length * 0.75).floor(),
                                  ];
                                  for (int i = 0; i < idxs.length; i++) {
                                    final p = pts[idxs[i]];
                                    markers.add(
                                      gmaps.Marker(
                                        markerId: gmaps.MarkerId('via_$i'),
                                        position: gmaps.LatLng(
                                          p.latitude,
                                          p.longitude,
                                        ),
                                        icon: gmaps
                                            .BitmapDescriptor.defaultMarkerWithHue(
                                          gmaps.BitmapDescriptor.hueAzure,
                                        ),
                                        infoWindow: const gmaps.InfoWindow(
                                          title: 'Via',
                                        ),
                                      ),
                                    );
                                  }
                                }
                                return const SizedBox.shrink();
                              },
                            ),

                          // Route info overlay (includes Dijkstra distance)
                          if (route != null && destLoc != null)
                            Positioned(
                              top: 16,
                              left: 16,
                              right: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.directions_car,
                                          color: RColors.primary,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${route.distance} · ${route.duration}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (controller
                                            .dijkstraDistanceMeters
                                            .value >
                                        0)
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.alt_route,
                                            color: Colors.indigo,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Shortest: ${(controller.dijkstraDistanceMeters.value / 1000).toStringAsFixed(2)} km',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                              color: Colors.indigo,
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      );
                    }),
                  ),
                ),

                // Route Info Card
                Obx(() {
                  if (controller.routeInfo.value != null) {
                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: RColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: RColors.primary.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Iconsax.routing, color: RColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            '${controller.routeInfo.value!.distance} · ${controller.routeInfo.value!.duration}',
                            style: TextStyle(
                              color: RColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),

                // Search Form
                _buildSearchForm(controller, context),

                // Available Rides Section
                Obx(() {
                  if (controller.fromLocation.value != null &&
                      controller.toLocation.value != null) {
                    if (!controller.isLoadingRides.value &&
                        controller.rides.isEmpty) {
                      controller.fetchAvailableRides();
                    }

                    return Column(
                      children: [
                        // Section Header
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Available Rides',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Row(
                                children: [
                                  // Refresh button
                                  IconButton(
                                    onPressed: controller.refreshRides,
                                    icon: Icon(
                                      Icons.refresh,
                                      color: RColors.primary,
                                      size: 20,
                                    ),
                                    tooltip: 'Refresh rides',
                                  ),
                                  // Status indicator
                                  Obx(
                                    () => Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: RColors.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        controller.isLoadingRides.value
                                            ? 'Searching...'
                                            : '${controller.rides.length} found',
                                        style: TextStyle(
                                          color: RColors.primary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Rides List
                        controller.isLoadingRides.value
                            ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32.0),
                                child: Column(
                                  children: [
                                    CircularProgressIndicator(
                                      color: RColors.primary,
                                    ),
                                    SizedBox(height: 16),
                                    _FindingText(),
                                  ],
                                ),
                              ),
                            )
                            : controller.ridesError.value.isNotEmpty
                            ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      size: 48,
                                      color: Colors.orange[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      controller.ridesError.value,
                                      textAlign: TextAlign.center,
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                    ),
                                    const SizedBox(height: 24),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        TextButton.icon(
                                          onPressed:
                                              () => controller.refreshRides(),
                                          icon: Icon(
                                            Icons.refresh,
                                            color: RColors.primary,
                                          ),
                                          label: Text(
                                            'Refresh',
                                            style: TextStyle(
                                              color: RColors.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        TextButton.icon(
                                          onPressed: () {
                                            controller.ridesError.value = '';
                                            _showSearchSuggestions(context);
                                          },
                                          icon: Icon(
                                            Icons.lightbulb_outline,
                                            color: RColors.secondary,
                                          ),
                                          label: Text(
                                            'Get Tips',
                                            style: TextStyle(
                                              color: RColors.secondary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            )
                            : controller.rides.isEmpty
                            ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.no_transfer,
                                      size: 48,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.color
                                          ?.withOpacity(0.4),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No rides available for this route',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.color
                                            ?.withOpacity(0.7),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Pull to refresh or try different locations',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.color
                                            ?.withOpacity(0.5),
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    TextButton.icon(
                                      onPressed:
                                          () => _showSearchSuggestions(context),
                                      icon: Icon(
                                        Icons.lightbulb_outline,
                                        color: RColors.secondary,
                                        size: 16,
                                      ),
                                      label: Text(
                                        'Get Search Tips',
                                        style: TextStyle(
                                          color: RColors.secondary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: controller.rides.length,
                              itemBuilder: (context, index) {
                                final ride = controller.rides[index];
                                final pickup = ride['pickup'] ?? {};
                                final destination = ride['destination'] ?? {};
                                final recurring = ride['isRecurring'] == true;
                                final departureTime =
                                    (ride['departureTime'] as Timestamp)
                                        .toDate();

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      // TODO: Show ride details
                                      print('Selected ride: ${ride['id']}');
                                    },
                                    borderRadius: BorderRadius.circular(16),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Header: Time · Price · Seats
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 10,
                                            ),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.centerLeft,
                                                end: Alignment.centerRight,
                                                colors: [
                                                  RColors.primary.withOpacity(
                                                    0.10,
                                                  ),
                                                  RColors.secondary.withOpacity(
                                                    0.10,
                                                  ),
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  Iconsax.clock,
                                                  size: 16,
                                                  color: RColors.primary,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  DateFormat(
                                                    'MMM dd, hh:mm a',
                                                  ).format(departureTime),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const Spacer(),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 6,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: RColors.primary
                                                        .withOpacity(0.12),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    '₹${((ride['pricePerSeat'] ?? 0) * (ride['availableSeats'] ?? 0)).toStringAsFixed(0)}',
                                                    style: const TextStyle(
                                                      color: RColors.primary,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 6,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.green
                                                        .withOpacity(0.12),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20,
                                                        ),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.event_seat,
                                                        size: 14,
                                                        color:
                                                            Colors.green[700],
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        '${(ride['availableSeats'] ?? 0).clamp(0, 6)} seats',
                                                        style: TextStyle(
                                                          color:
                                                              Colors.green[700],
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 14),
                                          // Student Info Row
                                          FutureBuilder<DocumentSnapshot>(
                                            future:
                                                FirebaseFirestore.instance
                                                    .collection('users')
                                                    .doc(ride['userId'])
                                                    .get(),
                                            builder: (context, snapshot) {
                                              if (snapshot.hasData &&
                                                  snapshot.data != null) {
                                                final userData =
                                                    snapshot.data!.data()
                                                        as Map<
                                                          String,
                                                          dynamic
                                                        >?;
                                                final firstName =
                                                    userData?['firstName'] ??
                                                    '';
                                                final lastName =
                                                    userData?['lastName'] ?? '';
                                                final studentId =
                                                    userData?['studentId'] ??
                                                    '';
                                                final department =
                                                    userData?['department'] ??
                                                    '';

                                                return Row(
                                                  children: [
                                                    CircleAvatar(
                                                      radius: 20,
                                                      backgroundColor: RColors
                                                          .primary
                                                          .withOpacity(0.1),
                                                      child: Text(
                                                        firstName.isNotEmpty
                                                            ? firstName[0]
                                                                .toUpperCase()
                                                            : 'S',
                                                        style: const TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              RColors.primary,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            '$firstName $lastName',
                                                            style:
                                                                const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 16,
                                                                ),
                                                          ),
                                                          Row(
                                                            children: [
                                                              Container(
                                                                padding:
                                                                    const EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          6,
                                                                      vertical:
                                                                          2,
                                                                    ),
                                                                decoration: BoxDecoration(
                                                                  color: RColors
                                                                      .primary
                                                                      .withOpacity(
                                                                        0.1,
                                                                      ),
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        4,
                                                                      ),
                                                                ),
                                                                child: Text(
                                                                  studentId,
                                                                  style: TextStyle(
                                                                    color:
                                                                        RColors
                                                                            .primary,
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                                ),
                                                              ),
                                                              if (department
                                                                  .isNotEmpty) ...[
                                                                const SizedBox(
                                                                  width: 8,
                                                                ),
                                                                Text(
                                                                  department,
                                                                  style: TextStyle(
                                                                    color:
                                                                        Colors
                                                                            .grey[600],
                                                                    fontSize:
                                                                        12,
                                                                  ),
                                                                ),
                                                              ],
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 6,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: RColors.primary
                                                            .withOpacity(0.1),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              20,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        '₹${((ride['pricePerSeat'] ?? 0) * (ride['availableSeats'] ?? 0)).toStringAsFixed(0)}',
                                                        style: TextStyle(
                                                          color:
                                                              RColors.primary,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              }
                                              // Show skeleton loader while loading
                                              return Row(
                                                children: [
                                                  CircleAvatar(
                                                    radius: 20,
                                                    backgroundColor: Theme.of(
                                                      context,
                                                    ).dividerColor.withOpacity(
                                                      0.2,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Container(
                                                          height: 16,
                                                          width: 120,
                                                          decoration: BoxDecoration(
                                                            color: Theme.of(
                                                                  context,
                                                                ).dividerColor
                                                                .withOpacity(
                                                                  0.2,
                                                                ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  8,
                                                                ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 4,
                                                        ),
                                                        Container(
                                                          height: 12,
                                                          width: 80,
                                                          decoration: BoxDecoration(
                                                            color: Theme.of(
                                                                  context,
                                                                ).dividerColor
                                                                .withOpacity(
                                                                  0.2,
                                                                ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  6,
                                                                ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                          vertical: 6,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                          .dividerColor
                                                          .withOpacity(0.2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20,
                                                          ),
                                                    ),
                                                    width: 60,
                                                    height: 30,
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                          const SizedBox(height: 16),

                                          // Route Details
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color:
                                                  Theme.of(context).cardColor,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).dividerColor,
                                              ),
                                            ),
                                            child: Column(
                                              children: [
                                                // Pickup
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            8,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.green
                                                            .withOpacity(0.1),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: const Icon(
                                                        Icons.trip_origin,
                                                        color: Colors.green,
                                                        size: 16,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            pickup['name'] ??
                                                                '',
                                                            style:
                                                                const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                          ),
                                                          Text(
                                                            pickup['address'] ??
                                                                '',
                                                            style: TextStyle(
                                                              color: Theme.of(
                                                                    context,
                                                                  )
                                                                  .textTheme
                                                                  .bodySmall
                                                                  ?.color
                                                                  ?.withOpacity(
                                                                    0.7,
                                                                  ),
                                                              fontSize: 12,
                                                            ),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        left: 20,
                                                      ),
                                                  child: Container(
                                                    height: 20,
                                                    width: 2,
                                                    color:
                                                        Theme.of(
                                                          context,
                                                        ).dividerColor,
                                                  ),
                                                ),
                                                // Destination
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            8,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.red
                                                            .withOpacity(0.1),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: const Icon(
                                                        Icons.location_on,
                                                        color: Colors.red,
                                                        size: 16,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            destination['name'] ??
                                                                '',
                                                            style:
                                                                const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                          ),
                                                          Text(
                                                            destination['address'] ??
                                                                '',
                                                            style: TextStyle(
                                                              color: Theme.of(
                                                                    context,
                                                                  )
                                                                  .textTheme
                                                                  .bodySmall
                                                                  ?.color
                                                                  ?.withOpacity(
                                                                    0.7,
                                                                  ),
                                                              fontSize: 12,
                                                            ),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          // Info Chips: distance from you, recurring
                                          Builder(
                                            builder: (context) {
                                              double? pickupKm;
                                              try {
                                                final p = ride['pickup'] ?? {};
                                                pickupKm =
                                                    Geolocator.distanceBetween(
                                                      controller
                                                          .fromLocation
                                                          .value!
                                                          .latitude,
                                                      controller
                                                          .fromLocation
                                                          .value!
                                                          .longitude,
                                                      (p['latitude'] as num)
                                                          .toDouble(),
                                                      (p['longitude'] as num)
                                                          .toDouble(),
                                                    ) /
                                                    1000.0;
                                              } catch (_) {}

                                              return Row(
                                                children: [
                                                  if (pickupKm != null)
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 10,
                                                            vertical: 6,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: RColors.info
                                                            .withOpacity(0.10),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              20,
                                                            ),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          const Icon(
                                                            Icons.near_me,
                                                            size: 14,
                                                            color: RColors.info,
                                                          ),
                                                          const SizedBox(
                                                            width: 6,
                                                          ),
                                                          Text(
                                                            '~${pickupKm.toStringAsFixed(1)} km from you',
                                                            style:
                                                                const TextStyle(
                                                                  color:
                                                                      RColors
                                                                          .info,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  if (pickupKm != null)
                                                    const SizedBox(width: 8),
                                                  if (recurring)
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 10,
                                                            vertical: 6,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.blue
                                                            .withOpacity(0.10),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              20,
                                                            ),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            Icons.repeat,
                                                            size: 14,
                                                            color:
                                                                Colors
                                                                    .blue[600],
                                                          ),
                                                          const SizedBox(
                                                            width: 6,
                                                          ),
                                                          Text(
                                                            'Recurring',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors
                                                                      .blue[600],
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                ],
                                              );
                                            },
                                          ),

                                          // Preferences Tags
                                          if (ride['preferences'] != null &&
                                              (ride['preferences'] as List)
                                                  .isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 12,
                                              ),
                                              child: Wrap(
                                                spacing: 8,
                                                runSpacing: 8,
                                                children:
                                                    (ride['preferences'] as List).map<
                                                      Widget
                                                    >((pref) {
                                                      return Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 8,
                                                              vertical: 4,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color:
                                                              Colors.grey[100],
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                          border: Border.all(
                                                            color:
                                                                Colors
                                                                    .grey[300]!,
                                                          ),
                                                        ),
                                                        child: Text(
                                                          pref.toString(),
                                                          style: TextStyle(
                                                            color:
                                                                Colors
                                                                    .grey[700],
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      );
                                                    }).toList(),
                                              ),
                                            ),

                                          const SizedBox(height: 16),
                                          // Book Now Button
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              onPressed: () async {
                                                final confirm = await Get.dialog<
                                                  bool
                                                >(
                                                  AlertDialog(
                                                    title: const Text(
                                                      'Confirm Booking',
                                                    ),
                                                    content: const Text(
                                                      'Do you want to book this ride and open a chat with the driver?',
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed:
                                                            () => Get.back(
                                                              result: false,
                                                            ),
                                                        child: const Text(
                                                          'Cancel',
                                                        ),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed:
                                                            () => Get.back(
                                                              result: true,
                                                            ),
                                                        child: const Text(
                                                          'Confirm',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                                if (confirm != true) return;

                                                // Get user data for chat
                                                final userDoc =
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection('users')
                                                        .doc(ride['userId'])
                                                        .get();
                                                final userData = userDoc.data();
                                                final userName =
                                                    '${userData?['firstName'] ?? ''} ${userData?['lastName'] ?? ''}'
                                                        .trim();

                                                // Navigate to chat, which will create a per-ride chat room
                                                Get.to(
                                                  () => ChatScreen(
                                                    otherUserId: ride['userId'],
                                                    rideInfo: ride,
                                                    otherUserName:
                                                        userName.isNotEmpty
                                                            ? userName
                                                            : null,
                                                  ),
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    RColors.primary,
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 12,
                                                    ),
                                              ),
                                              child: const Text(
                                                'Book Now',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                }),

                // Bottom padding
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchForm(FindRideController controller, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // From Location
          GestureDetector(
            onTap: () async {
              final result = await Get.to(
                () => LocationSearchScreen(
                  isPickupLocation: true,
                  title: 'Select Pickup Location',
                ),
              );
              if (result != null) {
                controller.setFromLocation(
                  RideLocation(
                    name: result['name'] ?? '',
                    address: result['address'] ?? '',
                    latitude: result['latitude'] ?? 0.0,
                    longitude: result['longitude'] ?? 0.0,
                    placeId: result['placeId'] ?? '',
                    type: result['type'] ?? 'other',
                    additionalInfo: result['additionalInfo'] ?? {},
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: RColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'From',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).textTheme.bodySmall?.color?.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                        Obx(
                          () => Text(
                            controller.fromLocation.value?.name ??
                                'Select pickup location',
                            style: TextStyle(
                              color:
                                  controller.fromLocation.value != null
                                      ? Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.color
                                      : Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.color
                                          ?.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // To Location
          GestureDetector(
            onTap: () async {
              final result = await Get.to(
                () => LocationSearchScreen(
                  isPickupLocation: false,
                  title: 'Select Destination',
                ),
              );
              if (result != null) {
                controller.setToLocation(
                  RideLocation(
                    name: result['name'] ?? '',
                    address: result['address'] ?? '',
                    latitude: result['latitude'] ?? 0.0,
                    longitude: result['longitude'] ?? 0.0,
                    placeId: result['placeId'] ?? '',
                    type: result['type'] ?? 'other',
                    additionalInfo: result['additionalInfo'] ?? {},
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: Colors.red),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'To',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).textTheme.bodySmall?.color?.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                        Obx(
                          () => Text(
                            controller.toLocation.value?.name ??
                                'Select destination',
                            style: TextStyle(
                              color:
                                  controller.toLocation.value != null
                                      ? Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.color
                                      : Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.color
                                          ?.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Route Info
          Obx(() {
            if (controller.isCalculatingRoute.value) {
              return Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Center(
                  child: Column(
                    children: [
                      const CircularProgressIndicator(strokeWidth: 2),
                      const SizedBox(height: 8),
                      _FindingSubText(text: 'Calculating route...'),
                    ],
                  ),
                ),
              );
            }

            if (controller.routeInfo.value != null) {
              return Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: RColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.route, color: RColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      '${controller.routeInfo.value!.distance} · ${controller.routeInfo.value!.duration}',
                      style: TextStyle(
                        color: RColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  // Decode polyline string to list of LatLng points
  List<gmaps.LatLng> _decodePolyline(String encoded) {
    List<gmaps.LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      final p = gmaps.LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble());
      poly.add(p);
    }
    return poly;
  }

  // Show search suggestions when no rides are found
  void _showSearchSuggestions(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.lightbulb_outline, color: RColors.secondary, size: 24),
              const SizedBox(width: 8),
              const Text('Search Tips'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Try these suggestions to find more rides:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              _buildSuggestionItem(
                Icons.location_on,
                'Use nearby landmarks',
                'Try searching for nearby malls, stations, or universities instead of exact addresses.',
              ),
              const SizedBox(height: 8),
              _buildSuggestionItem(
                Icons.access_time,
                'Check different times',
                'Rides are often available at different departure times.',
              ),
              const SizedBox(height: 8),
              _buildSuggestionItem(
                Icons.expand_more,
                'Expand search radius',
                'Try searching for locations within 2-5km of your destination.',
              ),
              const SizedBox(height: 8),
              _buildSuggestionItem(
                Icons.refresh,
                'Refresh regularly',
                'New rides are added frequently. Pull down to refresh.',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Got it', style: TextStyle(color: RColors.primary)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSuggestionItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: RColors.secondary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                description,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Themed helper widgets for subdued loading text
class _FindingText extends StatelessWidget {
  const _FindingText();
  @override
  Widget build(BuildContext context) {
    return Text(
      'Finding rides...',
      style: TextStyle(
        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
      ),
    );
  }
}

class _FindingSubText extends StatelessWidget {
  final String text;
  const _FindingSubText({required this.text});
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
        fontSize: 12,
      ),
    );
  }
}
