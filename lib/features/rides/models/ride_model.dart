import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../services/location_service.dart';

class RideModel {
  final String id;
  final String status;

  // Driver Information
  final DriverInfo driver;
  final VehicleInfo vehicle;

  // Route & Location Details
  final RideLocation pickup;
  final RideLocation destination;
  final List<RideWaypoint> waypoints;
  final String routePolyline;
  final double estimatedDistance;
  final int estimatedDuration;

  // Timing
  final DateTime departureTime;
  final DateTime? actualDepartureTime;
  final DateTime? estimatedArrival;
  final bool isFlexibleTime;

  // Capacity & Pricing
  final int totalSeats;
  final int availableSeats;
  final double pricePerSeat;
  final String currency;
  final bool isPriceNegotiable;

  // Ride Details
  final List<String> preferences;
  final RideType rideType;
  final bool allowsIntermediateStops;
  final bool allowsLuggage;

  // Safety & Verification
  final String university;
  final String department;
  final bool isStudentVerified;
  final bool requiresStudentVerification;
  final bool isLiveTrackingEnabled;
  final List<TrackingPoint> routeTracking;
  final List<EmergencyContact> emergencyContacts;
  final bool hasPanicButton;

  // Passengers & Requests
  final List<RidePassenger> passengers;
  final List<RideRequest> pendingRequests;
  final List<String> rejectedRequests;

  // Recurring Rides
  final bool isRecurring;
  final List<String> recurringDays;

  // Payment & Coins
  final PaymentInfo payment;
  final RaahiCoinsInfo coinsInfo;

  // Driver Rating & History
  final double driverRating;
  final int completedRides;

  // Metadata
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  RideModel({
    required this.id,
    required this.status,
    required this.driver,
    required this.vehicle,
    required this.pickup,
    required this.destination,
    required this.waypoints,
    required this.routePolyline,
    required this.estimatedDistance,
    required this.estimatedDuration,
    required this.departureTime,
    this.actualDepartureTime,
    this.estimatedArrival,
    required this.isFlexibleTime,
    required this.totalSeats,
    required this.availableSeats,
    required this.pricePerSeat,
    required this.currency,
    required this.isPriceNegotiable,
    required this.preferences,
    required this.rideType,
    required this.allowsIntermediateStops,
    required this.allowsLuggage,
    required this.university,
    required this.department,
    required this.isStudentVerified,
    required this.requiresStudentVerification,
    required this.isLiveTrackingEnabled,
    required this.routeTracking,
    required this.emergencyContacts,
    required this.hasPanicButton,
    required this.passengers,
    required this.pendingRequests,
    required this.rejectedRequests,
    required this.isRecurring,
    required this.recurringDays,
    required this.payment,
    required this.coinsInfo,
    required this.driverRating,
    required this.completedRides,
    required this.createdAt,
    required this.updatedAt,
    required this.metadata,
  });

  factory RideModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;

