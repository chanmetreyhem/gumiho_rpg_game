/// Caps concurrent VFX so rapid fire cannot spawn unlimited particles.
class EffectManager {
  int _active = 0;

  static const int maxActive = 32;

  int get active => _active;

  bool tryAcquire() {
    if (_active >= maxActive) return false;
    _active++;
    return true;
  }

  void release() {
    if (_active > 0) _active--;
  }

  void reset() => _active = 0;
}
