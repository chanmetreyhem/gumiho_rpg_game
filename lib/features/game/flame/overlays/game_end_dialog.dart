import 'package:flutter/material.dart';
import 'package:gumiho_rpg_game/l10n/app_localizations.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_animations.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_card.dart';

class GameEndDialog extends StatelessWidget {
  const GameEndDialog({
    super.key,
    required this.won,
    required this.stars,
    required this.totalCoins,
    required this.onContinue,
    this.onPlayAgain,
    this.onWatchAdForCoins,
    this.onWatchAdToRevive,
  });

  final bool won;
  final int stars;
  final int totalCoins;
  final VoidCallback onContinue;
  final VoidCallback? onPlayAgain;
  final VoidCallback? onWatchAdForCoins;
  final VoidCallback? onWatchAdToRevive;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: ScaleFadeIn(
        child: AppCard(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.orange, AppColors.orangeDark],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    (won ? l10n.levelComplete : l10n.gameOver).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            if (won) ...[
              Text(
                l10n.youScored,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '$totalCoins',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppColors.purple,
                      fontSize: 40,
                    ),
              ),
              Text(
                l10n.points,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (i) => FadeSlideIn(
                    delay: Duration(milliseconds: 200 + i * 120),
                    offset: const Offset(0, 20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        i < stars
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: AppColors.gold,
                        size: 36,
                      ),
                    ),
                  ),
                ),
              ),
            ] else ...[
              Icon(
                Icons.sentiment_dissatisfied_rounded,
                size: 64,
                color: AppColors.purple.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.coinsEarned(totalCoins),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
            const SizedBox(height: 24),
            if (!won && onWatchAdToRevive != null) ...[
              PrimaryButton(
                label: l10n.watchAdToRevive,
                icon: Icons.play_circle_outline_rounded,
                onPressed: onWatchAdToRevive,
              ),
              const SizedBox(height: 10),
            ],
            if (!won && onWatchAdForCoins != null) ...[
              SecondaryButton(
                label: l10n.watchAdForCoins,
                onPressed: onWatchAdForCoins,
              ),
              const SizedBox(height: 10),
            ],
            if (won && onPlayAgain != null)
              PrimaryButton(
                label: l10n.playAgain,
                icon: Icons.replay_rounded,
                onPressed: onPlayAgain,
              ),
            if (won && onPlayAgain != null) const SizedBox(height: 10),
            SecondaryButton(
              label: won ? l10n.continueBtn : l10n.closeGame,
              onPressed: onContinue,
            ),
          ],
        ),
        ),
      ),
    );
  }
}