    return RideModel(
      id: doc.id,
      status: d['status'] ?? 'active',
      driver: DriverInfo.fromMap(d['driver'] ?? {}),
      vehicle: VehicleInfo.fromMap(d['vehicle'] ?? {}),
      pickup: RideLocation.fromMap(d['pickup'] ?? {}),
      destination: RideLocation.fromMap(d['destination'] ?? {}),
      waypoints:
          (d['waypoints'] as List? ?? [])
              .map((e) => RideWaypoint.fromMap(e))
              .toList(),
      routePolyline: d['routePolyline'] ?? '',
      estimatedDistance: (d['estimatedDistance'] ?? 0).toDouble(),
      estimatedDuration: d['estimatedDuration'] ?? 0,
      departureTime: (d['departureTime'] as Timestamp).toDate(),
      isFlexibleTime: d['isFlexibleTime'] ?? false,
      totalSeats: d['totalSeats'] ?? 4,
      availableSeats: d['availableSeats'] ?? 4,
      pricePerSeat: (d['pricePerSeat'] ?? 0).toDouble(),
      currency: d['currency'] ?? 'PKR',
      isPriceNegotiable: d['isPriceNegotiable'] ?? false,
      preferences: List<String>.from(d['preferences'] ?? []),
      rideType: RideType.fromString(d['rideType'] ?? 'regular'),
      allowsIntermediateStops: d['allowsIntermediateStops'] ?? false,
      allowsLuggage: d['allowsLuggage'] ?? true,
      university: d['university'] ?? '',
      department: d['department'] ?? '',
      isStudentVerified: d['isStudentVerified'] ?? false,
      requiresStudentVerification: d['requiresStudentVerification'] ?? true,
      isLiveTrackingEnabled: d['isLiveTrackingEnabled'] ?? false,
      routeTracking:
          (d['routeTracking'] as List? ?? [])
              .map((e) => TrackingPoint.fromMap(e))
              .toList(),
      emergencyContacts:
          (d['emergencyContacts'] as List? ?? [])
              .map((e) => EmergencyContact.fromMap(e))
              .toList(),
      hasPanicButton: d['hasPanicButton'] ?? true,
      passengers:
          (d['passengers'] as List? ?? [])
              .map((e) => RidePassenger.fromMap(e))
              .toList(), // 👈 now supplied
      pendingRequests:
          (d['pendingRequests'] as List? ?? [])
              .map((e) => RideRequest.fromMap(e))
              .toList(), // 👈 now supplied
      rejectedRequests: List<String>.from(d['rejectedRequests'] ?? []),
      isRecurring: d['isRecurring'] ?? false,
      recurringDays: List<String>.from(d['recurringDays'] ?? []),
      payment: PaymentInfo.fromMap(d['payment'] ?? {}), // 👈 now supplied
      coinsInfo: RaahiCoinsInfo.fromMap(d['coinsInfo'] ?? {}),
      driverRating: (d['driverRating'] ?? 5).toDouble(),
      completedRides: d['completedRides'] ?? 0,
      createdAt: (d['createdAt'] as Timestamp).toDate(),
      updatedAt: (d['updatedAt'] as Timestamp).toDate(),
      metadata: Map<String, dynamic>.from(d['metadata'] ?? {}),
    );
  }

  // Business logic methods
  bool get isActive => status == 'active';
  bool get hasAvailableSeats => availableSeats > 0;
  bool get isFull => availableSeats <= 0;

  double get totalEarnings => pricePerSeat * (totalSeats - availableSeats);

  bool get isDepartingSoon {
    final now = DateTime.now();
    final diff = departureTime.difference(now).inMinutes;
    return diff > 0 && diff <= 30;
  }

  /// Check if ride matches search criteria
  bool matchesSearchCriteria({
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
    // Check if ride is active and has seats
    if (!isActive || !hasAvailableSeats) return false;

    // Check pickup distance
    final pickupDistance = pickup.distanceTo(
      searchPickup.latitude,
      searchPickup.longitude,
    );
    if (pickupDistance > maxPickupDistance) return false;

    // Check destination distance
    final destDistance = destination.distanceTo(
      searchDestination.latitude,
      searchDestination.longitude,
    );
    if (destDistance > maxDestinationDistance) return false;

    // Check time difference
    final timeDiff = departureTime.difference(searchTime).inMinutes.abs();
    if (timeDiff > maxTimeDifferenceMinutes) return false;

    // Check vehicle type filter
    if (vehicleTypeFilter != null &&
        vehicle.type.toLowerCase() != vehicleTypeFilter.toLowerCase()) {
      return false;
    }

    // Check price filter
    if (maxPriceFilter != null && pricePerSeat > maxPriceFilter) {
      return false;
    }

    // Check preferences filter
    if (preferenceFilters != null && preferenceFilters.isNotEmpty) {
      final hasMatch = preferenceFilters.any(
        (pref) => preferences.contains(pref),
      );
      if (!hasMatch) return false;
    }

    return true;
  }
}

// Enums and other supporting classes
enum LocationType {
  university,
  mall,
  restaurant,
  hospital,
  airport,
  station,
  home,
  current,
  other;

  static LocationType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'university':
        return LocationType.university;
      case 'mall':
        return LocationType.mall;
      case 'restaurant':
        return LocationType.restaurant;
      case 'hospital':
        return LocationType.hospital;
      case 'airport':
        return LocationType.airport;
      case 'station':
        return LocationType.station;
      case 'home':
        return LocationType.home;
      case 'current':
        return LocationType.current;
      default:
        return LocationType.other;
    }
  }
}

