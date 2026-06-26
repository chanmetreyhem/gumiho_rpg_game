import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gumiho_rpg_game/l10n/app_localizations.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_animations.dart';
import '../../application/game_session_notifier.dart';
import '../gumiho_game.dart';

class GameHudOverlay extends ConsumerStatefulWidget {
  const GameHudOverlay({super.key, required this.game});

  final GumihoGame game;

  @override
  ConsumerState<GameHudOverlay> createState() => _GameHudOverlayState();
}

class _GameHudOverlayState extends ConsumerState<GameHudOverlay> {
  bool _draggingBomb = false;
  Offset? _dragLocalPosition;

  Vector2? _localToWorld(Offset local) =>
      widget.game.canvasToWorld(Vector2(local.dx, local.dy));

  Offset _toLocal(Offset global) {
    final box = context.findRenderObject() as RenderBox;
    return box.globalToLocal(global);
  }

  void _startBombDrag(Offset globalPosition) {
    if (ref.read(gameSessionNotifierProvider).bombsRemaining <= 0) return;
    if (widget.game.paused) return;
    final local = _toLocal(globalPosition);
    setState(() {
      _draggingBomb = true;
      _dragLocalPosition = local;
    });
    widget.game.setBombAimPreview(_localToWorld(local));
  }

  void _updateBombDrag(Offset localPosition) {
    if (!_draggingBomb) return;
    setState(() => _dragLocalPosition = localPosition);
    widget.game.setBombAimPreview(_localToWorld(localPosition));
  }

  void _endBombDrag() {
    if (!_draggingBomb) return;

    final world =
        _dragLocalPosition == null ? null : _localToWorld(_dragLocalPosition!);

    widget.game.setBombAimPreview(null);
    if (world != null) {
      widget.game.throwBombAt(world);
    }

    setState(() {
      _draggingBomb = false;
      _dragLocalPosition = null;
    });
  }

  void _cancelBombDrag() {
    if (!_draggingBomb) return;
    widget.game.setBombAimPreview(null);
    setState(() {
      _draggingBomb = false;
      _dragLocalPosition = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final playerHp = ref.watch(
      gameSessionNotifierProvider.select((s) => s.playerHp),
    );
    final maxHp = ref.watch(
      gameSessionNotifierProvider.select((s) => s.maxHp),
    );
    final currentWave = ref.watch(
      gameSessionNotifierProvider.select((s) => s.currentWave),
    );
    final totalWaves = ref.watch(
      gameSessionNotifierProvider.select((s) => s.totalWaves),
    );
    final runCoins = ref.watch(
      gameSessionNotifierProvider.select((s) => s.runCoins),
    );
    final bombsRemaining = ref.watch(
      gameSessionNotifierProvider.select((s) => s.bombsRemaining),
    );

    return Stack(
      children: [
        if (_draggingBomb)
          Positioned.fill(
            child: Listener(
              behavior: HitTestBehavior.translucent,
              onPointerMove: (event) => _updateBombDrag(event.position),
              onPointerUp: (_) => _endBombDrag(),
              onPointerCancel: (_) => _cancelBombDrag(),
              child: Container(color: Colors.transparent),
            ),
          ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                FadeSlideIn(
                  offset: const Offset(0, -12),
                  child: Row(
                    children: [
                      _GlassChip(
                        child: _HpBar(hp: playerHp, maxHp: maxHp),
                      ),
                      const Spacer(),
                      _GlassIconButton(
                        icon: Icons.pause_rounded,
                        onPressed: widget.game.requestPause,
                        tooltip: l10n.pause,
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 120),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _GlassChip(
                        child: _InfoRow(
                          icon: Icons.waves_rounded,
                          label: l10n.wave(currentWave, totalWaves),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _GlassChip(
                        child: _InfoRow(
                          icon: Icons.monetization_on_rounded,
                          animatedValue: runCoins,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _DraggableBombChip(
                        label: l10n.bomb,
                        count: bombsRemaining,
                        enabled: bombsRemaining > 0 && !widget.game.paused,
                        onDragStart: _startBombDrag,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_draggingBomb && _dragLocalPosition != null)
          _BombDragGhost(position: _dragLocalPosition!),
      ],
    );
  }
}

class _BombDragGhost extends StatelessWidget {
  const _BombDragGhost({required this.position});

  final Offset position;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx - 22,
      top: position.dy - 22,
      child: IgnorePointer(
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppColors.orange, AppColors.orangeDark],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.orange.withValues(alpha: 0.45),
                blurRadius: 14,
              ),
            ],
          ),
          child: const Icon(
            Icons.whatshot_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}

class _DraggableBombChip extends StatelessWidget {
  const _DraggableBombChip({
    required this.label,
    required this.count,
    required this.enabled,
    required this.onDragStart,
  });

  final String label;
  final int count;
  final bool enabled;
  final void Function(Offset globalPosition) onDragStart;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: enabled
          ? (details) => onDragStart(details.globalPosition)
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: enabled
                ? [AppColors.orange, AppColors.orangeDark]
                : [Colors.grey.shade400, Colors.grey.shade500],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            if (enabled)
              BoxShadow(
                color: AppColors.orange.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.whatshot_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(
              '$label ($count)',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassChip extends StatelessWidget {
  const _GlassChip({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withValues(alpha: 0.12),
            blurRadius: 12,
          ),
        ],
      ),
      child: child,
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return _GlassChip(
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: AppColors.purple),
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      ),
    );
  }
}

class _HpBar extends StatelessWidget {
  const _HpBar({required this.hp, required this.maxHp});

  final double hp;
  final double maxHp;

  @override
  Widget build(BuildContext context) {
    final ratio = maxHp > 0 ? (hp / maxHp).clamp(0.0, 1.0) : 0.0;
    return AnimatedProgressBar(
      value: ratio,
      backgroundColor: AppColors.purpleLight.withValues(alpha: 0.3),
      foregroundColor: AppColors.purple,
      lowForegroundColor: AppColors.orange,
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    this.label,
    this.animatedValue,
  });

  final IconData icon;
  final String? label;
  final int? animatedValue;

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w700,
      fontSize: 13,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.purple, size: 16),
        const SizedBox(width: 6),
        if (animatedValue != null)
          AnimatedCountText(value: animatedValue!, style: textStyle)
        else
          Text(label ?? '', style: textStyle),
      ],
    );
  }
}
