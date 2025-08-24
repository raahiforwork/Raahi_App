import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../utils/constants/colors.dart';
import '../models/ride_location.dart';
import 'package:geocoding/geocoding.dart';

class FindRideController extends GetxController {
  static FindRideController get instance => Get.find();

  // Google Maps API Configuration
  static const String _googleApiKey = 'AIzaSyCmAnZmoJqH-Pq3ZwjE3D359IFw0B4LjRk';
  static const String _placesBaseUrl =
      'https://maps.googleapis.com/maps/api/place';
  static const String _directionsBaseUrl =
      'https://maps.googleapis.com/maps/api/directions';
  static const String _geocodeBaseUrl =
      'https://maps.googleapis.com/maps/api/geocode';

  // Location Services
  final isGettingLocation = false.obs;
  final currentPosition = Rxn<Position>();
  final currentLocationName = ''.obs;

  // Location Selection
  final fromLocation = Rxn<RideLocation>();
  final toLocation = Rxn<RideLocation>();

  // Search Controllers
  final pickupController = TextEditingController();
  final destinationController = TextEditingController();
  final pickupSuggestions = <PlaceSuggestion>[].obs;
  final destinationSuggestions = <PlaceSuggestion>[].obs;
  final isSearchingPlaces = false.obs;

  // Route Information
  final routeInfo = Rxn<RouteInfo>();
  final isCalculatingRoute = false.obs;

  // Dijkstra Shortest Path (computed from current route polyline)
  final dijkstraDistanceMeters = 0.0.obs;
  final dijkstraPath = <LatLng>[].obs;

  // Real-time rides list
  final rides = <Map<String, dynamic>>[].obs;
  final isLoadingRides = false.obs;
  final ridesError = ''.obs;
  StreamSubscription? _ridesSubscription;
  Timer? _autoRefreshTimer;

  // Debounce timers
  Timer? _pickupSearchTimer;
  Timer? _destinationSearchTimer;

  @override
  void onInit() {
    super.onInit();
    _initializeLocationServices();
  }

  @override
  void onClose() {
    _pickupSearchTimer?.cancel();
    _destinationSearchTimer?.cancel();
    _autoRefreshTimer?.cancel();
    pickupController.dispose();
    destinationController.dispose();
    _ridesSubscription?.cancel();
    super.onClose();
  }

  // Initialize location services
  Future<void> _initializeLocationServices() async {
    await getCurrentLocation();
  }

  // Get current location using Geolocator
  Future<void> getCurrentLocation() async {
    try {
      isGettingLocation.value = true;

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions denied';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions permanently denied';
      }

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled';
      }

