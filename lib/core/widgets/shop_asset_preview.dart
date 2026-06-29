import 'package:flutter/material.dart';

import '../../data/config/game_assets.dart';
import '../../features/game/domain/enemy_type.dart';
import '../theme/app_theme.dart';

class CharacterPreview extends StatelessWidget {
  const CharacterPreview({
    super.key,
    required this.characterFolder,
    this.size = 48,
  });

  final String characterFolder;
  final double size;

  @override
  Widget build(BuildContext context) {
    final bodyPath =
        'assets/images/${GameAssets.characterPart(characterFolder, 'Body')}';
    final headPath =
        'assets/images/${GameAssets.characterPart(characterFolder, 'Head')}';

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            bodyPath,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.person_rounded,
              color: AppColors.purple,
            ),
          ),
          Positioned(
            top: size * 0.02,
            child: Image.asset(
              headPath,
              height: size * 0.48,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

class EnemyPreview extends StatelessWidget {
  const EnemyPreview({
    super.key,
    required this.enemyType,
    this.size = 64,
    this.flip = false,
    this.opacity = 1.0,
  });

  final EnemyType enemyType;
  final double size;
  final bool flip;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final bodyPath = 'assets/images/${GameAssets.enemyPartPath(enemyType, 'body')}';
    final headPath = 'assets/images/${GameAssets.enemyPartPath(enemyType, 'head')}';

    return SizedBox(
      width: size,
      height: size,
      child: Opacity(
        opacity: opacity,
        child: Transform.flip(
          flipX: flip,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                bodyPath,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.pest_control_rounded,
                  color: AppColors.purple.withValues(alpha: 0.6),
                  size: size * 0.5,
                ),
              ),
              Positioned(
                top: size * 0.02,
                child: Image.asset(
                  headPath,
                  height: size * 0.48,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GunPreview extends StatelessWidget {
  const GunPreview({
    super.key,
    required this.weaponId,
    this.size = 48,
  });

  final String weaponId;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        'assets/images/${GameAssets.gunPath(weaponId)}',
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.sports_martial_arts,
          color: AppColors.purple,
        ),
      ),
    );
  }
}

class ArenaPreview extends StatelessWidget {
  const ArenaPreview({
    super.key,
    required this.imageFileName,
    this.width = 120,
    this.height = 72,
  });

  final String imageFileName;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        'assets/images/arenas/$imageFileName',
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: width,
          height: height,
          color: AppColors.purple.withValues(alpha: 0.1),
          child: const Icon(Icons.landscape_rounded, color: AppColors.purple),
        ),
      ),
    );
  }
}
