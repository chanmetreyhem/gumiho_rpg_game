import 'package:flutter/material.dart';
import 'package:gumiho_rpg_game/l10n/app_localizations.dart';

import '../../../../core/theme/game_ui_theme.dart';
import '../../../../core/widgets/app_animations.dart';
import '../../../../core/widgets/game_ui_widgets.dart';

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
        child: GameHudPanel(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          radius: 18,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: won
                      ? GameUiColors.playGradient
                      : const LinearGradient(
                          colors: [Color(0xFF5C2B2B), GameUiColors.waveRed],
                        ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  (won ? l10n.levelComplete : l10n.gameOver).toUpperCase(),
                  textAlign: TextAlign.center,
                  style: GameUiText.hudBold(
                    15,
                    color: won ? const Color(0xFF2D1600) : Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (won) ...[
                Text(l10n.youScored, style: GameUiText.label()),
                const SizedBox(height: 8),
                Text(
                  '$totalCoins',
                  style: GameUiText.hudBold(
                    40,
                    color: GameUiColors.actionYellow,
                  ),
                ),
                Text(l10n.points, style: GameUiText.label()),
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
                          color: GameUiColors.actionYellow,
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                ),
              ] else ...[
                const Icon(
                  Icons.sentiment_dissatisfied_rounded,
                  size: 64,
                  color: GameUiColors.textMuted,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.coinsEarned(totalCoins),
                  style: GameUiText.hudBold(16),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),
              if (!won && onWatchAdToRevive != null) ...[
                SizedBox(
                  width: double.infinity,
                  child: GamePlayButton(
                    label: l10n.watchAdToRevive,
                    icon: Icons.play_circle_outline_rounded,
                    compact: true,
                    onPressed: onWatchAdToRevive,
                  ),
                ),
                const SizedBox(height: 10),
              ],
              if (!won && onWatchAdForCoins != null) ...[
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onWatchAdForCoins,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: GameUiColors.expCyan,
                      side: const BorderSide(color: GameUiColors.expCyan),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(l10n.watchAdForCoins),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              if (won && onPlayAgain != null)
                SizedBox(
                  width: double.infinity,
                  child: GamePlayButton(
                    label: l10n.playAgain,
                    icon: Icons.replay_rounded,
                    onPressed: onPlayAgain,
                  ),
                ),
              if (won && onPlayAgain != null) const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onContinue,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: GameUiColors.panelBorder),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(won ? l10n.continueBtn : l10n.closeGame),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
