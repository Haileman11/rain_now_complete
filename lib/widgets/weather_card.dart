import 'package:flutter/material.dart';
import '../models/weather_models.dart';
import '../providers/settings_provider.dart';
import '../providers/language_provider.dart';
import '../utils/constants.dart';

class WeatherCard extends StatelessWidget {
  final WeatherData weather;
  final SettingsProvider settings;
  final LanguageProvider language;
  final bool isDarkMode;

  const WeatherCard({
    Key? key,
    required this.weather,
    required this.settings,
    required this.language,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        children: [
          // Main weather display
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          settings.formatTemperature(weather.temperature).replaceAll('°C', '').replaceAll('°F', ''),
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w300,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          settings.settings.temperatureUnit == 'fahrenheit' ? '°F' : '°C',
                          style: TextStyle(
                            fontSize: 18,
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      weather.description,
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                        fontSize: 16,
                        // textTransform: TextTransform.capitalize,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      language.t('updated_now'),
                      style: TextStyle(
                        color: isDarkMode ? Colors.white54 : Colors.black38,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: isDarkMode 
                      ? AppColors.darkSecondary 
                      : AppColors.lightSecondary,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Icon(
                  _getWeatherIcon(weather.icon),
                  size: 40,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Weather details grid
          Row(
            children: [
              Expanded(
                child: _buildWeatherStat(
                  language.t('humidity'),
                  '${weather.humidity}%',
                  Icons.water_drop_outlined,
                ),
              ),
              Expanded(
                child: _buildWeatherStat(
                  language.t('wind'),
                  settings.formatWindSpeed(weather.windSpeed),
                  Icons.air,
                ),
              ),
              Expanded(
                child: _buildWeatherStat(
                  language.t('pressure'),
                  '${weather.pressure} mb',
                  Icons.speed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.accent,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: isDarkMode ? Colors.white70 : Colors.black54,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  IconData _getWeatherIcon(String iconCode) {
    final iconMap = {
      '01d': Icons.wb_sunny,
      '01n': Icons.nightlight_round,
      '02d': Icons.sunny_snowing,
      '02n': Icons.cloud,
      '03d': Icons.cloud,
      '03n': Icons.cloud,
      '04d': Icons.cloud,
      '04n': Icons.cloud,
      '09d': Icons.grain,
      '09n': Icons.grain,
      '10d': Icons.grain,
      '10n': Icons.grain,
      '11d': Icons.flash_on,
      '11n': Icons.flash_on,
      '13d': Icons.ac_unit,
      '13n': Icons.ac_unit,
      '50d': Icons.blur_on,
      '50n': Icons.blur_on,
    };
    
    return iconMap[iconCode] ?? Icons.cloud;
  }
}