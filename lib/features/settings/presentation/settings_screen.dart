import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gumiho_rpg_game/l10n/app_localizations.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_background.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../../core/widgets/app_card.dart';
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
                        l10n.settings,
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.language,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          SegmentedButton<String>(
                            segments: [
                              ButtonSegment(
                                value: 'en',
                                label: Text(l10n.english),
                              ),
                              ButtonSegment(
                                value: 'km',
                                label: Text(l10n.khmer),
                              ),
                            ],
                            selected: {settings.localeCode},
                            onSelectionChanged: (set) =>
                                notifier.setLocale(set.first),
                            style: ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.resolveWith((states) {
                                if (states.contains(WidgetState.selected)) {
                                  return AppColors.purple;
                                }
                                return Colors.transparent;
                              }),
                              foregroundColor:
                                  WidgetStateProperty.resolveWith((states) {
                                if (states.contains(WidgetState.selected)) {
                                  return Colors.white;
                                }
                                return AppColors.textPrimary;
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SliderRow(
                            label: l10n.musicVolume,
                            value: settings.musicVolume,
                            onChanged: notifier.setMusicVolume,
                          ),
                          const SizedBox(height: 16),
                          _SliderRow(
                            label: l10n.sfxVolume,
                            value: settings.sfxVolume,
                            onChanged: notifier.setSfxVolume,
                          ),
                          const SizedBox(height: 16),
                          _SliderRow(
                            label: l10n.joystickSensitivity,
                            value: settings.joystickSensitivity,
                            min: 0.5,
                            max: 1.5,
                            onChanged: notifier.setJoystickSensitivity,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.premium,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: () async {
                              await ref
                                  .read(monetizationServiceProvider)
                                  .restorePurchases();
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.purchaseRestored)),
                              );
                            },
                            child: Text(l10n.restorePurchases),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.resetProgress,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.resetProgressConfirm,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: () => _confirmReset(context, ref, l10n),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red.shade700,
                              side: BorderSide(color: Colors.red.shade300),
                            ),
                            child: Text(l10n.reset),
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
        title: Text(l10n.resetProgressTitle),
        content: Text(l10n.resetProgressConfirm),
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
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
        ],
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 1,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        Slider(
          value: value,
          min: min,
          max: max,
          activeColor: AppColors.purple,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
