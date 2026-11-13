import 'dart:ui' show Size;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/main.dart';

void main() {
  testWidgets('main menu renders and offers hero selection', (tester) async {
    await tester.pumpWidget(const ArcheroSoundApp());
    expect(find.text('ARCHERO: SOUND EDITION'), findsOneWidget);
    expect(find.text('اختيار البطل واللعب'), findsOneWidget);
  });

  testWidgets('main menu adapts to phone and tablet viewports', (tester) async {
    const sizes = <Size>[
      Size(360, 640),
      Size(390, 844),
      Size(800, 1280),
    ];
    for (final size in sizes) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(const ArcheroSoundApp());
      await tester.pump();
      expect(find.text('اختيار البطل واللعب'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('critical character and enemy sprite sheets render all four frames',
      (tester) async {
    const assets = <String>[
      'assets/spritesheets/player_idle.svg',
      'assets/spritesheets/player_walk.svg',
      'assets/spritesheets/player_attack.svg',
      'assets/spritesheets/player_death.svg',
      'assets/spritesheets/player_flame_idle.svg',
      'assets/spritesheets/player_shadow_idle.svg',
      'assets/spritesheets/player_storm_idle.svg',
      'assets/spritesheets/enemy_melee.svg',
      'assets/spritesheets/enemy_melee_attack.svg',
      'assets/spritesheets/enemy_death.svg',
      'assets/spritesheets/enemy_ranged.svg',
      'assets/spritesheets/enemy_runner.svg',
      'assets/spritesheets/enemy_runner_attack.svg',
      'assets/spritesheets/enemy_tank.svg',
      'assets/spritesheets/enemy_tank_attack.svg',
      'assets/spritesheets/enemy_stalker.svg',
      'assets/spritesheets/enemy_stalker_attack.svg',
      'assets/spritesheets/boss_walk.svg',
      'assets/spritesheets/boss_attack.svg',
      'assets/spritesheets/boss_death.svg',
    ];

    for (final asset in assets) {
      for (var frame = 0; frame < 4; frame++) {
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 96,
                height: 96,
                child: SpriteSheetFrame(
                  asset: asset,
                  frameCount: 4,
                  frameIndex: frame,
                ),
              ),
            ),
          ),
        ));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '$asset frame $frame');
      }
    }
  });

  testWidgets('combat aura and projectile painters render without errors',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 160,
            height: 160,
            child: Stack(
              children: [
                CustomPaint(
                  size: const Size(160, 160),
                  painter: const EnemyAuraPainter(
                    type: 'ranged',
                    phase: 1.2,
                    attacking: true,
                    hit: false,
                  ),
                ),
                CustomPaint(
                  size: const Size(160, 160),
                  painter: const BossAuraPainter(phase: 2.1, attacking: true),
                ),
                CustomPaint(
                  size: const Size(32, 32),
                  painter: const RangedProjectilePainter(),
                ),
                CustomPaint(
                  size: const Size(160, 160),
                  painter: const CombatEffectPainter(
                    type: 'rangedShot',
                    progress: .35,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
