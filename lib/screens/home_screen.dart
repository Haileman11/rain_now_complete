import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../providers/weather_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/subscription_provider.dart';
import '../utils/constants.dart';
import '../widgets/weather_card.dart';
import '../widgets/rain_chart.dart';
import '../widgets/weather_map.dart';
import '../widgets/search_modal.dart';
import '../widgets/rain_alert_banner.dart';
import '../services/admob_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showSearch = false;
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeWeatherData();
    });
    _loadInterstitial();

  }

  Future<void> _initializeWeatherData() async {
    final weatherProvider = context.read<WeatherProvider>();
    
    // Initialize notifications only once
    await weatherProvider.initializeNotifications();
    
    // Only initialize weather data if no location data exists
    if (weatherProvider.currentWeather == null && 
        weatherProvider.selectedLocation == null) {
      await weatherProvider.initializeWeatherData();
    }
  }

  void _loadInterstitial() {
    InterstitialAd.load(
      adUnitId: AdMobService.interstitialAdUnitId, // Use test ID
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;

          // Show right away when loaded (first app open)
          _interstitialAd?.show();

          // Dispose after showing
          _interstitialAd?.fullScreenContentCallback =
              FullScreenContentCallback(
            onAdDismissedFullScreenContent: (InterstitialAd ad) {
              ad.dispose();
            },
            onAdFailedToShowFullScreenContent:
                (InterstitialAd ad, AdError error) {
              ad.dispose();
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('Interstitial failed to load: $error');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;
    final language = context.watch<LanguageProvider>();
    final weatherProvider = context.watch<WeatherProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final subscriptionProvider = context.watch<SubscriptionProvider>();

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header
            _buildHeader(isDarkMode, language, weatherProvider),
            
            // Main Content
            Expanded(
              child: Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: _buildMainContent(isDarkMode, language, weatherProvider, settingsProvider),
                      ),
                      // Banner Ad for free users
                      if (subscriptionProvider.showAds)
                        Container(
                          height: 60,
                          margin: const EdgeInsets.all(8),
                          child: subscriptionProvider.getBannerAdWidget(),
                        ),
                    ],
                  ),
                  // Search Modal Overlay
                  if (_showSearch) 
                    SearchModal(
                      onClose: () => setState(() => _showSearch = false),
                      onLocationSelected: (location) async {
                        await weatherProvider.setSelectedLocation(location);
                        setState(() => _showSearch = false);
                      },
                      onUseCurrentLocation: () async {
                        await weatherProvider.useCurrentLocation();
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

  Widget _buildHeader(bool isDarkMode, LanguageProvider language, WeatherProvider weatherProvider) {
    final themeProvider = context.read<ThemeProvider>();
    
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
            // Rain Now Logo with gradient
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(
                Icons.water_drop,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    'Rain Now',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black87,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _getLocationText(weatherProvider),
                    style: TextStyle(
                      color: isDarkMode ? Colors.white.withOpacity(0.7) : Colors.black87.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            // Search and Theme Toggle
            Row(
              children: [
                IconButton(
                  onPressed: () => setState(() => _showSearch = true),
                  icon: Icon(
                    Icons.search,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                IconButton(
                  onPressed: () => themeProvider.toggleTheme(),
                  icon: Icon(
                    isDarkMode ? Icons.light_mode : Icons.dark_mode,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getLocationText(WeatherProvider weatherProvider) {
    if (weatherProvider.selectedLocation != null) {
      return '📍 ${weatherProvider.selectedLocation!['name']}';
    } else if (weatherProvider.currentWeather != null) {
      return '🌐 ${weatherProvider.currentWeather!.name}, ${weatherProvider.currentWeather!.country}';
    } else if (weatherProvider.locationError != null) {
      return 'Location unavailable';
    } else {
      return 'Loading location...';
    }
  }

  Widget _buildMainContent(
    bool isDarkMode,
    LanguageProvider language,
    WeatherProvider weatherProvider,
    SettingsProvider settingsProvider,
  ) {
    return RefreshIndicator(
      onRefresh: () => weatherProvider.refreshWeatherData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Rain Alert Banner
            if (weatherProvider.hasRainAlert && !weatherProvider.isLoadingRain)
              RainAlertBanner(language: language),
            
            const SizedBox(height: 16),
            
            // Location Error
            if (weatherProvider.locationError != null && weatherProvider.selectedLocation == null)
              _buildLocationError(weatherProvider, language, isDarkMode),
            
            // Current Weather Card
            if (weatherProvider.isLoadingWeather)
              _buildWeatherSkeleton(isDarkMode)
            else if (weatherProvider.weatherError != null)
              _buildWeatherError(language, isDarkMode)
            else if (weatherProvider.currentWeather != null)
              WeatherCard(
                weather: weatherProvider.currentWeather!,
                settings: settingsProvider,
                language: language,
                isDarkMode: isDarkMode,
              ),
            
            const SizedBox(height: 16),
            
            // Rain Forecast Chart
            _buildRainForecastCard(weatherProvider, language, isDarkMode),
            
            const SizedBox(height: 16),
            
            // Weather Map
            if (weatherProvider.getActiveLocation() != null)
              WeatherMap(
                latitude: weatherProvider.getActiveLocation()!['lat']!,
                longitude: weatherProvider.getActiveLocation()!['lon']!,
                isDarkMode: isDarkMode,
                language: language,
              ),
            
            const SizedBox(height: 100), // Space for bottom navigation
          ],
        ),
      ),
    );
  }

  Widget _buildLocationError(WeatherProvider weatherProvider, LanguageProvider language, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.warning, color: Colors.orange),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language.t('location_required'),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                      ),
                    ),
                    Text(
                      weatherProvider.locationError!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.orange.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => weatherProvider.getCurrentLocation(),
                  icon: const Icon(Icons.location_on),
                  label: Text(language.t('try_again')),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => _showSearch = true),
                  icon: const Icon(Icons.search),
                  label: Text(language.t('search_city')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherSkeleton(bool isDarkMode) {
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
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 48,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 16,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: List.generate(3, (index) => Expanded(
              child: Container(
                height: 60,
                margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherError(LanguageProvider language, bool isDarkMode) {
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
          const Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            language.t('error_loading_weather'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please check your connection and try again',
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<WeatherProvider>().refreshWeatherData(),
            child: Text(language.t('try_again')),
          ),
        ],
      ),
    );
  }

  Widget _buildRainForecastCard(WeatherProvider weatherProvider, LanguageProvider language, bool isDarkMode) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.access_time,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                language.t('rain_forecast'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isDarkMode ? AppColors.darkSecondary : AppColors.lightSecondary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '🎁 ${language.t('refresh')}',
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Rain Chart
          if (weatherProvider.isLoadingRain)
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else if (weatherProvider.rainForecast.isNotEmpty)
            RainChart(
              rainData: weatherProvider.rainForecast,
              isDarkMode: isDarkMode,
            )
          else
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: isDarkMode 
                    ? AppColors.darkSecondary.withOpacity(0.3)
                    : AppColors.lightSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  language.t('no_rain_expected'),
                  style: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}