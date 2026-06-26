import 'package:go_router/go_router.dart';

import '../../features/game/presentation/game_screen.dart';
import '../../features/levels/presentation/level_select_screen.dart';
import '../../features/profile/presentation/main_menu_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/shop/presentation/shop_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MainMenuScreen(),
    ),
    GoRoute(
      path: '/levels',
      builder: (context, state) => const LevelSelectScreen(),
    ),
    GoRoute(
      path: '/shop',
      builder: (context, state) => const ShopScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/game/:levelId',
      builder: (context, state) {
        final levelId = int.parse(state.pathParameters['levelId']!);
        return GameScreen(levelId: levelId);
      },
    ),
  ],
);