      // Get current position with fallback to last known
      Position position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 15),
        );
      } catch (e) {
        final lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown == null) {
          rethrow;
        }
        position = lastKnown;
      }
      currentPosition.value = position;

      // Reverse geocode to get address
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      final place = placemarks.first;
      // Force country to India if not already
      String country =
          (place.country?.toLowerCase() == 'india') ? place.country! : 'India';
      final address = [
        place.name,
        place.subLocality,
        place.locality,
        place.administrativeArea,
        country,
      ].whereType<String>().where((e) => e.trim().isNotEmpty).join(', ');
      currentLocationName.value = address;

      // Set fromLocation to current location
      fromLocation.value = RideLocation(
        name: 'Current Location',
        address: address,
        latitude: position.latitude,
        longitude: position.longitude,
        placeId: '',
        type: 'current_location',
        additionalInfo: {},
      );
      pickupController.text = 'Current Location';

      _showSuccessSnackbar('Location Found', 'Current location updated');
    } catch (e) {
      _showErrorSnackbar(
        'Location Error',
        e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      isGettingLocation.value = false;
    }
  }

  // Google Geocoding API - Convert coordinates to address
  Future<String> getAddressFromCoordinates(double lat, double lng) async {
    try {
      final url =
          '$_geocodeBaseUrl/json'
          '?latlng=$lat,$lng'
          '&key=$_googleApiKey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          return data['results'][0]['formatted_address'];
        }
      }
    } catch (e) {
      print('Geocoding error: $e');
    }
    return '';
  }

  // Google Geocoding API - Convert address to coordinates
  Future<Map<String, double>?> getCoordinatesFromAddress(String address) async {
    try {
      final url =
          '$_geocodeBaseUrl/json'
          '?address=${Uri.encodeComponent(address)}'
          '&key=$_googleApiKey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final location = data['results'][0]['geometry']['location'];
          return {
            'lat': location['lat'].toDouble(),
            'lng': location['lng'].toDouble(),
          };
        }
      }
    } catch (e) {
      print('Geocoding error: $e');
    }
    return null;
  }

  // Google Places API - Search for places
  Future<void> searchPickupLocations(String query) async {
    if (query.trim().isEmpty) {
      pickupSuggestions.clear();
      return;
    }

    _pickupSearchTimer?.cancel();
    _pickupSearchTimer = Timer(const Duration(milliseconds: 500), () async {
      try {
        isSearchingPlaces.value = true;
        final suggestions = await _searchPlaces(query);
        pickupSuggestions.assignAll(suggestions);
      } catch (e) {
        print('Pickup search error: $e');
        pickupSuggestions.clear();
      } finally {
        isSearchingPlaces.value = false;
      }
    });
  }

  Future<void> searchDestinationLocations(String query) async {
    if (query.trim().isEmpty) {
      destinationSuggestions.clear();
      return;
    }

    _destinationSearchTimer?.cancel();
    _destinationSearchTimer = Timer(
      const Duration(milliseconds: 500),
      () async {
        try {
          isSearchingPlaces.value = true;
          final suggestions = await _searchPlaces(query);
          destinationSuggestions.assignAll(suggestions);
        } catch (e) {
          print('Destination search error: $e');
          destinationSuggestions.clear();
        } finally {
          isSearchingPlaces.value = false;
        }
      },
    );
  }

  // Core Google Places search
  Future<List<PlaceSuggestion>> _searchPlaces(String query) async {
    try {
      String locationBias = '';
      if (currentPosition.value != null) {
        locationBias =
            '&location=${currentPosition.value!.latitude},${currentPosition.value!.longitude}&radius=50000';
      }

      final url =
          '$_placesBaseUrl/autocomplete/json'
          '?input=${Uri.encodeComponent(query)}'
          '&key=$_googleApiKey'
          '&components=country:in' // <-- restrict to India
          '&types=establishment|geocode'
          '$locationBias';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final predictions = data['predictions'] as List;
          return predictions
              .map((prediction) => PlaceSuggestion.fromJson(prediction))
              .toList();
        }
      }
    } catch (e) {
      print('Places search error: $e');
    }
    return [];
  }

  // Google Places Details API - Get detailed place information
  Future<RideLocation?> getPlaceDetails(String placeId) async {
    try {
      final url =
          '$_placesBaseUrl/details/json'
          '?place_id=$placeId'
          '&fields=name,geometry,formatted_address,types,rating,opening_hours'
          '&key=$_googleApiKey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final result = data['result'];
          final geometry = result['geometry']['location'];
          final types = List<String>.from(result['types'] ?? []);

          return RideLocation(
            name: result['name'] ?? '',
            address: result['formatted_address'] ?? '',
            latitude: geometry['lat'].toDouble(),
            longitude: geometry['lng'].toDouble(),
            placeId: placeId,
            type: _getLocationTypeFromGoogleTypes(types),
          );
        }
      }
    } catch (e) {
      print('Place details error: $e');
    }
    return null;
  }

  // Google Directions API - Calculate route between two points
  Future<RouteInfo?> calculateRoute(RideLocation from, RideLocation to) async {
    try {
      isCalculatingRoute.value = true;

      final url =
          '$_directionsBaseUrl/json'
          '?origin=${from.latitude},${from.longitude}'
          '&destination=${to.latitude},${to.longitude}'
          '&key=$_googleApiKey'
          '&mode=driving'
          '&traffic_model=best_guess'
          '&departure_time=now';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final leg = route['legs'][0];

          return RouteInfo(
            distance: leg['distance']['text'],
            duration: leg['duration']['text'],
            distanceValue: leg['distance']['value'],
            durationValue: leg['duration']['value'],
            polyline: route['overview_polyline']['points'],
            steps: _extractSteps(leg['steps']),
            bounds: LatLngBounds(
              southwest: LatLng(
                route['bounds']['southwest']['lat'],
                route['bounds']['southwest']['lng'],
              ),
              northeast: LatLng(
                route['bounds']['northeast']['lat'],
                route['bounds']['northeast']['lng'],
              ),
            ),
          );
        }
      }
    } catch (e) {
      print('Route calculation error: $e');
    } finally {
      isCalculatingRoute.value = false;
    }
    return null;
  }

  // Extract navigation steps from directions response
  List<NavigationStep> _extractSteps(List<dynamic> steps) {
    return steps
        .map(
          (step) => NavigationStep(
            instruction: step['html_instructions'],
            distance: step['distance']['text'],
            duration: step['duration']['text'],
            startLocation: LatLng(
              step['start_location']['lat'].toDouble(),
              step['start_location']['lng'].toDouble(),
            ),
            endLocation: LatLng(
              step['end_location']['lat'].toDouble(),
              step['end_location']['lng'].toDouble(),
            ),
          ),
        )
        .toList();
  }

  // Select pickup location
  Future<void> selectPickupLocation(PlaceSuggestion suggestion) async {
    try {
      final location = await getPlaceDetails(suggestion.placeId);
      if (location != null) {
        fromLocation.value = location;
        pickupController.text = location.name;
        pickupSuggestions.clear();

        _showSuccessSnackbar('Pickup Selected', location.name);

        // Auto-calculate route if destination is set
        if (toLocation.value != null) {
          await _calculateAndUpdateRoute();
        }
      }
    } catch (e) {
      _showErrorSnackbar('Error', 'Failed to select pickup: $e');
    }
  }

  // Select destination location
  Future<void> selectDestinationLocation(PlaceSuggestion suggestion) async {
    try {
      final location = await getPlaceDetails(suggestion.placeId);
      if (location != null) {
        toLocation.value = location;
        destinationController.text = location.name;
        destinationSuggestions.clear();

        _showSuccessSnackbar('Destination Selected', location.name);

        // Auto-calculate route if pickup is set
        if (fromLocation.value != null) {
          await _calculateAndUpdateRoute();
        }
      }
    } catch (e) {
      _showErrorSnackbar('Error', 'Failed to select destination: $e');
    }
  }

  // Set current location as pickup
  Future<void> setCurrentLocationAsPickup() async {
    if (currentPosition.value == null) {
      await getCurrentLocation();
    }

    if (currentPosition.value != null) {
      fromLocation.value = RideLocation(
        name: 'Current Location',
        address: currentLocationName.value,
        latitude: currentPosition.value!.latitude,
        longitude: currentPosition.value!.longitude,
        placeId: 'current_location',
        type: 'current',
      );

      pickupController.text = 'Current Location';
      _showSuccessSnackbar('Pickup Set', 'Current location set as pickup');

      if (toLocation.value != null) {
        await _calculateAndUpdateRoute();
      }
    }
  }

  // Calculate and update route information
  Future<void> _calculateAndUpdateRoute() async {
    if (fromLocation.value != null && toLocation.value != null) {
      final route = await calculateRoute(
        fromLocation.value!,
        toLocation.value!,
      );
      if (route != null) {
        routeInfo.value = route;
        _showSuccessSnackbar(
          'Route Calculated',
          'Distance: ${route.distance}, Duration: ${route.duration}',
        );
        // Compute Dijkstra shortest path based on current route polyline
        _computeShortestPathUsingDijkstra();
        // Auto-refresh available rides after route changes
        fetchAvailableRides();
      }
    }
  }

  // Add this method to calculate route when locations are set
  Future<void> calculateRouteInfo() async {
    if (fromLocation.value == null || toLocation.value == null) return;

    try {
      isCalculatingRoute.value = true;
      print('🗺️ Calculating route info...');

      final url =
          '$_directionsBaseUrl/json'
          '?origin=${fromLocation.value!.latitude},${fromLocation.value!.longitude}'
          '&destination=${toLocation.value!.latitude},${toLocation.value!.longitude}'
          '&key=$_googleApiKey'
          '&mode=driving';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final leg = route['legs'][0];

          routeInfo.value = RouteInfo(
            distance: leg['distance']['text'],
            duration: leg['duration']['text'],
            distanceValue: leg['distance']['value'],
            durationValue: leg['duration']['value'],
            polyline: route['overview_polyline']['points'],
            steps: _extractSteps(leg['steps']),
            bounds: LatLngBounds(
              southwest: LatLng(
                route['bounds']['southwest']['lat'],
                route['bounds']['southwest']['lng'],
              ),
              northeast: LatLng(
                route['bounds']['northeast']['lat'],
                route['bounds']['northeast']['lng'],
              ),
            ),
          );

          print(
            '✅ Route calculated: ${routeInfo.value?.distance} / ${routeInfo.value?.duration}',
          );
          // Compute Dijkstra shortest path based on current route polyline
          _computeShortestPathUsingDijkstra();
          fetchAvailableRides(); // Fetch rides after route is calculated
        }
      }
    } catch (e) {
      print('❌ Error calculating route: $e');
    } finally {
      isCalculatingRoute.value = false;
    }
  }

  // Decode the polyline string into a list of LatLng
  List<LatLng> _decodePolylineToLatLng(String encoded) {
    final List<LatLng> path = [];
    int index = 0;
    int lat = 0;
    int lng = 0;
    while (index < encoded.length) {
      int b;
      int shift = 0;
      int result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      path.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return path;
  }

  // Compute shortest path using Dijkstra on the decoded polyline points.
  // Note: The Google Directions polyline already represents a path. Here, we
  // model it as a graph with edges between consecutive points and run Dijkstra
  // to demonstrate shortest-path calculation and compute the total distance.
  void _computeShortestPathUsingDijkstra() {
    try {
      final currentRoute = routeInfo.value;
      if (currentRoute == null || currentRoute.polyline.isEmpty) {
        dijkstraPath.clear();
        dijkstraDistanceMeters.value = 0.0;
        return;
      }

      final nodes = _decodePolylineToLatLng(currentRoute.polyline);
      if (nodes.length < 2) {
        dijkstraPath.assignAll(nodes);
        dijkstraDistanceMeters.value = 0.0;
        return;
      }

      final int n = nodes.length;
      // Build adjacency list with edges between consecutive nodes
      final List<List<_Edge>> graph = List.generate(n, (i) => <_Edge>[]);
      for (int i = 0; i < n - 1; i++) {
        final a = nodes[i];
        final b = nodes[i + 1];
        final w = Geolocator.distanceBetween(
          a.latitude,
          a.longitude,
          b.latitude,
          b.longitude,
        );
        graph[i].add(_Edge(i + 1, w));
        graph[i + 1].add(_Edge(i, w));
      }

      // Dijkstra from 0 to n-1
      final distances = List<double>.filled(n, double.infinity);
      final previous = List<int?>.filled(n, null);
      final visited = List<bool>.filled(n, false);
      distances[0] = 0.0;

      for (int iter = 0; iter < n; iter++) {
        int u = -1;
        double best = double.infinity;
        for (int i = 0; i < n; i++) {
          if (!visited[i] && distances[i] < best) {
            best = distances[i];
            u = i;
          }
        }
        if (u == -1) break;
        visited[u] = true;
        if (u == n - 1) break; // reached destination

        for (final e in graph[u]) {
          if (visited[e.to]) continue;
          final alt = distances[u] + e.weightMeters;
          if (alt < distances[e.to]) {
            distances[e.to] = alt;
            previous[e.to] = u;
          }
        }
      }

      // Reconstruct path
      final List<int> pathIdx = [];
      int? curr = n - 1;
      while (curr != null) {
        pathIdx.add(curr);
        curr = previous[curr];
      }
      pathIdx.setAll(0, pathIdx.reversed);

      final List<LatLng> path = [for (final i in pathIdx) nodes[i]];
      dijkstraPath.assignAll(path);
      dijkstraDistanceMeters.value =
          distances[n - 1].isFinite ? distances[n - 1] : _sumPathDistance(path);
    } catch (e) {
      print('Dijkstra computation error: $e');
      dijkstraPath.clear();
      dijkstraDistanceMeters.value = 0.0;
    }
  }

  double _sumPathDistance(List<LatLng> pts) {
    double total = 0.0;
    for (int i = 0; i < pts.length - 1; i++) {
      total += Geolocator.distanceBetween(
        pts[i].latitude,
        pts[i].longitude,
        pts[i + 1].latitude,
        pts[i + 1].longitude,
      );
    }
    return total;
  }

  // Lightweight edge record for Dijkstra

  // Update the location setters to trigger route calculation
  void setFromLocation(RideLocation location) {
    fromLocation.value = location;
    if (toLocation.value != null) {
      calculateRouteInfo();
    }
  }

  void setToLocation(RideLocation location) {
    toLocation.value = location;
    if (fromLocation.value != null) {
      calculateRouteInfo();
    }
  }

  // Call this after both fromLocation and toLocation are set
  void fetchAvailableRides() {
    try {
      if (fromLocation.value == null || toLocation.value == null) {
        print('❌ Missing locations');
        rides.clear();
        ridesError.value = 'Please select pickup and destination locations.';
        return;
      }

      print('🔍 Starting ride fetch...');
      print(
        '📍 From: ${fromLocation.value?.name} to ${toLocation.value?.name}',
      );

      isLoadingRides.value = true;
      ridesError.value = '';
      _ridesSubscription?.cancel();

      final searchTime = DateTime.now();

      // Create a more flexible query with real-time updates
      _ridesSubscription = FirebaseFirestore.instance
          .collection('rides')
          .where('status', isEqualTo: 'active')
          .snapshots()
          .listen(
            (snapshot) {
              try {
                print(
                  '📦 Received ${snapshot.docs.length} rides from Firestore',
                );

                if (snapshot.docs.isEmpty) {
                  print('ℹ️ No rides found in Firestore');
                  rides.value = [];
                  ridesError.value = 'No rides available at the moment.';
                  isLoadingRides.value = false;
                  return;
                }

                final List<Map<String, dynamic>> allRides =
                    snapshot.docs.map((doc) {
                      final data = doc.data();
                      data['id'] = doc.id;
                      return data;
                    }).toList();

                print('🔄 Processing ${allRides.length} rides...');

                final List<Map<String, dynamic>> filtered =
                    allRides.where((ride) {
                      try {
                        print('🚗 Processing ride ${ride['id']}:');

                        // Basic data validation
                        final pickup = ride['pickup'];
                        final destination = ride['destination'];

                        if (pickup == null ||
                            destination == null ||
                            !pickup.containsKey('latitude') ||
                            !pickup.containsKey('longitude') ||
                            !destination.containsKey('latitude') ||
                            !destination.containsKey('longitude')) {
                          print('❌ Invalid location data');
                          return false;
                        }

                        // Check if ride has available seats (limited to 6)
                        final availableSeats = ride['availableSeats'] ?? 0;
                        if (availableSeats <= 0 || availableSeats > 6) {
                          print(
                            '❌ Invalid available seats: $availableSeats (must be 1-6)',
                          );
                          return false;
                        }

                        // Verify departure time is in the future
                        final Timestamp? departureTimestamp =
                            ride['departureTime'];
                        if (departureTimestamp == null) {
                          print('❌ No departure time');
                          return false;
                        }

                        final departureTime = departureTimestamp.toDate();
                        if (departureTime.isBefore(searchTime)) {
                          print('❌ Already departed');
                          return false;
                        }

                        // Enhanced location matching with multiple strategies
                        final bool isRouteMatching = _isRouteMatching(
                          pickup,
                          destination,
                          fromLocation.value!,
                          toLocation.value!,
                        );

                        if (!isRouteMatching) {
                          print('❌ Route does not match search criteria');
                          return false;
                        }

                        print('✅ Ride matches search criteria');
                        return true;
                      } catch (e) {
                        print('❌ Error processing ride: $e');
                        return false;
                      }
                    }).toList();

                print('📊 Found ${filtered.length} matching rides');

                // Sort by departure time and distance
                filtered.sort((a, b) {
                  // First sort by departure time
                  final aTime = (a['departureTime'] as Timestamp).toDate();
                  final bTime = (b['departureTime'] as Timestamp).toDate();
                  final timeComparison = aTime.compareTo(bTime);

                  if (timeComparison != 0) return timeComparison;

                  // If same time, sort by distance
                  final aPickup = a['pickup'];
                  final bPickup = b['pickup'];
                  final aDistance = Geolocator.distanceBetween(
                    fromLocation.value!.latitude,
                    fromLocation.value!.longitude,
                    (aPickup['latitude'] as num).toDouble(),
                    (aPickup['longitude'] as num).toDouble(),
                  );
                  final bDistance = Geolocator.distanceBetween(
                    fromLocation.value!.latitude,
                    fromLocation.value!.longitude,
                    (bPickup['latitude'] as num).toDouble(),
                    (bPickup['longitude'] as num).toDouble(),
                  );

                  return aDistance.compareTo(bDistance);
                });

                rides.value = filtered;

                if (filtered.isEmpty) {
                  ridesError.value =
                      'No rides available for your route. Try adjusting your search or check back later.';
                } else {
                  ridesError.value = '';
                  _showSuccessSnackbar(
                    'Rides Found',
                    'Found ${filtered.length} ride${filtered.length == 1 ? '' : 's'} for your route!',
                  );
                }
              } catch (e) {
                print('❌ Error processing snapshot: $e');
                ridesError.value = 'Error loading rides. Please try again.';
              } finally {
                isLoadingRides.value = false;
              }
            },
            onError: (error) {
              print('❌ Firestore error: $error');
              isLoadingRides.value = false;
              ridesError.value =
                  'Connection error. Please check your internet and try again.';
            },
          );

      // Start auto-refresh timer
      _startAutoRefresh();
    } catch (e) {
      print('❌ Unexpected error in fetchAvailableRides: $e');
      isLoadingRides.value = false;
      ridesError.value = 'Something went wrong. Please try again.';
    }
  }

  // Start auto-refresh timer for real-time updates
  void _startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (fromLocation.value != null && toLocation.value != null) {
        print('🔄 Auto-refreshing rides...');
        // The Firestore listener will automatically update the rides
        // This timer ensures we're actively listening for changes
      } else {
        timer.cancel();
      }
    });
  }

  // Stop auto-refresh (removed unused method)

  // Manual refresh method
  Future<void> refreshRides() async {
    if (fromLocation.value != null && toLocation.value != null) {
      print('🔄 Manual refresh requested');
      isLoadingRides.value = true;
      ridesError.value = '';

      // Force a refresh by temporarily canceling and restarting the subscription
      _ridesSubscription?.cancel();
      await Future.delayed(const Duration(milliseconds: 500));
      fetchAvailableRides();
    }
  }

  // Removed legacy fuzzy matching helper

  // Enhanced route matching with multiple strategies
  bool _isRouteMatching(
    Map<String, dynamic> pickup,
    Map<String, dynamic> destination,
    RideLocation fromLocation,
    RideLocation toLocation,
  ) {
    try {
      // STRICT matching only. Show only the searched ride.
      // 1) Prefer exact placeId match when available on both sides
      final pickupPlaceId = (pickup['placeId'] as String?)?.trim() ?? '';
      final destPlaceId = (destination['placeId'] as String?)?.trim() ?? '';

      if (pickupPlaceId.isNotEmpty &&
          destPlaceId.isNotEmpty &&
          fromLocation.placeId.trim().isNotEmpty &&
          toLocation.placeId.trim().isNotEmpty) {
        final placeIdMatch =
            pickupPlaceId == fromLocation.placeId.trim() &&
            destPlaceId == toLocation.placeId.trim();
        if (placeIdMatch) {
          print('✅ Strict match by placeId');
          return true;
        }
      }

      // 2) Otherwise require both pickup and destination to be VERY close
      //    to the searched coordinates (direction-sensitive)
      const double strictRadiusMeters = 300.0; // ~0.3 km
      final pickupDistance = Geolocator.distanceBetween(
        fromLocation.latitude,
        fromLocation.longitude,
        (pickup['latitude'] as num).toDouble(),
        (pickup['longitude'] as num).toDouble(),
      );
      final destinationDistance = Geolocator.distanceBetween(
        toLocation.latitude,
        toLocation.longitude,
        (destination['latitude'] as num).toDouble(),
        (destination['longitude'] as num).toDouble(),
      );

      if (pickupDistance <= strictRadiusMeters &&
          destinationDistance <= strictRadiusMeters) {
        print(
          '✅ Strict match by coordinates within ${strictRadiusMeters.toInt()}m',
        );
        return true;
      }

      // 3) Final fallback: exact normalized name/address equality
      String norm(String s) => s.toLowerCase().trim();

      final pickupName = pickup['name'] as String? ?? '';
      final destinationName = destination['name'] as String? ?? '';
      if (norm(pickupName) == norm(fromLocation.name) &&
          norm(destinationName) == norm(toLocation.name)) {
        print('✅ Strict match by exact names');
        return true;
      }

      final pickupAddress = pickup['address'] as String? ?? '';
      final destinationAddress = destination['address'] as String? ?? '';
      if (pickupAddress.isNotEmpty && destinationAddress.isNotEmpty) {
        if (norm(pickupAddress) == norm(fromLocation.address) &&
            norm(destinationAddress) == norm(toLocation.address)) {
          print('✅ Strict match by exact addresses');
          return true;
        }
      }

      // No strict match -> exclude
      return false;
    } catch (e) {
      print('❌ Error in strict route matching: $e');
      return false;
    }
  }

  // Removed legacy dynamic radius helper

  // Utility methods
  String _getLocationTypeFromGoogleTypes(List<String> types) {
    if (types.contains('university') || types.contains('school'))
      return 'university';
    if (types.contains('shopping_mall') || types.contains('store'))
      return 'mall';
    if (types.contains('restaurant') || types.contains('food'))
      return 'restaurant';
    if (types.contains('hospital')) return 'hospital';
    if (types.contains('transit_station')) return 'station';
    return 'other';
  }

  void _showSuccessSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: RColors.success,
      colorText: RColors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: RColors.error,
      colorText: RColors.white,
    );
  }

  // Clear selections
  void clearPickupSelection() {
    fromLocation.value = null;
    pickupController.clear();
    pickupSuggestions.clear();
    routeInfo.value = null;
  }

  void clearDestinationSelection() {
    toLocation.value = null;
    destinationController.clear();
    destinationSuggestions.clear();
    routeInfo.value = null;
  }
}

