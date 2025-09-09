import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cities_provider.dart';
import '../providers/weather_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/constants.dart';
import '../widgets/search_modal.dart';

class CitiesScreen extends StatefulWidget {
  const CitiesScreen({Key? key}) : super(key: key);

  @override
  State<CitiesScreen> createState() => _CitiesScreenState();
}

class _CitiesScreenState extends State<CitiesScreen> {
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CitiesProvider>().loadWeatherForAllCities();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;
    final language = context.watch<LanguageProvider>();
    final citiesProvider = context.watch<CitiesProvider>();
    final settingsProvider = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(isDarkMode, language, citiesProvider),
            
            // Content
            Expanded(
              child: Stack(
                children: [
                  _buildContent(isDarkMode, language, citiesProvider, settingsProvider),
                  // Search Modal Overlay
                  if (_showSearch) 
                    SearchModal(
                      onClose: () => setState(() => _showSearch = false),
                      onLocationSelected: (location) {
                        citiesProvider.addCity(location);
                        setState(() => _showSearch = false);
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode, LanguageProvider language, CitiesProvider citiesProvider) {
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
              Icons.location_on,
              color: AppColors.primary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              language.t('saved_cities'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () => citiesProvider.refreshAllCityWeather(),
              icon: Icon(
                Icons.refresh,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
            IconButton(
              onPressed: () => setState(() => _showSearch = true),
              icon: Icon(
                Icons.add,
                color: AppColors.primary,
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
    CitiesProvider citiesProvider,
    SettingsProvider settingsProvider,
  ) {
    if (citiesProvider.isLoadingWeather && citiesProvider.savedCities.isEmpty) {
      return _buildLoadingState(isDarkMode, language);
    }

    if (citiesProvider.savedCities.isEmpty) {
      return _buildEmptyState(language, isDarkMode);
    }

    return RefreshIndicator(
      onRefresh: () => citiesProvider.refreshAllCityWeather(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: citiesProvider.savedCities.length,
        itemBuilder: (context, index) {
          final city = citiesProvider.savedCities[index];
          final weather = citiesProvider.getWeatherForCity(city.id);
          
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              onTap: () {
                // Set as active location
                context.read<WeatherProvider>().setSelectedLocation({
                  'name': '${city.name}, ${city.country}',
                  'lat': city.lat,
                  'lon': city.lon,
                });
                
                // Navigate back to home
                DefaultTabController.of(context)?.animateTo(0);
              },
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isDarkMode 
                      ? AppColors.darkSecondary 
                      : AppColors.lightSecondary,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  weather != null ? _getWeatherIcon(weather.icon) : Icons.location_city,
                  color: AppColors.accent,
                  size: 24,
                ),
              ),
              title: Text(
                city.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${city.state != null ? '${city.state}, ' : ''}${city.country}',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.white60 : Colors.black54,
                    ),
                  ),
                  if (weather != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      weather.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? Colors.white54 : Colors.black45,
                      ),
                    ),
                  ],
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (weather != null)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          settingsProvider.formatTemperature(weather.temperature),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w300,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        if (weather.humidity > 0)
                          Text(
                            '${weather.humidity}% ${language.t('humidity')}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDarkMode ? Colors.white54 : Colors.black45,
                            ),
                          ),
                      ],
                    )
                  else
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _showDeleteConfirmation(city.id, city.name),
                    icon: Icon(
                      Icons.delete_outline,
                      color: Colors.red.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState(bool isDarkMode, LanguageProvider language) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            language.t('loading'),
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
            Icons.location_city,
            size: 64,
            color: isDarkMode ? Colors.white30 : Colors.black26,
          ),
          const SizedBox(height: 16),
          Text(
            'No saved cities',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add cities to see their weather',
            style: TextStyle(
              color: isDarkMode ? Colors.white54 : Colors.black38,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => setState(() => _showSearch = true),
            icon: const Icon(Icons.add),
            label: Text(language.t('add_city')),
          ),
          const SizedBox(height: 32),
          // Quick add popular cities
          Text(
            'Popular cities:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.popularCities.map((city) {
              return OutlinedButton(
                onPressed: () {
                  context.read<CitiesProvider>().addCity(city);
                },
                child: Text(city['name']),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(String cityId, String cityName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove City'),
          content: Text('Are you sure you want to remove $cityName from your saved cities?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.read<CitiesProvider>().removeCity(cityId);
                Navigator.of(context).pop();
              },
              child: const Text('Remove'),
            ),
          ],
        );
      },
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