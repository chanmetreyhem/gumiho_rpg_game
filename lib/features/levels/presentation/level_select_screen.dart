import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gumiho_rpg_game/l10n/app_localizations.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_animations.dart';
import '../../../core/widgets/app_background.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../../core/widgets/app_card.dart';
import '../../../data/config/level_config.dart';
import '../../profile/application/profile_notifier.dart';

class LevelSelectScreen extends ConsumerWidget {
  const LevelSelectScreen({super.key});

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
            data: (profile) => Column(
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
                        l10n.selectLevel,
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.purple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.monetization_on,
                          color: AppColors.purple,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.coins,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            '${profile.coins}',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.82,
                  ),
                  itemCount: LevelConfig.totalLevels,
                  itemBuilder: (context, index) {
                    final level = index + 1;
                    final unlocked = profile.isLevelUnlocked(level);
                    final stars = profile.levelStars[level] ?? 0;

                    return FadeSlideIn(
                      delay: Duration(milliseconds: (index % 20) * 28),
                      offset: const Offset(0, 14),
                      child: _LevelTile(
                        level: level,
                        label: l10n.level(level),
                        unlocked: unlocked,
                        stars: stars,
                        onTap:
                            unlocked ? () => context.push('/game/$level') : null,
                      ),
                    );
                  },
                ),
              ),
              const AppBottomNav(currentIndex: 1),
            ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LevelTile extends StatelessWidget {
  const _LevelTile({
    required this.level,
    required this.label,
    required this.unlocked,
    required this.stars,
    this.onTap,
  });

  final int level;
  final String label;
  final bool unlocked;
  final int stars;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      enabled: onTap != null,
      child: AppCard(
        onTap: null,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        color: unlocked ? Colors.white : const Color(0xFFF0EDF8),
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: unlocked
                  ? AppColors.purple.withValues(alpha: 0.12)
                  : Colors.grey.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              unlocked ? Icons.play_arrow_rounded : Icons.lock_rounded,
              color: unlocked ? AppColors.purple : AppColors.textSecondary,
              size: 26,
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: TextStyle(
                color: unlocked ? AppColors.textPrimary : AppColors.textSecondary,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          if (stars > 0) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (i) => Icon(
                  i < stars ? Icons.star_rounded : Icons.star_border_rounded,
                  color: AppColors.gold,
                  size: 12,
                ),
              ),
            ),
          ],
        ],
        ),
      ),
    );
  }
}
