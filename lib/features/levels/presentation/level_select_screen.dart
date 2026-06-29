import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gumiho_rpg_game/l10n/app_localizations.dart';

import '../../../core/theme/game_ui_theme.dart';
import '../../../core/widgets/app_animations.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../../core/widgets/game_ui_widgets.dart';
import '../../../data/config/level_config.dart';
import '../../profile/application/profile_notifier.dart';

class LevelSelectScreen extends ConsumerStatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  ConsumerState<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends ConsumerState<LevelSelectScreen> {
  static const _levelsPerPage = 20;
  static const _columns = 4;

  final _pageController = PageController();
  int _currentPage = 0;

  int get _pageCount =>
      (LevelConfig.totalLevels / _levelsPerPage).ceil();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<int> _levelsForPage(int page) {
    final start = page * _levelsPerPage + 1;
    final end = ((page + 1) * _levelsPerPage).clamp(1, LevelConfig.totalLevels);
    return List.generate(end - start + 1, (i) => start + i);
  }

  @override
  Widget build(BuildContext context) {
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
              final nextLevel = (profile.highestLevelCleared + 1)
                  .clamp(1, LevelConfig.totalLevels);
              final canQuickPlay = profile.isLevelUnlocked(nextLevel);

              return Column(
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
                            l10n.selectLevel,
                            textAlign: TextAlign.center,
                            style: GameUiText.hudBold(20),
                          ),
                        ),
                        const SizedBox(width: 38),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: GameHudPanel(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l10n.coins, style: GameUiText.label()),
                                Text(
                                  '${profile.coins}',
                                  style: GameUiText.hudBold(18,
                                      color: GameUiColors.actionYellow),
                                ),
                              ],
                            ),
                          ),
                          GamePlayButton(
                            label: l10n.quickPlay,
                            compact: true,
                            onPressed: canQuickPlay
                                ? () => context.push('/game/$nextLevel')
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.levelPage(_currentPage + 1, _pageCount),
                          style: GameUiText.label(),
                        ),
                        Text(
                          l10n.levelsPerPage(_levelsPerPage),
                          style: GameUiText.label(),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _pageCount,
                      onPageChanged: (page) => setState(() => _currentPage = page),
                      itemBuilder: (context, pageIndex) {
                        final levels = _levelsForPage(pageIndex);
                        return GridView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: _columns,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 0.88,
                          ),
                          itemCount: levels.length,
                          itemBuilder: (context, index) {
                            final level = levels[index];
                            final unlocked = profile.isLevelUnlocked(level);
                            final stars = profile.levelStars[level] ?? 0;

                            return FadeSlideIn(
                              delay: Duration(milliseconds: index * 24),
                              offset: const Offset(0, 10),
                              child: _LevelTile(
                                level: level,
                                label: l10n.level(level),
                                unlocked: unlocked,
                                stars: stars,
                                onTap: unlocked
                                    ? () => context.push('/game/$level')
                                    : null,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GameRoundButton(
                          icon: Icons.chevron_left_rounded,
                          size: 36,
                          onPressed: _currentPage > 0
                              ? () => _pageController.previousPage(
                                    duration: const Duration(milliseconds: 280),
                                    curve: Curves.easeOutCubic,
                                  )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        GamePageDots(
                          pageCount: _pageCount,
                          currentPage: _currentPage,
                          onPageSelected: (page) {
                            _pageController.animateToPage(
                              page,
                              duration: const Duration(milliseconds: 280),
                              curve: Curves.easeOutCubic,
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        GameRoundButton(
                          icon: Icons.chevron_right_rounded,
                          size: 36,
                          onPressed: _currentPage < _pageCount - 1
                              ? () => _pageController.nextPage(
                                    duration: const Duration(milliseconds: 280),
                                    curve: Curves.easeOutCubic,
                                  )
                              : null,
                        ),
                      ],
                    ),
                  ),
                  const AppBottomNav(currentIndex: 1),
                ],
              );
            },
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
    return Material(
      color: unlocked ? GameUiColors.tileUnlocked : GameUiColors.tileLocked,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: unlocked
                  ? GameUiColors.panelBorder
                  : Colors.transparent,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: unlocked
                      ? GameUiColors.tileActive
                      : Colors.black26,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  unlocked ? Icons.play_arrow_rounded : Icons.lock_rounded,
                  color: unlocked ? GameUiColors.expCyan : Colors.white38,
                  size: 24,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: GameUiText.hudBold(11),
                textAlign: TextAlign.center,
              ),
              if (stars > 0) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    3,
                    (i) => Icon(
                      i < stars
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: GameUiColors.actionYellow,
                      size: 11,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
