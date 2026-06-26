import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gumiho_rpg_game/l10n/app_localizations.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_background.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/shop_asset_preview.dart';
import '../../../data/config/shop_catalog.dart';
import '../../monetization/application/monetization_service.dart';
import '../../monetization/data/monetization_config.dart';
import '../../profile/application/profile_notifier.dart';
import '../../profile/domain/player_profile.dart';

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final profileAsync = ref.watch(profileNotifierProvider);
    final notifier = ref.read(profileNotifierProvider.notifier);
    final monetization = ref.watch(monetizationServiceProvider);

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      color: AppColors.textPrimary,
                      onPressed: () => context.go('/'),
                    ),
                    Expanded(
                      child: Text(
                        l10n.shop,
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: profileAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, __) => Center(child: Text(l10n.gameOver)),
                  data: (profile) => ListView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                    children: [
                      AppCard(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.orange.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.account_balance_wallet_rounded,
                                color: AppColors.orange,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.coins,
                                  style:
                                      Theme.of(context).textTheme.bodyMedium,
                                ),
                                Text(
                                  '${profile.coins}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _SectionTitle(title: l10n.premium),
                      _PremiumSection(
                        profile: profile,
                        monetization: monetization,
                        l10n: l10n,
                      ),
                      const SizedBox(height: 20),
                      _SectionTitle(title: l10n.guns),
                      ...ShopCatalog.weapons.map((weapon) {
                        final owned = profile.ownedGuns.contains(weapon.id);
                        final equipped = profile.equippedGunId == weapon.id;
                        return _ShopTile(
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
                          coins: profile.coins,
                          equipLabel: l10n.equip,
                          buyLabel: l10n.buy,
                          equippedLabel: l10n.equipped,
                          freeLabel: l10n.free,
                          preview: GunPreview(weaponId: weapon.id),
                          onBuy: () =>
                              notifier.purchaseGun(weapon.id, weapon.price),
                          onEquip: () => notifier.equipGun(weapon.id),
                        );
                      }),
                      const SizedBox(height: 20),
                      _SectionTitle(title: l10n.skins),
                      ...ShopCatalog.skins.map((skin) {
                        final owned = profile.ownedSkins.contains(skin.id);
                        final equipped = profile.equippedSkinId == skin.id;
                        return _ShopTile(
                          title: skin.name,
                          subtitle: l10n.skinStats(
                            (skin.hpBonus * 100).toInt(),
                            (skin.speedBonus * 100).toInt(),
                          ),
                          price: skin.price,
                          owned: owned,
                          equipped: equipped,
                          coins: profile.coins,
                          equipLabel: l10n.equip,
                          buyLabel: l10n.buy,
                          equippedLabel: l10n.equipped,
                          freeLabel: l10n.free,
                          preview: CharacterPreview(
                            characterFolder: skin.characterFolder,
                          ),
                          onBuy: () =>
                              notifier.purchaseSkin(skin.id, skin.price),
                          onEquip: () => notifier.equipSkin(skin.id),
                        );
                      }),
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}

class _ShopTile extends StatelessWidget {
  const _ShopTile({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.owned,
    required this.equipped,
    required this.coins,
    required this.equipLabel,
    required this.buyLabel,
    required this.equippedLabel,
    required this.freeLabel,
    required this.preview,
    this.onBuy,
    this.onEquip,
  });

  final String title;
  final String subtitle;
  final int price;
  final bool owned;
  final bool equipped;
  final int coins;
  final String equipLabel;
  final String buyLabel;
  final String equippedLabel;
  final String freeLabel;
  final Widget preview;
  final VoidCallback? onBuy;
  final VoidCallback? onEquip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.purple.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: preview,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            if (equipped)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.purple.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  equippedLabel,
                  style: const TextStyle(
                    color: AppColors.purple,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              )
            else if (owned)
              TextButton(
                onPressed: onEquip,
                child: Text(equipLabel),
              )
            else
              PrimaryButton(
                expanded: false,
                label: price == 0 ? freeLabel : '$price',
                onPressed: coins >= price || price == 0 ? onBuy : null,
              ),
          ],
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
        profile.ownedSkins.contains(MonetizationConfig.premiumWizardSkinId);

    return Column(
      children: [
        if (profile.removeAdsPurchased)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              l10n.adsRemoved,
              style: const TextStyle(
                color: AppColors.purple,
                fontWeight: FontWeight.w700,
              ),
            ),
          )
        else
          _IapTile(
            title: l10n.removeAds,
            price: _price(MonetizationConfig.removeAdsProductId, '\$2.99'),
            icon: Icons.block_rounded,
            enabled: monetization.isIapAvailable,
            onTap: () => monetization.buyNonConsumable(
              MonetizationConfig.removeAdsProductId,
            ),
          ),
        _IapTile(
          title: l10n.coinPack500,
          price: _price(MonetizationConfig.coins500ProductId, '\$0.99'),
          icon: Icons.monetization_on_rounded,
          enabled: monetization.isIapAvailable,
          onTap: () => monetization.buyProduct(
            MonetizationConfig.coins500ProductId,
          ),
        ),
        _IapTile(
          title: l10n.coinPack1500,
          price: _price(MonetizationConfig.coins1500ProductId, '\$2.99'),
          icon: Icons.savings_rounded,
          enabled: monetization.isIapAvailable,
          onTap: () => monetization.buyProduct(
            MonetizationConfig.coins1500ProductId,
          ),
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
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.orange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppColors.orange),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            PrimaryButton(
              expanded: false,
              label: price,
              onPressed: enabled ? onTap : null,
            ),
          ],
        ),
      ),
    );
  }
}
