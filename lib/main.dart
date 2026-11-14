import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
export 'combat_painters.dart';
export 'hero_catalog.dart';
import 'audio_service.dart';
import 'combat_painters.dart';
import 'hero_catalog.dart';
import 'progress_store.dart';
import 'world_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final progress = await ProgressStore.load();
  globalCoins = progress['coins']!;
  heroHpUpgrade = progress['hpUpgrade']!;
  heroAtkUpgrade = progress['atkUpgrade']!;
  bestStage = progress['bestStage']!;
  bestScore = progress['bestScore']!;
  runApp(const ArcheroSoundApp());
}

// -----------------------------------------------------------------------------
// إعدادات عامة وحفظ مؤقت للتقدم أثناء تشغيل التطبيق
// -----------------------------------------------------------------------------

int globalCoins = 150;
int heroHpUpgrade = 0;
int heroAtkUpgrade = 0;
int bestStage = 1;
int bestScore = 0;

Future<void> saveProgress() => ProgressStore.save(
  coins: globalCoins,
  hpUpgrade: heroHpUpgrade,
  atkUpgrade: heroAtkUpgrade,
  bestStage: bestStage,
  bestScore: bestScore,
);


class ArcheroSoundApp extends StatelessWidget {
  const ArcheroSoundApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Archero Sound Edition',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF090A0F),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.amber,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MainMenuScreen(),
    );
  }
}

