import 'package:get/get.dart';
import '../data/repositories/authentication/autentication_repository.dart';
import '../features/location/controller/location_controller.dart';
import '../data/repositories/user/user_repository.dart';
import '../data/repositories/ride/ride_repository.dart';
import '../features/personalization/controllers/auth_controller.dart';
import '../features/personalization/controllers/dynamic_location_controller.dart';
import '../features/personalization/controllers/profile_controller.dart';
import '../features/personalization/controllers/ride_matching_controller.dart';
import '../features/personalization/controllers/update_name_controller.dart';
import '../features/rides/controllers/find_ride_controller.dart';
import '../features/rides/controllers/offer_ride_controller.dart';
import '../utils/http/network_manager.dart';
import '../utils/theme/theme_controller.dart';

class GeneralBindings extends Bindings {
  @override
  void dependencies() {
    // Core utilities
    Get.put<NetworkManager>(NetworkManager(), permanent: true);
    Get.put<ThemeController>(ThemeController(), permanent: true);

    // Core repositories
    Get.put<UserRepository>(UserRepository(), permanent: true);
    Get.put<RideRepository>(RideRepository(), permanent: true);
    Get.put<AuthenticationRepository>(
      AuthenticationRepository(),
      permanent: true,
    );

    // Core controllers (permanent - needed throughout app lifecycle)
    Get.put<AuthController>(AuthController(), permanent: true);
    Get.put<LocationController>(LocationController(), permanent: true);

    // Home controllers
    Get.put<DynamicLocationController>(
      DynamicLocationController(),
      permanent: true,
    );
    Get.put<RideMatchingController>(RideMatchingController(), permanent: true);

    // Ride controllers
    Get.lazyPut<FindRideController>(() => FindRideController());
    Get.lazyPut<OfferRideController>(() => OfferRideController());

    // Feature controllers (lazy - created when needed)
    Get.lazyPut<ProfileController>(() => ProfileController());
    Get.lazyPut<UpdateNameController>(() => UpdateNameController());
  }
}
