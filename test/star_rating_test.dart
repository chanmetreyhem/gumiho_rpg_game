import 'package:flutter_test/flutter_test.dart';
import 'package:gumiho_rpg_game/features/game/domain/star_rating.dart';

void main() {
  group('StarRating', () {
    test('returns 3 stars above 70% HP', () {
      expect(StarRating.fromHp(80, 100), 3);
    });

    test('returns 2 stars between 40% and 70% HP', () {
      expect(StarRating.fromHp(50, 100), 2);
    });

    test('returns 1 star below 40% HP', () {
      expect(StarRating.fromHp(20, 100), 1);
    });
  });
}
