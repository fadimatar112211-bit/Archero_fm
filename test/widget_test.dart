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

  testWidgets('main menu shows resource wallet and disables unopened chests without keys', (tester) async {
    await tester.pumpWidget(const ArcheroSoundApp());
    await tester.ensureVisible(find.text('💎 الموارد والصناديق'));
    expect(find.text('الجواهر'), findsOneWidget);
    expect(find.text('المفاتيح'), findsOneWidget);
    expect(find.text('شظايا المعدات'), findsOneWidget);
    final supplyChest = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'صندوق الإمدادات · 1 مفتاح'),
    );
    expect(supplyChest.onPressed, isNull);
    expect(tester.takeException(), isNull);
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

  testWidgets('combat arena lays out across phone and tablet viewports', (tester) async {
    const sizes = <Size>[
      Size(360, 640),
      Size(390, 844),
      Size(800, 1280),
    ];

    for (final size in sizes) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(
        const MaterialApp(home: GameScreen(heroType: 1)),
      );
      await tester.pump(const Duration(milliseconds: 32));
      expect(tester.takeException(), isNull, reason: 'Arena viewport $size');
    }

    await tester.pumpWidget(const SizedBox.shrink());
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('combat pauses in background and resumes only its own pause',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: GameScreen(heroType: 1)),
    );
    await tester.pump(const Duration(milliseconds: 32));

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    expect(find.text('متابعة اللعب'), findsOneWidget);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(find.text('متابعة اللعب'), findsNothing);

    // A pause initiated by the player must not be auto-dismissed by resume.
    await tester.tap(find.byIcon(Icons.pause));
    await tester.pump();
    expect(find.text('متابعة اللعب'), findsOneWidget);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(find.text('متابعة اللعب'), findsOneWidget);
    await tester.tap(find.text('متابعة اللعب'));
    await tester.pump();

    expect(find.text('متابعة اللعب'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
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

  testWidgets('hero selection explains each active and passive ability',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: HeroSelectionScreen()),
    );

    expect(find.textContaining('انفجار اللهب'), findsOneWidget);
    expect(find.textContaining('جلد اللهب'), findsOneWidget);
    expect(find.textContaining('خطوة الظل'), findsOneWidget);
    expect(find.textContaining('وتر العاصفة'), findsOneWidget);
    expect(tester.takeException(), isNull);
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
