# Rain Now - Complete Flutter Weather App

A comprehensive weather application built with Flutter that provides real-time weather data, minute-by-minute rain forecasts, interactive weather radar, and multi-city support. This is a complete replica of the web version with all functionality included.

## Features

### 🌟 Core Features
- **Real-time Weather Data** - Current conditions with temperature, humidity, wind, and pressure
- **Minute-by-Minute Rain Forecasts** - Detailed precipitation predictions for the next hour
- **7-Day Weather Forecasts** - Extended forecasts with temperature trends and conditions
- **Interactive Weather Radar** - Live precipitation maps with location markers
- **Multi-City Support** - Save and manage multiple cities with live weather updates
- **Rain Alerts** - Automatic notifications when rain is expected

### 🎨 User Interface
- **Dark/Light Theme** - Matches your system preferences or manual toggle
- **Responsive Design** - Optimized for phones and tablets
- **Professional Design** - Exact replica of the web version with gradient logo and cards
- **Smooth Animations** - Fluid transitions and loading states

### 🌍 Localization
- **Multi-Language Support** - English, Spanish, French, German, Chinese, Arabic
- **Smart Translation** - Weather descriptions and UI elements in your language
- **Date/Time Formatting** - Localized date and time display

### ⚙️ Settings & Customization
- **Temperature Units** - Celsius or Fahrenheit
- **Wind Speed Units** - km/h, mph, or m/s
- **Notification Control** - Rain alerts and weather updates
- **Data Management** - Clear cache and reset preferences

### 📍 Location Services
- **GPS Location** - Automatic weather for your current location
- **City Search** - Find and add cities worldwide
- **Location History** - Recently viewed locations
- **Popular Cities** - Quick access to major cities

## Screenshots

### Home Screen
- Current weather display with large temperature
- Hourly rain forecast chart
- Interactive weather radar map
- Rain alert notifications

### Forecast Screen
- 7-day weather forecast
- Temperature trend charts
- Daily conditions with icons
- High/low temperatures

### Cities Screen
- Saved cities list with current weather
- Add/remove cities functionality
- Live weather updates for all cities
- Search for new cities

### Settings Screen
- Units and preferences
- Notification settings
- Language selection
- Theme toggle
- About and sharing options

## Installation

### Prerequisites
- Flutter 3.4.0 or later
- Android Studio / Xcode for device testing
- iOS 13.0+ or Android 6.0+ for physical devices

### Quick Start
```bash
# Clone and navigate
cd rain_now_complete

# Install dependencies
flutter pub get

# Run on device/simulator
flutter run
```

### Platform-Specific Setup

#### iOS Setup
```bash
# Navigate to iOS directory
cd ios

# Install pods
pod install

# Return and run
cd ..
flutter run
```

#### Android Setup
- Ensure Android SDK is installed
- Enable Developer Options and USB Debugging on device
- Connect device or start emulator
- Run `flutter run`

## API Integration

The app connects to a weather API backend for real data:

### Backend Connection
- **Base URL**: `http://localhost:5000` (configurable in `lib/utils/constants.dart`)
- **Endpoints**: Weather data, city search, rain forecasts, settings
- **Fallback**: Demo data when backend is unavailable

### API Endpoints Used
- `GET /api/weather/current` - Current weather by coordinates
- `GET /api/weather/forecast` - 7-day forecast
- `GET /api/weather/rain-forecast` - Minute-by-minute rain data
- `GET /api/cities/search` - City search
- `GET /api/settings` - User preferences
- `PATCH /api/settings` - Update preferences

## Architecture

### State Management
- **Provider Pattern** - Clean separation of concerns
- **Weather Provider** - Manages weather data and location
- **Cities Provider** - Handles saved cities and search
- **Settings Provider** - User preferences and API sync
- **Theme Provider** - Dark/light mode management
- **Language Provider** - Internationalization

### Project Structure
```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   └── weather_models.dart
├── providers/                # State management
│   ├── weather_provider.dart
│   ├── cities_provider.dart
│   ├── settings_provider.dart
│   ├── theme_provider.dart
│   └── language_provider.dart
├── screens/                  # Main app screens
│   ├── home_screen.dart
│   ├── forecast_screen.dart
│   ├── cities_screen.dart
│   └── settings_screen.dart
├── widgets/                  # Reusable UI components
│   ├── weather_card.dart
│   ├── rain_chart.dart
│   ├── weather_map.dart
│   ├── search_modal.dart
│   ├── rain_alert_banner.dart
│   └── forecast_chart.dart
├── services/                 # API and external services
│   └── api_service.dart
└── utils/                    # Constants and utilities
    └── constants.dart
```