// -----------------------------------------------------------------------------
// القائمة الرئيسية والمتجر
// -----------------------------------------------------------------------------

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  Future<void> _buyHealth() => _purchaseUpgrade(
    cost: 50,
    apply: () => heroHpUpgrade += 25,
    rollback: () => heroHpUpgrade -= 25,
    insufficientMessage: 'عملاتك لا تكفي لشراء ترقية الصحة.',
  );

  Future<void> _buyAttack() => _purchaseUpgrade(
    cost: 70,
    apply: () => heroAtkUpgrade += 15,
    rollback: () => heroAtkUpgrade -= 15,
    insufficientMessage: 'عملاتك لا تكفي لشراء ترقية الهجوم.',
  );

  Future<void> _purchaseUpgrade({
    required int cost,
    required void Function() apply,
    required void Function() rollback,
    required String insufficientMessage,
  }) async {
    if (globalCoins < cost) {
      _message(insufficientMessage);
      return;
    }

    setState(() {
      globalCoins -= cost;
      apply();
    });

    try {
      await saveProgress();
    } catch (_) {
      // Roll back the in-memory purchase when persistence fails. This keeps
      // the visible balance and upgrade values consistent with saved data.
      globalCoins += cost;
      rollback();
      if (!mounted) return;
      setState(() {});
      _message('تعذّر حفظ عملية الشراء. لم يتم اعتماد الترقية، حاول مجدداً.');
      return;
    }

    if (!mounted) return;
    await playRealSound('coin');
  }

  void _message(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF260044), Color(0xFF090A0F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(22),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  children: [
                    const Icon(
                      Icons.sports_esports_rounded,
                      size: 82,
                      color: Colors.amberAccent,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'ARCHERO: SOUND EDITION',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'قاتل، طوّر بطلك، وتجاوز المراحل',
                      style: TextStyle(color: Colors.amber, fontSize: 14),
                    ),
                    const SizedBox(height: 25),
                    _panel(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.monetization_on,
                              color: Colors.amber, size: 25),
                          const SizedBox(width: 9),
                          Text(
                            'رصيدك: $globalCoins',
                            style: const TextStyle(
                              color: Colors.yellowAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _panel(
                      child: Wrap(
                        alignment: WrapAlignment.spaceEvenly,
                        runAlignment: WrapAlignment.center,
                        spacing: 22,
                        runSpacing: 12,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.emoji_events, color: Colors.amber),
                              const SizedBox(height: 4),
                              Text('أفضل مرحلة: $bestStage',
                                  textAlign: TextAlign.center),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.stars, color: Colors.lightBlueAccent),
                              const SizedBox(height: 4),
                              Text('أفضل نتيجة: $bestScore',
                                  textAlign: TextAlign.center),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _panel(
                      child: Column(
                        children: [
                          const Text(
                            '🛠️ متجر تطوير القدرات',
                            style: TextStyle(
                              color: Colors.amberAccent,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('زيادة الصحة الحالية: +$heroHpUpgrade'),
                          Text('زيادة الهجوم الحالية: +$heroAtkUpgrade'),
                          const SizedBox(height: 14),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              FilledButton.icon(
                                onPressed: _buyHealth,
                                icon: const Icon(Icons.favorite),
                                label: const Text('صحة +25 (50)'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.blue.shade800,
                                ),
                              ),
                              FilledButton.icon(
                                onPressed: _buyAttack,
                                icon: const Icon(Icons.flash_on),
                                label: const Text('هجوم +15 (70)'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.deepOrange.shade800,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        onPressed: () {
                          playRealSound('special');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HeroSelectionScreen(),
                            ),
                          ).then((_) {
                            if (mounted) setState(() {});
                          });
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          'اختيار البطل واللعب',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 19,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _panel({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: child,
    );
  }
}

// -----------------------------------------------------------------------------
// اختيار الأبطال
// -----------------------------------------------------------------------------

class HeroSelectionScreen extends StatelessWidget {
  const HeroSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اختر بطلك الأسطوري')),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: heroChoices.length,
          itemBuilder: (context, index) {
            final hero = heroChoices[index];
            return Card(
              clipBehavior: Clip.antiAlias,
              color: const Color(0xFF111725),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(19),
                side: BorderSide(color: hero.color.withOpacity(.9), width: 1.4),
              ),
              elevation: 7,
              shadowColor: hero.color.withOpacity(.28),
              child: ListTile(
                contentPadding: const EdgeInsets.all(13),
                leading: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      hero.color.withOpacity(.42),
                      const Color(0xFF101522),
                    ]),
                    border: Border.all(color: hero.color.withOpacity(.9), width: 1.5),
                    boxShadow: [
                      BoxShadow(color: hero.color.withOpacity(.32), blurRadius: 14, spreadRadius: 1),
                    ],
                  ),
                  padding: const EdgeInsets.all(7),
                  child: SpriteSheetFrame(
                    asset: switch (hero.id) {
                      2 => 'assets/spritesheets/player_flame_idle.svg',
                      3 => 'assets/spritesheets/player_shadow_idle.svg',
                      4 => 'assets/spritesheets/player_storm_idle.svg',
                      _ => 'assets/spritesheets/player_idle.svg',
                    },
                    frameCount: 4,
                    frameIndex: 0,
                  ),
                ),
                title: Text(
                  hero.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(hero.description),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 17),
                onTap: () async {
                  playRealSound('special');
                  var selectedStage = 1;
                  if (bestStage > 1) {
                    final choice = await showDialog<int>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('اختر طريقة اللعب'),
                        content: Text(
                          'أفضل تقدم محفوظ لديك هو المرحلة $bestStage.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext, 1),
                            child: const Text('مغامرة جديدة'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(
                              dialogContext,
                              bestStage,
                            ),
                            child: Text('متابعة من المرحلة $bestStage'),
                          ),
                        ],
                      ),
                    );
                    if (!context.mounted || choice == null) return;
                    selectedStage = choice;
                  }
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GameScreen(
                        heroType: hero.id,
                        initialStage: selectedStage,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// بيانات اللعبة
// -----------------------------------------------------------------------------

typedef GameObject = Map<String, dynamic>;

class GameScreen extends StatefulWidget {
  final int heroType;
  final int initialStage;

  const GameScreen({
    super.key,
    required this.heroType,
    this.initialStage = 1,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  String get playerSpritePrefix => switch (widget.heroType) {
    2 => 'assets/spritesheets/player_flame',
    3 => 'assets/spritesheets/player_shadow',
    4 => 'assets/spritesheets/player_storm',
    _ => 'assets/spritesheets/player',
  };

  final Random random = Random();
  late final AnimationController worldAnimationController;

  double playerX = 180;
  double playerY = 430;
  double playerHp = 100;
  double playerMaxHp = 100;
  double playerSpeed = 3.5;
  DateTime? lastDamageAt;
  double attackPowerMultiplier = 1;
  int extraArrows = 0;
  int animationTicks = 0;
  int heroAttackTicks = 0;
  int playerMoveTicks = 0;
  final List<Map<String, dynamic>> combatEffects = [];
  final List<Map<String, dynamic>> defeatedSprites = [];

  int score = 0;
  late int stage = widget.initialStage;
  int specialCooldown = 0;

  bool isPaused = false;
  bool showMysteryChest = false;
  bool gameOverShown = false;
  bool playerDying = false;
  int playerDeathTicks = 0;
  bool stageTransitioning = false;

  Timer? gameLoop;
  Timer? shootLoop;
  Timer? cooldownLoop;

  final List<GameObject> enemies = [];
  final List<GameObject> arrows = [];
  final List<GameObject> enemyProjectiles = [];
  final List<GameObject> coins = [];

  @override
  void initState() {
    super.initState();
    worldAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    playerMaxHp += heroHpUpgrade.toDouble();
    playerHp = playerMaxHp;
    attackPowerMultiplier += heroAtkUpgrade * 0.08;

    if (widget.heroType == 2) {
      playerHp += 50;
      playerMaxHp += 50;
    } else if (widget.heroType == 3) {
      playerSpeed = 5.2;
    } else if (widget.heroType == 4) {
      extraArrows = 1;
    }

    _spawnEnemies();

    gameLoop = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!mounted || isPaused || showMysteryChest || gameOverShown) return;
    if (playerDying) {
      playerDeathTicks++;
      if (playerDeathTicks >= 24) _endGame();
      if (mounted) setState(() {});
      return;
    }
      _updateEngine();
    });

    shootLoop = Timer.periodic(const Duration(milliseconds: 650), (_) {
      if (!mounted ||
          isPaused ||
          showMysteryChest ||
          gameOverShown ||
          enemies.isEmpty) {
        return;
      }
      _shootArrows();
    });
  }

  void _spawnEnemies() {
    enemies.clear();
    arrows.clear();
    enemyProjectiles.clear();

    // يزداد التحدي تدريجياً، مع سقف لمعدل النمو حتى تبقى المراحل
    // المتقدمة صعبة دون أن تتحول إلى أعداء سريعي الحركة أو ممتلئي الصحة بشكل غير عادل.
    final difficultyStep = min(max(stage - 1, 0), 20).toDouble();

    if (stage % 5 == 0) {
      final bossProgress = min(max(stage - 5, 0), 45).toDouble();
      final bossHp = 360.0 + bossProgress * 22;
      enemies.add({
        'x': 180.0,
        'y': 105.0,
        'hp': bossHp,
        'maxHp': bossHp,
        'type': 'boss',
        'radius': 36.0,
        'speed': 0.78 + min(difficultyStep, 16) * 0.012,
      });
    } else {
      final count = min(2 + (stage ~/ 2), 7);
      for (int i = 0; i < count; i++) {
        // تنويع الأعداء تدريجياً حتى يختلف أسلوب كل مواجهة.
        final variant = (i + stage) % 4;
        final String enemyType = switch (variant) {
          0 => 'runner',
          1 => 'tank',
          2 => 'stalker',
          _ => 'ranged',
        };
        final baseHp = 55.0 + difficultyStep * 10;
        final hp = switch (enemyType) {
          'tank' => baseHp * 1.8,
          'runner' => baseHp * 0.72,
          'stalker' => baseHp * 0.9,
          'ranged' => baseHp * 0.82,
          _ => baseHp,
        };
        final speed = switch (enemyType) {
          'tank' => 0.52 + difficultyStep * 0.008,
          'runner' => 1.25 + difficultyStep * 0.018,
          'stalker' => 0.90 + difficultyStep * 0.014,
          'ranged' => 0.68 + difficultyStep * 0.010,
          _ => 0.76 + difficultyStep * 0.012,
        };
        enemies.add({
          'x': 35.0 + random.nextDouble() * 290,
          'y': 90.0 + random.nextDouble() * 190,
          'hp': hp,
          'maxHp': hp,
          'type': enemyType,
          'radius': enemyType == 'tank' ? 23.0 : 19.0,
          'speed': speed,
        });
      }
    }

    if (mounted) setState(() {});
  }

  void _shootArrows() {
    if (enemies.isEmpty) return;

    final target = enemies.reduce((a, b) {
      final da = pow((a['x'] as double) - playerX, 2) +
          pow((a['y'] as double) - playerY, 2);
      final db = pow((b['x'] as double) - playerX, 2) +
          pow((b['y'] as double) - playerY, 2);
      return da <= db ? a : b;
    });
    final angle = atan2(
      (target['y'] as double) - playerY,
      (target['x'] as double) - playerX,
    );

    heroAttackTicks = 12;
    final totalShots = 1 + extraArrows;
    for (int i = 0; i < totalShots; i++) {
      final spread = i == 0 ? 0.0 : (i.isOdd ? 0.20 : -0.20);
      arrows.add({
        'x': playerX,
        'y': playerY,
        'vx': cos(angle + spread) * 8.5,
        'vy': sin(angle + spread) * 8.5,
      });
    }
    playRealSound('shoot');
  }

  void _useSpecialSkill() {
    if (specialCooldown > 0 || enemies.isEmpty || isPaused ||
        showMysteryChest || gameOverShown) return;

    setState(() {
      // Distinct hero skills: flame burst, shadow evasion, storm strike.
      final skillDamage = switch (widget.heroType) {
        2 => 70.0,
        3 => 42.0,
        4 => 54.0,
        _ => 48.0,
      } * attackPowerMultiplier;

      if (widget.heroType == 3) {
        playerMoveTicks = 36;
        combatEffects.add({
          'x': playerX, 'y': playerY, 'type': 'dodge', 'life': 24,
        });
      }

      for (int i = enemies.length - 1; i >= 0; i--) {
        final enemy = enemies[i];
        final isBoss = enemy['type'] == 'boss';
        enemy['hp'] = (enemy['hp'] as double) -
            (isBoss ? skillDamage * 0.65 : skillDamage);
        enemy['hitTicks'] = 10;
        combatEffects.add({
          'x': enemy['x'], 'y': enemy['y'],
          'type': widget.heroType == 2 ? 'bossHit' :
              widget.heroType == 3 ? 'shadowHit' :
              widget.heroType == 4 ? 'metalHit' : 'sparkHit',
          'life': 22,
        });

        if ((enemy['hp'] as double) <= 0) {
          final x = enemy['x'];
          final y = enemy['y'];
          final type = enemy['type'] as String;
          defeatedSprites.add({
            'x': x, 'y': y, 'type': type, 'boss': isBoss, 'life': 24,
          });
          combatEffects.add({
            'x': x, 'y': y, 'type': isBoss ? 'bossBurst' : 'defeat',
            'life': 25,
          });
          coins.add({'x': x, 'y': y});
          score += isBoss ? 150 : 20;
          enemies.removeAt(i);
        }
      }
      specialCooldown = 15;
    });

    playRealSound('special');
    _checkStageComplete();
    cooldownLoop?.cancel();
    cooldownLoop = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (specialCooldown <= 1) {
        setState(() => specialCooldown = 0);
        timer.cancel();
      } else {
        setState(() => specialCooldown--);
      }
    });
  }

  void _updateEngine() {
    if (!mounted || gameOverShown || stageTransitioning) return;
    animationTicks++;
    if (heroAttackTicks > 0) heroAttackTicks--;
    if (playerMoveTicks > 0) playerMoveTicks--;

    // Update timed enemy defeat animations.
    for (int i = defeatedSprites.length - 1; i >= 0; i--) {
      defeatedSprites[i]['life'] = (defeatedSprites[i]['life'] as int) - 1;
      if ((defeatedSprites[i]['life'] as int) <= 0) defeatedSprites.removeAt(i);
    }

    // تحديث عمر المؤثرات القتالية.
    for (int i = combatEffects.length - 1; i >= 0; i--) {
      combatEffects[i]['life'] = (combatEffects[i]['life'] as int) - 1;
      if ((combatEffects[i]['life'] as int) <= 0) combatEffects.removeAt(i);
    }

    // تحريك مقذوفات الأعداء وفحص إصابة اللاعب.
    for (int i = enemyProjectiles.length - 1; i >= 0; i--) {
      final shot = enemyProjectiles[i];
      shot['x'] = (shot['x'] as double) + (shot['vx'] as double);
      shot['y'] = (shot['y'] as double) + (shot['vy'] as double);
      shot['life'] = (shot['life'] as int) - 1;
      final sx = (shot['x'] as double) - playerX;
      final sy = (shot['y'] as double) - playerY;
      if (sqrt(sx * sx + sy * sy) < 19) {
        if (playerMoveTicks > 0) {
          combatEffects.add({'x': playerX, 'y': playerY, 'type': 'dodge', 'life': 14});
        } else {
          // مهلة قصيرة بين الإصابات تمنع تكدّس المقذوفات في نفس اللحظة،
          // من دون إلغاء فرصة إصابة اللاعب بمقذوفات لاحقة.
          final now = DateTime.now();
          final canTakeDamage = lastDamageAt == null ||
              now.difference(lastDamageAt!).inMilliseconds >= 260;
          if (canTakeDamage) {
            playerHp -= (shot['damage'] as double?) ?? 6.0;
            lastDamageAt = now;
            combatEffects.add({
              'x': playerX, 'y': playerY, 'type': 'playerHit', 'life': 20,
            });
            playRealSound('hit');
          } else {
            combatEffects.add({
              'x': playerX, 'y': playerY, 'type': 'dodge', 'life': 10,
            });
          }
        }
        enemyProjectiles.removeAt(i);
      } else if ((shot['life'] as int) <= 0 ||
          (shot['x'] as double) < -20 || (shot['x'] as double) > 420 ||
          (shot['y'] as double) < -20 || (shot['y'] as double) > 850) {
        enemyProjectiles.removeAt(i);
      }
    }

    // تحريك الأسهم وفحص اصطدامها بالأعداء.
    for (int i = arrows.length - 1; i >= 0; i--) {
      final arrow = arrows[i];
      arrow['x'] = (arrow['x'] as double) + (arrow['vx'] as double);
      arrow['y'] = (arrow['y'] as double) + (arrow['vy'] as double);

      if ((arrow['x'] as double) < -20 ||
          (arrow['x'] as double) > 420 ||
          (arrow['y'] as double) < -20 ||
          (arrow['y'] as double) > 850) {
        arrows.removeAt(i);
        continue;
      }

      bool arrowRemoved = false;
      for (int j = enemies.length - 1; j >= 0; j--) {
        final enemy = enemies[j];
        final dx = (arrow['x'] as double) - (enemy['x'] as double);
        final dy = (arrow['y'] as double) - (enemy['y'] as double);
        if (sqrt(dx * dx + dy * dy) <
            (enemy['radius'] as double) + 5) {
          final hitType = switch (enemy['type']) {
            'tank' => 'metalHit',
            'stalker' => 'shadowHit',
            'runner' => 'sparkHit',
            'boss' => 'bossHit',
            _ => 'impact',
          };
          combatEffects.add({
            'x': enemy['x'], 'y': enemy['y'], 'type': hitType, 'life': 16,
          });
          enemy['hitTicks'] = 9;
          enemy['hp'] = (enemy['hp'] as double) -
              (35 * attackPowerMultiplier);
          arrows.removeAt(i);
          arrowRemoved = true;

          if ((enemy['hp'] as double) <= 0) {
            defeatedSprites.add({'x': enemy['x'], 'y': enemy['y'], 'type': enemy['type'], 'boss': enemy['type'] == 'boss', 'life': 24});
            combatEffects.add({
              'x': enemy['x'], 'y': enemy['y'],
              'type': enemy['type'] == 'boss' ? 'bossBurst' : 'defeat',
              'life': 25,
            });
            coins.add({'x': enemy['x'], 'y': enemy['y']});
            score += enemy['type'] == 'boss' ? 150 : 20;
            enemies.removeAt(j);
            playRealSound('hit');
          }
          break;
        }
      }
      if (arrowRemoved) continue;
    }

    // إطفاء ومضة الإصابة تدريجياً حتى لا تبقى الشخصية مضيئة.
    for (final enemy in enemies) {
      final hitTicks = (enemy['hitTicks'] as int?) ?? 0;
      if (hitTicks > 0) enemy['hitTicks'] = hitTicks - 1;
    }

    // ذكاء قتالي متنوع: اندفاع السريع، التفاف المتخفي، واندفاعة الزعيم.
    for (final enemy in enemies) {
      final dx = playerX - (enemy['x'] as double);
      final dy = playerY - (enemy['y'] as double);
      final distance = sqrt(dx * dx + dy * dy);
      final angle = atan2(dy, dx);
      final type = enemy['type'] as String;
      final bossEnraged = type == 'boss' &&
          (enemy['hp'] as double) <= (enemy['maxHp'] as double) * 0.35;
      var attackTicks = (enemy['attackTicks'] as int?) ?? 0;
      var attackCooldown = (enemy['attackCooldown'] as int?) ?? 0;
      if (attackTicks > 0) attackTicks--;
      if (attackCooldown > 0) attackCooldown--;
      final attackRange = 23 + (enemy['radius'] as double) + 24;
      var areaAttackTicks = (enemy['areaAttackTicks'] as int?) ?? 0;
      if (areaAttackTicks > 0) areaAttackTicks--;
      if (type == 'ranged' && distance >= 105 && distance <= 255 && attackCooldown == 0) {
        final shotAngle = atan2(dy, dx);
        enemyProjectiles.add({
          'x': enemy['x'], 'y': enemy['y'],
          // مقذوف أبطأ قليلاً ليمنح اللاعب وقتاً أوضح للمراوغة.
          'vx': cos(shotAngle) * 3.8, 'vy': sin(shotAngle) * 3.8,
          'damage': 6.0,
          'life': 110,
        });
        attackTicks = 12;
        attackCooldown = 108;
        combatEffects.add({'x': enemy['x'], 'y': enemy['y'], 'type': 'rangedShot', 'life': 12});
      }
      if (type == 'boss' &&
          distance <= 220 &&
          areaAttackTicks == 0 &&
          attackCooldown == 0) {
        areaAttackTicks = 32;
        attackCooldown = bossEnraged ? 132 : 180;
        enemy['areaHitDone'] = false;
        combatEffects.add({
          'x': enemy['x'], 'y': enemy['y'],
          'type': 'bossTell', 'life': 32,
        });
      } else if (type != 'boss' && type != 'ranged' &&
          distance <= attackRange &&
          attackCooldown == 0) {
        attackTicks = 16;
        attackCooldown = 76;
        enemy['attackHitDone'] = false;
        combatEffects.add({
          'x': enemy['x'], 'y': enemy['y'],
          'type': 'enemyAttack', 'life': 12,
        });
      }
      enemy['areaAttackTicks'] = areaAttackTicks;
      enemy['attackTicks'] = attackTicks;
      enemy['attackCooldown'] = attackCooldown;
      if (type == 'boss' &&
          areaAttackTicks == 8 &&
          enemy['areaHitDone'] != true) {
        enemy['areaHitDone'] = true;
        final blastDx = playerX - (enemy['x'] as double);
        final blastDy = playerY - (enemy['y'] as double);
        final blastDistance = sqrt(blastDx * blastDx + blastDy * blastDy);
        if (blastDistance <= (bossEnraged ? 132 : 112)) {
          if (playerMoveTicks > 0) {
            combatEffects.add({
              'x': playerX, 'y': playerY, 'type': 'dodge', 'life': 18,
            });
          } else {
            playerHp -= bossEnraged ? 20 : 15;
            combatEffects.add({
              'x': playerX, 'y': playerY, 'type': 'playerHit', 'life': 22,
            });
            playRealSound('hit');
          }
        }
        combatEffects.add({
          'x': enemy['x'], 'y': enemy['y'],
          'type': 'bossBurst', 'life': 24,
        });
      }
      var moveSpeed = enemy['speed'] as double;
      var moveAngle = angle;

      if (type == 'ranged') {
        if (distance < 145) {
          moveAngle += pi;
          moveSpeed *= 1.05;
        } else if (distance < 185) {
          moveSpeed *= 0.08;
        } else {
          moveSpeed *= 0.72;
        }
      } else if (type == 'runner') {
        final dashCycle = animationTicks % 105;
        if (dashCycle < 18) {
          moveSpeed *= 2.35;
          if (dashCycle == 0) {
            combatEffects.add({
              'x': enemy['x'], 'y': enemy['y'],
              'type': 'enemyAttack', 'life': 12,
            });
          }
        } else {
          moveSpeed *= 0.78;
        }
      } else if (type == 'stalker') {
        // يتحرك جانبياً حول اللاعب بدلاً من مطاردته بخط مستقيم.
        final side = sin(animationTicks * 0.055 + (enemy['x'] as double)) >= 0 ? 1.0 : -1.0;
        moveAngle += side * 0.48;
        moveSpeed *= distance < 105 ? 0.72 : 1.12;
      } else if (type == 'boss') {
        final bossCycle = animationTicks % 180;
        if (bossCycle < 28) {
          moveSpeed *= bossEnraged ? 3.15 : 2.65;
          if (bossCycle == 0) {
            combatEffects.add({
              'x': enemy['x'], 'y': enemy['y'],
              'type': 'bossTell', 'life': 28,
            });
          }
        } else {
          moveSpeed *= 0.72;
        }
      } else if (type == 'tank') {
        moveSpeed *= 0.82;
      }

      enemy['x'] = (enemy['x'] as double) + cos(moveAngle) * moveSpeed;
      enemy['y'] = (enemy['y'] as double) + sin(moveAngle) * moveSpeed;
      // دورة مشي مستقلة تتقدم بحسب سرعة الحركة الفعلية لكل عدو.
      enemy['walkPhase'] = ((enemy['walkPhase'] as double?) ?? 0.0) +
          moveSpeed.abs() * (type == 'runner' ? 0.16 : 0.11);
      // لحظة الضرر تقع في منتصف ضربة الهجوم، مرة واحدة لكل دورة.
      final impactDistance = 23 + (enemy['radius'] as double) + 14;
      final impactFrame = type == 'boss' ? 12 : 8;
      if (type != 'ranged' && attackTicks == impactFrame &&
          enemy['attackHitDone'] != true &&
          distance <= impactDistance &&
          playerMoveTicks > 0) {
        enemy['attackHitDone'] = true;
        combatEffects.add({
          'x': playerX, 'y': playerY, 'type': 'dodge', 'life': 14,
        });
      }
      if (type != 'ranged' && attackTicks == impactFrame &&
          enemy['attackHitDone'] != true &&
          distance <= impactDistance &&
          playerMoveTicks <= 0) {
        final now = DateTime.now();
        if (lastDamageAt == null ||
            now.difference(lastDamageAt!).inMilliseconds >= 220) {
          // ضرر مختلف لكل فئة: الدبابة بطيئة لكنها تضرب بقوة،
          // والعدّاء أخف ضرراً مقابل اندفاعاته المتكررة.
          final contactDamage = switch (type) {
            'boss' => bossEnraged ? 12.0 : 10.0,
            'tank' => 8.0,
            'stalker' => 6.0,
            'runner' => 4.0,
            _ => 5.0,
          };
          playerHp -= contactDamage;
          lastDamageAt = now;
          enemy['attackHitDone'] = true;
          combatEffects.add({
            'x': playerX, 'y': playerY, 'type': 'playerHit', 'life': 20,
          });
          combatEffects.add({
            'x': enemy['x'], 'y': enemy['y'],
            'type': 'enemyAttack', 'life': 12,
          });
        }
      }
    }

    // جمع العملات.
    var collectedCoin = false;
    for (int i = coins.length - 1; i >= 0; i--) {
      final dx = playerX - (coins[i]['x'] as double);
      final dy = playerY - (coins[i]['y'] as double);
      if (sqrt(dx * dx + dy * dy) < 34) {
        globalCoins += 10;
        collectedCoin = true;
        coins.removeAt(i);
        playRealSound('coin');
      }
    }

    if (collectedCoin) saveProgress();

    if (playerHp <= 0) {
      playerHp = 0;
      playerDying = true;
      playerDeathTicks = 0;
      playRealSound('hit');
      if (mounted) setState(() {});
      return;
    }

    if (enemies.isEmpty) {
      _checkStageComplete();
    }

    if (mounted) setState(() {});
  }

  void _checkStageComplete() {
    if (stageTransitioning || enemies.isNotEmpty || gameOverShown) return;
    stageTransitioning = true;
    stage++;
    bestStage = max(bestStage, stage);
    playerHp = min(playerMaxHp, playerHp + 35);
    saveProgress();

    if (stage % 2 == 0) {
      setState(() => showMysteryChest = true);
      playRealSound('special');
    } else {
      _showPerksDialog();
    }
  }

  Future<void> _showPerksDialog() async {
    if (!mounted || gameOverShown) return;
    setState(() => isPaused = true);

    final choice = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          '✨ ترقية مهارة أسطورية',
          style: TextStyle(color: Colors.amber),
        ),
        content: const Text('اختر ترقية واحدة للمرحلة القادمة:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, 'arrow'),
            child: const Text('سهم إضافي'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, 'attack'),
            child: const Text('قوة الهجوم +35%'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, 'health'),
            child: const Text('استعادة 40 صحة'),
          ),
        ],
      ),
    );

    if (!mounted || gameOverShown) return;
    setState(() {
      if (choice == 'arrow') {
        extraArrows++;
      } else if (choice == 'attack') {
        attackPowerMultiplier += 0.35;
      } else if (choice == 'health') {
        playerHp = min(playerMaxHp, playerHp + 40);
      }
      isPaused = false;
      stageTransitioning = false;
    });
    _spawnEnemies();
  }

  void _collectChest() {
    setState(() {
      globalCoins += 75;
      showMysteryChest = false;
      stageTransitioning = false;
    });
    saveProgress();
    playRealSound('coin');
    _spawnEnemies();
  }

  Future<void> _endGame() async {
    if (gameOverShown) return;
    gameOverShown = true;
    bestStage = max(bestStage, stage);
    bestScore = max(bestScore, score);
    saveProgress();
    gameLoop?.cancel();
    shootLoop?.cancel();
    cooldownLoop?.cancel();
    playRealSound('hit');

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'انتهت المعركة',
          style: TextStyle(color: Colors.redAccent),
        ),
        content: Text(
          'المرحلة التي وصلت إليها: $stage\n'
          'النقاط الإجمالية: $score\n'
          'رصيد العملات: 🪙 $globalCoins',
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const MainMenuScreen()),
                (route) => false,
              );
            },
            child: const Text('العودة للقائمة الرئيسية'),
          ),
        ],
      ),
    );
  }

  void _togglePause() {
    if (showMysteryChest || gameOverShown) return;
    setState(() => isPaused = !isPaused);
  }

  @override
  void dispose() {
    gameLoop?.cancel();
    shootLoop?.cancel();
    cooldownLoop?.cancel();
    worldAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanUpdate: (details) {
                if (isPaused || showMysteryChest || gameOverShown) return;
                setState(() {
                  if (details.delta.distanceSquared > 0.25) playerMoveTicks = 8;
                  playerX = (playerX + details.delta.dx)
                      .clamp(22.0, width - 22.0)
                      .toDouble();
                  playerY = (playerY + details.delta.dy)
                      .clamp(105.0, height - 35.0)
                      .toDouble();
                });
              },
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  const Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF202638), Color(0xFF10131C)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),

                  // خلفية زخرفية بسيطة.
                  Positioned.fill(
                    child: RepaintBoundary(
                      child: CustomPaint(
                        painter: ArenaPainter(
                          theme: WorldTheme.forStage(stage),
                          animation: worldAnimationController,
                        ),
                      ),
                    ),
                  ),

                  // لوحة معلومات المرحلة.
                  Positioned(
                    top: 8,
                    left: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.72),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.amber.withOpacity(0.4)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('المرحلة $stage',
                              style: const TextStyle(color: Colors.amber)),
                          Text('⭐ $score'),
                          Text('🪙 $globalCoins'),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            onPressed: _togglePause,
                            icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // شريط الصحة.
                  Positioned(
                    top: 65,
                    left: 15,
                    right: 15,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        minHeight: 10,
                        value: (playerHp / playerMaxHp).clamp(0.0, 1.0),
                        backgroundColor: Colors.red.shade900,
                        color: Colors.greenAccent,
                      ),
                    ),
                  ),

                  // العملات.
                  ...coins.map((coin) => Positioned(
                        left: (coin['x'] as double) - 10,
                        top: (coin['y'] as double) - 10,
                        child: const Text('🪙', style: TextStyle(fontSize: 20)),
                      )),

                  // الأسهم.
                  ...arrows.map((arrow) => Positioned(
                        left: (arrow['x'] as double) - 5,
                        top: (arrow['y'] as double) - 5,
                        child: Transform.rotate(
                          angle: atan2(
                            arrow['vy'] as double,
                            arrow['vx'] as double,
                          ),
                          child: const CustomPaint(
                            size: Size(25, 12),
                            painter: ArrowSpritePainter(),
                          ),
                        ),
                      )),

                  // مقذوفات الأعداء بعيدة المدى.
                  ...enemyProjectiles.map((shot) => Positioned(
                        left: (shot['x'] as double) - 11,
                        top: (shot['y'] as double) - 11,
                        child: Transform.rotate(
                          angle: animationTicks * .16,
                          child: const CustomPaint(
                            size: Size(22, 22),
                            painter: RangedProjectilePainter(),
                          ),
                        ),
                      )),

                  // الأعداء وأشرطة صحتهم.
                  ...enemies.map((enemy) {
                    final radius = enemy['radius'] as double;
                    final enemyType = enemy['type'] as String;
                    final isBoss = enemyType == 'boss';
                    final enemyColor = switch (enemyType) {
                      'ranged' => Colors.cyan,
                      'runner' => Colors.orange,
                      'tank' => Colors.blueGrey,
                      'stalker' => Colors.purple,
                      'boss' => Colors.deepPurple,
                      _ => Colors.red,
                    };

                    final walkPhase = (enemy['walkPhase'] as double?) ?? 0.0;
                    final enemyPhase = walkPhase + (enemy['x'] as double) * 0.03;
                    final enemyAttacking =
                        ((enemy['attackTicks'] as int?) ?? 0) > 0 ||
                        (isBoss && ((enemy['areaAttackTicks'] as int?) ?? 0) > 0);
                    final enemyHit = ((enemy['hitTicks'] as int?) ?? 0) > 0;
                    // حركة مشي ناعمة مستمرة فوق إطارات الـSVG، مع اختلاف وزن كل فئة.
                    final gait = sin(walkPhase * 1.8);
                    final gaitBounce = cos(walkPhase * 3.6).abs();
                    final gaitStrength = enemyType == 'tank' || enemyType == 'boss' ? 0.45 : 1.0;
                    final attackLean = enemyAttacking ? (enemyType == 'boss' ? -0.16 : -0.24) : gait * 0.045 * gaitStrength;
                    final hpRatio = ((enemy['hp'] as double) /
                            (enemy['maxHp'] as double))
                        .clamp(0.0, 1.0);

                    return Positioned(
                      left: (enemy['x'] as double) - radius,
                      top: (enemy['y'] as double) - radius,
                      child: Column(
                        children: [
                          Container(
                            width: radius * 2,
                            height: 5,
                            margin: const EdgeInsets.only(bottom: 4),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: hpRatio,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isBoss ? Colors.purpleAccent : enemyColor,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: radius * 2,
                            height: radius * 2,
                            child: Transform.translate(
                              offset: Offset(enemyAttacking ? -3.5 : sin(enemyPhase).abs() * -2.0, (sin(enemyPhase * 1.35) * 1.5 - gaitBounce * 1.15 * gaitStrength) * (enemyAttacking ? 0.45 : 1.0)),
                              child: Transform.rotate(
                                angle: enemyHit ? 0.10 * sin(enemyPhase * 5) : attackLean,
                                child: Transform.scale(
                                  scale: (1 + gaitBounce * 0.018 * gaitStrength + sin(enemyPhase) * 0.012) * (enemyAttacking ? 1.06 : 1.0) * (enemyHit ? 0.96 : 1.0),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      if (isBoss)
                                        CustomPaint(
                                          painter: BossAuraPainter(
                                            phase: animationTicks * .045,
                                            attacking: enemyAttacking,
                                          ),
                                        )
                                      else
                                        CustomPaint(
                                          painter: EnemyAuraPainter(
                                            type: enemyType,
                                            phase: enemyPhase,
                                            attacking: enemyAttacking,
                                            hit: enemyHit,
                                          ),
                                        ),
                                      SpriteSheetFrame(
                                        asset: enemyType == 'ranged'
                                            ? 'assets/spritesheets/enemy_ranged.svg'
                                            : enemyType == 'boss'
                                            ? (enemyAttacking ? 'assets/spritesheets/boss_attack.svg' : 'assets/spritesheets/boss_walk.svg')
                                            : enemyAttacking && enemyType == 'runner'
                                                ? 'assets/spritesheets/enemy_runner_attack.svg'
                                                : enemyAttacking && enemyType != 'stalker' && enemyType != 'tank' && enemyType != 'ranged'
                                                    ? 'assets/spritesheets/enemy_melee_attack.svg'
                                                    : enemyAttacking && enemyType == 'stalker'
                                                ? 'assets/spritesheets/enemy_stalker_attack.svg'
                                                : enemyAttacking && enemyType == 'tank'
                                                    ? 'assets/spritesheets/enemy_tank_attack.svg'
                                                    : enemyType == 'runner'
                                                        ? 'assets/spritesheets/enemy_runner.svg'
                                                        : enemyType == 'stalker'
                                                            ? 'assets/spritesheets/enemy_stalker.svg'
                                                            : enemyType == 'tank'
                                                                ? 'assets/spritesheets/enemy_tank.svg'
                                                                : 'assets/spritesheets/enemy_melee.svg',
                                        frameCount: 4,
                                        frameIndex: enemyAttacking
                                            ? (animationTicks ~/ 2) % 4
                                            : (walkPhase * 1.8).floor() % 4,
                                      ),
                                      if (enemyHit)
                                        DecoratedBox(decoration: BoxDecoration(color: Colors.white.withOpacity(.32))),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  ...defeatedSprites.map((sprite) {
                    final life = sprite['life'] as int;
                    final size = sprite['boss'] == true ? 104.0 : 66.0;
                    return Positioned(
                      left: (sprite['x'] as double) - size / 2,
                      top: (sprite['y'] as double) - size / 2,
                      width: size,
                      height: size,
                      child: Opacity(
                        opacity: (life / 24).clamp(0.0, 1.0),
                        child: SpriteSheetFrame(
                          asset: sprite['boss'] == true
                              ? 'assets/spritesheets/boss_death.svg'
                              : sprite['type'] == 'runner'
                                  ? 'assets/spritesheets/enemy_runner_death.svg'
                                  : sprite['type'] == 'tank'
                                      ? 'assets/spritesheets/enemy_tank_death.svg'
                                      : sprite['type'] == 'stalker'
                                          ? 'assets/spritesheets/enemy_stalker_death.svg'
                                          : 'assets/spritesheets/enemy_death.svg',
                           frameCount: 4,
                          frameIndex: ((24 - life) ~/ 6).clamp(0, 3),
                        ),
                      ),
                    );
                  }),

                  // ومضات الاصطدام وانفجارات هزيمة الوحوش.
                  ...combatEffects.map((effect) {
                    final life = effect['life'] as int;
                    final type = effect['type'] as String;
                    final radius = type == 'bossTell' || type == 'bossBurst'
                        ? 112.0
                        : ((type == 'defeat' || type == 'playerHit') ? 42.0 : 29.0);
                    return Positioned(
                      left: (effect['x'] as double) - radius,
                      top: (effect['y'] as double) - radius,
                      child: CustomPaint(
                        size: Size(radius * 2, radius * 2),
                        painter: CombatEffectPainter(
                          type: type,
                          progress: (1 - life / (
                            type == 'bossTell' ? 32 :
                            type == 'bossBurst' ? 24 :
                            (type == 'impact' || type.endsWith('Hit') || type == 'enemyAttack')
                                ? (type == 'enemyAttack' ? 12 : 16)
                                : 25
                          )).clamp(0.0, 1.0),
                        ),
                      ),
                    );
                  }),

                  // اللاعب.
                  Positioned(
                    left: playerX - 21,
                    top: playerY - 21,
                    child: SizedBox(
                      width: 58,
                      height: 58,
                      child: Transform.translate(
                        offset: Offset(heroAttackTicks > 0 ? 3.0 : 0.0, sin(animationTicks * 0.13).abs() * -2.4),
                        child: Transform.rotate(
                          angle: heroAttackTicks > 0 ? -0.10 - (heroAttackTicks / 12) * 0.13 : sin(animationTicks * 0.13) * 0.025,
                          child: Transform.scale(
                            scale: (1 + sin(animationTicks * 0.13) * 0.025) * (heroAttackTicks > 0 ? 1.045 : 1.0),
                            child: SpriteSheetFrame(
                              asset: playerDying
                                  ? '${playerSpritePrefix}_death.svg'
                                  : heroAttackTicks > 0
                                      ? '${playerSpritePrefix}_attack.svg'
                                      : playerMoveTicks > 0
                                          ? '${playerSpritePrefix}_walk.svg'
                                          : '${playerSpritePrefix}_idle.svg',
                              frameCount: 4,
                              frameIndex: playerDying
                                  ? (playerDeathTicks ~/ 6).clamp(0, 3)
                                  : heroAttackTicks > 0
                                      ? (animationTicks ~/ 2) % 4
                                      : playerMoveTicks > 0
                                          ? (animationTicks ~/ 7) % 4
                                          : 0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // زر المهارة الخاصة.
                  Positioned(
                    right: 15,
                    bottom: 20,
                    child: FilledButton.icon(
                      onPressed: _useSpecialSkill,
                      style: FilledButton.styleFrom(
                        backgroundColor: specialCooldown == 0
                            ? Colors.deepPurple
                            : Colors.grey.shade800,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                      icon: const Icon(Icons.auto_awesome),
                      label: Text(
                        specialCooldown == 0
                            ? 'المهارة الخاصة'
                            : 'انتظر $specialCooldown',
                      ),
                    ),
                  ),

                  // طبقة الإيقاف المؤقت.
                  if (isPaused)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.78),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'اللعبة متوقفة',
                                style: TextStyle(
                                  fontSize: 27,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 15),
                              FilledButton.icon(
                                onPressed: _togglePause,
                                icon: const Icon(Icons.play_arrow),
                                label: const Text('متابعة اللعب'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const MainMenuScreen(),
                                    ),
                                    (route) => false,
                                  );
                                },
                                child: const Text('الخروج إلى القائمة'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // صندوق المكافأة.
                  if (showMysteryChest)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.82),
                        child: Center(
                          child: Container(
                            margin: const EdgeInsets.all(24),
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(0xFF241B05),
                              border: Border.all(color: Colors.amber, width: 2),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.card_giftcard,
                                  color: Colors.amber,
                                  size: 58,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'صندوق المكافآت الأسطوري!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.amberAccent,
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text('تحصل على 75 عملة مجانية'),
                                const SizedBox(height: 18),
                                FilledButton(
                                  onPressed: _collectChest,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: Colors.amber,
                                    foregroundColor: Colors.black,
                                  ),
                                  child: const Text('افتح الصندوق'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }


}

class SpriteSheetFrame extends StatelessWidget {
  const SpriteSheetFrame({
    super.key,
    required this.asset,
    required this.frameCount,
    required this.frameIndex,
  });

  final String asset;
  final int frameCount;
  final int frameIndex;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        if (!width.isFinite || !height.isFinite || width <= 0 || height <= 0) {
          return const SizedBox.expand();
        }
        final frame = frameIndex % frameCount;
        return ClipRect(
          child: SizedBox(
            width: width,
            height: height,
            child: OverflowBox(
              alignment: Alignment.centerLeft,
              minWidth: width * frameCount,
              maxWidth: width * frameCount,
              minHeight: height,
              maxHeight: height,
              child: Transform.translate(
                offset: Offset(-width * frame, 0),
                child: SizedBox(
                  width: width * frameCount,
                  height: height,
                  child: SvgPicture.asset(asset, fit: BoxFit.fill),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
