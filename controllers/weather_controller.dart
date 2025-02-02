import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../models/weather_model.dart';
import '../services/weather_service.dart';

class WeatherController extends GetxController {
  final WeatherService _weatherService = WeatherService();
  final _currentWeather = Rxn<WeatherModel>();
  final _forecast = RxList<WeatherModel>([]);
  final _isLoading = false.obs;  // Boolean should not be null
  final _error = ''.obs;  // String should not be null

  WeatherModel? get currentWeather => _currentWeather.value;
  List<WeatherModel> get forecast => _forecast;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;

  get weeklyForecast => null;



  @override
  void onInit() {
    super.onInit();
    fetchWeatherData();
  }

  // Fetch weather data from the service
  Future<void> fetchWeatherData() async {
    try {
      _isLoading.value = true;
      _error.value = '';

      // Fetch the current location
      final position = await _weatherService.getCurrentLocation();

      // Fetch current weather
      final weather = await _weatherService.getWeather(
        position.latitude,
        position.longitude,
      );

      // Update current weather observable
      _currentWeather.value = weather;

      // Fetch the forecast
      final forecastData = await _weatherService.getForecast(
        position.latitude,
        position.longitude,
      );
      _forecast.assignAll(forecastData);

      // Save to local storage for offline access
      await _weatherService.saveWeatherData(weather, forecastData);

    } catch (e) {
      _error.value = 'Failed to fetch weather data: $e';

      // Try to load cached data if fetching fails
      final cached = await _weatherService.getCachedWeatherData();
      if (cached != null) {
        _currentWeather.value = cached.currentWeather;
        _forecast.assignAll(cached.forecast);
      }
    } finally {
      _isLoading.value = false;
    }
    
  }
}
