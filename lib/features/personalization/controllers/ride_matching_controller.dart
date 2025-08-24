import 'package:get/get.dart';
import '../../rides/screens/find_ride_screen.dart';
import '../../rides/screens/offer_ride_screen.dart';

class RideMatchingController extends GetxController {
  static RideMatchingController get instance => Get.find<RideMatchingController>();

  final isLoading = false.obs;
  final nearbyRides = <Map<String, dynamic>>[].obs;
  final recentRides = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadMockData();
  }

  // ADD THESE METHODS:
  Future<void> findRides() async {
    isLoading.value = true;
    await Get.to(() => const FindRideScreen());
    isLoading.value = false;
  }

  Future<void> offerRide() async {
    isLoading.value = true;
    await Get.to(() =>  OfferRideScreen());
    isLoading.value = false;
  }

  // ...rest of your controller

  void _loadMockData() {
    nearbyRides.value = [
      {
        'driver': 'Ahmed Khan',
        'from': 'FAST University',
        'to': 'Packages Mall',
        'time': '2:30 PM',
        'seats': '2',
        'price': '₨180',
        'distance': '1.2 km away'
      },
      {
        'driver': 'Sara Ahmed',
        'from': 'UMT',
        'to': 'Fortress Stadium',
        'time': '3:00 PM',
        'seats': '3',
        'price': '₨160',
        'distance': '800 m away'
      },
    ];

    recentRides.value = [
      {'from': 'LUMS', 'to': 'Emporium Mall', 'date': 'Yesterday', 'price': '₨150'},
      {'from': 'UCP', 'to': 'Liberty Market', 'date': '2 days ago', 'price': '₨120'},
    ];
  }
}
