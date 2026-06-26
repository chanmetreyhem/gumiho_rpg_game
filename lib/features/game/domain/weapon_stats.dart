import 'weapon_special.dart';

class WeaponStats {
  const WeaponStats({
    required this.id,
    required this.name,
    required this.damage,
    required this.fireRate,
    required this.bulletSpeed,
    required this.spreadAngle,
    this.price = 0,
    this.special = WeaponSpecial.none,
    this.bulletColor = 0xFFFFF59D,
    this.bulletGlowColor = 0xFFFFEB3B,
    this.description = '',
  });

  final String id;
  final String name;
  final double damage;
  final double fireRate;
  final double bulletSpeed;
  final double spreadAngle;
  final int price;
  final WeaponSpecial special;
  final int bulletColor;
  final int bulletGlowColor;
  final String description;
}
