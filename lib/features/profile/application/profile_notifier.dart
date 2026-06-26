import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../monetization/data/monetization_config.dart';
import '../data/profile_repository.dart';
import '../domain/player_profile.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

final profileNotifierProvider =
    AsyncNotifierProvider<ProfileNotifier, PlayerProfile>(ProfileNotifier.new);

class ProfileNotifier extends AsyncNotifier<PlayerProfile> {
  @override
  Future<PlayerProfile> build() async {
    return ref.read(profileRepositoryProvider).load();
  }

  PlayerProfile get _current => state.requireValue;

  Future<void> _persist(PlayerProfile profile) async {
    state = AsyncData(profile);
    await ref.read(profileRepositoryProvider).save(profile);
  }

  Future<void> addCoins(int amount) async {
    await _persist(_current.copyWith(coins: _current.coins + amount));
  }

  Future<void> completeLevel(int level, int stars, int coinsEarned) async {
    final newStars = Map<int, int>.from(_current.levelStars);
    final existing = newStars[level] ?? 0;
    if (stars > existing) newStars[level] = stars;

    await _persist(
      _current.copyWith(
        coins: _current.coins + coinsEarned,
        highestLevelCleared: level > _current.highestLevelCleared
            ? level
            : _current.highestLevelCleared,
        levelStars: newStars,
      ),
    );
  }

  Future<void> purchaseGun(String gunId, int price) async {
    if (_current.ownedGuns.contains(gunId) || _current.coins < price) return;
    await _persist(
      _current.copyWith(
        coins: _current.coins - price,
        ownedGuns: [..._current.ownedGuns, gunId],
      ),
    );
  }

  Future<void> purchaseSkin(String skinId, int price) async {
    if (_current.ownedSkins.contains(skinId) || _current.coins < price) return;
    await _persist(
      _current.copyWith(
        coins: _current.coins - price,
        ownedSkins: [..._current.ownedSkins, skinId],
      ),
    );
  }

  Future<void> equipGun(String gunId) async {
    if (!_current.ownedGuns.contains(gunId)) return;
    await _persist(_current.copyWith(equippedGunId: gunId));
  }

  Future<void> equipSkin(String skinId) async {
    if (!_current.ownedSkins.contains(skinId)) return;
    await _persist(_current.copyWith(equippedSkinId: skinId));
  }

  Future<void> resetProgress() async {
    const fresh = PlayerProfile();
    await _persist(fresh);
  }

  Future<void> handleIapPurchase(String productId) async {
    switch (productId) {
      case MonetizationConfig.removeAdsProductId:
        await _persist(_current.copyWith(removeAdsPurchased: true));
      case MonetizationConfig.coins500ProductId:
        await addCoins(MonetizationConfig.coins500Amount);
      case MonetizationConfig.coins1500ProductId:
        await addCoins(MonetizationConfig.coins1500Amount);
      case MonetizationConfig.premiumWizardProductId:
        final skins = List<String>.from(_current.ownedSkins);
        if (!skins.contains(MonetizationConfig.premiumWizardSkinId)) {
          skins.add(MonetizationConfig.premiumWizardSkinId);
        }
        await _persist(_current.copyWith(ownedSkins: skins));
    }
  }

  Future<void> grantRewardedCoins() async {
    await addCoins(MonetizationConfig.rewardedCoinBonus);
  }
}
