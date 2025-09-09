import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_models.dart';
import '../services/api_service.dart';

class SettingsProvider with ChangeNotifier {
  final SharedPreferences _prefs;
  AppSettings _settings = AppSettings();
  bool _isLoading = false;
  bool _isSaving = false;

  SettingsProvider(this._prefs) {
    loadSettings();
  }

  // Getters
  AppSettings get settings => _settings;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;

  // Temperature conversion
  String formatTemperature(double tempCelsius) {
    if (_settings.temperatureUnit == 'fahrenheit') {
      final fahrenheit = (tempCelsius * 9/5) + 32;
      return '${fahrenheit.round()}°F';
    }
    return '${tempCelsius.round()}°C';
  }
  
  // Wind speed conversion
  String formatWindSpeed(double speedMs) {
    switch (_settings.windSpeedUnit) {
      case 'mph':
        final mph = speedMs * 2.237;
        return '${mph.toStringAsFixed(1)} mph';
      case 'kmh':
        final kmh = speedMs * 3.6;
        return '${kmh.toStringAsFixed(1)} km/h';
      default:
        return '${speedMs.toStringAsFixed(1)} m/s';
    }
  }

  // Load settings
  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Try to load from backend first
      _settings = await ApiService.getSettings();
      
      // Save to local storage as backup
      await _saveSettingsLocally();
    } catch (e) {
      // Fallback to local storage
      await _loadSettingsLocally();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Load settings from local storage
  Future<void> _loadSettingsLocally() async {
    try {
      final String? settingsJson = _prefs.getString('app_settings');
      if (settingsJson != null) {
        final Map<String, dynamic> settingsMap = json.decode(settingsJson);
        _settings = AppSettings.fromJson(settingsMap);
      }
    } catch (e) {
      debugPrint('Failed to load local settings: $e');
      _settings = AppSettings(); // Use defaults
    }
  }
  
  // Save settings locally
  Future<void> _saveSettingsLocally() async {
    try {
      final String settingsJson = json.encode(_settings.toJson());
      await _prefs.setString('app_settings', settingsJson);
    } catch (e) {
      debugPrint('Failed to save local settings: $e');
    }
  }
  
  // Update a setting
  Future<void> updateSetting(String key, dynamic value) async {
    _isSaving = true;
    notifyListeners();
    
    try {
      // Update local settings
      switch (key) {
        case 'temperatureUnit':
          _settings = _settings.copyWith(temperatureUnit: value);
          break;
        case 'windSpeedUnit':
          _settings = _settings.copyWith(windSpeedUnit: value);
          break;
        case 'rainAlerts':
          _settings = _settings.copyWith(rainAlerts: value);
          break;
        case 'weatherUpdates':
          _settings = _settings.copyWith(weatherUpdates: value);
          break;
        case 'darkMode':
          _settings = _settings.copyWith(darkMode: value);
          break;
        case 'language':
          _settings = _settings.copyWith(language: value);
          break;
      }
      
      // Save locally first
      await _saveSettingsLocally();
      
      // Try to sync with backend
      try {
        _settings = await ApiService.updateSettings(_settings);
      } catch (e) {
        debugPrint('Failed to sync settings with backend: $e');
        // Continue with local settings
      }
      
    } catch (e) {
      debugPrint('Failed to update setting: $e');
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
  
  // Bulk update settings
  Future<void> updateSettings(AppSettings newSettings) async {
    _isSaving = true;
    notifyListeners();
    
    try {
      _settings = newSettings;
      await _saveSettingsLocally();
      
      try {
        _settings = await ApiService.updateSettings(_settings);
      } catch (e) {
        debugPrint('Failed to sync settings with backend: $e');
      }
      
    } catch (e) {
      debugPrint('Failed to update settings: $e');
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
  
  // Reset to defaults
  Future<void> resetToDefaults() async {
    await updateSettings(AppSettings());
  }
  
  // Clear all data
  Future<void> clearAllData() async {
    try {
      // Clear all SharedPreferences
      await _prefs.clear();
      
      // Reset to defaults
      _settings = AppSettings();
      notifyListeners();
      
    } catch (e) {
      debugPrint('Failed to clear data: $e');
    }
  }
}