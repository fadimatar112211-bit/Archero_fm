import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/game_arena_view.dart';
import 'package:archero_fm/world_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AnimationController animation;

  setUp(() {
    animation = AnimationController(
      vsync: const TestVSync(),
      duration: const Duration(seconds: 12),
    );
  });

  tearDown(() {
    animation.dispose();
  });

  GameArenaView buildView({
    required void Function(double, double) onSize,
    required void Function(Offset, double, double) onDrag,
    VoidCallback? onPause,
  }) {
    return GameArenaView(
      stage: 3,
      score: 42,
      coins: 17,
      isPaused: false,
      playerHp: 80,
      playerMaxHp: 100,
      worldAnimation: animation,
      worldTheme: WorldTheme.forest,
      coinActors: const [],
      playerArrows: const [],
      enemyProjectiles: const [],
      enemies: const [],
      defeatedSprites: const [],
      combatEffects: const [],
      playerX: 180,
      playerY: 430,
      heroSpritePrefix: 'assets/spritesheets/player',
      animationTicks: 0,
      heroAttackTicks: 0,
      playerMoveTicks: 0,
      playerDying: false,
      playerDeathTicks: 0,
      specialCooldown: 0,
      showMysteryChest: false,
      onArenaSizeChanged: onSize,
      onPlayerDrag: onDrag,
      onPause: onPause ?? () {},
      onSpecialSkill: () {},
      onCollectChest: () {},
    );
  }

  testWidgets('renders presentation from supplied run snapshot', (tester) async {
    tester.view.physicalSize = const Size(400, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 400,
          height: 700,
          child: buildView(
            onSize: (_, __) {},
            onDrag: (_, __, ___) {},
          ),
        ),
      ),
    );

    expect(find.text('المرحلة 3'), findsOneWidget);
    expect(find.text('⭐ 42'), findsOneWidget);
    expect(find.text('🪙 17'), findsOneWidget);
    expect(find.text('المهارة الخاصة'), findsOneWidget);
  });

  testWidgets('reports arena dimensions and drag intent to its owner',
      (tester) async {
    tester.view.physicalSize = const Size(400, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    Size? reportedSize;
    Offset? reportedDelta;

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 400,
          height: 700,
          child: buildView(
            onSize: (width, height) => reportedSize = Size(width, height),
            onDrag: (delta, _, __) => reportedDelta = delta,
          ),
        ),
      ),
    );

    expect(reportedSize, isNotNull);
    expect(reportedSize!.width, 400);
    expect(reportedSize!.height, 700);

    await tester.drag(find.byKey(const ValueKey('game-arena-gesture')), const Offset(18, -9));
    await tester.pump();

    expect(reportedDelta, const Offset(18, -9));
  });
}
