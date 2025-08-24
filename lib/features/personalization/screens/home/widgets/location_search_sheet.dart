// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:iconsax/iconsax.dart';
// import 'package:animate_do/animate_do.dart';
// import '../../../../../utils/constants/colors.dart';
// import '../../../controllers/location_search_controller.dart';
//
// class LocationSearchSheet extends StatelessWidget {
//   final LocationSearchController controller;
//   final bool isFromLocation;
//
//   const LocationSearchSheet({
//     Key? key,
//     required this.controller,
//     required this.isFromLocation,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//
//     return Scaffold(
//       backgroundColor: isDark ? RColors.dark : RColors.white,
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.transparent,
//         leading: IconButton(
//           icon: const Icon(Iconsax.arrow_left),
//           onPressed: () => Get.back(),
//         ),
//         title: Text(
//           isFromLocation ? 'Choose pickup location' : 'Choose destination',
//           style: const TextStyle(fontWeight: FontWeight.w600),
//         ),
//       ),
//       body: Column(
//         children: [
//           // Search Bar
//           _buildSearchBar(isDark),
//
//           // Current Location Option
//           _buildCurrentLocationOption(isDark),
//
//           // Search Results
//           Expanded(
//             child: Obx(() {
//               if (controller.isSearching.value) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//
//               if (controller.searchResults.isEmpty && controller.searchController.text.isNotEmpty) {
//                 return _buildNoResults(isDark);
//               }
//
//               if (controller.searchController.text.isEmpty) {
//                 return _buildSuggestions(isDark);
//               }
//
//               return _buildSearchResults(isDark);
//             }),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSearchBar(bool isDark) {
//     return Container(
//       margin: const EdgeInsets.all(16),
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       decoration: BoxDecoration(
//         color: isDark ? RColors.darkContainer : RColors.lightContainer,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: RColors.borderPrimary),
//       ),
//       child: TextField(
//         controller: controller.searchController,
//         autofocus: true,
//         onChanged: controller.searchLocations,
//         decoration: InputDecoration(
//           hintText: 'Search for a location...',
//           border: InputBorder.none,
//           prefixIcon: Icon(
//             Iconsax.search_normal,
//             color: isDark ? RColors.darkGrey : RColors.textSecondary,
//           ),
//           suffixIcon: Obx(() => controller.searchController.text.isNotEmpty
//               ? IconButton(
//             icon: const Icon(Iconsax.close_circle),
//             onPressed: () {
//               controller.searchController.clear();
//               controller.searchResults.clear();
//             },
//           )
//               : const SizedBox.shrink()),
//         ),
//         style: TextStyle(
//           color: isDark ? RColors.textWhite : RColors.textPrimary,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCurrentLocationOption(bool isDark) {
//     return FadeInUp(
//       duration: const Duration(milliseconds: 300),
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 16),
//         child: ListTile(
//           leading: Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: RColors.primary.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: const Icon(Iconsax.location, color: RColors.primary),
//           ),
//           title: Text(
//             'Use current location',
//             style: TextStyle(
//               fontWeight: FontWeight.w600,
//               color: isDark ? RColors.textWhite : RColors.textPrimary,
//             ),
//           ),
//           subtitle: Text(
//             'GPS will be used to find your location',
//             style: TextStyle(
//               color: isDark ? RColors.darkGrey : RColors.textSecondary,
//             ),
//           ),
//           trailing: const Icon(Iconsax.gps, color: RColors.primary),
//           onTap: () => controller.setCurrentLocation(isFromLocation),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSearchResults(bool isDark) {
//     return ListView.builder(
//       padding: const EdgeInsets.all(16),
//       itemCount: controller.searchResults.length,
//       itemBuilder: (context, index) {
//         final location = controller.searchResults[index];
//         return FadeInUp(
//           duration: Duration(milliseconds: 300 + (index * 100)),
//           child: Container(
//             margin: const EdgeInsets.only(bottom: 8),
//             child: ListTile(
//               leading: Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: _getLocationTypeColor(location['type']).withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(
//                   _getLocationTypeIcon(location['type']),
//                   color: _getLocationTypeColor(location['type']),
//                 ),
//               ),
//               title: Text(
//                 location['name'],
//                 style: TextStyle(
//                   fontWeight: FontWeight.w600,
//                   color: isDark ? RColors.textWhite : RColors.textPrimary,
//                 ),
//               ),
//               subtitle: Text(
//                 location['address'],
//                 style: TextStyle(
//                   color: isDark ? RColors.darkGrey : RColors.textSecondary,
//                 ),
//               ),
//               trailing: Icon(
//                 Iconsax.arrow_right_3,
//                 color: isDark ? RColors.darkGrey : RColors.textSecondary,
//               ),
//               onTap: () => controller.selectLocation(location, isFromLocation),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildSuggestions(bool isDark) {
//     final suggestions = controller.predefinedLocations.take(8).toList();
//
//     return ListView(
//       padding: const EdgeInsets.all(16),
//       children: [
//         Text(
//           'Suggested locations',
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: isDark ? RColors.textWhite : RColors.textPrimary,
//           ),
//         ),
//         const SizedBox(height: 16),
//         ...suggestions.map((location) => FadeInLeft(
//           duration: const Duration(milliseconds: 400),
//           child: Container(
//             margin: const EdgeInsets.only(bottom: 8),
//             child: ListTile(
//               leading: Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: _getLocationTypeColor(location['type']).withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(
//                   _getLocationTypeIcon(location['type']),
//                   color: _getLocationTypeColor(location['type']),
//                 ),
//               ),
//               title: Text(
//                 location['name'],
//                 style: TextStyle(
//                   fontWeight: FontWeight.w600,
//                   color: isDark ? RColors.textWhite : RColors.textPrimary,
//                 ),
//               ),
//               subtitle: Text(
//                 location['address'],
//                 style: TextStyle(
//                   color: isDark ? RColors.darkGrey : RColors.textSecondary,
//                 ),
//               ),
//               onTap: () => controller.selectLocation(location, isFromLocation),
//             ),
//           ),
//         )).toList(),
//       ],
//     );
//   }
//
//   Widget _buildNoResults(bool isDark) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Iconsax.search_normal,
//             size: 64,
//             color: isDark ? RColors.darkGrey : RColors.textSecondary,
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'No locations found',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//               color: isDark ? RColors.textWhite : RColors.textPrimary,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Try searching with different keywords',
//             style: TextStyle(
//               color: isDark ? RColors.darkGrey : RColors.textSecondary,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Color _getLocationTypeColor(String type) {
//     switch (type) {
//       case 'university':
//         return RColors.primary;
//       case 'mall':
//         return RColors.secondary;
//       case 'airport':
//         return RColors.info;
//       case 'stadium':
//         return RColors.warning;
//       default:
//         return RColors.accent;
//     }
//   }
//
//   IconData _getLocationTypeIcon(String type) {
//     switch (type) {
//       case 'university':
//         return Iconsax.building_4;
//       case 'mall':
//         return Iconsax.shop;
//       case 'airport':
//         return Iconsax.airplane;
//       case 'stadium':
//         return Iconsax.medal_star;
//       default:
//         return Iconsax.location;
//     }
//   }
// }
