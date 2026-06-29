import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gumiho_rpg_game/l10n/app_localizations.dart';

import '../../../../core/theme/game_ui_theme.dart';
import '../../../../core/widgets/app_animations.dart';
import '../../domain/run_combo.dart';
import '../gumiho_game.dart';

class ComboPickOverlay extends StatelessWidget {
  const ComboPickOverlay({super.key, required this.game});

  final GumihoGame game;

  static const _cardBorder = Color(0xFF1E1408);
  static const _actBg = Color(0xFFFFCC99);
  static const _statBg = Color(0xFF99CCFF);
  static const _pasBg = Color(0xFFCCAAFF);
  static const _progressFill = Color(0xFFFF7A1A);
  static const _progressTrack = Color(0xFF3D2817);
  static const _cardWidth = 112.0;
  static const _cardHeight = 228.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final choices = game.comboChoices;

    return Material(
      color: Colors.transparent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(color: Colors.black.withValues(alpha: 0.62)),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),
                FadeSlideIn(
                  offset: const Offset(0, -16),
                  child: Text(
                    l10n.comboPickTitle,
                    textAlign: TextAlign.center,
                    style: GameUiText.hudBold(22),
                  ),
                ),
                const SizedBox(height: 8),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 60),
                  child: Text(
                    l10n.comboPickSubtitle,
                    textAlign: TextAlign.center,
                    style: GameUiText.label(color: GameUiColors.textMuted),
                  ),
                ),
                const SizedBox(height: 22),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 100),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: choices.asMap().entries.map((entry) {
                        final combo = entry.value;
                        return Padding(
                          padding: EdgeInsets.only(
                            left: entry.key == 0 ? 0 : 10,
                          ),
                          child: _ComboSkillCard(
                            width: _cardWidth,
                            height: _cardHeight,
                            combo: combo,
                            pickCount: game.runBuffs.pickCount(combo.type),
                            categoryLabel: _categoryLabel(l10n, combo.type),
                            backgroundColor: _backgroundFor(combo.type),
                            title: _title(l10n, combo),
                            boostText: _boostText(l10n, combo),
                            description: _description(l10n, combo),
                            onTap: () => game.pickCombo(combo),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const Spacer(flex: 2),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 280),
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Text(
                      l10n.comboPickHint,
                      textAlign: TextAlign.center,
                      style: GameUiText.hudBold(16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _backgroundFor(ComboType type) {
    return switch (type.category) {
      ComboCategory.active => _actBg,
      ComboCategory.stat => _statBg,
      ComboCategory.passive => _pasBg,
    };
  }

  String _categoryLabel(AppLocalizations l10n, ComboType type) {
    return switch (type.category) {
      ComboCategory.active => l10n.comboCategoryAct,
      ComboCategory.stat => l10n.comboCategoryStat,
      ComboCategory.passive => l10n.comboCategoryPas,
    };
  }

  String _title(AppLocalizations l10n, RunCombo combo) {
    return switch (combo.type) {
      ComboType.damageUp => l10n.comboDamageTitle,
      ComboType.fireRateUp => l10n.comboFireRateTitle,
      ComboType.maxHpUp => l10n.comboMaxHpTitle,
      ComboType.heal => l10n.comboHealTitle,
      ComboType.speedUp => l10n.comboSpeedTitle,
      ComboType.extraBomb => l10n.comboBombTitle,
      ComboType.bulletSpeedUp => l10n.comboBulletSpeedTitle,
    };
  }

  String _boostText(AppLocalizations l10n, RunCombo combo) {
    final percent = (combo.value * 100).round();
    return switch (combo.type) {
      ComboType.damageUp => l10n.comboDamageDesc(percent),
      ComboType.fireRateUp => l10n.comboFireRateDesc(percent),
      ComboType.maxHpUp => l10n.comboMaxHpDesc(percent),
      ComboType.heal => l10n.comboHealDesc(percent),
      ComboType.speedUp => l10n.comboSpeedDesc(percent),
      ComboType.extraBomb => l10n.comboBombDesc,
      ComboType.bulletSpeedUp => l10n.comboBulletSpeedDesc(percent),
    };
  }

  String _description(AppLocalizations l10n, RunCombo combo) =>
      _boostText(l10n, combo);
}

class _ComboSkillCard extends StatelessWidget {
  const _ComboSkillCard({
    required this.width,
    required this.height,
    required this.combo,
    required this.pickCount,
    required this.categoryLabel,
    required this.backgroundColor,
    required this.title,
    required this.boostText,
    required this.description,
    required this.onTap,
  });

  final double width;
  final double height;
  final RunCombo combo;
  final int pickCount;
  final String categoryLabel;
  final Color backgroundColor;
  final String title;
  final String boostText;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final progressMax = combo.type.progressMax;
    final nextLevel = pickCount + 1;
    final nextProgress = nextLevel % progressMax;

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: backgroundColor,
        elevation: 6,
        shadowColor: Colors.black54,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: ComboPickOverlay._cardBorder, width: 4),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      categoryLabel,
                      style: const TextStyle(
                        color: ComboPickOverlay._cardBorder,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const Spacer(),
                    _InfoButton(description: description, title: title),
                  ],
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _iconFor(combo.type),
                        size: 52,
                        color: ComboPickOverlay._cardBorder,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: ComboPickOverlay._cardBorder,
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        boostText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: ComboPickOverlay._cardBorder.withValues(alpha: 0.75),
                          fontWeight: FontWeight.w700,
                          fontSize: 9,
                          height: 1.15,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  l10n.comboLevel(nextLevel),
                  style: const TextStyle(
                    color: ComboPickOverlay._cardBorder,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                _ComboProgressBar(
                  current: nextProgress,
                  max: progressMax,
                  label: l10n.comboProgress(nextProgress, progressMax),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _iconFor(ComboType type) {
    return switch (type) {
      ComboType.damageUp => Icons.bolt_rounded,
      ComboType.fireRateUp => Icons.speed_rounded,
      ComboType.maxHpUp => Icons.favorite_rounded,
      ComboType.heal => Icons.healing_rounded,
      ComboType.speedUp => Icons.directions_run_rounded,
      ComboType.extraBomb => Icons.whatshot_rounded,
      ComboType.bulletSpeedUp => Icons.track_changes_rounded,
    };
  }
}

class _InfoButton extends StatelessWidget {
  const _InfoButton({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: Material(
        color: const Color(0xFF4A90D9),
        shape: const CircleBorder(
          side: BorderSide(color: ComboPickOverlay._cardBorder, width: 2),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            showDialog<void>(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: GameUiColors.backgroundBottom,
                title: Text(title, style: GameUiText.hudBold(16)),
                content: Text(description, style: GameUiText.label()),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text(MaterialLocalizations.of(ctx).okButtonLabel),
                  ),
                ],
              ),
            );
          },
          child: const Icon(Icons.search_rounded, color: Colors.white, size: 12),
        ),
      ),
    );
  }
}

class _ComboProgressBar extends StatelessWidget {
  const _ComboProgressBar({
    required this.current,
    required this.max,
    required this.label,
  });

  final int current;
  final int max;
  final String label;

  @override
  Widget build(BuildContext context) {
    final fill = max == 0 ? 0.0 : (current / max).clamp(0.0, 1.0);

    return SizedBox(
      height: 20,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: ComboPickOverlay._progressTrack,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: ComboPickOverlay._cardBorder,
                width: 2,
              ),
            ),
            child: const SizedBox.expand(),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: fill,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: ComboPickOverlay._progressFill,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const SizedBox(height: 16),
              ),
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 10,
              shadows: [Shadow(color: Colors.black54, blurRadius: 2)],
            ),
          ),
        ],
      ),
    );
  }
}
