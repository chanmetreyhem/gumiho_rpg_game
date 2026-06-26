import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../../domain/skin_stats.dart';
import '../../domain/weapon_stats.dart';
import '../gumiho_game.dart';
import 'character_visual.dart';
import 'gun_component.dart';

class PlayerComponent extends PositionComponent
    with CollisionCallbacks, HasGameReference<GumihoGame> {
  PlayerComponent({
    required this.skin,
    required this.weapon,
    required Vector2 startPosition,
  }) : super(
          position: startPosition,
          size: Vector2(52, 52),
          anchor: Anchor.center,
        ) {
    maxHp = 100 * (1 + skin.hpBonus);
    hp = maxHp;
    moveSpeed = 200 * (1 + skin.speedBonus);
  }

  final SkinStats skin;
  final WeaponStats weapon;
  late final GunComponent gun;
  late final CharacterVisual _visual;
  late double maxHp;
  late double hp;
  late double moveSpeed;

  Vector2? _moveDirection;
  Vector2? _aimDirection;
  double _speedScale = 1;

  @override
  Future<void> onLoad() async {
    _visual = CharacterVisual(characterFolder: skin.characterFolder);
    await add(_visual);
    gun = GunComponent(weapon: weapon);
    gun.position = Vector2.zero();
    await add(gun);
    add(CircleHitbox(radius: 22));
  }

  void setMoveDirection(Vector2? direction, {double speedScale = 1}) {
    _moveDirection = direction;
    _speedScale = speedScale;
  }

  void setAimDirection(Vector2 direction) {
    _aimDirection = direction;
    gun.setAimDirection(direction);
    _updateBodyFacing();
  }

  void stopAiming() {
    _aimDirection = null;
    gun.stopFiring();
    _updateBodyFacing();
  }

  void _updateBodyFacing() {
    final move = _moveDirection;
    final aim = _aimDirection;

    if (move != null && move.length >= 0.14) {
      _visual.angle = atan2(move.y, move.x);
      return;
    }

    if (aim != null && aim.length >= 0.1) {
      _visual.angle = atan2(aim.y, aim.x);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    final isMoving =
        _moveDirection != null && _moveDirection!.length >= 0.14;
    if (isMoving) {
      position += _moveDirection! *
          moveSpeed *
          _speedScale *
          game.runBuffs.speedMultiplier *
          dt;
      _visual.angle = atan2(_moveDirection!.y, _moveDirection!.x);
    }

    _visual.updateMovement(isMoving, dt);
    _clampToArena();
  }

  void _clampToArena() {
    final half = size.x / 2;
    position.x = position.x.clamp(half, GumihoGame.arenaSize.x - half);
    position.y = position.y.clamp(half, GumihoGame.arenaSize.y - half);
  }

  void takeDamage(double amount) {
    final reduced = amount * (1 - game.runBuffs.damageReduction).clamp(0.0, 1.0);
    hp = (hp - reduced).clamp(0, maxHp);
    game.spawnHurtEffect(position);
    game.onPlayerHpChanged(hp, maxHp);
    if (hp <= 0) game.onPlayerDied();
  }
}
