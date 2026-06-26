import 'package:flutter/material.dart';

import '../../data/config/game_assets.dart';
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
