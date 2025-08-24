import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RActiveRideCard extends StatelessWidget {
  const RActiveRideCard({
    super.key,
    required this.driverName,
    required this.pickup,
    required this.destination,
    required this.time,
    required this.avatarImage,
    required this.onBookNow,
  });

  final String driverName;
  final String pickup;
  final String destination;
  final String time;
  final String avatarImage;
  final VoidCallback onBookNow;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar with fallback
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey.shade700,
                child:
                    avatarImage.startsWith('http')
                        ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: avatarImage,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            placeholder:
                                (context, url) => const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 20,
                                ),
                            errorWidget:
                                (context, url, error) => const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 20,
                                ),
                          ),
                        )
                        : ClipOval(
                          child: Image.asset(
                            avatarImage,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 20,
                                ),
                          ),
                        ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  driverName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: onBookNow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'book now',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'time - $time',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pick-up: $pickup',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Destination: $destination',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.directions_car, color: Colors.white, size: 24),
            ],
          ),
        ],
      ),
    );
  }
}
