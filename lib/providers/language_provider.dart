import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  final SharedPreferences _prefs;
  String _currentLanguage = 'en';

  // Translation maps
  static const Map<String, Map<String, String>> _translations = {
    'en': {
      'home': 'Home',
      'forecast': 'Forecast',
      'cities': 'Cities',
      'settings': 'Settings',
      'search_location': 'Search Location',
      'search_city': 'Search for a city...',
      'current_weather': 'Current Weather',
      'rain_forecast': 'Next Hour Rain Forecast',
      'seven_day_forecast': '7-Day Forecast',
      'saved_cities': 'Saved Cities',
      'add_city': 'Add City',
      'temperature_unit': 'Temperature Unit',
      'wind_speed_unit': 'Wind Speed Unit',
      'rain_alerts': 'Rain Alerts',
      'weather_updates': 'Weather Updates',
      'dark_mode': 'Dark Mode',
      'language': 'Language',
      'about': 'About',
      'share_app': 'Share App',
      'clear_data': 'Clear Data',
      'celsius': 'Celsius',
      'fahrenheit': 'Fahrenheit',
      'kmh': 'km/h',
      'mph': 'mph',
      'ms': 'm/s',
      'english': 'English',
      'spanish': 'Spanish',
      'french': 'French',
      'german': 'German',
      'chinese': 'Chinese',
      'arabic': 'Arabic',
      'humidity': 'Humidity',
      'wind': 'Wind',
      'pressure': 'Pressure',
      'updated_now': 'Updated just now',
      'rain_expected': 'Rain Expected',
      'rain_expected_desc': 'Light rain is expected in the next hour.',
      'no_rain_expected': 'No rain expected in the next hour',
      'enable_location': 'Enable Location',
      'location_required': 'Location access required',
      'try_again': 'Try Again',
      'loading': 'Loading...',
      'error_loading_weather': 'Error loading weather data',
      'error_loading_forecast': 'Error loading forecast data',
      'refresh': 'Refresh',
      'today': 'Today',
      'tomorrow': 'Tomorrow',
      'monday': 'Monday',
      'tuesday': 'Tuesday',
      'wednesday': 'Wednesday',
      'thursday': 'Thursday',
      'friday': 'Friday',
      'saturday': 'Saturday',
      'sunday': 'Sunday',
    },
    'es': {
      'home': 'Inicio',
      'forecast': 'Pronóstico',
      'cities': 'Ciudades',
      'settings': 'Configuración',
      'search_location': 'Buscar Ubicación',
      'search_city': 'Buscar una ciudad...',
      'current_weather': 'Tiempo Actual',
      'rain_forecast': 'Pronóstico de Lluvia de la Próxima Hora',
      'seven_day_forecast': 'Pronóstico de 7 Días',
      'saved_cities': 'Ciudades Guardadas',
      'add_city': 'Agregar Ciudad',
      'temperature_unit': 'Unidad de Temperatura',
      'wind_speed_unit': 'Unidad de Velocidad del Viento',
      'rain_alerts': 'Alertas de Lluvia',
      'weather_updates': 'Actualizaciones del Tiempo',
      'dark_mode': 'Modo Oscuro',
      'language': 'Idioma',
      'about': 'Acerca de',
      'share_app': 'Compartir App',
      'clear_data': 'Limpiar Datos',
      'celsius': 'Celsius',
      'fahrenheit': 'Fahrenheit',
      'kmh': 'km/h',
      'mph': 'mph',
      'ms': 'm/s',
      'english': 'Inglés',
      'spanish': 'Español',
      'french': 'Francés',
      'german': 'Alemán',
      'chinese': 'Chino',
      'arabic': 'Árabe',
      'humidity': 'Humedad',
      'wind': 'Viento',
      'pressure': 'Presión',
      'updated_now': 'Actualizado ahora',
      'rain_expected': 'Se Espera Lluvia',
      'rain_expected_desc': 'Se espera lluvia ligera en la próxima hora.',
      'no_rain_expected': 'No se espera lluvia en la próxima hora',
      'enable_location': 'Habilitar Ubicación',
      'location_required': 'Se requiere acceso a la ubicación',
      'try_again': 'Intentar de Nuevo',
      'loading': 'Cargando...',
      'error_loading_weather': 'Error al cargar datos del tiempo',
      'error_loading_forecast': 'Error al cargar datos del pronóstico',
      'refresh': 'Actualizar',
      'today': 'Hoy',
      'tomorrow': 'Mañana',
      'monday': 'Lunes',
      'tuesday': 'Martes',
      'wednesday': 'Miércoles',
      'thursday': 'Jueves',
      'friday': 'Viernes',
      'saturday': 'Sábado',
      'sunday': 'Domingo',
    },
  };

  LanguageProvider(this._prefs) {
    loadLanguage();
  }

  String get currentLanguage => _currentLanguage;

  Future<void> loadLanguage() async {
    _currentLanguage = _prefs.getString('language') ?? 'en';
    notifyListeners();
  }

  Future<void> setLanguage(String languageCode) async {
    if (_currentLanguage != languageCode) {
      _currentLanguage = languageCode;
      await _prefs.setString('language', languageCode);
      notifyListeners();
    }
  }

  String translate(String key) {
    return _translations[_currentLanguage]?[key] ?? 
           _translations['en']?[key] ?? 
           key;
  }

  String t(String key) => translate(key);
}