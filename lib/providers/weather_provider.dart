import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/weather_models.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

class WeatherProvider with ChangeNotifier {
  WeatherData? _currentWeather;
  List<ForecastDay> _forecast = [];
  List<RainForecast> _rainForecast = [];
  Position? _currentPosition;
  Map<String, dynamic>? _selectedLocation;
  
  bool _isLoadingWeather = false;
  bool _isLoadingForecast = false;
  bool _isLoadingRain = false;
  String? _weatherError;
  String? _locationError;
  
  bool _hasShownRainAlert = false;
  final NotificationService _notificationService = NotificationService();

  // Getters
  WeatherData? get currentWeather => _currentWeather;
  List<ForecastDay> get forecast => _forecast;
  List<RainForecast> get rainForecast => _rainForecast;
  Position? get currentPosition => _currentPosition;
  Map<String, dynamic>? get selectedLocation => _selectedLocation;
  
  bool get isLoadingWeather => _isLoadingWeather;
  bool get isLoadingForecast => _isLoadingForecast;
  bool get isLoadingRain => _isLoadingRain;
  String? get weatherError => _weatherError;
  String? get locationError => _locationError;
  
  bool get hasRainAlert => _rainForecast.any((rain) => rain.precipitation > 0.1);

  // Get current location (only get GPS, don't auto-load weather)
  Future<void> getCurrentLocation({bool loadWeatherData = false}) async {
    try {
      _locationError = null;
      notifyListeners();
      
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _locationError = 'Location services are disabled';
        notifyListeners();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _locationError = 'Location permissions are denied';
          notifyListeners();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _locationError = 'Location permissions are permanently denied';
        notifyListeners();
        return;
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      
      notifyListeners();
      
      // Only load weather data if explicitly requested or no location selected
      if (loadWeatherData && _currentPosition != null) {
        await this.loadWeatherData(_currentPosition!.latitude, _currentPosition!.longitude);
      }
    } catch (e) {
      _locationError = 'Failed to get location: $e';
      notifyListeners();
    }
  }
  
  // Set selected location and save it persistently
  Future<void> setSelectedLocation(Map<String, dynamic> location) async {
    _selectedLocation = location;
    notifyListeners();
    
    // Save to persistent storage
    await _saveSelectedLocation(location);
    
    // Load weather for selected location
    loadWeatherData(location['lat'], location['lon']);
  }
  
  // Clear selected location and use current GPS location
  Future<void> useCurrentLocation() async {
    _selectedLocation = null;
    notifyListeners();
    
    // Clear from persistent storage
    await _clearSelectedLocation();
    
    // Reload weather for current position if available
    if (_currentPosition != null) {
      loadWeatherData(_currentPosition!.latitude, _currentPosition!.longitude);
    }
  }
  
  // Clear selected location without loading GPS data
  Future<void> clearSelectedLocation() async {
    _selectedLocation = null;
    await _clearSelectedLocation();
    notifyListeners();
  }
  
  // Get active location coordinates
  Map<String, double>? getActiveLocation() {
    if (_selectedLocation != null) {
      return {
        'lat': _selectedLocation!['lat'],
        'lon': _selectedLocation!['lon'],
      };
    } else if (_currentPosition != null) {
      return {
        'lat': _currentPosition!.latitude,
        'lon': _currentPosition!.longitude,
      };
    }
    return null;
  }
  
  // Load weather data
  Future<void> loadWeatherData(double lat, double lon) async {
    _isLoadingWeather = true;
    _weatherError = null;
    notifyListeners();
    
    try {
      _currentWeather = await ApiService.getCurrentWeather(lat, lon);
      _weatherError = null;
    } catch (e) {
      _weatherError = 'Failed to load weather: $e';
    } finally {
      _isLoadingWeather = false;
      notifyListeners();
    }
  }
  
