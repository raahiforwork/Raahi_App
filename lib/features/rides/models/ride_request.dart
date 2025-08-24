// models/ride_request.dart
import 'package:cloud_firestore/cloud_firestore.dart';


class RideRequest {
  final String id;
  final String rideId;
  final String passengerId;
  final String passengerName;
  final String passengerPhone;
  final String passengerEmail;
  final String? passengerProfileImage;
  final double passengerRating;
  final String message;
  final DateTime requestedAt;
  final RequestStatus status;
  final String? rejectionReason;
  final Map<String, dynamic> passengerInfo;

  RideRequest({
    required this.id,
    required this.rideId,
    required this.passengerId,
    required this.passengerName,
    required this.passengerPhone,
    required this.passengerEmail,
    this.passengerProfileImage,
    required this.passengerRating,
    required this.message,
    required this.requestedAt,
    required this.status,
    this.rejectionReason,
    required this.passengerInfo,
  });

  factory RideRequest.fromMap(Map<String, dynamic> map) {
    return RideRequest(
      id: map['id'] ?? '',
      rideId: map['rideId'] ?? '',
      passengerId: map['passengerId'] ?? '',
      passengerName: map['passengerName'] ?? '',
      passengerPhone: map['passengerPhone'] ?? '',
      passengerEmail: map['passengerEmail'] ?? '',
      passengerProfileImage: map['passengerProfileImage'],
      passengerRating: (map['passengerRating'] ?? 5.0).toDouble(),
      message: map['message'] ?? '',
      requestedAt: map['requestedAt'] is Timestamp
          ? (map['requestedAt'] as Timestamp).toDate()
          : DateTime.parse(map['requestedAt'] ?? DateTime.now().toIso8601String()),
      status: RequestStatus.fromString(map['status'] ?? 'pending'),
      rejectionReason: map['rejectionReason'],
      passengerInfo: Map<String, dynamic>.from(map['passengerInfo'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'rideId': rideId,
      'passengerId': passengerId,
      'passengerName': passengerName,
      'passengerPhone': passengerPhone,
      'passengerEmail': passengerEmail,
      'passengerProfileImage': passengerProfileImage,
      'passengerRating': passengerRating,
      'message': message,
      'requestedAt': Timestamp.fromDate(requestedAt),
      'status': status.toString(),
      'rejectionReason': rejectionReason,
      'passengerInfo': passengerInfo,
    };
  }

  // Helper methods
  bool get isPending => status == RequestStatus.pending;
  bool get isAccepted => status == RequestStatus.accepted;
  bool get isRejected => status == RequestStatus.rejected;

  RideRequest copyWith({
    RequestStatus? status,
    String? rejectionReason,
  }) {
    return RideRequest(
      id: id,
      rideId: rideId,
      passengerId: passengerId,
      passengerName: passengerName,
      passengerPhone: passengerPhone,
      passengerEmail: passengerEmail,
      passengerProfileImage: passengerProfileImage,
      passengerRating: passengerRating,
      message: message,
      requestedAt: requestedAt,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      passengerInfo: passengerInfo,
    );
  }
}

enum RequestStatus {
  pending,
  accepted,
  rejected;

  static RequestStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'accepted':
        return RequestStatus.accepted;
      case 'rejected':
        return RequestStatus.rejected;
      default:
        return RequestStatus.pending;
    }
  }

  @override
  String toString() {
    switch (this) {
      case RequestStatus.accepted:
        return 'accepted';
      case RequestStatus.rejected:
        return 'rejected';
      default:
        return 'pending';
    }
  }
}
