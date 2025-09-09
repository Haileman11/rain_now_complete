import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/weather_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/constants.dart';
import '../widgets/forecast_chart.dart';

class ForecastScreen extends StatefulWidget {
  const ForecastScreen({Key? key}) : super(key: key);

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadForecastData();
    });
  }

  Future<void> _loadForecastData() async {
    final weatherProvider = context.read<WeatherProvider>();
    final location = weatherProvider.getActiveLocation();
    if (location != null) {
      await weatherProvider.loadForecast(location['lat']!, location['lon']!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;
    final language = context.watch<LanguageProvider>();
    final weatherProvider = context.watch<WeatherProvider>();
    final settingsProvider = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(isDarkMode, language),
            
            // Content
            Expanded(
              child: _buildContent(isDarkMode, language, weatherProvider, settingsProvider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode, LanguageProvider language) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkCard : AppColors.lightCard,
        border: Border(
          bottom: BorderSide(
            color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.bar_chart,
              color: AppColors.primary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              language.t('seven_day_forecast'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () => _loadForecastData(),
              icon: Icon(
                Icons.refresh,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    bool isDarkMode,
    LanguageProvider language,
    WeatherProvider weatherProvider,
    SettingsProvider settingsProvider,
  ) {
    if (weatherProvider.isLoadingForecast) {
      return _buildLoadingState(isDarkMode);
    }

    if (weatherProvider.forecast.isEmpty) {
      return _buildEmptyState(language, isDarkMode);
    }

    return RefreshIndicator(
      onRefresh: () => _loadForecastData(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Temperature Chart
            _buildTemperatureChart(weatherProvider, isDarkMode, language, settingsProvider),
            
            const SizedBox(height: 24),
            
            // Daily Forecast List
            _buildDailyForecastList(weatherProvider, settingsProvider, language, isDarkMode),
            
            const SizedBox(height: 100), // Space for bottom navigation
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            'Loading forecast...',
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(LanguageProvider language, bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off,
            size: 64,
            color: isDarkMode ? Colors.white30 : Colors.black26,
          ),
          const SizedBox(height: 16),
          Text(
            language.t('error_loading_forecast'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Unable to load forecast data',
            style: TextStyle(
              color: isDarkMode ? Colors.white54 : Colors.black38,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _loadForecastData(),
            child: Text(language.t('try_again')),
          ),
        ],
      ),
    );
  }

  Widget _buildTemperatureChart(
    WeatherProvider weatherProvider,
    bool isDarkMode,
    LanguageProvider language,
    SettingsProvider settingsProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Temperature Trend',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ForecastChart(
            forecastData: weatherProvider.forecast,
            isDarkMode: isDarkMode,
            settings: settingsProvider,
          ),
        ],
      ),
    );
  }

  Widget _buildDailyForecastList(
    WeatherProvider weatherProvider,
    SettingsProvider settingsProvider,
    LanguageProvider language,
    bool isDarkMode,
  ) {
    return Column(
      children: weatherProvider.forecast.asMap().entries.map((entry) {
        final index = entry.key;
        final forecast = entry.value;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Row(
            children: [
              // Date
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getDayName(forecast.date, index, language),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      DateFormat('MMM d').format(forecast.date),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Weather Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDarkMode 
                      ? AppColors.darkSecondary 
                      : AppColors.lightSecondary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  _getWeatherIcon(forecast.icon),
                  color: AppColors.accent,
                  size: 24,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Description
              Expanded(
                flex: 2,
                child: Text(
                  forecast.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
              ),
              
              // Temperature
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    settingsProvider.formatTemperature(forecast.tempMax),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    settingsProvider.formatTemperature(forecast.tempMin),
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(width: 8),
              
              // Rain probability
              if (forecast.rainProbability != null && forecast.rainProbability! > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.water_drop,
                        size: 12,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${(forecast.rainProbability! * 100).round()}%',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.accent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _getDayName(DateTime date, int index, LanguageProvider language) {
    if (index == 0) return language.t('today');
    if (index == 1) return language.t('tomorrow');
    
    final weekdays = [
      language.t('monday'),
      language.t('tuesday'),
      language.t('wednesday'),
      language.t('thursday'),
      language.t('friday'),
      language.t('saturday'),
      language.t('sunday'),
    ];
    
    return weekdays[date.weekday - 1];
  }

  IconData _getWeatherIcon(String iconCode) {
    final iconMap = {
      '01d': Icons.wb_sunny,
      '01n': Icons.nightlight_round,
      '02d': Icons.sunny,
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