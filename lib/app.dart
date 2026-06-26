import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/monetization/application/monetization_service.dart';
import 'features/settings/application/settings_notifier.dart';
import 'package:gumiho_rpg_game/l10n/app_localizations.dart';

class GumihoApp extends ConsumerStatefulWidget {
  const GumihoApp({super.key});

  @override
  ConsumerState<GumihoApp> createState() => _GumihoAppState();
}

class _GumihoAppState extends ConsumerState<GumihoApp> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_initMonetization);
  }

  Future<void> _initMonetization() async {
    if (!kIsWeb) {
      await MobileAds.instance.initialize();
    }
    await ref.read(monetizationServiceProvider).init();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsNotifierProvider);
    final locale = Locale(settings.localeCode);

    return MaterialApp.router(
      title: 'Gumiho RPG',
      theme: AppTheme.forLocale(settings.localeCode),
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: appRouter,
    );
  }
}
