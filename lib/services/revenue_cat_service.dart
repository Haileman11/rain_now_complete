import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatService {
  static final RevenueCatService _instance = RevenueCatService._internal();
  factory RevenueCatService() => _instance;
  RevenueCatService._internal();

  static bool _isInitialized = false;
  bool _isPremium = false;
  
  // RevenueCat API Keys (Replace with your actual keys)
  static const String _androidApiKey = 'goog_GefeoatysKtTKqnLRPqoCicRImV';
  static const String _iosApiKey = 'appl_LcXQpCVrzyoKNMzOJotieFHCfAE';

  // Product IDs (Configure these in RevenueCat dashboard)
  static const String premiumMonthlyId = 'premium_monthly';
  static const String premiumYearlyId = 'premium_yearly';
  static const String premiumLifetimeId = 'premium_lifetime';

  // Getters
  bool get isPremium => _isPremium;
  bool get isInitialized => _isInitialized;

  // Initialize RevenueCat
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      late PurchasesConfiguration configuration;
      
      if (defaultTargetPlatform == TargetPlatform.android) {
        configuration = PurchasesConfiguration(_androidApiKey);
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        configuration = PurchasesConfiguration(_iosApiKey);
      } else {
        debugPrint('Unsupported platform for RevenueCat');
        return;
      }

      await Purchases.configure(configuration);
      _isInitialized = true;
      
      // Check current subscription status
      await checkSubscriptionStatus();
      
      debugPrint('RevenueCat initialized successfully');
    } catch (e) {
      debugPrint('RevenueCat initialization failed: $e');
    }
  }

  // Check subscription status
  Future<void> checkSubscriptionStatus() async {
    if (!_isInitialized) return;

    try {
      final customerInfo = await Purchases.getCustomerInfo();
      _isPremium = customerInfo.entitlements.all['premium']?.isActive ?? false;
      debugPrint('Premium status: $_isPremium');
    } catch (e) {
      debugPrint('Error checking subscription status: $e');
      _isPremium = false;
    }
  }

  // Get available packages
  Future<List<Package>> getAvailablePackages() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final offerings = await Purchases.getOfferings();
      // if (offerings.all != null) {
        return offerings.all.values
            .expand((offering) => offering.availablePackages)
            .toList();
      // }
    } catch (e) {
      debugPrint('Error getting packages: $e');
    }
    return [];
  }

  // Purchase a package
  Future<bool> purchasePackage(Package package) async {
    if (!_isInitialized) return false;

    try {
      final customerInfo = await Purchases.purchasePackage(package);
      _isPremium = customerInfo.entitlements.all['premium']?.isActive ?? false;
      debugPrint('Purchase successful. Premium status: $_isPremium');
      return true;
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      debugPrint('Purchase error: $errorCode - ${e.message}');
      
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        debugPrint('User cancelled purchase');
      } else if (errorCode == PurchasesErrorCode.purchaseNotAllowedError) {
        debugPrint('Purchase not allowed');
      }
      return false;
    } catch (e) {
      debugPrint('Unexpected purchase error: $e');
      return false;
    }
  }

  // Restore purchases
  Future<bool> restorePurchases() async {
    if (!_isInitialized) return false;

    try {
      final customerInfo = await Purchases.restorePurchases();
      _isPremium = customerInfo.entitlements.all['premium']?.isActive ?? false;
      debugPrint('Restore successful. Premium status: $_isPremium');
      return true;
    } catch (e) {
      debugPrint('Error restoring purchases: $e');
      return false;
    }
  }

  // Get customer info
  Future<CustomerInfo?> getCustomerInfo() async {
    if (!_isInitialized) return null;

    try {
      return await Purchases.getCustomerInfo();
    } catch (e) {
      debugPrint('Error getting customer info: $e');
      return null;
    }
  }

  // Set user ID (optional)
  Future<void> setUserId(String userId) async {
    if (!_isInitialized) return;

    try {
      await Purchases.logIn(userId);
      debugPrint('User ID set: $userId');
    } catch (e) {
      debugPrint('Error setting user ID: $e');
    }
  }

  // Log out user
  Future<void> logout() async {
    if (!_isInitialized) return;

    try {
      await Purchases.logOut();
      _isPremium = false;
      debugPrint('User logged out');
    } catch (e) {
      debugPrint('Error logging out: $e');
    }
  }

  // Get subscription info
  Future<Map<String, dynamic>> getSubscriptionInfo() async {
    final customerInfo = await getCustomerInfo();
    if (customerInfo == null) return {};

    final premiumEntitlement = customerInfo.entitlements.all['premium'];
    if (premiumEntitlement == null || !premiumEntitlement.isActive) {
      return {'isActive': false};
    }

    return {
      'isActive': true,
      'productIdentifier': premiumEntitlement.productIdentifier,
      'purchaseDate': premiumEntitlement.latestPurchaseDate,
      'expirationDate': premiumEntitlement.expirationDate,
      'willRenew': premiumEntitlement.willRenew,
      'periodType': premiumEntitlement.periodType.toString(),
    };
  }

  // Check if specific feature is available
  bool hasFeature(String featureId) {
    // For free users, all features are locked except basic ones
    if (!_isPremium) {
      return ['basic_weather', 'current_location'].contains(featureId);
    }
    
    // Premium users have access to all features
    return true;
  }

  // Get feature list for premium
  List<String> getPremiumFeatures() {
    return [
      'No Ads',
      'Extended 14-day Forecast',
      'Detailed Weather Maps',
      'Multiple City Support',
      'Custom Weather Alerts',
      'Historical Weather Data',
      'Weather Widgets',
      'Priority Customer Support',
    ];
  }
}