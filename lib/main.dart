import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manuscan/controllers/auth_controller.dart';
import 'bindings/app_bindings.dart';
import 'onboarding_screen.dart';
import 'login_page.dart';
import 'home_screen.dart';
import 'security/securityscreen.dart';
import 'palletdispatch/pallet_dispatch.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Getx bindings
  AppBindings().dependencies();

  final AuthController authController = Get.find();
  final String initialRoute = await authController.checkAuth();

  print('App starting');
  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ManuScan',
      initialBinding: AppBindings(),
      initialRoute: initialRoute,
      getPages: [
        GetPage(name: '/', page: () => const OnboardingScreen()),
        GetPage(name: '/login', page: () => const login_account()),
        GetPage(name: '/home', page: () => const HomeScreen()),
        GetPage(name: '/security', page: () => const SecurityScreen()),
        GetPage(
            name: '/palletdispatch', page: () => const PalletDispatchScreen1()),
      ],
    );
  }
}