### Key Dependencies
- **provider**: State management
- **http**: API requests
- **shared_preferences**: Local storage
- **geolocator**: Location services
- **fl_chart**: Charts and graphs
- **flutter_map**: Interactive maps
- **permission_handler**: Runtime permissions
- **intl**: Internationalization
- **cached_network_image**: Image caching
- **url_launcher**: External links

## Features Detailed

### Weather Data
- Temperature with configurable units
- Humidity percentage
- Wind speed and direction
- Atmospheric pressure
- Weather conditions with icons
- Visibility and UV index
- Sunrise/sunset times

### Rain Forecasting
- Minute-by-minute precipitation
- Rain intensity levels
- Time-based precipitation chart
- Rain probability percentages
- Storm tracking and alerts

### Location Features
- GPS-based current location
- Manual city selection
- Saved cities management
- Location search with autocomplete
- Popular cities quick selection
- Location-based weather alerts

### User Experience
- Pull-to-refresh on all screens
- Loading states and skeletons
- Error handling with retry options
- Offline capability with cached data
- Smooth navigation transitions
- Toast notifications for actions

## Configuration

### API Configuration
Edit `lib/utils/constants.dart` to change:
```dart
static const String apiBaseUrl = 'your-api-endpoint';
```

### Theme Customization
Modify colors in `lib/utils/constants.dart`:
```dart
class AppColors {
  static const Color primary = Color(0xFF3B82F6);
  static const Color accent = Color(0xFF06B6D4);
  // ... other colors
}
```

### Default Settings
Configure defaults in `lib/models/weather_models.dart`:
```dart
AppSettings({
  this.temperatureUnit = 'celsius',
  this.windSpeedUnit = 'kmh',
  this.rainAlerts = true,
  this.darkMode = true,
});
```

## Troubleshooting

### Common Issues

#### Location Permission Denied
- Check device location settings
- Ensure app has location permission
- Try manual city selection as alternative

#### API Connection Failed
- Verify backend is running on correct port
- Check network connectivity
- App will use demo data as fallback

#### Build Issues
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

#### iOS Build Problems
```bash
# Reset iOS pods
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter run
```

### Performance Tips
- Close unused background apps
- Clear app data if memory issues occur
- Restart app if weather data seems stale
- Check internet connection for real-time data

## Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support, please contact the development team or create an issue in the repository.

---
All api are set on the Vite app (backend). change them in the environment variables.

## Ad Configuration

This project integrates with **Google Mobile Ads (AdMob)**.  
During development, Google’s **test Ad Unit IDs** are used to avoid invalid traffic.  
Before publishing to the Play Store or App Store, replace them with your **real Ad Unit IDs** from the [AdMob Console](https://apps.admob.com).

### Setup

1. Add your **AdMob App ID** to the platform configs:
   - **Android**: in `AndroidManifest.xml`  
     ```xml
     <meta-data
         android:name="com.google.android.gms.ads.APPLICATION_ID"
         android:value="ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY"/>
     ```
   - **iOS**: in `Info.plist`  
     ```xml
     <key>GADApplicationIdentifier</key>
     <string>ca-app-pub-XXXXXXXXXXXXXXXX~ZZZZZZZZZZ</string>
     ```

2. Update the Ad Unit IDs in your Flutter code.  
   Example configuration (`lib/services/admob_service.dart`):

   ```dart
   import 'dart:io';

   class AdHelper {
     static String get bannerAdUnitId {
       if (Platform.isAndroid) {
         return 'ca-app-pub-3940256099942544/6300978111'; // Test ID
       } else if (Platform.isIOS) {
         return 'ca-app-pub-3940256099942544/2934735716'; // Test ID
       }
       return '';
     }

     static String get interstitialAdUnitId {
       if (Platform.isAndroid) {
         return 'ca-app-pub-3940256099942544/1033173712'; // Test ID
       } else if (Platform.isIOS) {
         return 'ca-app-pub-3940256099942544/4411468910'; // Test ID
       }
       return '';
     }
   }


**Rain Now** - Your complete weather companion with minute-by-minute precision! 🌧️📱