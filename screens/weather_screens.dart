import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import '../controllers/weather_controller.dart'; // Import the controller
import '../models/weather_model.dart';

class WeatherScreen extends StatelessWidget {
  const WeatherScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final WeatherController weatherController = Get.put(WeatherController());

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: const Color(0xFF1C1C1E),
        body: TabBarView(
          physics: const BouncingScrollPhysics(),
          children: [
            MainWeatherView(),
            WeeklyForecastScreen(),
            WeatherMapScreen(),
            WeatherDetailsScreen(),
            SearchLocationScreen(),
          ],
        ),
        bottomNavigationBar: Container(
          color: const Color(0xFF1C1C1E),
          child: const TabBar(
            indicatorColor: Colors.blueAccent,
            tabs: [
              Tab(icon: Icon(Icons.home, color: Colors.white)),
              Tab(icon: Icon(Icons.calendar_today, color: Colors.white)),
              Tab(icon: Icon(Icons.map, color: Colors.white)),
              Tab(icon: Icon(Icons.analytics, color: Colors.white)),
              Tab(icon: Icon(Icons.search, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

class MainWeatherView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final WeatherController weatherController = Get.find();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() {
              var weather = weatherController.currentWeather?.value;
              if (weather == null) {
                return const Text(
                  'Fetching weather data...',
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.w600, color: Colors.white),
                );
              }
              return Text(
                weather.city.isNotEmpty ? weather.city : 'Mogadishu',
                style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w600, color: Colors.white),
              );
            }),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() {
                  var weather = weatherController.currentWeather?.value;
                  if (weather == null) return const Text('21', style: TextStyle(fontSize: 96, fontWeight: FontWeight.w200, color: Colors.white));
                  return Text(
                    weather.temperature.isNotEmpty ? weather.temperature : '21',
                    style: const TextStyle(fontSize: 96, fontWeight: FontWeight.w200, color: Colors.white),
                  );
                }),
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text(
                    '°',
                    style: TextStyle(fontSize: 40, color: Colors.white),
                  ),
                ),
              ],
            ),
            Obx(() {
              var weather = weatherController.currentWeather?.value;
              if (weather == null) return const Text('Partly Cloudy', style: TextStyle(fontSize: 20, color: Colors.grey));
              return Text(
                weather.condition.isNotEmpty ? weather.condition : 'Partly Cloudy',
                style: const TextStyle(fontSize: 20, color: Colors.grey),
              );
            }),
            const SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: List.generate(5, (index) => _HourlyWeatherItem(time: '${index + 10}PM', temp: '21°')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HourlyWeatherItem extends StatelessWidget {
  final String time;
  final String temp;

  const _HourlyWeatherItem({required this.time, required this.temp});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8.0),
      child: Column(
        children: [
          Text(time, style: const TextStyle(color: Colors.white)),
          Text(temp, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

class WeeklyForecastScreen extends StatelessWidget {
  const WeeklyForecastScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              '10-DAY FORECAST',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Text(
                    index == 0 ? 'Today' : 'Day ${index + 1}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  title: const Icon(Icons.cloud),
                  trailing: Text(
                    '${29 - index}° / ${15 - index}°',
                    style: const TextStyle(color: Colors.grey),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class WeatherMapScreen extends StatelessWidget {
  const WeatherMapScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final WeatherController weatherController = Get.find();

    return Obx(() {
      var weather = weatherController.currentWeather?.value;
      if (weather == null) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      double latitude = weather.latitude ?? 0.0;
      double longitude = weather.longitude ?? 0.0;

      return FlutterMap(
        options: MapOptions(
          center: LatLng(latitude, longitude), // Correct center parameter
          zoom: 12.0, // Correct zoom parameter
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(latitude, longitude), // Correct point parameter
                width: 80.0,
                height: 80.0,
                builder: (ctx) => const Icon(
                  Icons.location_on,
                  size: 40,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      );
    });
  }
}


class WeatherDetailsScreen extends StatelessWidget {
  const WeatherDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'WEATHER DETAILS',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              children: const [
                WeatherDetailCard(
                  title: 'Temperature',
                  value: '21°',
                  subtitle: 'Feels like 20°',
                ),
                WeatherDetailCard(
                  title: 'Wind',
                  value: '4 km/h',
                  subtitle: 'Light breeze',
                ),
                WeatherDetailCard(
                  title: 'Humidity',
                  value: '73%',
                  subtitle: 'Normal',
                ),
                WeatherDetailCard(
                  title: 'Pressure',
                  value: '1015 hPa',
                  subtitle: 'Normal',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class WeatherDetailCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;

  const WeatherDetailCard({
    Key? key,
    required this.title,
    required this.value,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchLocationScreen extends StatelessWidget {
  const SearchLocationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for a city or airport',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          ListTile(
            title: const Text('My Location'),
            subtitle: const Text('Mogadishu'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  '21°',
                  style: TextStyle(fontSize: 20),
                ),
                Icon(Icons.cloud),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
