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

  static const Duration _loadTimeout = Duration(seconds: 8);
  static const Duration _showTimeout = Duration(seconds: 45);

  final PurchaseHandler onPurchase;

  RewardedAd? _rewardedAd;
  InterstitialAd? _interstitialAd;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;
  bool _iapAvailable = false;
  Map<String, ProductDetails> _products = {};

  bool get isIapAvailable => _iapAvailable;
  bool get isRewardedAdReady => _rewardedAd != null;
  Map<String, ProductDetails> get products => _products;

  Future<void> init() async {
    if (!kIsWeb) {
      unawaited(preloadAds());
    }
    await initIap();
  }

  Future<void> initIap() async {
    final iap = InAppPurchase.instance;
    _iapAvailable = await iap.isAvailable();
    if (!_iapAvailable) return;

    _purchaseSub = iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (_) {},
    );

    final response =
        await iap.queryProductDetails(MonetizationConfig.allProductIds);
    _products = {for (final p in response.productDetails) p.id: p};
  }

  Future<void> preloadAds() async {
    if (kIsWeb) return;
    await Future.wait([
      _loadRewardedAd(),
      _loadInterstitialAd(),
    ]);
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

  /// Returns true only if the user earned the reward. Never blocks indefinitely.
  Future<bool> showRewardedAd() async {
    if (kIsWeb) return false;

    if (_rewardedAd == null) {
      await _loadRewardedAd();
    }

    final ad = _rewardedAd;
    if (ad == null) return false;

    final completer = Completer<bool>();
    var rewarded = false;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        unawaited(_loadRewardedAd());
        if (!completer.isCompleted) completer.complete(rewarded);
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _rewardedAd = null;
        unawaited(_loadRewardedAd());
        if (!completer.isCompleted) completer.complete(false);
      },
    );

    try {
      await ad.show(
        onUserEarnedReward: (_, __) {
          rewarded = true;
        },
      );
    } on Object {
      _rewardedAd?.dispose();
      _rewardedAd = null;
      unawaited(_loadRewardedAd());
      return false;
    }

    try {
      return await completer.future.timeout(_showTimeout, onTimeout: () => false);
    } on TimeoutException {
      return false;
    }
  }

  /// Best-effort interstitial. Returns quickly when no ad is ready.
  Future<void> showInterstitialIfAllowed({required bool adsRemoved}) async {
    if (kIsWeb || adsRemoved) return;

    if (_interstitialAd == null) {
      await _loadInterstitialAd();
    }

    final ad = _interstitialAd;
    if (ad == null) return;

    _interstitialAd = null;

    final dismissed = Completer<void>();

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        unawaited(_loadInterstitialAd());
        if (!dismissed.isCompleted) dismissed.complete();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        unawaited(_loadInterstitialAd());
        if (!dismissed.isCompleted) dismissed.complete();
      },
    );

    try {
      await ad.show().timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          ad.dispose();
          unawaited(_loadInterstitialAd());
        },
      );
      await dismissed.future.timeout(
        _showTimeout,
        onTimeout: () {
          ad.dispose();
          unawaited(_loadInterstitialAd());
        },
      );
    } on Object {
      ad.dispose();
      unawaited(_loadInterstitialAd());
    }
  }

  Future<void> _loadRewardedAd() async {
    if (kIsWeb) return;
    final unitId = MonetizationConfig.rewardedAdUnitId;
    if (unitId.isEmpty) return;

    final loaded = Completer<void>();

    RewardedAd.load(
      adUnitId: unitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd?.dispose();
          _rewardedAd = ad;
          if (!loaded.isCompleted) loaded.complete();
        },
        onAdFailedToLoad: (_) {
          _rewardedAd = null;
          if (!loaded.isCompleted) loaded.complete();
        },
      ),
    );

    try {
      await loaded.future.timeout(_loadTimeout);
    } on TimeoutException {
      _rewardedAd = null;
    }
  }

  Future<void> _loadInterstitialAd() async {
    if (kIsWeb) return;
    final unitId = MonetizationConfig.interstitialAdUnitId;
    if (unitId.isEmpty) return;

    final loaded = Completer<void>();

    InterstitialAd.load(
      adUnitId: unitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd?.dispose();
          _interstitialAd = ad;
          if (!loaded.isCompleted) loaded.complete();
        },
        onAdFailedToLoad: (_) {
          _interstitialAd = null;
          if (!loaded.isCompleted) loaded.complete();
        },
      ),
    );

    try {
      await loaded.future.timeout(_loadTimeout);
    } on TimeoutException {
      _interstitialAd = null;
    }
  }

  void dispose() {
    _purchaseSub?.cancel();
    _rewardedAd?.dispose();
    _interstitialAd?.dispose();
  }
}
