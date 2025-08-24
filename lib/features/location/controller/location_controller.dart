import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationController extends GetxController {
  static LocationController get instance => Get.find();

  final currentPosition = Rxn<Position>();
  final isLoading = false.obs;
  final locationError = ''.obs;
  final hasPermission = false.obs;

  double get currentLatitude => currentPosition.value?.latitude ?? 31.5204;
  double get currentLongitude => currentPosition.value?.longitude ?? 74.3587;
  bool get hasValidLocation => currentPosition.value != null;

  @override
  void onInit() {
    super.onInit();
    checkLocationPermissions();
  }

  Future<void> checkLocationPermissions() async {
    try {
      final permission = await Permission.location.status;
      hasPermission.value = permission.isGranted;

      if (permission.isGranted) {
        await getCurrentLocation();
      }
    } catch (e) {
      print('Error checking location permissions: $e');
    }
  }

  Future<void> requestLocationPermission() async {
    try {
      final permission = await Permission.location.request();
      hasPermission.value = permission.isGranted;

      if (permission.isGranted) {
        await getCurrentLocation();
      } else {
        locationError.value = 'Location permission denied';
      }
    } catch (e) {
      locationError.value = 'Failed to request location permission';
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      isLoading.value = true;
      locationError.value = '';

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied';
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      currentPosition.value = position;
      hasPermission.value = true;
      locationError.value = '';

    } catch (e) {
      locationError.value = e.toString();
      print('Location error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<double> getDistanceTo(double latitude, double longitude) async {
    if (!hasValidLocation) {
      await getCurrentLocation();
    }

    if (hasValidLocation) {
      return Geolocator.distanceBetween(
        currentLatitude,
        currentLongitude,
        latitude,
        longitude,
      );
    }

    return 0.0;
  }
}
