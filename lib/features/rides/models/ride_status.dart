/// RideStatus
/// ----------
/// Centralised enum for every possible lifecycle state a ride can be in.
/// Import this file wherever you need to reference a ride’s status.
///
/// Example:
/// ```
/// if (ride.status == RideStatus.active) { … }
/// ```
enum RideStatus {
  /// Driver has published the ride and it is open for requests / bookings.
  active,

  /// Driver has accepted at least one request, is on the way to pick-ups.
  inProgress,

  /// Ride has been completed and all passengers were dropped off.
  completed,

  /// Driver or system cancelled the ride before completion.
  cancelled,

  /// Ride expired because the scheduled departure time passed with no action.
  expired,
}

extension RideStatusX on RideStatus {
  /// Convert enum value to its canonical lowercase string—ideal for storing
  /// in Firestore.
  String get asString => toString().split('.').last;

  /// Human-readable text for UI.
  String get label {
    switch (this) {
      case RideStatus.active:
        return 'Active';
      case RideStatus.inProgress:
        return 'In-progress';
      case RideStatus.completed:
        return 'Completed';
      case RideStatus.cancelled:
        return 'Cancelled';
      case RideStatus.expired:
        return 'Expired';
    }
  }

  /// Convert a string (e.g. from Firestore) back to `RideStatus`.
  static RideStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'active':
        return RideStatus.active;
      case 'inprogress':
      case 'in_progress':
      case 'in-progress':
        return RideStatus.inProgress;
      case 'completed':
        return RideStatus.completed;
      case 'cancelled':
        return RideStatus.cancelled;
      case 'expired':
        return RideStatus.expired;
      default:
      // Fallback—treat unknown values as cancelled to avoid unintended
      // “active” rides showing up.
        return RideStatus.cancelled;
    }
  }
}
