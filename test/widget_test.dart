import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gumiho_rpg_game/app.dart';
import 'package:gumiho_rpg_game/features/profile/application/profile_notifier.dart';
import 'package:gumiho_rpg_game/features/profile/domain/player_profile.dart';

class _TestProfileNotifier extends ProfileNotifier {
  @override
  Future<PlayerProfile> build() async => const PlayerProfile();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('App loads main menu', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileNotifierProvider.overrideWith(_TestProfileNotifier.new),
        ],
        child: const GumihoApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('LET\'S PLAY'), findsOneWidget);
    expect(find.text('WELCOME BACK'), findsOneWidget);
  });
}
