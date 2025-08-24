import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class RideRepository {
  static RideRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Fetch active rides within 40km radius
  Stream<List<Map<String, dynamic>>> getActiveRidesWithinRadius({
    required double userLat,
    required double userLng,
    double radiusKm = 40.0,
  }) {
    return _db
        .collection('rides')
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snapshot) {
          final List<Map<String, dynamic>> rides = [];

          print('🔍 Found ${snapshot.docs.length} total rides in Firebase');

          for (final doc in snapshot.docs) {
            try {
              final data = doc.data();
              data['id'] = doc.id;

              // Check if ride has required data
              if (data['from'] != null &&
                  data['to'] != null &&
                  data['createdByName'] != null &&
                  data['time'] != null) {
                // For now, include all rides since we don't have lat/lng coordinates
                // In a real app, you'd calculate distance using lat/lng
                rides.add(data);
                print(
                  '✅ Added ride: ${data['createdByName']} - ${data['from']} to ${data['to']}',
                );
              } else {
                print('❌ Skipped ride ${doc.id}: Missing required fields');
              }
            } catch (e) {
              print('❌ Error parsing ride ${doc.id}: $e');
            }
          }

          print('📊 Total valid rides: ${rides.length}');

          // Sort by departure time (earliest first)
          rides.sort((a, b) {
            final aTime = a['time'] ?? '';
            final bTime = b['time'] ?? '';
            return aTime.compareTo(bTime);
          });

          return rides;
        });
  }

  // Create a ride request with notification
  Future<String> createRideRequest({
    required String rideId,
    required String passengerId,
    required String passengerName,
    required String passengerPhone,
    required String passengerEmail,
    String? passengerProfileImage,
    required String message,
  }) async {
    try {
      print('🚀 Creating ride request for ride: $rideId');

      // Create the ride request
      final requestRef = await _db.collection('ride_requests').add({
        'rideId': rideId,
        'passengerId': passengerId,
        'passengerName': passengerName,
        'passengerPhone': passengerPhone,
        'passengerEmail': passengerEmail,
        'passengerProfileImage': passengerProfileImage,
        'passengerRating': 5.0,
        'message': message,
        'requestedAt': FieldValue.serverTimestamp(),
        'status': 'pending',
        'passengerInfo': {
          'userId': passengerId,
          'name': passengerName,
          'phone': passengerPhone,
          'email': passengerEmail,
          'profileImage': passengerProfileImage,
        },
      });

      print('✅ Ride request created with ID: ${requestRef.id}');

      // Get ride details to send notification to ride creator
      final rideDoc = await _db.collection('rides').doc(rideId).get();
      if (rideDoc.exists) {
        final rideData = rideDoc.data()!;
        final rideCreatorId = rideData['createdBy'] ?? '';

        print('📧 Sending notification to ride creator: $rideCreatorId');

        // Create notification for ride creator
        await _db.collection('notifications').add({
          'userId': rideCreatorId,
          'title': 'New Ride Request',
          'body': '$passengerName wants to book your ride',
          'type': 'ride_request',
          'rideId': rideId,
          'requestId': requestRef.id,
          'passengerId': passengerId,
          'passengerName': passengerName,
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });

        print('✅ Notification sent successfully');
      } else {
        print('❌ Ride document not found: $rideId');
      }

      return requestRef.id;
    } catch (e) {
      print('❌ Error creating ride request: $e');
      throw 'Failed to create ride request: $e';
    }
  }

  // Accept ride request
  Future<void> acceptRideRequest(String requestId) async {
    try {
      print('✅ Accepting ride request: $requestId');

      await _db.collection('ride_requests').doc(requestId).update({
        'status': 'accepted',
        'acceptedAt': FieldValue.serverTimestamp(),
      });

      // Get request details to notify passenger
      final requestDoc =
          await _db.collection('ride_requests').doc(requestId).get();
      if (requestDoc.exists) {
        final requestData = requestDoc.data()!;
        final passengerId = requestData['passengerId'];
        final rideId = requestData['rideId'];

        // Get ride details
        final rideDoc = await _db.collection('rides').doc(rideId).get();
        if (rideDoc.exists) {
          final rideData = rideDoc.data()!;
          final rideCreatorName = rideData['createdByName'] ?? 'Ride Creator';

          // Create notification for passenger
          await _db.collection('notifications').add({
            'userId': passengerId,
            'title': 'Ride Request Accepted',
            'body': '$rideCreatorName accepted your ride request',
            'type': 'ride_accepted',
            'rideId': rideId,
            'requestId': requestId,
            'isRead': false,
            'createdAt': FieldValue.serverTimestamp(),
          });

          print('✅ Acceptance notification sent to passenger');
        }
      }
    } catch (e) {
      print('❌ Error accepting ride request: $e');
      throw 'Failed to accept ride request: $e';
    }
  }

  // Reject ride request
  Future<void> rejectRideRequest(String requestId, String reason) async {
    try {
      print('❌ Rejecting ride request: $requestId');

      await _db.collection('ride_requests').doc(requestId).update({
        'status': 'rejected',
        'rejectionReason': reason,
        'rejectedAt': FieldValue.serverTimestamp(),
      });

      // Get request details to notify passenger
      final requestDoc =
          await _db.collection('ride_requests').doc(requestId).get();
      if (requestDoc.exists) {
        final requestData = requestDoc.data()!;
        final passengerId = requestData['passengerId'];
        final rideId = requestData['rideId'];

        // Get ride details
        final rideDoc = await _db.collection('rides').doc(rideId).get();
        if (rideDoc.exists) {
          final rideData = rideDoc.data()!;
          final rideCreatorName = rideData['createdByName'] ?? 'Ride Creator';

          // Create notification for passenger
          await _db.collection('notifications').add({
            'userId': passengerId,
            'title': 'Ride Request Rejected',
            'body': '$rideCreatorName rejected your ride request',
            'type': 'ride_rejected',
            'rideId': rideId,
            'requestId': requestId,
            'reason': reason,
            'isRead': false,
            'createdAt': FieldValue.serverTimestamp(),
          });

          print('✅ Rejection notification sent to passenger');
        }
      }
    } catch (e) {
      print('❌ Error rejecting ride request: $e');
      throw 'Failed to reject ride request: $e';
    }
  }

  // Get ride by ID
  Future<Map<String, dynamic>?> getRideById(String rideId) async {
    try {
      final doc = await _db.collection('rides').doc(rideId).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return data;
      }
      return null;
    } catch (e) {
      throw 'Failed to get ride: $e';
    }
  }

  // Update ride status
  Future<void> updateRideStatus(String rideId, String status) async {
    try {
      await _db.collection('rides').doc(rideId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Failed to update ride status: $e';
    }
  }

  // Get notifications for user
  Stream<List<Map<String, dynamic>>> getUserNotifications(String userId) {
    return _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => {...doc.data(), 'id': doc.id})
                  .toList(),
        );
  }

  // Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _db.collection('notifications').doc(notificationId).update({
        'isRead': true,
      });
    } catch (e) {
      throw 'Failed to mark notification as read: $e';
    }
  }

  // Get ride requests for a specific ride
  Stream<List<Map<String, dynamic>>> getRideRequestsForRide(String rideId) {
    return _db
        .collection('ride_requests')
        .where('rideId', isEqualTo: rideId)
        .where('status', isEqualTo: 'pending')
        .orderBy('requestedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => {...doc.data(), 'id': doc.id})
                  .toList(),
        );
  }

  // Get all ride requests for rides created by a user
  Stream<List<Map<String, dynamic>>> getRideRequestsForUser(String userId) {
    return _db
        .collection('rides')
        .where('createdBy', isEqualTo: userId)
        .where('status', isEqualTo: 'active')
        .snapshots()
        .asyncMap((ridesSnapshot) async {
          final rideIds = ridesSnapshot.docs.map((doc) => doc.id).toList();

          if (rideIds.isEmpty) return [];

          final requestsSnapshot =
              await _db
                  .collection('ride_requests')
                  .where('rideId', whereIn: rideIds)
                  .where('status', isEqualTo: 'pending')
                  .orderBy('requestedAt', descending: true)
                  .get();

          return requestsSnapshot.docs
              .map((doc) => {...doc.data(), 'id': doc.id})
              .toList();
        });
  }
}
