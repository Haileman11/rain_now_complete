import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_models.dart';
import '../utils/constants.dart';

class ApiService {
  static const String baseUrl = AppConstants.apiBaseUrl;
  
  // Get current weather by coordinates
  static Future<WeatherData> getCurrentWeather(double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/weather/current?lat=$lat&lon=$lon'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WeatherData.fromJson(data);
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      // Fallback to demo data
      return WeatherData(
        name: 'Demo Location',
        country: 'XX',
        temperature: 22.0,
        humidity: 65,
        windSpeed: 3.5,
        pressure: 1013,
        description: 'Clear sky',
        icon: '01d',
        lat: lat,
        lon: lon,
        lastUpdated: DateTime.now(),
      );
    }
  }
  
  // Get 7-day forecast
  static Future<List<ForecastDay>> getForecast(double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/weather/forecast?lat=$lat&lon=$lon'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> list = data['list'] ?? [];
        
        // Group by day and take one per day
        final Map<String, ForecastDay> dailyForecasts = {};
        for (var item in list) {
          final forecast = ForecastDay.fromJson(item);
          final dayKey = '${forecast.date.year}-${forecast.date.month}-${forecast.date.day}';
          
          if (!dailyForecasts.containsKey(dayKey)) {
            dailyForecasts[dayKey] = forecast;
          }
        }
        
        return dailyForecasts.values.take(7).toList();
      } else {
        throw Exception('Failed to load forecast data');
      }
    } catch (e) {
      // Fallback to demo data
      return _getDemoForecast();
    }
  }
  
  // Get minute-by-minute rain forecast
  static Future<List<RainForecast>> getRainForecast(double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/weather/rain-forecast?lat=$lat&lon=$lon'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> minutely = data['minutely'] ?? [];
        
        return minutely.map((item) => RainForecast.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load rain forecast');
      }
    } catch (e) {
      // Fallback to demo data
      return _getDemoRainForecast();
    }
  }
  
  // Search cities
  static Future<List<Map<String, dynamic>>> searchCities(String query) async {
    if (query.length < 2) return [];
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/cities/search?q=${Uri.encodeComponent(query)}'),
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> results = json.decode(response.body);
        return results.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to search cities');
      }
    } catch (e) {
      // Fallback to popular cities
      return AppConstants.popularCities
          .where((city) => city['name']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    }
  }
  
  // Get settings from backend
  static Future<AppSettings> getSettings() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/settings'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return AppSettings.fromJson(data);
      } else {
        throw Exception('Failed to load settings');
      }
    } catch (e) {
      // Return default settings
      return AppSettings();
    }
  }
  
  // Update settings on backend
  static Future<AppSettings> updateSettings(AppSettings settings) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/api/settings'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(settings.toJson()),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return AppSettings.fromJson(data);
      } else {
        throw Exception('Failed to update settings');
      }
    } catch (e) {
      // Return the settings as-is if backend fails
      return settings;
    }
  }
  
  // Demo data generators
  static List<ForecastDay> _getDemoForecast() {
    final now = DateTime.now();
    return List.generate(7, (index) {
      return ForecastDay(
        date: now.add(Duration(days: index)),
        tempMax: 25.0 + (index % 3) * 2,
        tempMin: 18.0 + (index % 3) * 2,
        humidity: 60 + (index % 4) * 5,
        windSpeed: 3.0 + (index % 3),
        description: ['Clear sky', 'Few clouds', 'Scattered clouds'][index % 3],
        icon: ['01d', '02d', '03d'][index % 3],
        rainProbability: (index % 4) * 0.25,
      );
    });
  }
  
  static List<RainForecast> _getDemoRainForecast() {
    final now = DateTime.now();
    return List.generate(60, (index) {
      return RainForecast(
        time: now.add(Duration(minutes: index)),
        precipitation: index > 20 && index < 35 ? (index - 20) * 0.2 : 0.0,
      );
    });
  }
}