  // Load forecast data
  Future<void> loadForecast(double lat, double lon) async {
    _isLoadingForecast = true;
    notifyListeners();
    
    try {
      _forecast = await ApiService.getForecast(lat, lon);
    } catch (e) {
      debugPrint('Failed to load forecast: $e');
    } finally {
      _isLoadingForecast = false;
      notifyListeners();
    }
  }
  
  // Load rain forecast
  Future<void> loadRainForecast(double lat, double lon) async {
    _isLoadingRain = true;
    notifyListeners();
    
    try {
      final previousRainAlert = hasRainAlert;
      _rainForecast = await ApiService.getRainForecast(lat, lon);
      
      // Check for rain alert and send notification
      await _checkRainAlert(previousRainAlert);
    } catch (e) {
      debugPrint('Failed to load rain forecast: $e');
    } finally {
      _isLoadingRain = false;
      notifyListeners();
    }
  }
  
  // Check rain alert and send notification
  Future<void> _checkRainAlert(bool previousRainAlert) async {
    final currentRainAlert = hasRainAlert;
    
    // Only send notification if rain alert is new (wasn't there before)
    if (currentRainAlert && !previousRainAlert && !_hasShownRainAlert) {
      _hasShownRainAlert = true;
      
      // Find when rain will start
      final firstRain = _rainForecast.firstWhere(
        (rain) => rain.precipitation > 0.1,
        orElse: () => _rainForecast.first,
      );
      
      final minutesToRain = firstRain.time.difference(DateTime.now()).inMinutes;
      
      String locationName = 'your location';
      if (_selectedLocation != null) {
        locationName = _selectedLocation!['name'];
      } else if (_currentWeather != null) {
        locationName = _currentWeather!.name;
      }
      
      await _notificationService.showRainAlert(
        title: '🌧️ Rain Alert',
        body: 'Rain expected in $minutesToRain minutes at $locationName',
        location: locationName,
      );
    }
    
    // Reset flag if no rain detected
    if (!currentRainAlert) {
      _hasShownRainAlert = false;
    }
  }
  
  // Initialize notification service
  Future<void> initializeNotifications() async {
    await _notificationService.initialize();
  }
  
  // Save selected location to persistent storage
  Future<void> _saveSelectedLocation(Map<String, dynamic> location) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locationJson = jsonEncode(location);
      await prefs.setString('selected_location', locationJson);
    } catch (e) {
      debugPrint('Error saving selected location: $e');
    }
  }
  
  // Load selected location from persistent storage
  Future<void> _loadSelectedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locationJson = prefs.getString('selected_location');
      if (locationJson != null) {
        _selectedLocation = jsonDecode(locationJson);
        debugPrint('Restored selected location: ${_selectedLocation!['name']}');
      }
    } catch (e) {
      debugPrint('Error loading selected location: $e');
    }
  }
  
  // Clear selected location from persistent storage
  Future<void> _clearSelectedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('selected_location');
      debugPrint('Cleared selected location from storage');
    } catch (e) {
      debugPrint('Error clearing selected location: $e');
    }
  }
  
  // Initialize weather data (called on app start only)
  Future<void> initializeWeatherData() async {
    // First, try to restore saved location
    await _loadSelectedLocation();
    
    // Get GPS location permission
    await getCurrentLocation();
    
    // Load weather data based on priority: saved location > GPS
    if (_selectedLocation != null) {
      // Load weather for saved selected location
      await loadWeatherData(_selectedLocation!['lat'], _selectedLocation!['lon']);
    } else if (_currentPosition != null) {
      // Load weather for GPS location only if no saved location
      await loadWeatherData(_currentPosition!.latitude, _currentPosition!.longitude);
    }
  }
  
  // Refresh all weather data
  Future<void> refreshWeatherData() async {
    final location = getActiveLocation();
    if (location != null) {
      await Future.wait([
        loadWeatherData(location['lat']!, location['lon']!),
        loadForecast(location['lat']!, location['lon']!),
        loadRainForecast(location['lat']!, location['lon']!),
      ]);
    }
  }
}