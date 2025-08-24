import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../models/ride_model.dart';
import '../../../../utils/constants/colors.dart';
import '../models/ride_status.dart';

class RideCard extends StatelessWidget {
  final RideModel ride;
  final VoidCallback onTap;
  final VoidCallback onRequest;

  const RideCard({
    Key? key,
    required this.ride,
    required this.onTap,
    required this.onRequest,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: RColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Driver Info and Time
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: RColors.primary.withOpacity(0.1),
                      backgroundImage:
                          ride.driver.name.isNotEmpty
                              ? NetworkImage(ride.driver.name)
                              : null,
                      child:
                          ride.driver.name.isEmpty
                              ? Text(
                                ride.driver.name.isNotEmpty
                                    ? ride.driver.name[0].toUpperCase()
                                    : 'D',
                                style: const TextStyle(
                                  color: RColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                              : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ride.driver.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: RColors.textPrimary,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Iconsax.star1,
                                size: 14,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                ride.driver.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: RColors.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: RColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  ride.driver.name,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: RColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          DateFormat('HH:mm').format(ride.departureTime),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: RColors.textPrimary,
                          ),
                        ),
                        Text(
                          DateFormat('MMM dd').format(ride.departureTime),
                          style: const TextStyle(
                            fontSize: 12,
                            color: RColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Route Information
                Row(
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: RColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(
                          width: 2,
                          height: 30,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                RColors.success.withOpacity(0.7),
                                RColors.error.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: RColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ride.pickup.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: RColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            ride.destination.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: RColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Vehicle and Price Info
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: RColors.lightContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getVehicleIcon(ride.vehicle.type),
                            size: 14,
                            color: RColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${ride.vehicle.color} ${ride.vehicle.model}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: RColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: RColors.info.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Iconsax.user,
                            size: 14,
                            color: RColors.info,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${ride.availableSeats} seats',
                            style: const TextStyle(
                              fontSize: 12,
                              color: RColors.info,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: RColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '₨${ride.pricePerSeat.toInt()}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: RColors.success,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                // Ride Status Indicator
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStatusIndicator(),
                    const SizedBox(width: 8),
                    if (ride.isFlexibleTime)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: RColors.warning.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Flexible Time',
                          style: TextStyle(
                            fontSize: 10,
                            color: RColors.warning,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    const Spacer(),
                    if (ride.vehicle.hasAC)
                      const Icon(Iconsax.wind, size: 16, color: RColors.info),
                  ],
                ),

                // Preferences
                if (ride.preferences.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children:
                        ride.preferences.take(3).map((pref) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: RColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _getPreferenceLabel(pref),
                              style: const TextStyle(
                                fontSize: 10,
                                color: RColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ],

                const SizedBox(height: 16),

                // Request Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: ride.hasAvailableSeats ? onRequest : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          ride.hasAvailableSeats
                              ? RColors.primary
                              : RColors.grey,
                      foregroundColor: RColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: ride.hasAvailableSeats ? 2 : 0,
                    ),
                    child: Text(
                      ride.hasAvailableSeats ? 'Request to Join' : 'Ride Full',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    // Assign default values to ensure all code paths are covered
    Color statusColor = RColors.success;
    String statusText = 'Active';
    if (ride.status == RideStatus.inProgress) {
      statusColor = RColors.warning;
      statusText = 'In Progress';
    } else if (ride.status == RideStatus.completed) {
      statusColor = RColors.info;
      statusText = 'Completed';
    } else if (ride.status == RideStatus.cancelled) {
      statusColor = RColors.error;
      statusText = 'Cancelled';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 10,
              color: statusColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getVehicleIcon(String vehicleType) {
    switch (vehicleType.toLowerCase()) {
      case 'car':
      case 'sedan':
      case 'hatchback':
        return Iconsax.car;
      case 'suv':
        return Iconsax.truck;
      case 'motorcycle':
      case 'bike':
        return Iconsax
            .car; // You can replace with a motorcycle icon if available
      case 'van':
        return Iconsax.bus;
      default:
        return Iconsax.car;
    }
  }

  String _getPreferenceLabel(String preference) {
    switch (preference.toLowerCase()) {
      case 'nosmoking':
        return 'No Smoking';
      case 'musicok':
        return 'Music OK';
      case 'petfriendly':
        return 'Pet Friendly';
      case 'quiet':
        return 'Quiet';
      case 'ac':
        return 'AC';
      case 'wifi':
        return 'WiFi';
      default:
        return preference;
    }
  }
}
