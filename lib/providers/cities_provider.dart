import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_models.dart';
import '../services/api_service.dart';

class CitiesProvider with ChangeNotifier {
  final SharedPreferences _prefs;
  List<SavedCity> _savedCities = [];
  Map<String, WeatherData> _cityWeatherData = {};
  List<Map<String, dynamic>> _searchResults = [];
  
  bool _isSearching = false;
  bool _isLoadingWeather = false;

  CitiesProvider(this._prefs) {
    loadSavedCities();
  }

  // Getters
  List<SavedCity> get savedCities => _savedCities;
  Map<String, WeatherData> get cityWeatherData => _cityWeatherData;
  List<Map<String, dynamic>> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  bool get isLoadingWeather => _isLoadingWeather;

  // Load saved cities from preferences
  Future<void> loadSavedCities() async {
    try {
      final String? citiesJson = _prefs.getString('saved_cities');
      if (citiesJson != null) {
        final List<dynamic> citiesList = json.decode(citiesJson);
        _savedCities = citiesList.map((json) => SavedCity.fromJson(json)).toList();
        notifyListeners();
        
        // Load weather for all saved cities
        loadWeatherForAllCities();
      }
    } catch (e) {
      debugPrint('Failed to load saved cities: $e');
    }
  }
  
  // Save cities to preferences
  Future<void> _saveCitiesToPrefs() async {
    try {
      final String citiesJson = json.encode(
        _savedCities.map((city) => city.toJson()).toList(),
      );
      await _prefs.setString('saved_cities', citiesJson);
    } catch (e) {
      debugPrint('Failed to save cities: $e');
    }
  }
  
  // Add a new city
  Future<void> addCity(Map<String, dynamic> cityData) async {
    try {
      final String cityId = '${cityData['lat']}_${cityData['lon']}';
      
      // Check if city already exists
      if (_savedCities.any((city) => city.id == cityId)) {
        return; // City already saved
      }
      
      final SavedCity newCity = SavedCity(
        id: cityId,
        name: cityData['name'],
        country: cityData['country'],
        state: cityData['state'],
        lat: cityData['lat'],
        lon: cityData['lon'],
        addedAt: DateTime.now(),
      );
      
      _savedCities.insert(0, newCity); // Add to beginning
      await _saveCitiesToPrefs();
      notifyListeners();
      
      // Load weather for the new city
      loadWeatherForCity(newCity);
    } catch (e) {
      debugPrint('Failed to add city: $e');
    }
  }
  
  // Remove a city
  Future<void> removeCity(String cityId) async {
    try {
      _savedCities.removeWhere((city) => city.id == cityId);
      _cityWeatherData.remove(cityId);
      await _saveCitiesToPrefs();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to remove city: $e');
    }
  }
  
  // Search cities
  Future<void> searchCities(String query) async {
    if (query.length < 2) {
      _searchResults = [];
      notifyListeners();
      return;
    }
    
    _isSearching = true;
    notifyListeners();
    
    try {
      _searchResults = await ApiService.searchCities(query);
    } catch (e) {
      debugPrint('Failed to search cities: $e');
      _searchResults = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }
  
  // Clear search results
  void clearSearchResults() {
    _searchResults = [];
    notifyListeners();
  }
  
  // Load weather for all saved cities
  Future<void> loadWeatherForAllCities() async {
    if (_savedCities.isEmpty) return;
    
    _isLoadingWeather = true;
    notifyListeners();
    
    for (final city in _savedCities) {
      try {
        final weather = await ApiService.getCurrentWeather(city.lat, city.lon);
        _cityWeatherData[city.id] = weather;
      } catch (e) {
        debugPrint('Failed to load weather for ${city.name}: $e');
      }
    }
    
    _isLoadingWeather = false;
    notifyListeners();
  }
  
  // Load weather for a single city
  Future<void> loadWeatherForCity(SavedCity city) async {
    try {
      final weather = await ApiService.getCurrentWeather(city.lat, city.lon);
      _cityWeatherData[city.id] = weather;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load weather for ${city.name}: $e');
    }
  }
  
  // Refresh weather for all cities
  Future<void> refreshAllCityWeather() async {
    await loadWeatherForAllCities();
  }
  
  // Get weather for a specific city
  WeatherData? getWeatherForCity(String cityId) {
    return _cityWeatherData[cityId];
  }
}