import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gumiho_rpg_game/l10n/app_localizations.dart';

import '../../../core/config/app_env.dart';
import '../../../core/theme/game_ui_theme.dart';
import '../../../core/widgets/app_animations.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../../core/widgets/game_ui_widgets.dart';
import '../../../core/widgets/shop_asset_preview.dart';
import '../../../data/config/shop_catalog.dart';
import '../../../data/shop/shop_access.dart';
import '../../monetization/application/monetization_service.dart';
import '../../monetization/data/monetization_config.dart';
import '../../profile/application/profile_notifier.dart';
import '../../profile/domain/player_profile.dart';

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final profileAsync = ref.watch(profileNotifierProvider);
    final notifier = ref.read(profileNotifierProvider.notifier);
    final monetization = ref.watch(monetizationServiceProvider);

    return Scaffold(
      body: GameScreenBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
                child: Row(
                  children: [
                    GameRoundButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onPressed: () => context.go('/'),
                      size: 38,
                    ),
                    Expanded(
                      child: Text(
                        l10n.shop,
                        textAlign: TextAlign.center,
                        style: GameUiText.hudBold(20),
                      ),
                    ),
                    const SizedBox(width: 38),
                  ],
                ),
              ),
              if (AppEnv.shopTestMode)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: GameHudPanel(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.science_rounded,
                          color: GameUiColors.actionOrange,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            l10n.shopTestModeBanner,
                            style: GameUiText.hudBold(12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Expanded(
                child: profileAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, __) => Center(child: Text(l10n.gameOver)),
                  data: (profile) => Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                        child: _LoadoutSummary(profile: profile, l10n: l10n),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                        child: TabBar(
                          controller: _tabs,
                          isScrollable: true,
                          tabAlignment: TabAlignment.start,
                          labelColor: GameUiColors.expCyan,
                          unselectedLabelColor: GameUiColors.textMuted,
                          indicatorColor: GameUiColors.expCyan,
                          dividerColor: Colors.transparent,
                          tabs: [
                            Tab(text: l10n.shopTabHeroes),
                            Tab(text: l10n.shopTabGuns),
                            Tab(text: l10n.shopTabArenas),
                            Tab(text: l10n.shopTabPremium),
                          ],
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: _tabs,
                          children: [
                            _ItemGrid(
                              l10n: l10n,
                              profile: profile,
                              children: ShopCatalog.skins.map((skin) {
                                final owned =
                                    ShopAccess.ownsSkin(profile, skin.id);
                                final equipped =
                                    profile.equippedSkinId == skin.id;
                                return _ShopItemCard(
                                  title: skin.name,
                                  subtitle: l10n.skinStats(
                                    (skin.hpBonus * 100).toInt(),
                                    (skin.speedBonus * 100).toInt(),
                                  ),
                                  price: skin.price,
                                  owned: owned,
                                  equipped: equipped,
                                  canBuy: ShopAccess.canAfford(
                                    profile,
                                    skin.price,
                                  ),
                                  l10n: l10n,
                                  preview: CharacterPreview(
                                    characterFolder: skin.characterFolder,
                                    size: 64,
                                  ),
                                  onAction: () {
                                    if (owned && !equipped) {
                                      notifier.equipSkin(skin.id);
                                    } else if (!owned) {
                                      notifier.purchaseSkin(
                                        skin.id,
                                        skin.price,
                                      );
                                    }
                                  },
                                );
                              }).toList(),
                            ),
                            _ItemGrid(
                              l10n: l10n,
                              profile: profile,
                              children: ShopCatalog.weapons.map((weapon) {
                                final owned =
                                    ShopAccess.ownsGun(profile, weapon.id);
                                final equipped =
                                    profile.equippedGunId == weapon.id;
                                return _ShopItemCard(
                                  title: weapon.name,
                                  subtitle: weapon.description.isNotEmpty
                                      ? '${l10n.weaponStats(weapon.damage.toInt(), weapon.fireRate.toString())}\n${weapon.description}'
                                      : l10n.weaponStats(
                                          weapon.damage.toInt(),
                                          weapon.fireRate.toString(),
                                        ),
                                  price: weapon.price,
                                  owned: owned,
                                  equipped: equipped,
                                  canBuy: ShopAccess.canAfford(
                                    profile,
                                    weapon.price,
                                  ),
                                  l10n: l10n,
                                  preview: GunPreview(
                                    weaponId: weapon.id,
                                    size: 64,
                                  ),
                                  onAction: () {
                                    if (owned && !equipped) {
                                      notifier.equipGun(weapon.id);
                                    } else if (!owned) {
                                      notifier.purchaseGun(
                                        weapon.id,
                                        weapon.price,
                                      );
                                    }
                                  },
                                );
                              }).toList(),
                            ),
                            _ItemGrid(
                              l10n: l10n,
                              profile: profile,
                              children: ShopCatalog.arenas.map((arena) {
                                final owned =
                                    ShopAccess.ownsArena(profile, arena.id);
                                final equipped =
                                    profile.equippedArenaId == arena.id;
                                return _ShopItemCard(
                                  title: arena.name,
                                  subtitle: l10n.shopTapToEquip,
                                  price: arena.price,
                                  owned: owned,
                                  equipped: equipped,
                                  canBuy: ShopAccess.canAfford(
                                    profile,
                                    arena.price,
                                  ),
                                  l10n: l10n,
                                  previewWide: true,
                                  preview: LayoutBuilder(
                                    builder: (context, constraints) {
                                      return ArenaPreview(
                                        imageFileName: arena.imageFileName,
                                        width: constraints.maxWidth,
                                        height: 88,
                                      );
                                    },
                                  ),
                                  onAction: () {
                                    if (owned && !equipped) {
                                      notifier.equipArena(arena.id);
                                    } else if (!owned) {
                                      notifier.purchaseArena(
                                        arena.id,
                                        arena.price,
                                      );
                                    }
                                  },
                                );
                              }).toList(),
                            ),
                            ListView(
                              padding: const EdgeInsets.fromLTRB(
                                24,
                                12,
                                24,
                                16,
                              ),
                              children: [
                                _PremiumSection(
                                  profile: profile,
                                  monetization: monetization,
                                  l10n: l10n,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const AppBottomNav(currentIndex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadoutSummary extends StatelessWidget {
  const _LoadoutSummary({required this.profile, required this.l10n});

  final PlayerProfile profile;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final skin = ShopCatalog.skinById(profile.equippedSkinId);
    final weapon = ShopCatalog.weaponById(profile.equippedGunId);
    final arena = ShopCatalog.arenaById(profile.equippedArenaId);

    return GameHudPanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(l10n.shopLoadout, style: GameUiText.hudBold(15)),
              const Spacer(),
              const Icon(
                Icons.monetization_on,
                color: GameUiColors.actionYellow,
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                '${profile.coins}',
                style: GameUiText.hudBold(14, color: GameUiColors.actionYellow),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _LoadoutChip(
                  label: skin.name,
                  child: CharacterPreview(
                    characterFolder: skin.characterFolder,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _LoadoutChip(
                  label: weapon.name,
                  child: GunPreview(weaponId: weapon.id, size: 40),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _LoadoutChip(
            label: arena.name,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return ArenaPreview(
                  imageFileName: arena.imageFileName,
                  width: constraints.maxWidth,
                  height: 56,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadoutChip extends StatelessWidget {
  const _LoadoutChip({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: GameUiColors.tileUnlocked,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: GameUiColors.panelBorder),
      ),
      child: Column(
        children: [
          child,
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GameUiText.hudBold(11),
          ),
        ],
      ),
    );
  }
}

class _ItemGrid extends StatelessWidget {
  const _ItemGrid({
    required this.l10n,
    required this.profile,
    required this.children,
  });

  final AppLocalizations l10n;
  final PlayerProfile profile;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
      children: [
        Text(l10n.shopTapToEquip, style: GameUiText.label()),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }
}

class _ShopItemCard extends StatelessWidget {
  const _ShopItemCard({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.owned,
    required this.equipped,
    required this.canBuy,
    required this.l10n,
    required this.preview,
    required this.onAction,
    this.previewWide = false,
  });

  final String title;
  final String subtitle;
  final int price;
  final bool owned;
  final bool equipped;
  final bool canBuy;
  final AppLocalizations l10n;
  final Widget preview;
  final VoidCallback onAction;
  final bool previewWide;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: FadeSlideIn(
        child: PressableScale(
          onTap: equipped ? () {} : onAction,
          enabled: !equipped,
          child: GameHudPanel(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (previewWide)
                  preview
                else
                  Center(child: preview),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: GameUiText.hudBold(14)),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: GameUiText.label(),
                          ),
                        ],
                      ),
                    ),
                    _ActionBadge(
                      equipped: equipped,
                      owned: owned,
                      price: price,
                      canBuy: canBuy,
                      l10n: l10n,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionBadge extends StatelessWidget {
  const _ActionBadge({
    required this.equipped,
    required this.owned,
    required this.price,
    required this.canBuy,
    required this.l10n,
  });

  final bool equipped;
  final bool owned;
  final int price;
  final bool canBuy;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    if (equipped) {
      return _pill(l10n.equipped, GameUiColors.expCyan);
    }
    if (owned) {
      return _pill(l10n.equip, GameUiColors.actionOrange);
    }
    final label = price == 0 ? l10n.free : '$price';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: canBuy ? GameUiColors.purpleBadge : GameUiColors.tileLocked,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GameUiText.hudBold(
          12,
          color: canBuy ? Colors.white : GameUiColors.textMuted,
        ),
      ),
    );
  }

  Widget _pill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _PremiumSection extends StatelessWidget {
  const _PremiumSection({
    required this.profile,
    required this.monetization,
    required this.l10n,
  });

  final PlayerProfile profile;
  final MonetizationService monetization;
  final AppLocalizations l10n;

  String _price(String productId, String fallback) {
    return monetization.products[productId]?.price ?? fallback;
  }

  @override
  Widget build(BuildContext context) {
    final wizardOwned =
        ShopAccess.ownsSkin(profile, MonetizationConfig.premiumWizardSkinId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.premium, style: GameUiText.hudBold(18)),
        const SizedBox(height: 12),
        _IapTile(
          title: l10n.coinPack500,
          price: _price(MonetizationConfig.coins500ProductId, '\$0.99'),
          icon: Icons.monetization_on_rounded,
          enabled: monetization.isIapAvailable,
          onTap: () =>
              monetization.buyProduct(MonetizationConfig.coins500ProductId),
        ),
        _IapTile(
          title: l10n.coinPack1500,
          price: _price(MonetizationConfig.coins1500ProductId, '\$2.99'),
          icon: Icons.savings_rounded,
          enabled: monetization.isIapAvailable,
          onTap: () =>
              monetization.buyProduct(MonetizationConfig.coins1500ProductId),
        ),
        if (!wizardOwned)
          _IapTile(
            title: l10n.premiumWizard,
            price: _price(MonetizationConfig.premiumWizardProductId, '\$4.99'),
            icon: Icons.auto_awesome_rounded,
            enabled: monetization.isIapAvailable,
            onTap: () => monetization.buyNonConsumable(
              MonetizationConfig.premiumWizardProductId,
            ),
          ),
      ],
    );
  }
}

class _IapTile extends StatelessWidget {
  const _IapTile({
    required this.title,
    required this.price,
    required this.icon,
    required this.onTap,
    this.enabled = true,
  });

  final String title;
  final String price;
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GameHudPanel(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: GameUiColors.actionOrange.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: GameUiColors.actionOrange),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(title, style: GameUiText.hudBold(14)),
            ),
            GamePlayButton(
              label: price,
              compact: true,
              onPressed: enabled ? onTap : null,
            ),
          ],
        ),
      ),
    );
  }
}
