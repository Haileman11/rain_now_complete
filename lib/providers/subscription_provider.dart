import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../services/revenue_cat_service.dart';
import '../services/admob_service.dart';

class SubscriptionProvider with ChangeNotifier {
  final RevenueCatService _revenueCatService = RevenueCatService();
  final AdMobService _adMobService = AdMobService();
  
  bool _isPremium = false;
  bool _isLoading = false;
  List<Package> _availablePackages = [];
  Map<String, dynamic> _subscriptionInfo = {};

  // Getters
  bool get isPremium => _isPremium;
  bool get isLoading => _isLoading;
  List<Package> get availablePackages => _availablePackages;
  Map<String, dynamic> get subscriptionInfo => _subscriptionInfo;
  bool get showAds => !_isPremium;

  // Initialize subscription services
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Initialize RevenueCat
      await _revenueCatService.initialize();
      
      // Initialize AdMob
      await AdMobService.initialize();
      
      // Check current subscription status
      await checkSubscriptionStatus();
      
      // Load available packages
      await loadPackages();
      
      // Load ads if not premium
      if (!_isPremium) {
        _adMobService.loadBannerAd();
        _adMobService.loadInterstitialAd();
      }
      
    } catch (e) {
      debugPrint('Error initializing subscription services: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check subscription status
  Future<void> checkSubscriptionStatus() async {
    try {
      await _revenueCatService.checkSubscriptionStatus();
      _isPremium = _revenueCatService.isPremium;
      
      if (_isPremium) {
        _subscriptionInfo = await _revenueCatService.getSubscriptionInfo();
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error checking subscription status: $e');
    }
  }

  // Load available packages
  Future<void> loadPackages() async {
    try {
      _availablePackages = await _revenueCatService.getAvailablePackages();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading packages: $e');
    }
  }

  // Purchase a subscription
  Future<bool> purchaseSubscription(Package package) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _revenueCatService.purchasePackage(package);
      if (success) {
        _isPremium = _revenueCatService.isPremium;
        if (_isPremium) {
          _subscriptionInfo = await _revenueCatService.getSubscriptionInfo();
          // Dispose ads for premium users
          _adMobService.dispose();
        }
        notifyListeners();
      }
      return success;
    } catch (e) {
      debugPrint('Error purchasing subscription: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Restore purchases
  Future<bool> restorePurchases() async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _revenueCatService.restorePurchases();
      if (success) {
        _isPremium = _revenueCatService.isPremium;
        if (_isPremium) {
          _subscriptionInfo = await _revenueCatService.getSubscriptionInfo();
          // Dispose ads for premium users
          _adMobService.dispose();
        }
        notifyListeners();
      }
      return success;
    } catch (e) {
      debugPrint('Error restoring purchases: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check if feature is available
  bool hasFeature(String featureId) {
    return _revenueCatService.hasFeature(featureId);
  }

  // Get premium features list
  List<String> getPremiumFeatures() {
    return _revenueCatService.getPremiumFeatures();
  }

  // Show interstitial ad (only for free users)
  void showInterstitialAd() {
    if (!_isPremium) {
      _adMobService.showInterstitialAd();
    }
  }

  // Get banner ad widget
  Widget getBannerAdWidget() {
    if (!_isPremium && _adMobService.isBannerAdReady) {
      return _adMobService.getBannerAdWidget();
    }
    return const SizedBox.shrink();
  }

  // Load ads for free users
  void loadAds() {
    if (!_isPremium) {
      _adMobService.loadBannerAd();
      _adMobService.loadInterstitialAd();
    }
  }

  // Get formatted subscription info
  String getSubscriptionStatusText() {
    if (!_isPremium) {
      return 'Free Version';
    }

    if (_subscriptionInfo.isEmpty) {
      return 'Premium Active';
    }

    final productId = _subscriptionInfo['productIdentifier'] ?? '';
    if (productId.contains('monthly')) {
      return 'Premium Monthly';
    } else if (productId.contains('yearly')) {
      return 'Premium Yearly';
    } else if (productId.contains('lifetime')) {
      return 'Premium Lifetime';
    }
    
    return 'Premium Active';
  }

  // Get expiration info
  String getExpirationText() {
    if (!_isPremium || _subscriptionInfo.isEmpty) {
      return '';
    }

    final expirationDate = _subscriptionInfo['expirationDate'];
    if (expirationDate == null) {
      return 'Lifetime access';
    }

    final willRenew = _subscriptionInfo['willRenew'] ?? false;
    if (willRenew) {
      return 'Renews automatically';
    } else {
      return 'Expires on ${expirationDate.toString().split(' ')[0]}';
    }
  }

  // Dispose resources
  @override
  void dispose() {
    _adMobService.dispose();
    super.dispose();
  }
}