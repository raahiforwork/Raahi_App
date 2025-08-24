import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:raahi/features/personalization/screens/home/home.dart';
import 'features/rides/screens/find_ride_screen.dart';
import 'features/rides/screens/offer_ride_screen.dart';
import 'features/rides/screens/chat_list_screen.dart';
import 'features/personalization/screens/profile/profile.dart';
import 'utils/constants/colors.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());

    return Scaffold(
      bottomNavigationBar: Obx(
        () => NavigationBar(
          height: 80,
          elevation: 0,
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected:
              (index) => controller.selectedIndex.value = index,
          backgroundColor:
              Theme.of(context).bottomAppBarTheme.color ??
              Theme.of(context).colorScheme.surface,
          indicatorColor: RColors.primary.withOpacity(0.12),
          destinations: const [
            NavigationDestination(
              icon: Icon(Iconsax.home),
              selectedIcon: Icon(Iconsax.home_15),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Iconsax.search_favorite),
              selectedIcon: Icon(Iconsax.search_favorite5),
              label: 'Find Ride',
            ),
            NavigationDestination(
              icon: Icon(Iconsax.add_circle),
              selectedIcon: Icon(Iconsax.add_circle5),
              label: 'Offer Ride',
            ),
            NavigationDestination(
              icon: Icon(Iconsax.message),
              selectedIcon: Icon(Iconsax.message),
              label: 'Messages',
            ),
            NavigationDestination(
              icon: Icon(Iconsax.user),
              selectedIcon: Icon(Iconsax.user_octagon5),
              label: 'Profile',
            ),
          ],
        ),
      ),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;

  final screens = [
    RaahiHomeScreen(),
    FindRideScreen(),
    OfferRideScreen(),
    ChatListScreen(),
    ProfileScreen(),
  ];

  // Removed unused _buildComingSoonScreen
}
