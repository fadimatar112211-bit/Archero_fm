import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/enemy_damage_resolver.dart';

void main() {
  test('damage lowers enemy health and starts hit feedback', () {
    final enemy = <String, dynamic>{'hp': 100.0};

    final defeated = EnemyDamageResolver.applyDamage(
      enemy: enemy,
      damage: 35,
    );

    expect(defeated, isFalse);
    expect(enemy['hp'], 65.0);
    expect(enemy['hitTicks'], 9);
  });

  test('damage reports defeat when health reaches zero or below', () {
    final enemy = <String, dynamic>{'hp': 30.0};

    final defeated = EnemyDamageResolver.applyDamage(
      enemy: enemy,
      damage: 35,
    );

    expect(defeated, isTrue);
    expect(enemy['hp'], -5.0);
  });

  test('enemy types map to distinct hit effects', () {
    expect(EnemyDamageResolver.effectFor('tank'), 'metalHit');
    expect(EnemyDamageResolver.effectFor('stalker'), 'shadowHit');
    expect(EnemyDamageResolver.effectFor('runner'), 'sparkHit');
    expect(EnemyDamageResolver.effectFor('boss'), 'bossHit');
    expect(EnemyDamageResolver.effectFor('unknown'), 'impact');
  });
}
