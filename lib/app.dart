import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raahi/utils/theme/theme.dart';

import 'bindings/general_bindings.dart';
import 'utils/theme/theme_controller.dart';

// -- Use this class to setup themes , initial Bindings , any animations and much more
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.put(ThemeController(), permanent: true);
    return Obx(
      () => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: themeController.themeMode.value,
        theme: RAppTheme.lightTheme,
        initialBinding: GeneralBindings(),
        darkTheme: RAppTheme.darkTheme,
        home: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
