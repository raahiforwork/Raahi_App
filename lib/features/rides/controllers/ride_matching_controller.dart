import 'package:get/get.dart';
import '../screens/find_ride_screen.dart';
import '../screens/offer_ride_screen.dart';

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

  Future<void> openFindRide() async {
    isLoading.value = true;
    await Get.to(() => const FindRideScreen());
    isLoading.value = false;
  }

  Future<void> openOfferRide() async {
    isLoading.value = true;
    await Get.to(() =>  OfferRideScreen());
    isLoading.value = false;
  }

  void requestRide(Map<String, dynamic> ride) {
    Get.snackbar('Request Sent', 'Your request has been sent to ${ride['driver']}', snackPosition: SnackPosition.BOTTOM);
  }

  void _loadMockData() {
    nearbyRides.value = [
      {'driver': 'Ahmed Khan', 'from': 'FAST University', 'to': 'Packages Mall', 'time': '2:30 PM', 'seats': '2', 'price': '₨180', 'distance': '1.2 km'},
      {'driver': 'Sara Ahmed', 'from': 'UMT', 'to': 'Fortress Stadium', 'time': '3:00 PM', 'seats': '3', 'price': '₨160', 'distance': '800 m'},
    ];
    recentRides.value = [
      {'from': 'LUMS', 'to': 'Emporium Mall', 'date': 'Yesterday', 'price': '₨150'},
      {'from': 'UCP', 'to': 'Liberty Market', 'date': '2 days ago', 'price': '₨120'},
    ];
  }
}
