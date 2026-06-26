import 'package:flutter/material.dart';
import 'package:gumiho_rpg_game/l10n/app_localizations.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/run_combo.dart';
import '../gumiho_game.dart';

class ComboPickOverlay extends StatelessWidget {
  const ComboPickOverlay({super.key, required this.game});

  final GumihoGame game;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final choices = game.comboChoices;

    return Material(
      color: Colors.black54,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AppCard(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.purple,
                    size: 36,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.comboPickTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.comboPickSubtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  ...choices.map(
                    (combo) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ComboOptionTile(
                        combo: combo,
                        title: _title(l10n, combo),
                        description: _description(l10n, combo),
                        onTap: () => game.pickCombo(combo),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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

  String _description(AppLocalizations l10n, RunCombo combo) {
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
}

class _ComboOptionTile extends StatelessWidget {
  const _ComboOptionTile({
    required this.combo,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final RunCombo combo;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.purple.withValues(alpha: 0.12),
                AppColors.purpleLight.withValues(alpha: 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.purple.withValues(alpha: 0.2)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.purple.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_iconFor(combo.type), color: AppColors.purple),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.purple,
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
