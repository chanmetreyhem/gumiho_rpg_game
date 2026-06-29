import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../../data/config/level_curve.dart';
import '../../domain/enemy_type.dart';
import '../gumiho_game.dart';
import 'enemy_visual.dart';
import 'player_component.dart';

class EnemyComponent extends PositionComponent
    with CollisionCallbacks, HasGameReference<GumihoGame> {
  EnemyComponent({
    required this.type,
    required this.level,
    required Vector2 spawnPosition,
  }) : super(
          position: spawnPosition,
          anchor: Anchor.center,
        ) {
    final stats = LevelCurve.scaledStats(type, level);
    hp = stats.hp;
    maxHp = stats.hp;
    speed = stats.speed;
    contactDamage = stats.contactDamage;
    coinReward = stats.coinReward;
    attackStopDistance = stats.attackStopDistance;
    size = Vector2.all(stats.size);
    _hurtboxRadius = LevelCurve.hurtboxRadius(stats.size);
  }

  final EnemyType type;
  final int level;

  late double hp;
  late double maxHp;
  late double speed;
  late double contactDamage;
  late int coinReward;
  late double attackStopDistance;

  late final double _hurtboxRadius;
  late final EnemyVisual _visual;

  /// Radius used for bullet collision (matches [CircleHitbox]).
  double get hitRadius => _hurtboxRadius;

  static final Paint _hpBgPaint = Paint()..color = Colors.black54;
  static final Paint _hpFillPaint = Paint()..color = Colors.red;

  double _contactCooldown = 0;
  bool _isMoving = false;
  bool _isAttacking = false;
  double _disorientTimer = 0;
  double _shockTimer = 0;

  double get _speedMultiplier {
    if (_shockTimer > 0) return 0;
    if (_disorientTimer > 0) return 0.45;
    return 1;
  }

  void applyDisorient(double seconds) {
    _disorientTimer = _disorientTimer > seconds ? _disorientTimer : seconds;
  }

  void applyShock(double seconds) {
    _shockTimer = _shockTimer > seconds ? _shockTimer : seconds;
  }

  @override
  Future<void> onLoad() async {
    _visual = EnemyVisual(
      enemyType: type,
      targetHeight: size.y,
    );
    await add(_visual);
    add(
      CircleHitbox(
        radius: _hurtboxRadius,
        anchor: Anchor.center,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_contactCooldown > 0) _contactCooldown -= dt;
    if (_disorientTimer > 0) _disorientTimer -= dt;
    if (_shockTimer > 0) _shockTimer -= dt;

    final player = game.player;
    final toPlayer = player.position - position;
    final distance = toPlayer.length;

    if (distance > 1) {
      _isMoving = distance > attackStopDistance;
      _isAttacking = !_isMoving;

      if (_isMoving) {
        position += toPlayer.normalized() * speed * _speedMultiplier * dt;
      } else if (_contactCooldown <= 0) {
        damagePlayer(player);
      }

      _visual.faceToward(toPlayer);
    } else {
      _isMoving = false;
      _isAttacking = false;
    }

    _visual.updateAnimation(
      isMoving: _isMoving,
      isAttacking: _isAttacking,
      dt: dt,
    );
  }

  void takeDamage(double amount) {
    if (hp <= 0) return;
    hp -= amount;
    if (hp <= 0) {
      game.spawnDeathEffect(position.clone());
      game.onEnemyKilled(this);
      removeFromParent();
    }
  }

  void damagePlayer(PlayerComponent player) {
    if (_contactCooldown > 0) return;
    _contactCooldown = 0.65;
    player.takeDamage(contactDamage);
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is PlayerComponent) {
      damagePlayer(other);
    }
  }

  @override
  void render(Canvas canvas) {
    final hpRatio = (hp / maxHp).clamp(0.0, 1.0);
    final barWidth = size.x;
    const barHeight = 4.0;
    canvas.drawRect(
      Rect.fromLTWH(0, -8, barWidth, barHeight),
      _hpBgPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, -8, barWidth * hpRatio, barHeight),
      _hpFillPaint,
    );
  }
}
