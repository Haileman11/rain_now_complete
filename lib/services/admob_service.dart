import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  static final AdMobService _instance = AdMobService._internal();
  factory AdMobService() => _instance;
  AdMobService._internal();

  static bool _isInitialized = false;
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  bool _isBannerAdReady = false;
  bool _isInterstitialAdReady = false;

  // Test Ad Unit IDs (Replace with your real Ad Unit IDs in production)
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-4159281980067233/2586218275';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-4159281980067233/3707555841';
    }
    return '';
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return ' ca-app-pub-4159281980067233/2443759802';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-4159281980067233/2005244322';
    }
    return '';
  }

  // Initialize Mobile Ads SDK
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    await MobileAds.instance.initialize();
    _isInitialized = true;
    debugPrint('AdMob initialized successfully');
  }

  // Load Banner Ad
  void loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('Banner ad loaded');
          _isBannerAdReady = true;
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner ad failed to load: $error');
          _isBannerAdReady = false;
          ad.dispose();
        },
        onAdOpened: (ad) {
          debugPrint('Banner ad opened');
        },
        onAdClosed: (ad) {
          debugPrint('Banner ad closed');
        },
      ),
    );
    _bannerAd!.load();
  }

  // Load Interstitial Ad
  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('Interstitial ad loaded');
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          
          // Set full screen content callback
          _interstitialAd!.setImmersiveMode(true);
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              debugPrint('Interstitial ad showed full screen content');
            },
            onAdDismissedFullScreenContent: (ad) {
              debugPrint('Interstitial ad dismissed');
              ad.dispose();
              _interstitialAd = null;
              _isInterstitialAdReady = false;
              // Load a new ad for next time
              loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('Interstitial ad failed to show: $error');
              ad.dispose();
              _interstitialAd = null;
              _isInterstitialAdReady = false;
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial ad failed to load: $error');
          _isInterstitialAdReady = false;
        },
      ),
    );
  }

  // Show Interstitial Ad
  void showInterstitialAd() {
    if (_isInterstitialAdReady && _interstitialAd != null) {
      _interstitialAd!.show();
    } else {
      debugPrint('Interstitial ad not ready');
      // Load a new ad
      loadInterstitialAd();
    }
  }

  // Get Banner Ad Widget
  BannerAd? get bannerAd => _isBannerAdReady ? _bannerAd : null;

  // Check if banner ad is ready
  bool get isBannerAdReady => _isBannerAdReady;

  // Check if interstitial ad is ready
  bool get isInterstitialAdReady => _isInterstitialAdReady;

  // Dispose ads
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _bannerAd = null;
    _interstitialAd = null;
    _isBannerAdReady = false;
    _isInterstitialAdReady = false;
  }

  // Show banner ad in a container
  Widget getBannerAdWidget() {
    if (_isBannerAdReady && _bannerAd != null) {
      return Container(
        alignment: Alignment.center,
        child: AdWidget(ad: _bannerAd!),
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
      );
    }
    return const SizedBox.shrink();
  }
}

// Widget for easy banner ad integration
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({Key? key}) : super(key: key);

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  final AdMobService _adMobService = AdMobService();

  @override
  void initState() {
    super.initState();
    _adMobService.loadBannerAd();
  }

  @override
  Widget build(BuildContext context) {
    return _adMobService.getBannerAdWidget();
  }

  @override
  void dispose() {
    super.dispose();
  }
}