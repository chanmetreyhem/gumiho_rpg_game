import 'package:flutter/material.dart';

/// Dark, high-contrast palette for in-game HUD and menu screens.
class GameUiColors {
  GameUiColors._();

  static const backgroundTop = Color(0xFF0F1524);
  static const backgroundBottom = Color(0xFF1A2438);
  static const panel = Color(0xE6182030);
  static const panelBorder = Color(0xFF3A4560);
  static const actionYellow = Color(0xFFFFD54F);
  static const actionOrange = Color(0xFFFF8A3D);
  static const expCyan = Color(0xFF40C4FF);
  static const expTrack = Color(0xFF1A237E);
  static const waveRed = Color(0xFFFF5252);
  static const waveTrack = Color(0xFF2A2A3A);
  static const hpGreen = Color(0xFF69F0AE);
  static const hpTrack = Color(0xFF1B5E20);
  static const purpleBadge = Color(0xFF7C4DFF);
  static const textPrimary = Colors.white;
  static const textMuted = Color(0xFFB0BEC5);
  static const tileLocked = Color(0xFF252D3D);
  static const tileUnlocked = Color(0xFF2E3A52);
  static const tileActive = Color(0xFF3D4F72);

  static const screenGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundTop, backgroundBottom],
  );

  static const playGradient = LinearGradient(
    colors: [Color(0xFFFFB74D), actionOrange],
  );
}

class GameUiText {
  static TextStyle hudBold(double size, {Color color = GameUiColors.textPrimary}) {
    return TextStyle(
      color: color,
      fontWeight: FontWeight.w900,
      fontSize: size,
      letterSpacing: 0.3,
      shadows: const [
        Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 1)),
      ],
    );
  }

  static TextStyle label({Color color = GameUiColors.textMuted}) {
    return TextStyle(
      color: color,
      fontWeight: FontWeight.w700,
      fontSize: 12,
      letterSpacing: 0.8,
    );
  }
}