enum RideType {
  regular,
  express,
  comfort;

  static RideType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'express':
        return RideType.express;
      case 'comfort':
        return RideType.comfort;
      default:
        return RideType.regular;
    }
  }
}

// Add all other supporting classes (DriverInfo, VehicleInfo, etc.)
class DriverInfo {
  final String userId;
  final String name;
  final String phone;
  final String email;
  final String profileImageUrl;
  final double rating;
  final int totalRides;
  final String studentId;
  final bool isVerified;
  final DateTime joinedDate;

  DriverInfo({
    required this.userId,
    required this.name,
    required this.phone,
    required this.email,
    required this.profileImageUrl,
    required this.rating,
    required this.totalRides,
    required this.studentId,
    required this.isVerified,
    required this.joinedDate,
  });

  factory DriverInfo.fromMap(Map<String, dynamic> map) {
    return DriverInfo(
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      profileImageUrl: map['profileImageUrl'] ?? '',
      rating: (map['rating'] ?? 5.0).toDouble(),
      totalRides: map['totalRides'] ?? 0,
      studentId: map['studentId'] ?? '',
      isVerified: map['isVerified'] ?? false,
      joinedDate:
          map['joinedDate'] != null
              ? (map['joinedDate'] as Timestamp).toDate()
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'phone': phone,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'rating': rating,
      'totalRides': totalRides,
      'studentId': studentId,
      'isVerified': isVerified,
      'joinedDate': Timestamp.fromDate(joinedDate),
    };
  }
}

class VehicleInfo {
  final String type;
  final String brand;
  final String model;
  final String color;
  final String plateNumber;
  final int year;
  final bool hasAC;
  final bool hasWiFi;
  final List<String> features;
  final List<String> photos;

  VehicleInfo({
    required this.type,
    required this.brand,
    required this.model,
    required this.color,
    required this.plateNumber,
    required this.year,
    required this.hasAC,
    required this.hasWiFi,
    required this.features,
    required this.photos,
  });

  factory VehicleInfo.fromMap(Map<String, dynamic> map) {
    return VehicleInfo(
      type: map['type'] ?? '',
      brand: map['brand'] ?? '',
      model: map['model'] ?? '',
      color: map['color'] ?? '',
      plateNumber: map['plateNumber'] ?? '',
      year: map['year'] ?? DateTime.now().year,
      hasAC: map['hasAC'] ?? false,
      hasWiFi: map['hasWiFi'] ?? false,
      features: List<String>.from(map['features'] ?? []),
      photos: List<String>.from(map['photos'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'brand': brand,
      'model': model,
      'color': color,
      'plateNumber': plateNumber,
      'year': year,
      'hasAC': hasAC,
      'hasWiFi': hasWiFi,
      'features': features,
      'photos': photos,
    };
  }
}

// Add placeholder classes for other supporting types
class RideWaypoint {
  RideWaypoint();
  factory RideWaypoint.fromMap(Map<String, dynamic> map) => RideWaypoint();
  Map<String, dynamic> toMap() => {};
}

class TrackingPoint {
  TrackingPoint();
  factory TrackingPoint.fromMap(Map<String, dynamic> map) => TrackingPoint();
  Map<String, dynamic> toMap() => {};
}

class EmergencyContact {
  EmergencyContact();
  factory EmergencyContact.fromMap(Map<String, dynamic> map) =>
      EmergencyContact();
  Map<String, dynamic> toMap() => {};
}

class RidePassenger {
  RidePassenger();
  factory RidePassenger.fromMap(Map<String, dynamic> map) => RidePassenger();
  Map<String, dynamic> toMap() => {};
}

class RideRequest {
  RideRequest();
  factory RideRequest.fromMap(Map<String, dynamic> map) => RideRequest();
  Map<String, dynamic> toMap() => {};
}

class PaymentInfo {
  PaymentInfo();
  factory PaymentInfo.fromMap(Map<String, dynamic> map) => PaymentInfo();
  Map<String, dynamic> toMap() => {};
}

class RaahiCoinsInfo {
  RaahiCoinsInfo();
  factory RaahiCoinsInfo.fromMap(Map<String, dynamic> map) => RaahiCoinsInfo();
  Map<String, dynamic> toMap() => {};
}
