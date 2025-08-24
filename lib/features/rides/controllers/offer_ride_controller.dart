import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../utils/constants/colors.dart';
import '../../../services/location_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/success_screen.dart';

class OfferRideController extends GetxController {
  static OfferRideController get instance => Get.find();

  // Text Controllers
  final vehicleBrandController = TextEditingController();
  final vehicleModelController = TextEditingController();
  final vehicleColorController = TextEditingController();
  final licensePlateController = TextEditingController();
  final pricePerSeatController = TextEditingController();

  // Location selection
  final pickupLocation = Rxn<RideLocation>();
  final destinationLocation = Rxn<RideLocation>();

  // Date and time
  final selectedDate = ''.obs;
  final selectedTime = ''.obs;
  final selectedDateTime = Rxn<DateTime>();

  // Vehicle details
  final vehicleType = ''.obs;
  final vehicleTypes = [
    'Car',
    'SUV',
    'Hatchback',
    'Sedan',
    'Motorcycle',
    'Van',
  ];

  // Ride details
  final availableSeats = 3.obs;
  final selectedPreferences = <String>[].obs;

  // Recurring ride
  final isRecurring = false.obs;
  final recurringDays = <String>[].obs;

  // State
  final isCreating = false.obs;
  final canCreateRide = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeDefaults();
    _setupValidation();
  }

  @override
  void onClose() {
    vehicleBrandController.dispose();
    vehicleModelController.dispose();
    vehicleColorController.dispose();
    licensePlateController.dispose();
    pricePerSeatController.dispose();
    super.onClose();
  }

  void _initializeDefaults() {
    final now = DateTime.now();
    final defaultTime = now.add(const Duration(hours: 1));

    selectedDate.value = DateFormat('MMM dd, yyyy').format(defaultTime);
    selectedTime.value = DateFormat('HH:mm').format(defaultTime);
    selectedDateTime.value = defaultTime;

    pricePerSeatController.text = '100';
  }

  void _setupValidation() {
    // Listen to all form changes
    ever(pickupLocation, (_) => _updateValidation());
    ever(destinationLocation, (_) => _updateValidation());
    ever(selectedDateTime, (_) => _updateValidation());
    ever(vehicleType, (_) => _updateValidation());
    ever(availableSeats, (_) => _updateValidation());
    ever(isRecurring, (_) => _updateValidation());
    ever(recurringDays, (_) => _updateValidation());

    // Listen to text field changes
    vehicleBrandController.addListener(_updateValidation);
    vehicleModelController.addListener(_updateValidation);
    vehicleColorController.addListener(_updateValidation);
    licensePlateController.addListener(_updateValidation);
    pricePerSeatController.addListener(_updateValidation);
  }

  void _updateValidation() {
    canCreateRide.value = _validateForm();
  }

  bool _validateForm() {
    return pickupLocation.value != null &&
        destinationLocation.value != null &&
        selectedDateTime.value != null &&
        pricePerSeatController.text.trim().isNotEmpty &&
        availableSeats.value > 0 &&
        (!isRecurring.value || recurringDays.isNotEmpty);
  }

  // Location methods
  void setPickupLocation(Map<String, dynamic> locationData) {
    // Extract state from additionalInfo if available
    String? state = locationData['additionalInfo']?['state'];
    pickupLocation.value = RideLocation(
      name: locationData['name'] ?? '',
      address: locationData['address'] ?? '',
      latitude: locationData['latitude'] ?? 0.0,
      longitude: locationData['longitude'] ?? 0.0,
      placeId: locationData['placeId'] ?? '',
      type: locationData['type'] ?? 'other',
      additionalInfo: {
        ...(locationData['additionalInfo'] ?? {}),
        if (state != null) 'state': state,
      },
    );

    Get.snackbar(
      'Location Selected',
      'Pickup: ${pickupLocation.value!.name}',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void setDestinationLocation(Map<String, dynamic> locationData) {
    // Extract state from additionalInfo if available
    String? state = locationData['additionalInfo']?['state'];
    destinationLocation.value = RideLocation(
      name: locationData['name'] ?? '',
      address: locationData['address'] ?? '',
      latitude: locationData['latitude'] ?? 0.0,
      longitude: locationData['longitude'] ?? 0.0,
      placeId: locationData['placeId'] ?? '',
      type: locationData['type'] ?? 'other',
      additionalInfo: {
        ...(locationData['additionalInfo'] ?? {}),
        if (state != null) 'state': state,
      },
    );

    Get.snackbar(
      'Location Selected',
      'Destination: ${destinationLocation.value!.name}',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  // Date and time selection
  Future<void> selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: Get.context!,
      initialDate: selectedDateTime.value ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );

    if (picked != null) {
      selectedDate.value = DateFormat('MMM dd, yyyy').format(picked);
      _updateSelectedDateTime(picked);
    }
  }

  Future<void> selectTime() async {
    final picked = await showTimePicker(
      context: Get.context!,
      initialTime: TimeOfDay.fromDateTime(
        selectedDateTime.value ?? DateTime.now(),
      ),
    );

    if (picked != null) {
      selectedTime.value = picked.format(Get.context!);

      final currentDate = selectedDateTime.value ?? DateTime.now();
      final newDateTime = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
        picked.hour,
        picked.minute,
      );

      _updateSelectedDateTime(newDateTime);
    }
  }

  void _updateSelectedDateTime(DateTime dateTime) {
    selectedDateTime.value = dateTime;
  }

  // Vehicle and ride details
  void setVehicleType(String? type) {
    if (type != null) {
      vehicleType.value = type;
    }
  }

  void setAvailableSeats(int seats) {
    if (seats >= 1 && seats <= 6) {
      availableSeats.value = seats;
    }
  }

  // Preferences
  void togglePreference(String preference) {
    if (selectedPreferences.contains(preference)) {
      selectedPreferences.remove(preference);
    } else {
      selectedPreferences.add(preference);
    }
  }

  // Recurring ride
  void toggleRecurring(bool value) {
    isRecurring.value = value;
    if (!value) {
      recurringDays.clear();
    }
  }

  void toggleRecurringDay(String day) {
    if (recurringDays.contains(day)) {
      recurringDays.remove(day);
    } else {
      recurringDays.add(day);
    }
  }

  // Create ride offer
  Future<void> createRideOffer() async {
    if (!canCreateRide.value) {
      Get.snackbar('Error', 'Please fill in all required fields');
      return;
    }

    // Intra-state validation
    final pickupState = pickupLocation.value?.additionalInfo['state'];
    final destinationState = destinationLocation.value?.additionalInfo['state'];
    if (pickupState == null ||
        destinationState == null ||
        pickupState != destinationState) {
      Get.snackbar(
        'Invalid Route',
        'Pickup and destination must be in the same state.',
      );
      return;
    }

    try {
      isCreating.value = true;
      final price = double.tryParse(pricePerSeatController.text);
      if (price == null || price <= 0) {
        Get.snackbar('Error', 'Please enter a valid price');
        return;
      }
      // Prepare ride data
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        Get.snackbar('Error', 'User not authenticated');
        isCreating.value = false;
        return;
      }
      final rideData = {
        'pickup': pickupLocation.value!.toMap(),
        'destination': destinationLocation.value!.toMap(),
        'departureTime': selectedDateTime.value,
        // Removed vehicleType, vehicleBrand, vehicleModel, vehicleColor, licensePlate
        'availableSeats': availableSeats.value,
        'pricePerSeat': price,
        'preferences': selectedPreferences,
        'isRecurring': isRecurring.value,
        'recurringDays': recurringDays,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'userId': userId,
        'status': 'active',
      };
      // Post to Firestore
      await FirebaseFirestore.instance.collection('rides').add(rideData);
      Get.snackbar(
        'Success!',
        'Your ride offer has been created successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: RColors.success,
        colorText: RColors.white,
        duration: const Duration(seconds: 3),
      );
      Get.to(() => SuccessScreen());
    } catch (e) {
      Get.snackbar('Error', 'Failed to create ride: $e');
    } finally {
      isCreating.value = false;
    }
  }

  // Clear form
  void clearForm() {
    pickupLocation.value = null;
    destinationLocation.value = null;
    vehicleType.value = '';
    vehicleBrandController.clear();
    vehicleModelController.clear();
    vehicleColorController.clear();
    licensePlateController.clear();
    pricePerSeatController.text = '100';
    availableSeats.value = 3;
    selectedPreferences.clear();
    isRecurring.value = false;
    recurringDays.clear();
    _initializeDefaults();
  }
}
