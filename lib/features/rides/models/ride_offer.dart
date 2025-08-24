// models/ride_offer.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class RideOffer {
  final String id;
  final String driverId;
  final String driverName;
  final String phone;
  final String? profileImage;
  final double rating;
  final String startAddress;
  final String endAddress;
  final double startLat;
  final double startLng;
  final double endLat;
  final double endLng;
  final DateTime departureTime;
  final DateTime createdAt;
  final int availableSeats;
  final int bookedSeats;
  final double pricePerSeat;
  final String vehicleInfo;
  final String vehicleType;
  final String status;
  final String? description;
  final bool allowSmoking;
  final bool allowPets;
  final bool isRecurring;
  final List<String> bookedBy;
  final double totalDistance;
  final int estimatedDuration;

  RideOffer({
    required this.id,
    required this.driverId,
    required this.driverName,
    required this.phone,
    this.profileImage,
    required this.rating,
    required this.startAddress,
    required this.endAddress,
    required this.startLat,
    required this.startLng,
    required this.endLat,
    required this.endLng,
    required this.departureTime,
    required this.createdAt,
    required this.availableSeats,
    this.bookedSeats = 0,
    required this.pricePerSeat,
    required this.vehicleInfo,
    required this.vehicleType,
    this.status = 'active',
    this.description,
    this.allowSmoking = false,
    this.allowPets = false,
    this.isRecurring = false,
    this.bookedBy = const [],
    this.totalDistance = 0.0,
    this.estimatedDuration = 0,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'driverId': driverId,
      'driverName': driverName,
      'phone': phone,
      'profileImage': profileImage,
      'rating': rating,
      'startAddress': startAddress,
      'endAddress': endAddress,
      'startLat': startLat,
      'startLng': startLng,
      'endLat': endLat,
      'endLng': endLng,
      'departureTime': Timestamp.fromDate(departureTime),
      'createdAt': Timestamp.fromDate(createdAt),
      'availableSeats': availableSeats,
      'bookedSeats': bookedSeats,
      'pricePerSeat': pricePerSeat,
      'vehicleInfo': vehicleInfo,
      'vehicleType': vehicleType,
      'status': status,
      'description': description,
      'allowSmoking': allowSmoking,
      'allowPets': allowPets,
      'isRecurring': isRecurring,
      'bookedBy': bookedBy,
      'totalDistance': totalDistance,
      'estimatedDuration': estimatedDuration,
    };
  }

  factory RideOffer.fromFirestore(Map<String, dynamic> doc, String docId) {
    return RideOffer(
      id: docId,
      driverId: doc['driverId'] ?? '',
      driverName: doc['driverName'] ?? '',
      phone: doc['phone'] ?? '',
      profileImage: doc['profileImage'],
      rating: (doc['rating'] ?? 4.5).toDouble(),
      startAddress: doc['startAddress'] ?? '',
      endAddress: doc['endAddress'] ?? '',
      startLat: (doc['startLat'] ?? 0.0).toDouble(),
      startLng: (doc['startLng'] ?? 0.0).toDouble(),
      endLat: (doc['endLat'] ?? 0.0).toDouble(),
      endLng: (doc['endLng'] ?? 0.0).toDouble(),
      departureTime: doc['departureTime'] != null
          ? (doc['departureTime'] as Timestamp).toDate()
          : DateTime.now(),
      createdAt: doc['createdAt'] != null
          ? (doc['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      availableSeats: doc['availableSeats'] ?? 1,
      bookedSeats: doc['bookedSeats'] ?? 0,
      pricePerSeat: (doc['pricePerSeat'] ?? 0.0).toDouble(),
      vehicleInfo: doc['vehicleInfo'] ?? '',
      vehicleType: doc['vehicleType'] ?? 'Car',
      status: doc['status'] ?? 'active',
      description: doc['description'],
      allowSmoking: doc['allowSmoking'] ?? false,
      allowPets: doc['allowPets'] ?? false,
      isRecurring: doc['isRecurring'] ?? false,
      bookedBy: List<String>.from(doc['bookedBy'] ?? []),
      totalDistance: (doc['totalDistance'] ?? 0.0).toDouble(),
      estimatedDuration: doc['estimatedDuration'] ?? 0,
    );
  }
}
