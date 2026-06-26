class LevelConfig {
  LevelConfig._();

  static const totalLevels = 100;

  static int waveCountForLevel(int level) {
    if (level <= 15) return 3;
    if (level <= 40) return 4;
    if (level <= 70) return 5;
    return 6;
  }
}
