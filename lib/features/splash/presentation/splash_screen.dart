import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gumiho_rpg_game/l10n/app_localizations.dart';

import '../../../core/widgets/shop_asset_preview.dart';
import '../../game/domain/enemy_type.dart';
import '../application/app_bootstrap.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  static const appVersion = '1.0.0';

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progressController;
  var _navigated = false;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    Future.microtask(_runBootstrap);
  }

  Future<void> _runBootstrap() async {
    try {
      await ref.read(appBootstrapProvider.notifier).run();
    } on Object {
      // Continue to menu even if a startup step fails.
    }
    if (!mounted || _navigated) return;
    _navigated = true;
    context.go('/');
  }

  void _syncProgress(double target) {
    _progressController.animateTo(
      target.clamp(0.0, 1.0),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  String _loadingLabel(AppLocalizations l10n, BootstrapPhase phase) {
    return switch (phase) {
      BootstrapPhase.profile => l10n.splashLoadingProfile,
      BootstrapPhase.settings => l10n.splashLoadingSettings,
      BootstrapPhase.ads => l10n.splashLoadingAds,
      BootstrapPhase.store => l10n.splashLoadingStore,
      BootstrapPhase.finishing => l10n.splashFinishing,
    };
  }

  @override
  Widget build(BuildContext context) {
    final bootstrap = ref.watch(appBootstrapProvider);
    final l10n = AppLocalizations.of(context)!;

    ref.listen<AppBootstrapState>(appBootstrapProvider, (_, next) {
      _syncProgress(next.progress);
    });

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1F4F63),
                  Color(0xFF163544),
                  Color(0xFF0E2230),
                ],
              ),
            ),
          ),
          CustomPaint(
            painter: _SplashRaysPainter(),
            size: Size.infinite,
          ),
          const Positioned(
            top: 72,
            left: 0,
            right: 0,
            child: _WoodenTitleSign(),
          ),
          const Positioned.fill(
            child: _SplashEnemyLayer(),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 118,
            child: _HeroCluster(),
          ),
          Positioned(
            left: 28,
            right: 28,
            bottom: 42,
            child: AnimatedBuilder(
              animation: _progressController,
              builder: (context, _) => _LoadingBar(
                progress: _progressController.value,
                label: _loadingLabel(l10n, bootstrap.phase),
              ),
            ),
          ),
          const Positioned(
            right: 16,
            bottom: 14,
            child: Text(
              'Version ${SplashScreen.appVersion}',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                shadows: [
                  Shadow(color: Colors.black54, offset: Offset(1, 1), blurRadius: 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WoodenTitleSign extends StatelessWidget {
  const _WoodenTitleSign();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 18, bottom: 10),
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 16),
            decoration: BoxDecoration(
              color: const Color(0xFF6B3F22),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF3D2414), width: 4),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF8B552F), Color(0xFF5A341C)],
              ),
            ),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.topCenter,
                  clipBehavior: Clip.none,
                  children: [
                    Text(
                      'CAVEMAN',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.bangers(
                        fontSize: 46,
                        height: 0.95,
                        letterSpacing: 1.5,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 5
                          ..color = const Color(0xFF2A1408),
                      ),
                    ),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFFFFE566), Color(0xFFFFA726)],
                      ).createShader(bounds),
                      child: Text(
                        'CAVEMAN',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.bangers(
                          fontSize: 46,
                          height: 0.95,
                          letterSpacing: 1.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Positioned(
                      top: -8,
                      child: Icon(
                        Icons.emoji_events_rounded,
                        color: Color(0xFFFFD54F),
                        size: 22,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'SURVIVOR',
                  style: GoogleFonts.bangers(
                    fontSize: 28,
                    letterSpacing: 3,
                    color: const Color(0xFFB0BEC5),
                    shadows: const [
                      Shadow(
                        color: Color(0xFF1A1A1A),
                        offset: Offset(2, 2),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Positioned(
            top: 6,
            left: 24,
            child: Icon(Icons.eco_rounded, color: Color(0xFF4CAF50), size: 28),
          ),
          const Positioned(
            top: 8,
            right: 28,
            child: Icon(Icons.eco_rounded, color: Color(0xFF66BB6A), size: 24),
          ),
          const Positioned(
            bottom: 0,
            left: 40,
            child: Icon(Icons.eco_rounded, color: Color(0xFF388E3C), size: 22),
          ),
          const Positioned(
            bottom: 2,
            right: 36,
            child: Icon(Icons.eco_rounded, color: Color(0xFF43A047), size: 26),
          ),
        ],
      ),
    );
  }
}

class _SplashEnemyLayer extends StatelessWidget {
  const _SplashEnemyLayer();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Boss silhouette behind the title + heroes.
          Positioned(
            top: 148,
            left: 0,
            right: 0,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 240,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(120),
                    ),
                  ),
                  const EnemyPreview(
                    enemyType: EnemyType.stoneClubBrute,
                    size: 210,
                  ),
                ],
              ),
            ),
          ),
          // Flanking threats.
          const Positioned(
            left: 8,
            top: 300,
            child: EnemyPreview(
              enemyType: EnemyType.scalebladeRavager,
              size: 96,
              flip: true,
            ),
          ),
          const Positioned(
            right: 8,
            top: 292,
            child: EnemyPreview(
              enemyType: EnemyType.venomjawBlaster,
              size: 100,
            ),
          ),
          const Positioned(
            left: 54,
            top: 248,
            child: EnemyPreview(
              enemyType: EnemyType.blazingBoneRaider,
              size: 72,
              flip: true,
              opacity: 0.9,
            ),
          ),
          const Positioned(
            right: 50,
            top: 244,
            child: EnemyPreview(
              enemyType: EnemyType.monster,
              size: 70,
              opacity: 0.9,
            ),
          ),
          // Enemy horde along the bottom (replaces abstract blobs).
          Positioned(
            left: 0,
            right: 0,
            bottom: 88,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                EnemyPreview(enemyType: EnemyType.zombie, size: 52, flip: true),
                SizedBox(width: 4),
                EnemyPreview(enemyType: EnemyType.scalebladeRavager, size: 48),
                SizedBox(width: 4),
                EnemyPreview(enemyType: EnemyType.monster, size: 56, flip: true),
                SizedBox(width: 4),
                EnemyPreview(enemyType: EnemyType.venomjawBlaster, size: 50),
                SizedBox(width: 4),
                EnemyPreview(enemyType: EnemyType.tank, size: 58, flip: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCluster extends StatelessWidget {
  const _HeroCluster();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: const [
          Positioned(
            bottom: 0,
            child: CharacterPreview(
              characterFolder: 'Cave_Man_Character_2',
              size: 118,
            ),
          ),
          Positioned(
            left: 42,
            bottom: 8,
            child: CharacterPreview(
              characterFolder: 'Warrior_Character_8',
              size: 92,
            ),
          ),
          Positioned(
            right: 42,
            bottom: 8,
            child: CharacterPreview(
              characterFolder: 'Soldier_Character_7',
              size: 92,
            ),
          ),
          Positioned(
            bottom: 34,
            child: CharacterPreview(
              characterFolder: 'Wizard_Character_9',
              size: 78,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingBar extends StatelessWidget {
  const _LoadingBar({
    required this.progress,
    required this.label,
  });

  final double progress;
  final String label;

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);
    return Column(
      children: [
        Container(
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFF102A38),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.black, width: 3),
            boxShadow: const [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              FractionallySizedBox(
                widthFactor: clamped,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF42A5F5), Color(0xFF1E88E5)],
                    ),
                  ),
                ),
              ),
              Center(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.bangers(
                    fontSize: 18,
                    color: Colors.white,
                    shadows: const [
                      Shadow(
                        color: Colors.black,
                        offset: Offset(1.5, 1.5),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SplashRaysPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.34);
    final paint = Paint()
      ..shader = ui.Gradient.radial(
        center,
        size.width * 0.75,
        [
          const Color(0xFF4FC3F7).withValues(alpha: 0.14),
          Colors.transparent,
        ],
      );
    canvas.drawRect(Offset.zero & size, paint);

    final rayPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 28;

    for (var i = 0; i < 8; i++) {
      final angle = -math.pi / 2 + (i - 3.5) * 0.22;
      final end = center + Offset(math.cos(angle), math.sin(angle)) * size.height;
      canvas.drawLine(center, end, rayPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
