class WeatherData {
  final String name;
  final String country;
  final double temperature;
  final int humidity;
  final double windSpeed;
  final int pressure;
  final String description;
  final String icon;
  final double? lat;
  final double? lon;
  final DateTime? lastUpdated;

  WeatherData({
    required this.name,
    required this.country,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    required this.description,
    required this.icon,
    this.lat,
    this.lon,
    this.lastUpdated,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      name: json['name'] ?? 'Unknown',
      country: json['sys']?['country'] ?? '',
      temperature: (json['main']['temp'] as num).toDouble(),
      humidity: json['main']['humidity'] as int,
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      pressure: json['main']['pressure'] as int,
      description: json['weather'][0]['description'] ?? '',
      icon: json['weather'][0]['icon'] ?? '01d',
      lat: json['coord']?['lat']?.toDouble(),
      lon: json['coord']?['lon']?.toDouble(),
      lastUpdated: DateTime.now(),
    );
  }
}

class ForecastDay {
  final DateTime date;
  final double tempMax;
  final double tempMin;
  final int humidity;
  final double windSpeed;
  final String description;
  final String icon;
  final double? rainProbability;

  ForecastDay({
    required this.date,
    required this.tempMax,
    required this.tempMin,
    required this.humidity,
    required this.windSpeed,
    required this.description,
    required this.icon,
    this.rainProbability,
  });

  factory ForecastDay.fromJson(Map<String, dynamic> json) {
    return ForecastDay(
      date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      tempMax: (json['main']['temp_max'] as num).toDouble(),
      tempMin: (json['main']['temp_min'] as num).toDouble(),
      humidity: json['main']['humidity'] as int,
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      description: json['weather'][0]['description'] ?? '',
      icon: json['weather'][0]['icon'] ?? '01d',
      rainProbability: json['pop']?.toDouble(),
    );
  }
}

class RainForecast {
  final DateTime time;
  final double precipitation;

  RainForecast({
    required this.time,
    required this.precipitation,
  });

  factory RainForecast.fromJson(Map<String, dynamic> json) {
    return RainForecast(
      time: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      precipitation: (json['precipitation'] as num).toDouble(),
    );
  }
}

class SavedCity {
  final String id;
  final String name;
  final String country;
  final String? state;
  final double lat;
  final double lon;
  final DateTime addedAt;

  SavedCity({
    required this.id,
    required this.name,
    required this.country,
    this.state,
    required this.lat,
    required this.lon,
    required this.addedAt,
  });

  factory SavedCity.fromJson(Map<String, dynamic> json) {
    return SavedCity(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      country: json['country'] ?? '',
      state: json['state'],
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      addedAt: DateTime.parse(json['addedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'country': country,
      'state': state,
      'lat': lat,
      'lon': lon,
      'addedAt': addedAt.toIso8601String(),
    };
  }
}

class AppSettings {
  final String temperatureUnit;
  final String windSpeedUnit;
  final bool rainAlerts;
  final bool weatherUpdates;
  final bool darkMode;
  final String language;

  AppSettings({
    this.temperatureUnit = 'celsius',
    this.windSpeedUnit = 'kmh',
    this.rainAlerts = true,
    this.weatherUpdates = true,
    this.darkMode = true,
    this.language = 'en',
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      temperatureUnit: json['temperatureUnit'] ?? 'celsius',
      windSpeedUnit: json['windSpeedUnit'] ?? 'kmh',
      rainAlerts: json['rainAlerts'] ?? true,
      weatherUpdates: json['weatherUpdates'] ?? true,
      darkMode: json['darkMode'] ?? true,
      language: json['language'] ?? 'en',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperatureUnit': temperatureUnit,
      'windSpeedUnit': windSpeedUnit,
      'rainAlerts': rainAlerts,
      'weatherUpdates': weatherUpdates,
      'darkMode': darkMode,
      'language': language,
    };
  }

  AppSettings copyWith({
    String? temperatureUnit,
    String? windSpeedUnit,
    bool? rainAlerts,
    bool? weatherUpdates,
    bool? darkMode,
    String? language,
  }) {
    return AppSettings(
      temperatureUnit: temperatureUnit ?? this.temperatureUnit,
      windSpeedUnit: windSpeedUnit ?? this.windSpeedUnit,
      rainAlerts: rainAlerts ?? this.rainAlerts,
      weatherUpdates: weatherUpdates ?? this.weatherUpdates,
      darkMode: darkMode ?? this.darkMode,
      language: language ?? this.language,
    );
  }
}