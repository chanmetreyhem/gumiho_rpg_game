import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/config/level_config.dart';

final gameSessionNotifierProvider =
    NotifierProvider<GameSessionNotifier, GameSessionState>(
  GameSessionNotifier.new,
);

class GameSessionState {
  const GameSessionState({
    this.selectedLevel = 1,
    this.isPaused = false,
    this.playerHp = 100,
    this.maxHp = 100,
    this.currentWave = 1,
    this.totalWaves = 3,
    this.bombsRemaining = 3,
    this.runCoins = 0,
    this.killCount = 0,
    this.elapsedSeconds = 0,
    this.isGameOver = false,
    this.isLevelComplete = false,
    this.starsEarned = 0,
    this.bonusCoins = 0,
  });

  final int selectedLevel;
  final bool isPaused;
  final double playerHp;
  final double maxHp;
  final int currentWave;
  final int totalWaves;
  final int bombsRemaining;
  final int runCoins;
  final int killCount;
  final double elapsedSeconds;
  final bool isGameOver;
  final bool isLevelComplete;
  final int starsEarned;
  final int bonusCoins;

  int get totalCoinsEarned => runCoins + bonusCoins;

  GameSessionState copyWith({
    int? selectedLevel,
    bool? isPaused,
    double? playerHp,
    double? maxHp,
    int? currentWave,
    int? totalWaves,
    int? bombsRemaining,
    int? runCoins,
    int? killCount,
    double? elapsedSeconds,
    bool? isGameOver,
    bool? isLevelComplete,
    int? starsEarned,
    int? bonusCoins,
  }) {
    return GameSessionState(
      selectedLevel: selectedLevel ?? this.selectedLevel,
      isPaused: isPaused ?? this.isPaused,
      playerHp: playerHp ?? this.playerHp,
      maxHp: maxHp ?? this.maxHp,
      currentWave: currentWave ?? this.currentWave,
      totalWaves: totalWaves ?? this.totalWaves,
      bombsRemaining: bombsRemaining ?? this.bombsRemaining,
      runCoins: runCoins ?? this.runCoins,
      killCount: killCount ?? this.killCount,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      isGameOver: isGameOver ?? this.isGameOver,
      isLevelComplete: isLevelComplete ?? this.isLevelComplete,
      starsEarned: starsEarned ?? this.starsEarned,
      bonusCoins: bonusCoins ?? this.bonusCoins,
    );
  }
}

class GameSessionNotifier extends Notifier<GameSessionState> {
  @override
  GameSessionState build() => const GameSessionState();

  void startLevel(int level, {required double maxHp}) {
    state = GameSessionState(
      selectedLevel: level,
      maxHp: maxHp,
      playerHp: maxHp,
      bombsRemaining: 3,
      totalWaves: LevelConfig.waveCountForLevel(level),
    );
  }

  void updateHud({
    double? playerHp,
    double? maxHp,
    int? currentWave,
    int? totalWaves,
    int? bombsRemaining,
    int? runCoins,
    int? killCount,
    double? elapsedSeconds,
  }) {
    state = state.copyWith(
      playerHp: playerHp,
      maxHp: maxHp,
      currentWave: currentWave,
      totalWaves: totalWaves,
      bombsRemaining: bombsRemaining,
      runCoins: runCoins,
      killCount: killCount,
      elapsedSeconds: elapsedSeconds,
    );
  }

  void setPaused(bool paused) {
    state = state.copyWith(isPaused: paused);
  }

  void endGame({
    required bool won,
    int stars = 0,
    int bonusCoins = 0,
    int? runCoins,
  }) {
    state = state.copyWith(
      isGameOver: !won,
      isLevelComplete: won,
      isPaused: true,
      starsEarned: stars,
      bonusCoins: bonusCoins,
      runCoins: runCoins,
    );
  }

  void revive() {
    state = state.copyWith(
      isGameOver: false,
      isPaused: false,
      playerHp: state.maxHp,
    );
  }

  void reset() {
    state = const GameSessionState();
  }
}
