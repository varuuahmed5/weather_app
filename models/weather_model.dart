import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class WeatherModel {
  @HiveField(0)
  final String cityName;
  @HiveField(1)
  final double temperature;
  @HiveField(2)
  final String condition;
  @HiveField(3)
  final double highTemp;
  @HiveField(4)
  final double lowTemp;
  @HiveField(5)
  final int humidity;
  @HiveField(6)
  final double windSpeed;
  @HiveField(7)
  final String icon;

  WeatherModel({
    required this.cityName,
    required this.temperature,
    required this.condition,
    required this.highTemp,
    required this.lowTemp,
    required this.humidity,
    required this.windSpeed,
    required this.icon,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    // Null checks for nested fields
    final weather = json['weather'] != null && (json['weather'] as List).isNotEmpty ? json['weather'][0] : null;
    final main = json['main'] ?? {};
    final wind = json['wind'] ?? {};

    return WeatherModel(
      cityName: json['name'] ?? 'Unknown', // default value if null
      temperature: (main['temp'] ?? 0.0).toDouble(), // default 0.0 if null
      condition: weather != null ? weather['description'] ?? 'No description' : 'No description',
      highTemp: (main['temp_max'] ?? 0.0).toDouble(), // default 0.0 if null
      lowTemp: (main['temp_min'] ?? 0.0).toDouble(), // default 0.0 if null
      humidity: main['humidity'] ?? 0, // default 0 if null
      windSpeed: (wind['speed'] ?? 0.0).toDouble(), // default 0.0 if null
      icon: weather != null ? weather['icon'] ?? '' : '', // default empty string if null
    );
  }

  get value => null;

  Map<String, dynamic> toJson() {
    return {
      'name': cityName,
      'main': {
        'temp': temperature,
        'temp_max': highTemp,
        'temp_min': lowTemp,
        'humidity': humidity,
      },
      'weather': [
        {
          'description': condition,
          'icon': icon,
        }
      ],
      'wind': {
        'speed': windSpeed,
      },
    };
  }
}
