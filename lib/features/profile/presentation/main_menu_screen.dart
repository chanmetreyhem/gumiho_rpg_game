import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gumiho_rpg_game/l10n/app_localizations.dart';

import '../../../core/theme/game_ui_theme.dart';
import '../../../core/widgets/app_animations.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../../core/widgets/game_ui_widgets.dart';
import '../../../core/widgets/shop_asset_preview.dart';
import '../../../data/config/level_config.dart';
import '../../../data/config/shop_catalog.dart';
import '../../monetization/application/monetization_service.dart';
import '../../monetization/data/monetization_config.dart';
import '../../profile/application/profile_notifier.dart';
import '../../profile/domain/player_profile.dart';

class MainMenuScreen extends ConsumerWidget {
  const MainMenuScreen({super.key});

  int _nextLevel(int highestCleared) {
    final next = highestCleared + 1;
    return next.clamp(1, LevelConfig.totalLevels);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final profileAsync = ref.watch(profileNotifierProvider);

    return Scaffold(
      body: GameScreenBackground(
        child: SafeArea(
          child: profileAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (_, __) => Center(
              child: Text(l10n.gameOver, style: GameUiText.hudBold(16)),
            ),
            data: (profile) {
              final skin = ShopCatalog.skinById(profile.equippedSkinId);
              final weapon = ShopCatalog.weaponById(profile.equippedGunId);
              final monetization = ref.watch(monetizationServiceProvider);
              final nextLevel = _nextLevel(profile.highestLevelCleared);
              final canQuickPlay = profile.isLevelUnlocked(nextLevel);

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: FadeSlideIn(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.welcomeBack,
                                  style: GameUiText.label(),
                                ),
                                Text(
                                  l10n.appTitle,
                                  style: GameUiText.hudBold(28),
                                ),
                              ],
                            ),
                          ),
                          GameHudPanel(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: GameStatChip(
                              icon: Icons.monetization_on_rounded,
                              value: '${profile.coins}',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          FadeSlideIn(
                            delay: const Duration(milliseconds: 80),
                            child: GameHudPanel(
                              padding: const EdgeInsets.all(18),
                              radius: 18,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 140,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF243B6B),
                                          Color(0xFF3D5A99),
                                        ],
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          right: 16,
                                          bottom: 8,
                                          child: CharacterPreview(
                                            characterFolder: skin.characterFolder,
                                            size: 96,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                l10n.level(nextLevel),
                                                style: GameUiText.hudBold(22),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                l10n.gameTagline,
                                                style: GameUiText.label(),
                                              ),
                                              const Spacer(),
                                              Row(
                                                children: [
                                                  GunPreview(
                                                    weaponId: weapon.id,
                                                    size: 36,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      '${skin.name} · ${weapon.name}',
                                                      style: GameUiText.hudBold(12),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: GamePlayButton(
                                      label: l10n.quickPlay,
                                      onPressed: canQuickPlay
                                          ? () => context.push('/game/$nextLevel')
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    width: double.infinity,
                                    child: GamePlayButton(
                                      label: l10n.selectLevel,
                                      icon: Icons.grid_view_rounded,
                                      compact: true,
                                      onPressed: () => context.push('/levels'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          FadeSlideIn(
                            delay: const Duration(milliseconds: 140),
                            child: _HomeIapSection(
                              profile: profile,
                              monetization: monetization,
                              l10n: l10n,
                            ),
                          ),
                          const SizedBox(height: 14),
                          FadeSlideIn(
                            delay: const Duration(milliseconds: 160),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _MenuShortcut(
                                    icon: Icons.storefront_rounded,
                                    label: l10n.shop,
                                    color: GameUiColors.actionOrange,
                                    onTap: () => context.push('/shop'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _MenuShortcut(
                                    icon: Icons.settings_rounded,
                                    label: l10n.settings,
                                    color: GameUiColors.expCyan,
                                    onTap: () => context.push('/settings'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const AppBottomNav(currentIndex: 0),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HomeIapSection extends StatelessWidget {
  const _HomeIapSection({
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
    final wizardOwned = profile.ownedSkins
        .contains(MonetizationConfig.premiumWizardSkinId);

    return GameHudPanel(
      padding: const EdgeInsets.all(16),
      radius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.premium, style: GameUiText.hudBold(18)),
          const SizedBox(height: 12),
          if (profile.removeAdsPurchased)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.verified_rounded,
                    color: GameUiColors.expCyan,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.adsRemoved,
                    style: GameUiText.hudBold(13, color: GameUiColors.expCyan),
                  ),
                ],
              ),
            )
          else
            _HomeIapTile(
              title: l10n.removeAds,
              subtitle: l10n.gameTagline,
              price: _price(MonetizationConfig.removeAdsProductId, '\$2.99'),
              icon: Icons.block_rounded,
              accent: GameUiColors.actionOrange,
              enabled: monetization.isIapAvailable,
              onTap: () => monetization.buyNonConsumable(
                MonetizationConfig.removeAdsProductId,
              ),
            ),
          _HomeIapTile(
            title: l10n.coinPack500,
            price: _price(MonetizationConfig.coins500ProductId, '\$0.99'),
            icon: Icons.monetization_on_rounded,
            accent: GameUiColors.actionYellow,
            enabled: monetization.isIapAvailable,
            onTap: () =>
                monetization.buyProduct(MonetizationConfig.coins500ProductId),
          ),
          _HomeIapTile(
            title: l10n.coinPack1500,
            price: _price(MonetizationConfig.coins1500ProductId, '\$2.99'),
            icon: Icons.savings_rounded,
            accent: GameUiColors.expCyan,
            enabled: monetization.isIapAvailable,
            onTap: () =>
                monetization.buyProduct(MonetizationConfig.coins1500ProductId),
          ),
          if (!wizardOwned)
            _HomeIapTile(
              title: l10n.premiumWizard,
              price: _price(MonetizationConfig.premiumWizardProductId, '\$4.99'),
              icon: Icons.auto_awesome_rounded,
              accent: GameUiColors.purpleBadge,
              enabled: monetization.isIapAvailable,
              onTap: () => monetization.buyNonConsumable(
                MonetizationConfig.premiumWizardProductId,
              ),
            ),
        ],
      ),
    );
  }
}

class _HomeIapTile extends StatelessWidget {
  const _HomeIapTile({
    required this.title,
    required this.price,
    required this.icon,
    required this.accent,
    required this.onTap,
    this.subtitle,
    this.enabled = true,
  });

  final String title;
  final String? subtitle;
  final String price;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: GameUiColors.tileUnlocked,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: accent, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: GameUiText.hudBold(13)),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: GameUiText.label().copyWith(fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                Text(price, style: GameUiText.hudBold(13, color: accent)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuShortcut extends StatelessWidget {
  const _MenuShortcut({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: GameUiColors.tileUnlocked,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(label, style: GameUiText.hudBold(13)),
            ],
          ),
        ),
      ),
    );
  }
}
