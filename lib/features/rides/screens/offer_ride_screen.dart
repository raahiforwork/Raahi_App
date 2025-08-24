import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../controllers/offer_ride_controller.dart';
import '../screens/location_search_screen.dart';
import '../../../../utils/constants/colors.dart';

class OfferRideScreen extends StatelessWidget {
  const OfferRideScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OfferRideController());

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Offer a Ride'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRouteSection(context, controller),
            const SizedBox(height: 16),
            _buildDateTimeSection(context, controller),
            const SizedBox(height: 16),
            _buildRideDetailsSection(context, controller),
            const SizedBox(height: 16),
            _buildPreferencesSection(context, controller),
            const SizedBox(height: 16),
            _buildRecurringSection(context, controller),
            const SizedBox(height: 32),
            _buildCreateButton(controller),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteSection(
    BuildContext context,
    OfferRideController controller,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Route Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // From Location
          Obx(
            () => _buildLocationField(
              context,
              'From',
              controller.pickupLocation.value?.name ?? 'Choose pickup location',
              Iconsax.record_circle,
              RColors.success,
              () => _selectLocation(context, controller, true),
            ),
          ),

          const SizedBox(height: 16),

          // To Location
          Obx(
            () => _buildLocationField(
              context,
              'To',
              controller.destinationLocation.value?.name ??
                  'Choose destination',
              Iconsax.location_tick,
              RColors.error,
              () => _selectLocation(context, controller, false),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDateTimeSection(
    BuildContext context,
    OfferRideController controller,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Departure Time',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              // color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Obx(
                  () => _buildDateTimeField(
                    context,
                    'Date',
                    controller.selectedDate.value,
                    Iconsax.calendar,
                    () => controller.selectDate(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(
                  () => _buildDateTimeField(
                    context,
                    'Time',
                    controller.selectedTime.value,
                    Iconsax.clock,
                    () => controller.selectTime(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRideDetailsSection(
    BuildContext context,
    OfferRideController controller,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ride Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              // color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Available Seats',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        // color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => _buildNumberSelector(
                        context,
                        controller.availableSeats.value,
                        (value) => controller.setAvailableSeats(value),
                        1,
                        6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  context,
                  'Price per Seat (₨)',
                  controller.pricePerSeatController,
                  '100',
                  Iconsax.money,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection(
    BuildContext context,
    OfferRideController controller,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ride Preferences',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              // color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 16),
          Obx(() => _buildPreferencesChips(context, controller)),
        ],
      ),
    );
  }

  Widget _buildRecurringSection(
    BuildContext context,
    OfferRideController controller,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Recurring Ride',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Obx(
                () => Switch(
                  value: controller.isRecurring.value,
                  onChanged: controller.toggleRecurring,
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Offer this ride on selected days of the week',
            style: TextStyle(fontSize: 12),
          ),
          Obx(
            () =>
                controller.isRecurring.value
                    ? Column(
                      children: [
                        SizedBox(height: 16),
                        _buildRecurringDaysSelector(context, controller),
                      ],
                    )
                    : SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton(OfferRideController controller) {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed:
              controller.canCreateRide.value && !controller.isCreating.value
                  ? controller.createRideOffer
                  : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: RColors.primary,
            foregroundColor: RColors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child:
              controller.isCreating.value
                  ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: RColors.white,
                      strokeWidth: 2,
                    ),
                  )
                  : const Text(
                    'Create Ride Offer',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
        ),
      ),
    );
  }

  // Helper Methods

  Widget _buildLocationField(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: iconColor, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Iconsax.arrow_right_3,
              color: Theme.of(context).textTheme.bodySmall?.color,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeField(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: RColors.primary, size: 16),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context,
    String label,
    TextEditingController controller,
    String hint,
    IconData icon, {
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: RColors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: RColors.primary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNumberSelector(
    BuildContext context,
    int value,
    ValueChanged<int> onChanged,
    int min,
    int max,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: value > min ? () => onChanged(value - 1) : null,
            icon: const Icon(Iconsax.minus),
            color: RColors.primary,
          ),
          Expanded(
            child: Text(
              value.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
          IconButton(
            onPressed: value < max ? () => onChanged(value + 1) : null,
            icon: const Icon(Iconsax.add),
            color: RColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesChips(
    BuildContext context,
    OfferRideController controller,
  ) {
    final preferences = [
      {
        'key': 'no-smoking',
        'label': 'No Smoking',
        'icon': Iconsax.close_circle,
      },
      {'key': 'music-ok', 'label': 'Music OK', 'icon': Iconsax.music},
      {'key': 'pet-friendly', 'label': 'Pet Friendly', 'icon': Iconsax.heart},
      {
        'key': 'quiet-ride',
        'label': 'Quiet Ride',
        'icon': Iconsax.volume_slash,
      },
      {'key': 'ac-available', 'label': 'AC Available', 'icon': Iconsax.wind},
      {
        'key': 'phone-calls-ok',
        'label': 'Phone Calls OK',
        'icon': Iconsax.call,
      },
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          preferences.map((pref) {
            final isSelected = controller.selectedPreferences.contains(
              pref['key'],
            );
            return FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(pref['icon'] as IconData, size: 16),
                  const SizedBox(width: 4),
                  Text(pref['label'] as String),
                ],
              ),
              selected: isSelected,
              onSelected:
                  (selected) =>
                      controller.togglePreference(pref['key'] as String),
              selectedColor: RColors.primary.withOpacity(0.2),
              checkmarkColor: RColors.primary,
            );
          }).toList(),
    );
  }

  Widget _buildRecurringDaysSelector(
    BuildContext context,
    OfferRideController controller,
  ) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final fullDays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Days',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: List.generate(days.length, (index) {
            final day = fullDays[index];
            final shortDay = days[index];
            final isSelected = controller.recurringDays.contains(
              day.toLowerCase(),
            );

            return FilterChip(
              label: Text(shortDay),
              selected: isSelected,
              onSelected:
                  (selected) =>
                      controller.toggleRecurringDay(day.toLowerCase()),
              selectedColor: Theme.of(
                context,
              ).colorScheme.primary.withOpacity(0.2),
              checkmarkColor: Theme.of(context).colorScheme.primary,
            );
          }),
        ),
      ],
    );
  }

  Future<void> _selectLocation(
    BuildContext context,
    OfferRideController controller,
    bool isPickup,
  ) async {
    final result = await Get.to(
      () => LocationSearchScreen(
        isPickupLocation: isPickup,
        title: isPickup ? 'Choose pickup location' : 'Choose destination',
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      if (isPickup) {
        controller.setPickupLocation(result);
      } else {
        controller.setDestinationLocation(result);
      }
    }
  }

  BoxDecoration _cardDecoration(BuildContext context) => BoxDecoration(
    color: Theme.of(context).cardColor,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Theme.of(context).shadowColor.withOpacity(0.1),
        blurRadius: 10,
        offset: const Offset(0, 2),
      ),
    ],
  );
}
