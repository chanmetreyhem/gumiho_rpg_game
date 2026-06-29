import 'package:flutter/material.dart';

import '../theme/game_ui_theme.dart';

class GameScreenBackground extends StatelessWidget {
  const GameScreenBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: GameUiColors.screenGradient),
      child: child,
    );
  }
}

class GameHudPanel extends StatelessWidget {
  const GameHudPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    this.radius = 10,
  });

  final Widget child;
  final EdgeInsets padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: GameUiColors.panel,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: GameUiColors.panelBorder, width: 1.5),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class GameRoundButton extends StatelessWidget {
  const GameRoundButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 40,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: GameUiColors.panel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: GameUiColors.panelBorder, width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(icon, color: Colors.white, size: size * 0.52),
          ),
        ),
      ),
    );
  }
}

class GameThickBar extends StatelessWidget {
  const GameThickBar({
    super.key,
    required this.value,
    required this.trackColor,
    required this.fillColor,
    this.height = 14,
    this.radius = 7,
  });

  final double value;
  final Color trackColor;
  final Color fillColor;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final ratio = value.clamp(0.0, 1.0);

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: trackColor,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: Colors.black26, width: 1),
            ),
            child: const SizedBox.expand(),
          ),
          FractionallySizedBox(
            widthFactor: ratio,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: fillColor,
                borderRadius: BorderRadius.circular(radius),
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ],
      ),
    );
  }
}

class GameStatChip extends StatelessWidget {
  const GameStatChip({
    super.key,
    required this.icon,
    required this.value,
    this.iconColor = GameUiColors.actionYellow,
  });

  final IconData icon;
  final String value;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: 16),
        const SizedBox(width: 4),
        Text(value, style: GameUiText.hudBold(13)),
      ],
    );
  }
}

class GamePlayButton extends StatelessWidget {
  const GamePlayButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.play_arrow_rounded,
    this.compact = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Material(
        borderRadius: BorderRadius.circular(compact ? 14 : 18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Ink(
          decoration: BoxDecoration(
            gradient: GameUiColors.playGradient,
            borderRadius: BorderRadius.circular(compact ? 14 : 18),
            boxShadow: [
              BoxShadow(
                color: GameUiColors.actionOrange.withValues(alpha: 0.45),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 16 : 24,
              vertical: compact ? 12 : 16,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: GameUiText.hudBold(compact ? 14 : 16,
                      color: const Color(0xFF2D1600)),
                ),
                const SizedBox(width: 8),
                Icon(icon, color: const Color(0xFF2D1600), size: compact ? 22 : 26),
              ],
            ),
          ),
        ),
      ),
    ),
    );
  }
}

class GameSectionCard extends StatelessWidget {
  const GameSectionCard({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return GameHudPanel(
      padding: const EdgeInsets.all(16),
      radius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title, style: GameUiText.hudBold(15)),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class GameSliderRow extends StatelessWidget {
  const GameSliderRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 1,
    this.displayValue,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final String? displayValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: GameUiText.hudBold(14))),
            Text(
              displayValue ?? '${(value * 100).round()}%',
              style: GameUiText.label(color: GameUiColors.expCyan),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: GameUiColors.expCyan,
            inactiveTrackColor: GameUiColors.expTrack,
            thumbColor: GameUiColors.actionYellow,
            overlayColor: GameUiColors.expCyan.withValues(alpha: 0.15),
            trackHeight: 8,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class GamePageDots extends StatelessWidget {
  const GamePageDots({
    super.key,
    required this.pageCount,
    required this.currentPage,
    required this.onPageSelected,
  });

  final int pageCount;
  final int currentPage;
  final ValueChanged<int> onPageSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pageCount, (index) {
        final active = index == currentPage;
        return GestureDetector(
          onTap: () => onPageSelected(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: active ? 22 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: active ? GameUiColors.expCyan : GameUiColors.panelBorder,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }
}

class GameSegmentToggle<T> extends StatelessWidget {
  const GameSegmentToggle({
    super.key,
    required this.options,
    required this.selected,
    required this.labelBuilder,
    required this.onChanged,
  });

  final List<T> options;
  final T selected;
  final String Function(T) labelBuilder;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: options.map((option) {
        final isSelected = option == selected;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Material(
              color: isSelected ? GameUiColors.expCyan : GameUiColors.tileUnlocked,
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => onChanged(option),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    labelBuilder(option),
                    textAlign: TextAlign.center,
                    style: GameUiText.hudBold(
                      13,
                      color: isSelected ? GameUiColors.backgroundTop : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
