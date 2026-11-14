import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/enemy_attack_factory.dart';

void main() {
  test('ranged projectile travels toward its target at configured speed', () {
    final projectile = EnemyAttackFactory.rangedProjectile(
      enemyX: 10,
      enemyY: 20,
      targetX: 10,
      targetY: 100,
    );

    expect(projectile['x'], 10.0);
    expect(projectile['y'], 20.0);
    expect(projectile['vx'], closeTo(0, 0.0001));
    expect(projectile['vy'], closeTo(3.8, 0.0001));
    expect(projectile['damage'], 6.0);
    expect(projectile['life'], 110);
  });

  test('custom speed and damage are preserved', () {
    final projectile = EnemyAttackFactory.rangedProjectile(
      enemyX: 0,
      enemyY: 0,
      targetX: 1,
      targetY: 0,
      speed: 5,
      damage: 12,
      lifetime: 60,
    );

    expect(projectile['vx'], 5.0);
    expect(projectile['vy'], closeTo(0, 0.0001));
    expect(projectile['damage'], 12.0);
    expect(projectile['life'], 60);
  });
}
