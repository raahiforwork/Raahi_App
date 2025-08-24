import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../controllers/location_search_controller.dart';
import '../../../../utils/constants/colors.dart';

class LocationSearchScreen extends StatelessWidget {
  final bool isPickupLocation;
  final String title;

  const LocationSearchScreen({
    Key? key,
    required this.isPickupLocation,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LocationSearchController());

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Iconsax.arrow_left,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(controller),
          if (isPickupLocation) _buildCurrentLocationOption(controller),
          Expanded(child: _buildSearchResults(controller)),
        ],
      ),
    );
  }

  Widget _buildSearchBar(LocationSearchController controller) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(Get.context!).dividerColor),
      ),
      child: TextField(
        autofocus: true,
        onChanged: controller.searchLocations,
        decoration: InputDecoration(
          hintText: 'Search for a location...',
          border: InputBorder.none,
          hintStyle: TextStyle(
            color: Theme.of(
              Get.context!,
            ).textTheme.bodySmall?.color?.withOpacity(0.6),
          ),
          prefixIcon: Icon(
            Iconsax.search_normal,
            color: Theme.of(
              Get.context!,
            ).textTheme.bodySmall?.color?.withOpacity(0.6),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentLocationOption(LocationSearchController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: RColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Iconsax.location, color: RColors.primary),
        ),
        title: Text(
          'Use current location',
          style: Theme.of(Get.context!).textTheme.bodyLarge,
        ),
        subtitle: Text(
          'GPS will find your location',
          style: TextStyle(
            color: Theme.of(
              Get.context!,
            ).textTheme.bodySmall?.color?.withOpacity(0.7),
          ),
        ),
        onTap: () async {
          try {
            // Ensure services enabled
            final serviceEnabled = await Geolocator.isLocationServiceEnabled();
            if (!serviceEnabled) {
              Get.snackbar(
                'Location Disabled',
                'Please enable location services',
              );
              await Geolocator.openLocationSettings();
              return;
            }

            // Permissions
            LocationPermission permission = await Geolocator.checkPermission();
            if (permission == LocationPermission.denied) {
              permission = await Geolocator.requestPermission();
              if (permission == LocationPermission.denied) {
                Get.snackbar(
                  'Permission Denied',
                  'Location permissions are denied',
                );
                return;
              }
            }
            if (permission == LocationPermission.deniedForever) {
              Get.snackbar(
                'Permission Denied',
                'Enable location permission from Settings',
              );
              await Geolocator.openAppSettings();
              return;
            }

            // Position
            Position position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high,
              timeLimit: const Duration(seconds: 15),
            );

            String address = 'Your current location';
            String? state;
            try {
              final placemarks = await placemarkFromCoordinates(
                position.latitude,
                position.longitude,
              );
              if (placemarks.isNotEmpty) {
                final p = placemarks.first;
                state = p.administrativeArea;
                address = [
                      p.name,
                      p.subLocality,
                      p.locality,
                      p.administrativeArea,
                      p.country,
                    ]
                    .whereType<String>()
                    .where((e) => e.trim().isNotEmpty)
                    .join(', ');
              }
            } catch (_) {}

            Get.back(
              result: {
                'name': 'Current Location',
                'address': address,
                'latitude': position.latitude,
                'longitude': position.longitude,
                'placeId': 'current_location',
                'type': 'current_location',
                'additionalInfo': {if (state != null) 'state': state},
              },
            );
          } catch (e) {
            Get.snackbar('Failed to fetch location', '$e');
          }
        },
      ),
    );
  }

  Widget _buildSearchResults(LocationSearchController controller) {
    return Obx(() {
      if (controller.isSearching.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.searchResults.isEmpty &&
          controller.query.value.isNotEmpty) {
        return Center(
          child: Text(
            'No locations found',
            style: TextStyle(
              color: Theme.of(
                Get.context!,
              ).textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
          ),
        );
      }

      if (controller.searchResults.isEmpty) {
        return _buildDefaultSuggestions(controller);
      }

      return ListView.builder(
        itemCount: controller.searchResults.length,
        itemBuilder: (context, index) {
          final location = controller.searchResults[index];
          return ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: RColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Iconsax.location, color: RColors.primary),
            ),
            title: Text(location['name'] ?? ''),
            subtitle: Text(
              location['address'] ?? '',
              style: TextStyle(
                color: Theme.of(
                  Get.context!,
                ).textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ),
            onTap: () async {
              // Fetch place details (with state), with geocoding fallback
              final details = await controller.getPlaceDetails(
                location['placeId'],
                fallbackName: location['name'],
                fallbackAddress: location['address'],
              );
              if (details != null) {
                Get.back(result: details);
              } else {
                Get.snackbar('Error', 'Failed to fetch location details');
              }
            },
          );
        },
      );
    });
  }

  Widget _buildDefaultSuggestions(LocationSearchController controller) {
    final suggestions = [
      {
        'name': 'LUMS University',
        'address': 'DHA Phase 5, Lahore',
        'latitude': 31.5204,
        'longitude': 74.3587,
        'placeId': 'lums_university',
        'type': 'university',
        'additionalInfo': {},
      },
      {
        'name': 'Emporium Mall',
        'address': 'Johar Town, Lahore',
        'latitude': 31.4697,
        'longitude': 74.2728,
        'placeId': 'emporium_mall',
        'type': 'mall',
        'additionalInfo': {},
      },
      {
        'name': 'Liberty Market',
        'address': 'Gulberg III, Lahore',
        'latitude': 31.5497,
        'longitude': 74.3436,
        'placeId': 'liberty_market',
        'type': 'market',
        'additionalInfo': {},
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Popular Destinations',
            style: Theme.of(
              Get.context!,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              final location = suggestions[index];
              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: RColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Iconsax.location, color: RColors.primary),
                ),
                title: Text(location['name'] as String),
                subtitle: Text(
                  location['address'] as String,
                  style: TextStyle(
                    color: Theme.of(
                      Get.context!,
                    ).textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ),
                onTap: () => Get.back(result: location),
              );
            },
          ),
        ),
      ],
    );
  }
}
