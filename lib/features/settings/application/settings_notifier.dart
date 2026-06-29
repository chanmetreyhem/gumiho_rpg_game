import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/settings_repository.dart';
import '../domain/game_settings.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

final settingsNotifierProvider =
    NotifierProvider<SettingsNotifier, GameSettings>(SettingsNotifier.new);

class SettingsNotifier extends Notifier<GameSettings> {
  @override
  GameSettings build() {
    _load();
    return const GameSettings();
  }

  Future<void> _load() async {
    state = await ref.read(settingsRepositoryProvider).load();
  }

  Future<void> ensureLoaded() async {
    state = await ref.read(settingsRepositoryProvider).load();
  }

  Future<void> setLocale(String code) async {
    state = state.copyWith(localeCode: code);
    await ref.read(settingsRepositoryProvider).save(state);
  }

  Future<void> setMusicVolume(double value) async {
    state = state.copyWith(musicVolume: value);
    await ref.read(settingsRepositoryProvider).save(state);
  }

  Future<void> setSfxVolume(double value) async {
    state = state.copyWith(sfxVolume: value);
    await ref.read(settingsRepositoryProvider).save(state);
  }

  Future<void> setJoystickSensitivity(double value) async {
    state = state.copyWith(joystickSensitivity: value);
    await ref.read(settingsRepositoryProvider).save(state);
  }
}
