import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_project/controllers/weather_controller.dart';
import 'package:new_project/models/weather_model.dart';
import 'package:new_project/screens/weather_screens.dart';
import 'package:new_project/services/weather_service.dart';

// Main entry point
void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      defaultTransition: Transition.fade,
    );
  }
}

// AppPages class to define all routes
class AppPages {
  static const INITIAL = '/weather';

  static final routes = [
    // Weather screen route
    GetPage(
      name: '/weather',
      page: () => WeatherScreen(),
      binding: BindingsBuilder(() {
        Get.put(WeatherController());
        // You can add more controllers or services here if needed
      }),
    ),
  ];
}
