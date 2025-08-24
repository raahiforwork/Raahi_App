import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../features/rides/models/ride_location.dart';

class RealTimeRideService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Search for rides in real-time based on criteria
  static Stream<List<Map<String, dynamic>>> searchRidesRealTime({
    required RideLocation pickup,
    required RideLocation destination,
    required DateTime departureTime,
    double maxPickupDistance = 2000, // 2km radius
    double maxDestinationDistance = 2000, // 2km radius
    int maxTimeDifferenceMinutes = 60, // 1 hour
    String? vehicleType,
    double? maxPrice,
    List<String>? preferences,
    Position? currentUserLocation,
  }) {
    return _firestore
        .collection('rides')
        .where('status', isEqualTo: 'active')
        .where('availableSeats', isGreaterThan: 0)
        .where(
          'departureTime',
          isGreaterThanOrEqualTo: departureTime.subtract(
            Duration(minutes: maxTimeDifferenceMinutes),
          ),
        )
        .where(
          'departureTime',
          isLessThanOrEqualTo: departureTime.add(
            Duration(minutes: maxTimeDifferenceMinutes),
          ),
        )
        .snapshots()
        .map((snapshot) {
          List<Map<String, dynamic>> rides =
              snapshot.docs
                  .map((doc) {
                    final data = doc.data();
                    data['id'] = doc.id;
                    return data;
                  })
                  .where(
                    (ride) => _matchesSearchCriteria(
                      ride: ride,
                      searchPickup: pickup,
                      searchDestination: destination,
                      searchTime: departureTime,
                      maxPickupDistance: maxPickupDistance,
                      maxDestinationDistance: maxDestinationDistance,
                      maxTimeDifferenceMinutes: maxTimeDifferenceMinutes,
                      vehicleTypeFilter: vehicleType,
                      maxPriceFilter: maxPrice,
                      preferenceFilters: preferences,
                    ),
                  )
                  .toList();

          // Sort by proximity to user's current location if available
          if (currentUserLocation != null) {
            rides.sort((a, b) {
              final pickupA = a['pickup'] as Map<String, dynamic>;
              final pickupB = b['pickup'] as Map<String, dynamic>;

              final distanceA = Geolocator.distanceBetween(
                currentUserLocation.latitude,
                currentUserLocation.longitude,
                (pickupA['latitude'] ?? 0.0).toDouble(),
                (pickupA['longitude'] ?? 0.0).toDouble(),
              );
              final distanceB = Geolocator.distanceBetween(
                currentUserLocation.latitude,
                currentUserLocation.longitude,
                (pickupB['latitude'] ?? 0.0).toDouble(),
                (pickupB['longitude'] ?? 0.0).toDouble(),
              );
              return distanceA.compareTo(distanceB);
            });
          }

          return rides;
        });
  }

  static bool _matchesSearchCriteria({
    required Map<String, dynamic> ride,
    required RideLocation searchPickup,
    required RideLocation searchDestination,
    required DateTime searchTime,
    double maxPickupDistance = 2000,
    double maxDestinationDistance = 2000,
    int maxTimeDifferenceMinutes = 60,
    String? vehicleTypeFilter,
    double? maxPriceFilter,
    List<String>? preferenceFilters,
  }) {
    // Check pickup distance
    final pickupData = ride['pickup'] as Map<String, dynamic>;
    final ridePickup = RideLocation.fromMap(pickupData);
    final pickupDistance = ridePickup.distanceTo(
      searchPickup.latitude,
      searchPickup.longitude,
    );

    if (pickupDistance > maxPickupDistance) return false;

    // Check destination distance
    final destinationData = ride['destination'] as Map<String, dynamic>;
    final rideDestination = RideLocation.fromMap(destinationData);
    final destDistance = rideDestination.distanceTo(
      searchDestination.latitude,
      searchDestination.longitude,
    );

    if (destDistance > maxDestinationDistance) return false;

    // Check time difference
    final rideDepartureTime = (ride['departureTime'] as Timestamp).toDate();
    final timeDifference =
        rideDepartureTime.difference(searchTime).inMinutes.abs();

    if (timeDifference > maxTimeDifferenceMinutes) return false;

    // Check vehicle type filter
    if (vehicleTypeFilter != null && vehicleTypeFilter.isNotEmpty) {
      final rideVehicleType = ride['vehicleType'] as String?;
      if (rideVehicleType?.toLowerCase() != vehicleTypeFilter.toLowerCase()) {
        return false;
      }
    }

    // Check price filter
    if (maxPriceFilter != null) {
      final ridePrice = (ride['pricePerSeat'] ?? 0.0).toDouble();
      if (ridePrice > maxPriceFilter) return false;
    }

    // Check preferences filter
    if (preferenceFilters != null && preferenceFilters.isNotEmpty) {
      final ridePreferences = List<String>.from(ride['preferences'] ?? []);
      final hasMatchingPreference = preferenceFilters.any(
        (pref) => ridePreferences.contains(pref),
      );
      if (!hasMatchingPreference) return false;
    }

    return true;
  }

  /// Request to join a ride
  static Future<bool> requestToJoinRide({
    required String rideId,
    required String passengerId,
    required Map<String, dynamic> passengerInfo,
    String message = '',
  }) async {
    try {
      final request = {
        'userId': passengerId,
        'name': passengerInfo['name'] ?? '',
        'phone': passengerInfo['phone'] ?? '',
        'email': passengerInfo['email'] ?? '',
        'profileImage': passengerInfo['profileImage'] ?? '',
        'rating': passengerInfo['rating'] ?? 5.0,
        'message': message,
        'requestedAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      };

      await _firestore.collection('rides').doc(rideId).update({
        'pendingRequests': FieldValue.arrayUnion([request]),
      });

      return true;
    } catch (e) {
      print('Error requesting to join ride: $e');
      return false;
    }
  }

  /// Create a mock ride for testing
  static Future<void> createMockRide({
    required String driverId,
    required RideLocation pickup,
    required RideLocation destination,
    required DateTime departureTime,
    required Map<String, dynamic> rideDetails,
  }) async {
    try {
      await _firestore.collection('rides').add({
        'driverId': driverId,
        'driverName': rideDetails['driverName'] ?? 'Test Driver',
        'driverPhone': rideDetails['driverPhone'] ?? '+92300000000',
        'driverRating': rideDetails['driverRating'] ?? 4.5,
        'driverProfileImage': rideDetails['driverProfileImage'] ?? '',
        'university': rideDetails['university'] ?? 'LUMS',
        'department': rideDetails['department'] ?? 'Computer Science',
        'pickup': pickup.toMap(),
        'destination': destination.toMap(),
        'departureTime': Timestamp.fromDate(departureTime),
        'vehicleType': rideDetails['vehicleType'] ?? 'Car',
        'vehicleModel': rideDetails['vehicleModel'] ?? 'Honda Civic',
        'vehicleColor': rideDetails['vehicleColor'] ?? 'White',
        'vehiclePlate': rideDetails['vehiclePlate'] ?? 'ABC-123',
        'totalSeats': rideDetails['totalSeats'] ?? 4,
        'availableSeats': rideDetails['availableSeats'] ?? 3,
        'pricePerSeat': rideDetails['pricePerSeat'] ?? 100.0,
        'currency': 'PKR',
        'preferences': rideDetails['preferences'] ?? ['No Smoking'],
        'rideType': rideDetails['rideType'] ?? 'regular',
        'status': 'active',
        'passengers': [],
        'pendingRequests': [],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error creating mock ride: $e');
    }
  }
}
