import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/settings_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../providers/cities_provider.dart';
import '../providers/weather_provider.dart';
import '../providers/subscription_provider.dart';
import '../screens/subscription_screen.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;
    final language = context.watch<LanguageProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final subscriptionProvider = context.watch<SubscriptionProvider>();

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(isDarkMode, language),
            
            // Content
            Expanded(
              child: _buildContent(context, isDarkMode, language, settingsProvider, subscriptionProvider),
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
              Icons.settings,
              color: AppColors.primary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              language.t('settings'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    bool isDarkMode,
    LanguageProvider language,
    SettingsProvider settingsProvider,
    SubscriptionProvider subscriptionProvider,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Premium Section
        _buildPremiumSection(context, isDarkMode, subscriptionProvider),
        
        const SizedBox(height: 24),
        
        // Units Section
        _buildSettingsGroup(
          context,
          'Units',
          [
            _buildSettingsTile(
              context,
              language.t('temperature_unit'),
              _getTemperatureUnitText(settingsProvider.settings.temperatureUnit, language),
              Icons.thermostat,
              () => _showTemperatureUnitDialog(context, settingsProvider, language),
              isDarkMode,
            ),
            _buildSettingsTile(
              context,
              language.t('wind_speed_unit'),
              _getWindSpeedUnitText(settingsProvider.settings.windSpeedUnit, language),
              Icons.air,
              () => _showWindSpeedUnitDialog(context, settingsProvider, language),
              isDarkMode,
            ),
          ],
          isDarkMode,
        ),
        
        const SizedBox(height: 24),
        
        // Notifications Section
        _buildSettingsGroup(
          context,
          'Notifications',
          [
            _buildSwitchTile(
              context,
              language.t('rain_alerts'),
              'Get notified about incoming rain',
              Icons.notifications,
              settingsProvider.settings.rainAlerts,
              (value) => settingsProvider.updateSetting('rainAlerts', value),
              isDarkMode,
            ),
            _buildSwitchTile(
              context,
              language.t('weather_updates'),
              'Periodic weather updates',
              Icons.update,
              settingsProvider.settings.weatherUpdates,
              (value) => settingsProvider.updateSetting('weatherUpdates', value),
              isDarkMode,
            ),
          ],
          isDarkMode,
        ),
        
        const SizedBox(height: 24),
        
        // Appearance Section
        _buildSettingsGroup(
          context,
          'Appearance',
          [
            _buildSwitchTile(
              context,
              language.t('dark_mode'),
              'Use dark theme',
              Icons.dark_mode,
              isDarkMode,
              (value) => context.read<ThemeProvider>().setDarkMode(value),
              isDarkMode,
            ),
            _buildSettingsTile(
              context,
              language.t('language'),
              _getLanguageText(language.currentLanguage),
              Icons.language,
              () => _showLanguageDialog(context, language),
              isDarkMode,
            ),
          ],
          isDarkMode,
        ),
        
        const SizedBox(height: 24),
        
        // App Section
        _buildSettingsGroup(
          context,
          'App',
          [
            _buildSettingsTile(
              context,
              language.t('share_app'),
              '',
              Icons.share,
              () => _shareApp(context),
              isDarkMode,
            ),
            _buildSettingsTile(
              context,
              language.t('clear_data'),
              'Reset all app data',
              Icons.delete_outline,
              () => _showClearDataDialog(context, settingsProvider, language),
              isDarkMode,
              isDestructive: true,
            ),
            _buildSettingsTile(
              context,
              language.t('about'),
              'Version 1.0.0',
              Icons.info,
              () => _showAboutDialog(context),
              isDarkMode,
            ),
          ],
          isDarkMode,
        ),
        
        const SizedBox(height: 100), // Space for bottom navigation
      ],
    );
  }

  Widget _buildSettingsGroup(
    BuildContext context,
    String title,
    List<Widget> children,
    bool isDarkMode,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    VoidCallback onTap,
    bool isDarkMode, {
    bool isDestructive = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
            width: 0.5,
          ),
        ),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : AppColors.accent,
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive 
                ? Colors.red 
                : isDarkMode ? Colors.white : Colors.black87,
            fontSize: 16,
          ),
        ),
        subtitle: value.isNotEmpty
            ? Text(
                value,
                style: TextStyle(
                  color: isDarkMode ? Colors.white60 : Colors.black54,
                  fontSize: 14,
                ),
              )
            : null,
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: isDarkMode ? Colors.white30 : Colors.black26,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
    bool isDarkMode,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
            width: 0.5,
          ),
        ),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: AppColors.accent,
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: isDarkMode ? Colors.white60 : Colors.black54,
            fontSize: 14,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ),
    );
  }

  String _getTemperatureUnitText(String unit, LanguageProvider language) {
    switch (unit) {
      case 'fahrenheit':
        return language.t('fahrenheit');
      default:
        return language.t('celsius');
    }
  }

  String _getWindSpeedUnitText(String unit, LanguageProvider language) {
    switch (unit) {
      case 'mph':
        return language.t('mph');
      case 'ms':
        return language.t('ms');
      default:
        return language.t('kmh');
    }
  }

  String _getLanguageText(String languageCode) {
    switch (languageCode) {
      case 'es':
        return 'Español';
      case 'fr':
        return 'Français';
      case 'de':
        return 'Deutsch';
      case 'zh':
        return '中文';
      case 'ar':
        return 'العربية';
      default:
        return 'English';
    }
  }

  void _showTemperatureUnitDialog(
    BuildContext context,
    SettingsProvider settingsProvider,
    LanguageProvider language,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(language.t('temperature_unit')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: Text(language.t('celsius')),
                value: 'celsius',
                groupValue: settingsProvider.settings.temperatureUnit,
                onChanged: (value) {
                  if (value != null) {
                    settingsProvider.updateSetting('temperatureUnit', value);
                    Navigator.of(context).pop();
                  }
                },
              ),
              RadioListTile<String>(
                title: Text(language.t('fahrenheit')),
                value: 'fahrenheit',
                groupValue: settingsProvider.settings.temperatureUnit,
                onChanged: (value) {
                  if (value != null) {
                    settingsProvider.updateSetting('temperatureUnit', value);
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showWindSpeedUnitDialog(
    BuildContext context,
    SettingsProvider settingsProvider,
    LanguageProvider language,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(language.t('wind_speed_unit')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: Text(language.t('kmh')),
                value: 'kmh',
                groupValue: settingsProvider.settings.windSpeedUnit,
                onChanged: (value) {
                  if (value != null) {
                    settingsProvider.updateSetting('windSpeedUnit', value);
                    Navigator.of(context).pop();
                  }
                },
              ),
              RadioListTile<String>(
                title: Text(language.t('mph')),
                value: 'mph',
                groupValue: settingsProvider.settings.windSpeedUnit,
                onChanged: (value) {
                  if (value != null) {
                    settingsProvider.updateSetting('windSpeedUnit', value);
                    Navigator.of(context).pop();
                  }
                },
              ),
              RadioListTile<String>(
                title: Text(language.t('ms')),
                value: 'ms',
                groupValue: settingsProvider.settings.windSpeedUnit,
                onChanged: (value) {
                  if (value != null) {
                    settingsProvider.updateSetting('windSpeedUnit', value);
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLanguageDialog(BuildContext context, LanguageProvider language) {
    final languages = [
      {'code': 'en', 'name': 'English'},
      {'code': 'es', 'name': 'Español'},
      {'code': 'fr', 'name': 'Français'},
      {'code': 'de', 'name': 'Deutsch'},
      {'code': 'zh', 'name': '中文'},
      {'code': 'ar', 'name': 'العربية'},
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(language.t('language')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: languages.map((lang) {
              return RadioListTile<String>(
                title: Text(lang['name']!),
                value: lang['code']!,
                groupValue: language.currentLanguage,
                onChanged: (value) {
                  if (value != null) {
                    language.setLanguage(value);
                    Navigator.of(context).pop();
                  }
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showClearDataDialog(
    BuildContext context,
    SettingsProvider settingsProvider,
    LanguageProvider language,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(language.t('clear_data')),
          content: const Text('This will clear all app data including saved cities and settings. This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Clear all data
                settingsProvider.clearAllData();
                context.read<CitiesProvider>().loadSavedCities();
                context.read<WeatherProvider>().clearSelectedLocation();
                
                Navigator.of(context).pop();
                
                // Show confirmation
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All data has been cleared'),
                  ),
                );
              },
              child: const Text('Clear', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _shareApp(BuildContext context) {
    // Implement app sharing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality coming soon!'),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('About Rain Watcher'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Rain Watcher - Weather App'),
              SizedBox(height: 8),
              Text('Version: 1.0.0'),
              SizedBox(height: 8),
              Text('Get minute-by-minute rain forecasts and comprehensive weather information.'),
              SizedBox(height: 16),
              Text('Features:'),
              Text('• Real-time weather data'),
              Text('• Minute-by-minute rain forecasts'),
              Text('• 7-day weather forecasts'),
              Text('• Multiple city support'),
              Text('• Weather radar maps'),
              Text('• Rain alerts and notifications'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPremiumSection(BuildContext context, bool isDarkMode, SubscriptionProvider subscriptionProvider) {
    if (subscriptionProvider.isPremium) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.verified,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Premium Active',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subscriptionProvider.getSubscriptionStatusText(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SubscriptionScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF667eea),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Manage',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFF667eea),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isDarkMode ? AppColors.darkCard : AppColors.lightCard,
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(
                  Icons.star,
                  color: Color(0xFF667eea),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Upgrade to Premium',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Remove ads and unlock all features',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SubscriptionScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF667eea),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Upgrade',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF667eea),
                  size: 16,
                ),
                const SizedBox(width: 8),
                const Text('No Ads'),
                const SizedBox(width: 16),
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF667eea),
                  size: 16,
                ),
                const SizedBox(width: 8),
                const Text('14-day Forecast'),
                const SizedBox(width: 16),
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF667eea),
                  size: 16,
                ),
                const SizedBox(width: 8),
                const Text('Weather Maps'),
              ],
            ),
          ],
        ),
      );
    }
  }
}