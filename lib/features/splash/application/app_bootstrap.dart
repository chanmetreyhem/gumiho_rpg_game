import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../game/data/game_image_preloader.dart';
import '../../game/flame/audio/game_audio.dart';
import '../../monetization/application/monetization_service.dart';
import '../../profile/application/profile_notifier.dart';
import '../../settings/application/settings_notifier.dart';

enum BootstrapPhase {
  profile,
  settings,
  ads,
  store,
  finishing,
}

class AppBootstrapState {
  const AppBootstrapState({
    this.phase = BootstrapPhase.profile,
    this.progress = 0,
  });

  final BootstrapPhase phase;
  final double progress;

  AppBootstrapState copyWith({
    BootstrapPhase? phase,
    double? progress,
  }) {
    return AppBootstrapState(
      phase: phase ?? this.phase,
      progress: progress ?? this.progress,
    );
  }
}

final appBootstrapProvider =
    NotifierProvider<AppBootstrapNotifier, AppBootstrapState>(
  AppBootstrapNotifier.new,
);

class AppBootstrapNotifier extends Notifier<AppBootstrapState> {
  static const _minSplashDuration = Duration(milliseconds: 1800);

  @override
  AppBootstrapState build() => const AppBootstrapState();

  Future<void> run() async {
    final started = DateTime.now();

    _advance(BootstrapPhase.profile, 0.12);
    await ref.read(profileNotifierProvider.future);

    _advance(BootstrapPhase.settings, 0.32);
    await ref.read(settingsNotifierProvider.notifier).ensureLoaded();

    final monetization = ref.read(monetizationServiceProvider);

    if (!kIsWeb) {
      _advance(BootstrapPhase.ads, 0.52);
      await MobileAds.instance.initialize();

      _advance(BootstrapPhase.store, 0.72);
      await monetization.initIap();
      unawaited(monetization.preloadAds());
    } else {
      _advance(BootstrapPhase.store, 0.72);
      await monetization.initIap();
    }

    _advance(BootstrapPhase.finishing, 0.92);
    await Future.wait([
      GameImagePreloader.preloadCore(),
      GameAudio.warmUp(),
    ]);

    final elapsed = DateTime.now().difference(started);
    if (elapsed < _minSplashDuration) {
      await Future<void>.delayed(_minSplashDuration - elapsed);
    }

    state = state.copyWith(progress: 1);
  }

  void _advance(BootstrapPhase phase, double progress) {
    state = state.copyWith(phase: phase, progress: progress);
  }
}
