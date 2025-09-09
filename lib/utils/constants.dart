import 'package:flutter/material.dart';

class AppColors {
  // Main dark theme colors (matching web version)
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkSecondary = Color(0xFF475569);
  static const Color primary = Color(0xFF3B82F6);
  static const Color accent = Color(0xFF06B6D4);
  
  // Light theme colors
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightSecondary = Color(0xFF64748B);
}

class AppConstants {
  static const String apiBaseUrl = 'http://localhost:5000';
  static const Duration refreshInterval = Duration(minutes: 5);
  static const Duration rainForecastInterval = Duration(minutes: 1);
  
  // Weather icon mappings
  static const Map<String, IconData> weatherIcons = {
    'clear': Icons.wb_sunny,
    'clouds': Icons.cloud,
    'rain': Icons.grain,
    'drizzle': Icons.grain,
    'thunderstorm': Icons.flash_on,
    'snow': Icons.ac_unit,
    'mist': Icons.blur_on,
    'smoke': Icons.blur_on,
    'haze': Icons.blur_on,
    'dust': Icons.blur_on,
    'fog': Icons.blur_on,
    'sand': Icons.blur_on,
    'ash': Icons.blur_on,
    'squall': Icons.air,
    'tornado': Icons.tornado,
  };
  
  // Popular cities for quick selection
  static const List<Map<String, dynamic>> popularCities = [
    {'name': 'New York', 'country': 'US', 'lat': 40.7128, 'lon': -74.0060},
    {'name': 'London', 'country': 'GB', 'lat': 51.5074, 'lon': -0.1278},
    {'name': 'Paris', 'country': 'FR', 'lat': 48.8566, 'lon': 2.3522},
    {'name': 'Tokyo', 'country': 'JP', 'lat': 35.6762, 'lon': 139.6503},
    {'name': 'Sydney', 'country': 'AU', 'lat': -33.8688, 'lon': 151.2093},
    {'name': 'Dubai', 'country': 'AE', 'lat': 25.2048, 'lon': 55.2708},
  ];
}