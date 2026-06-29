import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gumiho_rpg_game/l10n/app_localizations.dart';

import '../theme/game_ui_theme.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
  });

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: GameUiColors.panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: GameUiColors.panelBorder, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: Icons.home_rounded,
            label: l10n.navHome,
            selected: currentIndex == 0,
            onTap: () => context.go('/'),
          ),
          _NavItem(
            icon: Icons.sports_esports_rounded,
            label: l10n.navPlay,
            selected: currentIndex == 1,
            onTap: () => context.push('/levels'),
          ),
          _NavItem(
            icon: Icons.storefront_rounded,
            label: l10n.shop,
            selected: currentIndex == 2,
            onTap: () => context.push('/shop'),
          ),
          _NavItem(
            icon: Icons.settings_rounded,
            label: l10n.settings,
            selected: currentIndex == 3,
            onTap: () => context.push('/settings'),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? GameUiColors.expCyan : GameUiColors.textMuted;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
