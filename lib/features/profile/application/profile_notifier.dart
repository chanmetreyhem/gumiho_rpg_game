import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_env.dart';
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
    if (_current.ownedGuns.contains(gunId)) {
      await equipGun(gunId);
      return;
    }
    if (AppEnv.shopTestMode) {
      await _persist(
        _current.copyWith(
          ownedGuns: [..._current.ownedGuns, gunId],
          equippedGunId: gunId,
        ),
      );
      return;
    }
    if (_current.coins < price) return;
    await _persist(
      _current.copyWith(
        coins: _current.coins - price,
        ownedGuns: [..._current.ownedGuns, gunId],
        equippedGunId: gunId,
      ),
    );
  }

  Future<void> purchaseSkin(String skinId, int price) async {
    if (_current.ownedSkins.contains(skinId)) {
      await equipSkin(skinId);
      return;
    }
    if (AppEnv.shopTestMode) {
      await _persist(
        _current.copyWith(
          ownedSkins: [..._current.ownedSkins, skinId],
          equippedSkinId: skinId,
        ),
      );
      return;
    }
    if (_current.coins < price) return;
    await _persist(
      _current.copyWith(
        coins: _current.coins - price,
        ownedSkins: [..._current.ownedSkins, skinId],
        equippedSkinId: skinId,
      ),
    );
  }

  Future<void> purchaseArena(String arenaId, int price) async {
    if (_current.ownedArenas.contains(arenaId)) {
      await equipArena(arenaId);
      return;
    }
    if (AppEnv.shopTestMode) {
      await _persist(
        _current.copyWith(
          ownedArenas: [..._current.ownedArenas, arenaId],
          equippedArenaId: arenaId,
        ),
      );
      return;
    }
    if (_current.coins < price) return;
    await _persist(
      _current.copyWith(
        coins: _current.coins - price,
        ownedArenas: [..._current.ownedArenas, arenaId],
        equippedArenaId: arenaId,
      ),
    );
  }

  Future<void> equipGun(String gunId) async {
    if (!_current.ownedGuns.contains(gunId) && !AppEnv.shopTestMode) return;
    await _persist(_current.copyWith(equippedGunId: gunId));
  }

  Future<void> equipSkin(String skinId) async {
    if (!_current.ownedSkins.contains(skinId) && !AppEnv.shopTestMode) return;
    await _persist(_current.copyWith(equippedSkinId: skinId));
  }

  Future<void> equipArena(String arenaId) async {
    if (!_current.ownedArenas.contains(arenaId) && !AppEnv.shopTestMode) {
      return;
    }
    await _persist(_current.copyWith(equippedArenaId: arenaId));
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
