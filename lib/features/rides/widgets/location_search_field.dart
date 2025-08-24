import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:raahi/features/rides/widgets/place_prediction.dart';
import '../controllers/find_ride_controller.dart';
import '../../../../utils/constants/colors.dart';

class LocationSearchField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final Color iconColor;
  final TextEditingController controller;
  final Function(PlacePrediction) onLocationSelected;
  final Function(String) onSearchChanged;
  final RxList<PlacePrediction> suggestions;
  final RxBool isLoading;
  final bool showCurrentLocation;

  const LocationSearchField({
    Key? key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.iconColor,
    required this.controller,
    required this.onLocationSelected,
    required this.onSearchChanged,
    required this.suggestions,
    required this.isLoading,
    this.showCurrentLocation = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: RColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: RColors.borderPrimary),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              suffixIcon:
                  showCurrentLocation
                      ? IconButton(
                        icon: const Icon(
                          Iconsax.location,
                          color: RColors.primary,
                        ),
                        onPressed: () {
                          final findController = Get.find<FindRideController>();
                          findController.setCurrentLocationAsPickup();
                        },
                      )
                      : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),

        // Suggestions list
        Obx(() {
          if (isLoading.value) {
            return Container(
              margin: const EdgeInsets.only(top: 8),
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
              child: const Center(
                child: CircularProgressIndicator(color: RColors.primary),
              ),
            );
          }

          if (suggestions.isNotEmpty) {
            return Container(
              margin: const EdgeInsets.only(top: 8),
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
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: suggestions.length,
                separatorBuilder:
                    (context, index) =>
                        Divider(height: 1, color: RColors.borderPrimary),
                itemBuilder: (context, index) {
                  final suggestion = suggestions[index];
                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getLocationIcon(suggestion.types), // ✅ Now this works!
                        color: iconColor,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      suggestion.mainText,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(suggestion.secondaryText),
                    trailing:
                        suggestion.distanceMeters != null
                            ? Text(
                              _formatDistance(suggestion.distanceMeters!),
                              style: TextStyle(
                                fontSize: 12,
                                color: RColors.textSecondary,
                              ),
                            )
                            : null,
                    onTap: () {
                      onLocationSelected(suggestion);
                    },
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        }),
      ],
    );
  }

  IconData _getLocationIcon(List<String> types) {
    // Check for specific place types and return appropriate icons
    if (types.any(
      (type) =>
          ['university', 'school', 'educational_institution'].contains(type),
    )) {
      return Iconsax.building_4;
    } else if (types.any(
      (type) => ['shopping_mall', 'store', 'supermarket'].contains(type),
    )) {
      return Iconsax.shop;
    } else if (types.any(
      (type) => ['restaurant', 'food', 'meal_takeaway', 'cafe'].contains(type),
    )) {
      return Iconsax.cup;
    } else if (types.any(
      (type) => ['hospital', 'pharmacy', 'doctor'].contains(type),
    )) {
      return Iconsax.hospital;
    } else if (types.any(
      (type) => ['gas_station', 'car_repair'].contains(type),
    )) {
      return Iconsax.gas_station;
    } else if (types.any((type) => ['bank', 'atm', 'finance'].contains(type))) {
      return Iconsax.bank;
    } else if (types.any((type) => ['lodging', 'hotel'].contains(type))) {
      return Iconsax.building;
    } else if (types.any(
      (type) => ['airport', 'bus_station', 'subway_station'].contains(type),
    )) {
      return Iconsax.airplane;
    }

    // Default location icon
    return Iconsax.location;
  }

  String _formatDistance(int meters) {
    if (meters < 1000) {
      return '${meters}m';
    } else {
      final km = meters / 1000;
      return '${km.toStringAsFixed(1)}km';
    }
  }
}
