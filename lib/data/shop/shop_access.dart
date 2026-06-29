import '../../core/config/app_env.dart';
import '../../features/profile/domain/player_profile.dart';

/// Shared shop ownership rules (respects [AppEnv.shopTestMode]).
class ShopAccess {
  ShopAccess._();

  static bool ownsSkin(PlayerProfile profile, String skinId) =>
      AppEnv.shopTestMode || profile.ownedSkins.contains(skinId);

  static bool ownsGun(PlayerProfile profile, String gunId) =>
      AppEnv.shopTestMode || profile.ownedGuns.contains(gunId);

  static bool ownsArena(PlayerProfile profile, String arenaId) =>
      AppEnv.shopTestMode || profile.ownedArenas.contains(arenaId);

  static bool canAfford(PlayerProfile profile, int price) =>
      AppEnv.shopTestMode || price == 0 || profile.coins >= price;
}
