class LevelConfig {
  LevelConfig._();

  static const totalLevels = 200;

  static int waveCountForLevel(int level) {
    if (level <= 20) return 3;
    if (level <= 60) return 4;
    if (level <= 120) return 5;
    if (level <= 180) return 6;
    return 7;
  }
}
