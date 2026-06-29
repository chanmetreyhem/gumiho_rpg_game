import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gumiho_rpg_game/l10n/app_localizations.dart';

import '../../../core/theme/game_ui_theme.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../../core/widgets/game_ui_widgets.dart';
import '../../monetization/application/monetization_service.dart';
import '../../profile/application/profile_notifier.dart';
import '../application/settings_notifier.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsNotifierProvider);
    final notifier = ref.read(settingsNotifierProvider.notifier);

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
                        l10n.settings,
                        textAlign: TextAlign.center,
                        style: GameUiText.hudBold(20),
                      ),
                    ),
                    const SizedBox(width: 38),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    GameSectionCard(
                      title: l10n.language,
                      child: GameSegmentToggle<String>(
                        options: const ['en', 'km'],
                        selected: settings.localeCode,
                        labelBuilder: (code) =>
                            code == 'en' ? l10n.english : l10n.khmer,
                        onChanged: notifier.setLocale,
                      ),
                    ),
                    const SizedBox(height: 14),
                    GameSectionCard(
                      title: l10n.audioSettings,
                      child: Column(
                        children: [
                          GameSliderRow(
                            label: l10n.musicVolume,
                            value: settings.musicVolume,
                            onChanged: notifier.setMusicVolume,
                          ),
                          const SizedBox(height: 12),
                          GameSliderRow(
                            label: l10n.sfxVolume,
                            value: settings.sfxVolume,
                            onChanged: notifier.setSfxVolume,
                          ),
                          const SizedBox(height: 12),
                          GameSliderRow(
                            label: l10n.joystickSensitivity,
                            value: settings.joystickSensitivity,
                            min: 0.5,
                            max: 1.5,
                            displayValue:
                                '${settings.joystickSensitivity.toStringAsFixed(1)}x',
                            onChanged: notifier.setJoystickSensitivity,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    GameSectionCard(
                      title: l10n.premium,
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () async {
                            await ref
                                .read(monetizationServiceProvider)
                                .restorePurchases();
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.purchaseRestored)),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: GameUiColors.expCyan,
                            side: const BorderSide(color: GameUiColors.expCyan),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(l10n.restorePurchases),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    GameSectionCard(
                      title: l10n.accountSettings,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.resetProgressConfirm,
                            style: GameUiText.label(),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () =>
                                  _confirmReset(context, ref, l10n),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: GameUiColors.waveRed,
                                side: const BorderSide(color: GameUiColors.waveRed),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: Text(l10n.reset),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const AppBottomNav(currentIndex: 3),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmReset(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: GameUiColors.backgroundBottom,
        title: Text(l10n.resetProgressTitle, style: GameUiText.hudBold(16)),
        content: Text(l10n.resetProgressConfirm, style: GameUiText.label()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(profileNotifierProvider.notifier).resetProgress();
              if (context.mounted) context.go('/');
            },
            child: Text(
              l10n.reset,
              style: const TextStyle(color: GameUiColors.waveRed),
            ),
          ),
        ],
      ),
    );
  }
}