// Data Models
class PlaceSuggestion {
  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;

  PlaceSuggestion({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
  });

  factory PlaceSuggestion.fromJson(Map<String, dynamic> json) {
    final structuredFormatting = json['structured_formatting'] ?? {};
    return PlaceSuggestion(
      placeId: json['place_id'] ?? '',
      description: json['description'] ?? '',
      mainText: structuredFormatting['main_text'] ?? '',
      secondaryText: structuredFormatting['secondary_text'] ?? '',
    );
  }
}

class RouteInfo {
  final String distance;
  final String duration;
  final int distanceValue;
  final int durationValue;
  final String polyline;
  final List<NavigationStep> steps;
  final LatLngBounds bounds;

  RouteInfo({
    required this.distance,
    required this.duration,
    required this.distanceValue,
    required this.durationValue,
    required this.polyline,
    required this.steps,
    required this.bounds,
  });
}

class NavigationStep {
  final String instruction;
  final String distance;
  final String duration;
  final LatLng startLocation;
  final LatLng endLocation;

  NavigationStep({
    required this.instruction,
    required this.distance,
    required this.duration,
    required this.startLocation,
    required this.endLocation,
  });
}

class LatLng {
  final double latitude;
  final double longitude;

  LatLng(this.latitude, this.longitude);
}

class LatLngBounds {
  final LatLng southwest;
  final LatLng northeast;

  LatLngBounds({required this.southwest, required this.northeast});
}

// Lightweight edge record for Dijkstra
class _Edge {
  final int to;
  final double weightMeters;
  _Edge(this.to, this.weightMeters);
}
