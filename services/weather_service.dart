import 'package:dio/dio.dart';
import 'package:new_project/models/weather_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';

// Fasalka CachedWeatherData
class CachedWeatherData {
  final WeatherModel currentWeather;
  final List<WeatherModel> forecast;

  
  CachedWeatherData weatherData = CachedWeatherData(
    currentWeather: "Sunny",
    forecast: "Rain in the evening",
    timestamp: DateTime.now(),
  );

  print(weatherData.toString());

  bool isFresh = weatherData.isDataFresh(Duration(minutes: 10));
  print(isFresh ? "Data is fresh" : "Data is outdated");


}

// Fasalka WeatherService
class WeatherService {
  final Dio _dio = Dio();
  final String _apiKey = '732a97c9f7cc52bbda18275f2cd765af';
  final String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  // Function to get the current location
  Future<Position> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      return await Geolocator.getCurrentPosition();
    } catch (e) {
      throw Exception('Failed to get current location: $e');
    }
  }

  // Function to get the current weather data
  Future<WeatherModel> getWeather(double lat, double lon) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/weather',
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'appid': _apiKey,
          'units': 'metric',
        },
      );
      if (response.statusCode == 200) {
        return WeatherModel.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch weather data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch weather data: $e');
    }
  }

  // Function to get weather forecast
  Future<List<WeatherModel>> getForecast(double lat, double lon) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/forecast',
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'appid': _apiKey,
          'units': 'metric',
        },
      );
      if (response.statusCode == 200) {
        return (response.data['list'] as List)
            .map((e) => WeatherModel.fromJson(e))
            .toList();
      } else {
        throw Exception('Failed to fetch forecast data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch forecast data: $e');
    }
  }

  // Function to save the current weather and forecast data into Hive
  Future<void> saveWeatherData(
      WeatherModel currentWeather,
      List<WeatherModel> forecast,
      ) async {
    try {
      final box = await Hive.openBox('weatherCache');
      await box.put('currentWeather', currentWeather.toJson());
      await box.put('forecast', forecast.map((e) => e.toJson()).toList());
    } catch (e) {
      throw Exception('Failed to save weather data: $e');
    }
  }

  // Function to retrieve cached weather data from Hive
  Future<CachedWeatherData?> getCachedWeatherData() async {
    try {
      final box = await Hive.openBox('weatherCache');
      final currentWeather = box.get('currentWeather');
      final forecast = box.get('forecast');

      if (currentWeather == null || forecast == null) return null;

      return CachedWeatherData(
        currentWeather: WeatherModel.fromJson(currentWeather),
        forecast: (forecast as List<dynamic>)
            .map((e) => WeatherModel.fromJson(e))
            .toList(),
      );
    } catch (e) {
      throw Exception('Failed to retrieve cached weather data: $e');
    }
  }
}
