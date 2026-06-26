import 'dart:io';

import 'package:flutter/foundation.dart';

class MonetizationConfig {
  MonetizationConfig._();

  /// Google sample ad units — replace before production release.
  static String get rewardedAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917';
    }
    if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313';
    }
    return '';
  }

  static String get interstitialAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712';
    }
    if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910';
    }
    return '';
  }

  static const removeAdsProductId = 'gumiho_remove_ads';
  static const coins500ProductId = 'gumiho_coins_500';
  static const coins1500ProductId = 'gumiho_coins_1500';
  static const premiumWizardProductId = 'gumiho_premium_wizard';

  static const allProductIds = {
    removeAdsProductId,
    coins500ProductId,
    coins1500ProductId,
    premiumWizardProductId,
  };

  static const rewardedCoinBonus = 50;
  static const coins500Amount = 500;
  static const coins1500Amount = 1500;
  static const premiumWizardSkinId = 'wizard';
}
