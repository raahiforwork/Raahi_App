import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../controllers/dynamic_location_controller.dart';
import '../../../../utils/constants/colors.dart';

class DynamicLocationSearchScreen extends StatelessWidget {
  final bool isPickupLocation;
  final String title;

  const DynamicLocationSearchScreen({
    Key? key,
    required this.isPickupLocation,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DynamicLocationController>();

    return Scaffold(
      backgroundColor: RColors.white,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _buildSearchBar(controller),
          _buildCurrentLocationOption(controller),
          Expanded(child: _buildContent(controller)),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: RColors.white,
      leading: IconButton(
        icon: const Icon(Iconsax.arrow_left, color: RColors.textPrimary),
        onPressed: () => Get.back(),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: RColors.textPrimary,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildSearchBar(DynamicLocationController controller) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: RColors.lightContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: RColors.borderPrimary),
      ),
      child: Row(
        children: [
          const Icon(Iconsax.search_normal, color: RColors.textSecondary),
          const SizedBox(width: 12),
          Expanded( // ✅ Fixed: Added Expanded to prevent overflow
            child: TextField(
              controller: controller.searchController,
              autofocus: true,
              onChanged: controller.searchLocations,
              decoration: const InputDecoration(
                hintText: 'Search for a location...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: RColors.textSecondary),
              ),
              style: const TextStyle(
                color: RColors.textPrimary,
                fontSize: 16,
              ),
            ),
          ),
          // ✅ Fixed: Simplified without unnecessary Obx
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller.searchController,
            builder: (context, value, child) {
              return value.text.isNotEmpty
                  ? IconButton(
                icon: const Icon(Iconsax.close_circle, color: RColors.textSecondary),
                onPressed: () {
                  controller.searchController.clear();
                  controller.searchResults.clear();
                },
              )
                  : const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentLocationOption(DynamicLocationController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: controller.setCurrentLocationAsPickup,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: RColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Iconsax.location, color: RColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded( // ✅ Fixed: Added Expanded to prevent overflow
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Use current location',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: RColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'GPS will be used to find your location',
                        style: TextStyle(
                          color: RColors.textSecondary,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis, // ✅ Fixed: Added overflow handling
                      ),
                    ],
                  ),
                ),
                const Icon(Iconsax.gps, color: RColors.primary, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(DynamicLocationController controller) {
    return Obx(() { // ✅ Fixed: Proper Obx usage with observables
      if (controller.isSearching.value) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: RColors.primary),
              SizedBox(height: 16),
              Text('Searching locations...'),
            ],
          ),
        );
      }

      if (controller.searchResults.isEmpty && controller.searchController.text.isNotEmpty) {
        return _buildNoResults();
      }

      if (controller.searchController.text.isEmpty) {
        return _buildSuggestions(controller);
      }

      return _buildSearchResults(controller);
    });
  }

  Widget _buildSearchResults(DynamicLocationController controller) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.searchResults.length,
      itemBuilder: (context, index) {
        final prediction = controller.searchResults[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => controller.selectLocation(prediction, isPickupLocation),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getLocationTypeColor(prediction.types).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getLocationTypeIcon(prediction.types),
                        color: _getLocationTypeColor(prediction.types),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded( // ✅ Fixed: Added Expanded to prevent overflow
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            prediction.mainText,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: RColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (prediction.secondaryText.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              prediction.secondaryText,
                              style: const TextStyle(
                                color: RColors.textSecondary,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const Icon(
                      Iconsax.arrow_right_3,
                      color: RColors.textSecondary,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuggestions(DynamicLocationController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSavedPlaces(),
          const SizedBox(height: 20),
          _buildRecentSearches(),
          const SizedBox(height: 20),
          _buildPopularPlaces(controller),
        ],
      ),
    );
  }

  Widget _buildSavedPlaces() {
    final savedPlaces = [
      {
        'name': 'Home',
        'address': 'Your home address',
        'icon': Iconsax.home,
        'color': RColors.success
      },
      {
        'name': 'University',
        'address': 'Your university',
        'icon': Iconsax.building_4,
        'color': RColors.primary
      },
      {
        'name': 'Work',
        'address': 'Your workplace',
        'icon': Iconsax.briefcase,
        'color': RColors.info
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Saved places',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: RColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...savedPlaces.map((place) => _buildPlaceItem(
          place['name'] as String,
          place['address'] as String,
          place['icon'] as IconData,
          place['color'] as Color,
              () {
            Get.snackbar('Selected', '${place['name']} selected');
            Get.back();
          },
        )).toList(),
      ],
    );
  }

  Widget _buildRecentSearches() {
    final recentSearches = [
      {'name': 'Emporium Mall', 'address': 'Johar Town, Lahore'},
      {'name': 'Liberty Market', 'address': 'Gulberg III, Lahore'},
      {'name': 'Food Street', 'address': 'Fort Road, Lahore'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent searches',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: RColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                Get.snackbar('Cleared', 'Recent searches cleared');
              },
              child: const Text('Clear', style: TextStyle(color: RColors.primary)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...recentSearches.map((search) => _buildPlaceItem(
          search['name']!,
          search['address']!,
          Iconsax.clock,
          RColors.textSecondary,
              () {
            Get.snackbar('Selected', '${search['name']} selected');
            Get.back();
          },
        )).toList(),
      ],
    );
  }

  Widget _buildPopularPlaces(DynamicLocationController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Popular university locations',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: RColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...controller.mockLocations.take(4).map((location) => _buildPlaceItem(
          location.mainText,
          location.secondaryText,
          _getLocationTypeIcon(location.types),
          _getLocationTypeColor(location.types),
              () {
            controller.selectLocation(location, isPickupLocation);
          },
        )).toList(),
      ],
    );
  }

  Widget _buildPlaceItem(
      String name,
      String address,
      IconData icon,
      Color iconColor,
      VoidCallback onTap,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 16),
                ),
                const SizedBox(width: 12),
                Expanded( // ✅ Fixed: Added Expanded to prevent overflow
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: RColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis, // ✅ Fixed: Added overflow handling
                      ),
                      if (address.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          address,
                          style: const TextStyle(
                            color: RColors.textSecondary,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis, // ✅ Fixed: Added overflow handling
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoResults() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.search_normal,
            size: 48,
            color: RColors.textSecondary,
          ),
          SizedBox(height: 16),
          Text(
            'No locations found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: RColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Try searching with different keywords',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: RColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getLocationTypeColor(List<String> types) {
    if (types.contains('university') || types.contains('school')) {
      return RColors.primary;
    } else if (types.contains('shopping_mall') || types.contains('store')) {
      return RColors.secondary;
    } else if (types.contains('restaurant') || types.contains('food')) {
      return RColors.warning;
    } else if (types.contains('hospital')) {
      return RColors.error;
    }
    return RColors.info;
  }

  IconData _getLocationTypeIcon(List<String> types) {
    if (types.contains('university') || types.contains('school')) {
      return Iconsax.building_4;
    } else if (types.contains('shopping_mall') || types.contains('store')) {
      return Iconsax.shop;
    } else if (types.contains('restaurant') || types.contains('food')) {
      return Iconsax.cup;
    } else if (types.contains('hospital')) {
      return Iconsax.hospital;
    } else if (types.contains('market')) {
      return Iconsax.bag_2;
    }
    return Iconsax.location;
  }
}
