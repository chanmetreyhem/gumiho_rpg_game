import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../profile/application/profile_notifier.dart';
import '../data/monetization_config.dart';

typedef PurchaseHandler = Future<void> Function(String productId);

final monetizationServiceProvider = Provider<MonetizationService>((ref) {
  final service = MonetizationService(
    onPurchase: (productId) =>
        ref.read(profileNotifierProvider.notifier).handleIapPurchase(productId),
  );
  ref.onDispose(service.dispose);
  return service;
});

class MonetizationService {
  MonetizationService({required this.onPurchase});

  final PurchaseHandler onPurchase;

  RewardedAd? _rewardedAd;
  InterstitialAd? _interstitialAd;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;
  bool _iapAvailable = false;
  Map<String, ProductDetails> _products = {};

  bool get isIapAvailable => _iapAvailable;
  Map<String, ProductDetails> get products => _products;

  Future<void> init() async {
    if (!kIsWeb) {
      await _loadRewardedAd();
      await _loadInterstitialAd();
    }
    await _initIap();
  }

  Future<void> _initIap() async {
    final iap = InAppPurchase.instance;
    _iapAvailable = await iap.isAvailable();
    if (!_iapAvailable) return;

    _purchaseSub = iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (_) {},
    );

    final response = await iap.queryProductDetails(MonetizationConfig.allProductIds);
    _products = {for (final p in response.productDetails) p.id: p};
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        await onPurchase(purchase.productID);
        if (purchase.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchase);
        }
      } else if (purchase.status == PurchaseStatus.error) {
        if (purchase.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchase);
        }
      }
    }
  }

  Future<void> buyProduct(String productId) async {
    if (!_iapAvailable) return;
    final product = _products[productId];
    if (product == null) return;

    final isConsumable = productId == MonetizationConfig.coins500ProductId ||
        productId == MonetizationConfig.coins1500ProductId;

    await InAppPurchase.instance.buyConsumable(
      purchaseParam: PurchaseParam(productDetails: product),
      autoConsume: isConsumable,
    );
  }

  Future<void> buyNonConsumable(String productId) async {
    if (!_iapAvailable) return;
    final product = _products[productId];
    if (product == null) return;

    await InAppPurchase.instance.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: product),
    );
  }

  Future<void> restorePurchases() async {
    if (!_iapAvailable) return;
    await InAppPurchase.instance.restorePurchases();
  }

  Future<bool> showRewardedAd() async {
    if (kIsWeb) return false;
    final ad = _rewardedAd;
    if (ad == null) {
      await _loadRewardedAd();
      return false;
    }

    final completer = Completer<bool>();
    var rewarded = false;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        _loadRewardedAd();
        if (!completer.isCompleted) completer.complete(rewarded);
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _rewardedAd = null;
        _loadRewardedAd();
        if (!completer.isCompleted) completer.complete(false);
      },
    );

    ad.show(
      onUserEarnedReward: (_, __) {
        rewarded = true;
      },
    );

    return completer.future;
  }

  Future<void> showInterstitialIfAllowed({required bool adsRemoved}) async {
    if (kIsWeb || adsRemoved) return;
    final ad = _interstitialAd;
    if (ad == null) {
      await _loadInterstitialAd();
      return;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        _loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _interstitialAd = null;
        _loadInterstitialAd();
      },
    );
    await ad.show();
    _interstitialAd = null;
  }

  Future<void> _loadRewardedAd() async {
    if (kIsWeb) return;
    final unitId = MonetizationConfig.rewardedAdUnitId;
    if (unitId.isEmpty) return;

    await RewardedAd.load(
      adUnitId: unitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _rewardedAd = ad,
        onAdFailedToLoad: (_) => _rewardedAd = null,
      ),
    );
  }

  Future<void> _loadInterstitialAd() async {
    if (kIsWeb) return;
    final unitId = MonetizationConfig.interstitialAdUnitId;
    if (unitId.isEmpty) return;

    await InterstitialAd.load(
      adUnitId: unitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (_) => _interstitialAd = null,
      ),
    );
  }

  void dispose() {
    _purchaseSub?.cancel();
    _rewardedAd?.dispose();
    _interstitialAd?.dispose();
  }
}
