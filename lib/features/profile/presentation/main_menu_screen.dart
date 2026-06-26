import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gumiho_rpg_game/l10n/app_localizations.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_animations.dart';
import '../../../core/widgets/app_background.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/shop_asset_preview.dart';
import '../../../data/config/shop_catalog.dart';
import '../../profile/application/profile_notifier.dart';

class MainMenuScreen extends ConsumerWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final profileAsync = ref.watch(profileNotifierProvider);

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: profileAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (_, __) => Center(child: Text(l10n.gameOver)),
            data: (profile) {
              final skin =
                  ShopCatalog.skinById(profile.equippedSkinId);
              final weapon =
                  ShopCatalog.weaponById(profile.equippedGunId);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: FadeSlideIn(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.welcomeBack,
                                  style:
                                      Theme.of(context).textTheme.bodyMedium,
                                ),
                                Text(
                                  l10n.appTitle,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineLarge,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.purple.withValues(alpha: 0.1),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.pets_rounded,
                              color: AppColors.purple,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          FadeSlideIn(
                            delay: const Duration(milliseconds: 80),
                            child: AppCard(
                            padding: EdgeInsets.zero,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 160,
                                  width: double.infinity,
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(24),
                                    ),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFF3D2A7A),
                                        Color(0xFF6C3CE9),
                                      ],
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        right: -20,
                                        bottom: -10,
                                        child: Icon(
                                          Icons.shield_moon_rounded,
                                          size: 120,
                                          color: Colors.white
                                              .withValues(alpha: 0.15),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Row(
                                          children: [
                                            _Pill(
                                              icon: Icons.monetization_on,
                                              label: '${profile.coins}',
                                            ),
                                            const Spacer(),
                                            _Pill(
                                              icon: Icons.flag_rounded,
                                              label: l10n.level(
                                                profile.highestLevelCleared +
                                                            1 >
                                                        10
                                                    ? 10
                                                    : profile
                                                            .highestLevelCleared +
                                                        1,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.appTitle,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        l10n.gameTagline,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                      const SizedBox(height: 14),
                                      Text(
                                        l10n.equippedLoadout,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Container(
                                            padding:
                                                const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: AppColors.purple
                                                  .withValues(alpha: 0.08),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: CharacterPreview(
                                              characterFolder:
                                                  skin.characterFolder,
                                              size: 40,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              skin.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding:
                                                const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: AppColors.orange
                                                  .withValues(alpha: 0.08),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: GunPreview(
                                              weaponId: weapon.id,
                                              size: 40,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            weapon.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      PrimaryButton(
                                        label: l10n.letsPlay,
                                        icon: Icons.play_arrow_rounded,
                                        onPressed: () =>
                                            context.push('/levels'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ),
                          const SizedBox(height: 16),
                          FadeSlideIn(
                            delay: const Duration(milliseconds: 180),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _QuickAction(
                                    icon: Icons.storefront_rounded,
                                    label: l10n.shop,
                                    color: AppColors.orange,
                                    onTap: () => context.push('/shop'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _QuickAction(
                                    icon: Icons.settings_rounded,
                                    label: l10n.settings,
                                    color: AppColors.purple,
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

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.gold, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
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
    return PressableScale(
      onTap: onTap,
      child: AppCard(
        onTap: null,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
