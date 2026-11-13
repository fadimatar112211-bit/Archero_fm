import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'progress_store.dart';
import 'stage_flow.dart';
import 'skill_system.dart';
import 'boss_combat.dart';
import 'world_rules.dart';
import 'shop_economy.dart';
import 'audio_service.dart';
import 'world_theme.dart';
import 'combat_stats.dart';
import 'combat_targeting.dart';

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

final GameAudioService gameAudio = GameAudioService();

Future<void> playRealSound(String type) => gameAudio.play(type);

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
  Future<void> _buyHealth() async {
    final upgrade = ShopEconomy.health(heroHpUpgrade);
    if (!upgrade.canPurchase(globalCoins)) {
      _message(
        upgrade.isMaxed
            ? 'وصلت إلى الحد الأقصى لترقية الصحة.'
            : 'عملاتك لا تكفي لشراء ترقية الصحة.',
      );
      return;
    }
    setState(() {
      globalCoins -= upgrade.cost;
      heroHpUpgrade += upgrade.increase;
    });
    await saveProgress();
    await playRealSound('coin');
  }

  Future<void> _buyAttack() async {
    final upgrade = ShopEconomy.attack(heroAtkUpgrade);
    if (!upgrade.canPurchase(globalCoins)) {
      _message(
        upgrade.isMaxed
            ? 'وصلت إلى الحد الأقصى لترقية الهجوم.'
            : 'عملاتك لا تكفي لشراء ترقية الهجوم.',
      );
      return;
    }
    setState(() {
      globalCoins -= upgrade.cost;
      heroAtkUpgrade += upgrade.increase;
    });
    await saveProgress();
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
                                onPressed: ShopEconomy.health(heroHpUpgrade).canPurchase(globalCoins)
                                    ? _buyHealth
                                    : null,
                                icon: const Icon(Icons.favorite),
                                label: Text(ShopEconomy.health(heroHpUpgrade).isMaxed
                                    ? 'الصحة: الحد الأقصى'
                                    : 'صحة +25 · المستوى ${ShopEconomy.health(heroHpUpgrade).level}/${ShopEconomy.health(heroHpUpgrade).maxLevel} · ${ShopEconomy.health(heroHpUpgrade).cost} عملة'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.blue.shade800,
                                ),
                              ),
                              FilledButton.icon(
                                onPressed: ShopEconomy.attack(heroAtkUpgrade).canPurchase(globalCoins)
                                    ? _buyAttack
                                    : null,
                                icon: const Icon(Icons.flash_on),
                                label: Text(ShopEconomy.attack(heroAtkUpgrade).isMaxed
                                    ? 'الهجوم: الحد الأقصى'
                                    : 'هجوم +15 · المستوى ${ShopEconomy.attack(heroAtkUpgrade).level}/${ShopEconomy.attack(heroAtkUpgrade).maxLevel} · ${ShopEconomy.attack(heroAtkUpgrade).cost} عملة'),
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

class HeroInfo {
  final int id;
  final String name;
  final String description;
  final Color color;
  final IconData icon;

  const HeroInfo(
    this.id,
    this.name,
    this.description,
    this.color,
    this.icon,
  );
}

const heroChoices = <HeroInfo>[
  HeroInfo(
    1,
    'الرامي المتوازن',
    'صحة وسرعة وهجوم متوازنة.',
    Colors.blue,
    Icons.sports_martial_arts,
  ),
  HeroInfo(
    2,
    'فارس النارية',
    'يبدأ بصحة إضافية قدرها 50.',
    Colors.deepOrange,
    Icons.local_fire_department,
  ),
  HeroInfo(
    3,
    'صياد الظل',
    'يمتلك سرعة حركة أعلى.',
    Colors.purple,
    Icons.speed,
  ),
  HeroInfo(
    4,
    'حارس العواصف',
    'يطلق سهماً إضافياً في كل هجمة.',
    Colors.teal,
    Icons.bolt,
  ),
];

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

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  String get playerSpritePrefix => switch (widget.heroType) {
    2 => 'assets/spritesheets/player_flame',
    3 => 'assets/spritesheets/player_shadow',
    4 => 'assets/spritesheets/player_storm',
    _ => 'assets/spritesheets/player',
  };

  final Random random = Random();
  late final AnimationController worldAnimationController;

  double arenaWidth = 360;
  double arenaHeight = 640;
  bool _arenaInitialized = false;
  double playerX = 180;
  double playerY = 430;
  double playerHp = 100;
  double playerMaxHp = 100;
  double playerSpeed = 3.5;
  DateTime? lastDamageAt;
  double attackPowerMultiplier = 1;
  int extraArrows = 0;
  double criticalChance = 0;
  double attackSpeedMultiplier = 1;
  double enemySpeedMultiplier = 1;
  double coinPickupRadius = 34;
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
    WidgetsBinding.instance.addObserver(this);
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

    _restartShootLoop();
  }

  void _spawnEnemies({bool notify = true}) {
    enemies.clear();
    arrows.clear();
    enemyProjectiles.clear();

    // يزداد التحدي تدريجياً، مع سقف لمعدل النمو حتى تبقى المراحل
    // المتقدمة صعبة دون أن تتحول إلى أعداء سريعي الحركة أو ممتلئي الصحة بشكل غير عادل.
    final difficultyStep = min(max(stage - 1, 0), 20).toDouble();
    final worldRules = WorldRules.forStage(stage);

    if (stage % 5 == 0) {
      final bossProgress = min(max(stage - 5, 0), 45).toDouble();
      final bossHp = (360.0 + bossProgress * 22) *
          worldRules.enemyHealthMultiplier;
      enemies.add({
        'x': arenaWidth / 2,
        'y': arenaHeight * 0.16,
        'hp': bossHp,
        'maxHp': bossHp,
        'type': 'boss',
        'radius': 36.0,
        'speed': (0.78 + min(difficultyStep, 16) * 0.012) *
            enemySpeedMultiplier * worldRules.enemySpeedMultiplier,
        'bossPhase': 1,
        'bossVolleyCooldown': 90,
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
        final baseVariantHp = switch (enemyType) {
          'tank' => baseHp * 1.8,
          'runner' => baseHp * 0.72,
          'stalker' => baseHp * 0.9,
          'ranged' => baseHp * 0.82,
          _ => baseHp,
        };
        final hp = baseVariantHp * worldRules.enemyHealthMultiplier;
        final speed = switch (enemyType) {
          'tank' => 0.52 + difficultyStep * 0.008,
          'runner' => 1.25 + difficultyStep * 0.018,
          'stalker' => 0.90 + difficultyStep * 0.014,
          'ranged' => 0.68 + difficultyStep * 0.010,
          _ => 0.76 + difficultyStep * 0.012,
        };
        enemies.add({
          'x': 24.0 + random.nextDouble() * max(1.0, arenaWidth - 48.0),
          'y': arenaHeight * (0.14 + random.nextDouble() * 0.26),
          'hp': hp,
          'maxHp': hp,
          'type': enemyType,
          'radius': enemyType == 'tank' ? 23.0 : 19.0,
          'speed': speed * enemySpeedMultiplier *
              worldRules.enemySpeedMultiplier,
        });
      }
    }

    if (notify && mounted) setState(() {});
  }

  void _syncArenaSize(double width, double height) {
    if (!width.isFinite || !height.isFinite || width <= 0 || height <= 0) return;
    if (!_arenaInitialized) {
      arenaWidth = width;
      arenaHeight = height;
      playerX = width / 2;
      playerY = height * 0.72;
      _arenaInitialized = true;
      _spawnEnemies(notify: false);
      return;
    }
    if ((arenaWidth - width).abs() < 0.5 && (arenaHeight - height).abs() < 0.5) return;

    final scaleX = width / arenaWidth;
    final scaleY = height / arenaHeight;
    playerX = (playerX * scaleX).clamp(22.0, max(22.0, width - 22.0)).toDouble();
    playerY = (playerY * scaleY).clamp(105.0, max(105.0, height - 35.0)).toDouble();
    for (final collection in [enemies, arrows, enemyProjectiles, coins, combatEffects, defeatedSprites]) {
      for (final item in collection) {
        final x = item['x'];
        final y = item['y'];
        if (x is num) item['x'] = (x.toDouble() * scaleX).clamp(-20.0, width + 20.0).toDouble();
        if (y is num) item['y'] = (y.toDouble() * scaleY).clamp(-20.0, height + 20.0).toDouble();
      }
    }
    arenaWidth = width;
    arenaHeight = height;
  }

  void _shootArrows() {
    if (enemies.isEmpty) return;

    final origin = CombatPoint(playerX, playerY);
    final targetIndex = nearestTargetIndex(
      origin: origin,
      targets: enemies
          .map((enemy) => CombatPoint(
                enemy['x'] as double,
                enemy['y'] as double,
              ))
          .toList(growable: false),
    );
    if (targetIndex == null) return;
    final target = enemies[targetIndex];

    heroAttackTicks = 12;
    final totalShots = 1 + extraArrows;
    for (int i = 0; i < totalShots; i++) {
      final spread = i == 0 ? 0.0 : (i.isOdd ? 0.20 : -0.20);
      final velocity = aimedProjectileVelocity(
        origin: origin,
        target: CombatPoint(
          target['x'] as double,
          target['y'] as double,
        ),
        speed: 8.5,
        angleOffset: spread,
      );
      arrows.add({
        'x': playerX,
        'y': playerY,
        'vx': velocity.x,
        'vy': velocity.y,
      });
    }
    playRealSound('shoot');
  }

  void _restartShootLoop() {
    shootLoop?.cancel();
    final intervalMs = CombatBalance.shootIntervalMs(attackSpeedMultiplier);
    shootLoop = Timer.periodic(Duration(milliseconds: intervalMs), (_) {
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
      if (isPaused || showMysteryChest || gameOverShown) return;
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
          (shot['x'] as double) < -20 || (shot['x'] as double) > arenaWidth + 20 ||
          (shot['y'] as double) < -20 || (shot['y'] as double) > arenaHeight + 20) {
        enemyProjectiles.removeAt(i);
      }
    }

    // تحريك الأسهم وفحص اصطدامها بالأعداء.
    for (int i = arrows.length - 1; i >= 0; i--) {
      final arrow = arrows[i];
      arrow['x'] = (arrow['x'] as double) + (arrow['vx'] as double);
      arrow['y'] = (arrow['y'] as double) + (arrow['vy'] as double);

      if ((arrow['x'] as double) < -20 ||
          (arrow['x'] as double) > arenaWidth + 20 ||
          (arrow['y'] as double) < -20 ||
          (arrow['y'] as double) > arenaHeight + 20) {
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
          final isCritical = random.nextDouble() < criticalChance;
          final arrowDamage = CombatBalance.arrowDamage(
            baseDamage: 35,
            attackMultiplier: attackPowerMultiplier,
            criticalChance: criticalChance,
            roll: isCritical ? 0 : 1,
          );
          enemy['hp'] = (enemy['hp'] as double) - arrowDamage;
          if (isCritical) {
            combatEffects.add({
              'x': enemy['x'],
              'y': enemy['y'],
              'type': 'criticalHit',
              'life': 22,
            });
          }
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
      final bossPhase = type == 'boss'
          ? BossCombat.phaseForHealth(
              hp: enemy['hp'] as double,
              maxHp: enemy['maxHp'] as double,
            )
          : 1;
      final bossConfig = BossCombat.configForPhase(bossPhase);
      final previousBossPhase = (enemy['bossPhase'] as int?) ?? 1;
      final bossEnraged = bossPhase == 3;
      if (type == 'boss' && bossPhase != previousBossPhase) {
        enemy['bossPhase'] = bossPhase;
        combatEffects.add({
          'x': enemy['x'], 'y': enemy['y'],
          'type': 'bossBurst', 'life': 30,
        });
      }
      var bossVolleyCooldown =
          (enemy['bossVolleyCooldown'] as int?) ?? 90;
      if (type == 'boss' && bossPhase >= 2) {
        if (bossVolleyCooldown > 0) bossVolleyCooldown--;
        if (bossVolleyCooldown == 0 && distance <= 320) {
          final baseAngle = atan2(dy, dx);
          final count = bossConfig.volleyCount;
          for (var shotIndex = 0; shotIndex < count; shotIndex++) {
            final spread = count == 1
                ? 0.0
                : (shotIndex / (count - 1) - 0.5) * 0.78;
            final shotAngle = baseAngle + spread;
            enemyProjectiles.add({
              'x': enemy['x'], 'y': enemy['y'],
              'vx': cos(shotAngle) * bossConfig.projectileSpeed,
              'vy': sin(shotAngle) * bossConfig.projectileSpeed,
              'damage': bossConfig.projectileDamage,
              'life': 115,
            });
          }
          bossVolleyCooldown = bossConfig.volleyCooldownTicks;
          combatEffects.add({
            'x': enemy['x'], 'y': enemy['y'],
            'type': 'bossTell', 'life': 16,
          });
        }
      }
      enemy['bossVolleyCooldown'] = bossVolleyCooldown;
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
          moveSpeed *= (bossEnraged ? 3.15 : 2.65) *
              bossConfig.movementMultiplier;
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
      if (sqrt(dx * dx + dy * dy) < coinPickupRadius) {
        globalCoins +=
            (10 * WorldRules.forStage(stage).coinRewardMultiplier).round();
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

    final advance = StageFlow.complete(stage);
    stage = advance.nextStage;
    bestStage = max(bestStage, stage);
    playerHp = min(playerMaxHp, playerHp + 35);
    saveProgress();

    if (advance.reward == StageRewardType.mysteryChest) {
      setState(() => showMysteryChest = true);
      playRealSound('special');
    } else {
      _showPerksDialog();
    }
  }

  Future<void> _showPerksDialog() async {
    if (!mounted || gameOverShown) return;
    setState(() => isPaused = true);

    final offers = SkillSystem.rollOffers(
      stage: stage,
      random: random,
    );
    final choice = await showDialog<SkillId>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          '✨ اختر مهارة للمرحلة القادمة',
          style: TextStyle(color: Colors.amber),
        ),
        content: const Text(
          'كل ترقية تمنحك ميزة تستمر خلال هذه الجولة. '
          'تزداد فرصة ظهور المهارات النادرة مع تقدمك.',
        ),
        actions: offers.map((skill) {
          final rarityLabel = switch (skill.rarity) {
            SkillRarity.common => 'عادية',
            SkillRarity.rare => 'نادرة',
            SkillRarity.epic => 'ملحمية',
          };
          final rarityColor = switch (skill.rarity) {
            SkillRarity.common => Colors.white70,
            SkillRarity.rare => Colors.lightBlueAccent,
            SkillRarity.epic => Colors.purpleAccent,
          };
          return TextButton(
            onPressed: () => Navigator.pop(dialogContext, skill.id),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(skill.title),
                Text(
                  '$rarityLabel · ${skill.description}',
                  style: TextStyle(color: rarityColor, fontSize: 11),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );

    if (!mounted || gameOverShown) return;
    setState(() {
      switch (choice) {
        case SkillId.extraArrow:
          extraArrows++;
        case SkillId.attackPower:
          attackPowerMultiplier += 0.25;
        case SkillId.healing:
          playerHp = min(playerMaxHp, playerHp + 55);
        case SkillId.vitality:
          playerMaxHp += 25;
          playerHp = min(playerMaxHp, playerHp + 25);
        case SkillId.frostAura:
          enemySpeedMultiplier *= 0.9;
        case SkillId.coinMagnet:
          coinPickupRadius *= 1.45;
        case SkillId.criticalStrike:
          criticalChance = (criticalChance + 0.15).clamp(0.0, 0.75).toDouble();
        case SkillId.swiftHands:
          attackSpeedMultiplier = (attackSpeedMultiplier * 1.18).clamp(1.0, 2.2).toDouble();
          _restartShootLoop();
        case null:
          break;
      }
      isPaused = false;
      stageTransitioning = false;
    });
    _spawnEnemies();
  }

  void _collectChest() {
    setState(() {
      globalCoins += (75 * WorldRules.forStage(max(1, stage - 1)).coinRewardMultiplier).round();
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
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => GameScreen(
                    heroType: widget.heroType,
                    initialStage: stage,
                  ),
                ),
              );
            },
            child: const Text('إعادة المحاولة'),
          ),
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed ||
        !mounted ||
        isPaused ||
        gameOverShown ||
        showMysteryChest) {
      return;
    }
    // Never let combat continue behind another app or a system interruption.
    setState(() => isPaused = true);
  }

  void _togglePause() {
    if (showMysteryChest || gameOverShown) return;
    setState(() => isPaused = !isPaused);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
            _syncArenaSize(width, height);

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

class EnemyAuraPainter extends CustomPainter {
  final String type;
  final double phase;
  final bool attacking;
  final bool hit;
  const EnemyAuraPainter({required this.type, required this.phase, required this.attacking, required this.hit});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final pulse = .5 + sin(phase * (type == 'runner' ? 2.2 : 1.25)) * .5;
    final color = switch (type) {
      'ranged' => const Color(0xFF55E8FF),
      'runner' => const Color(0xFFFFA33B),
      'tank' => const Color(0xFF75C8D8),
      'stalker' => const Color(0xFFB77AFF),
      _ => const Color(0xFFFF5B62),
    };
    final radius = size.shortestSide * (type == 'tank' ? .39 : .35);
    final glow = Paint()
      ..color = color.withOpacity(hit ? .42 : attacking ? .28 : .13 + pulse * .07)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(c, radius, glow);
    final ring = Paint()
      ..color = color.withOpacity(attacking ? .9 : .32 + pulse * .2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = type == 'tank' ? 2.6 : 1.5;
    canvas.drawCircle(c, radius * (1 + pulse * .055), ring);
    if (type == 'stalker' || type == 'runner' || type == 'ranged') {
      for (var i = 0; i < 3; i++) {
        final a = phase * (type == 'runner' ? 2.8 : type == 'ranged' ? 1.15 : .65) + i * 2 * pi / 3;
        final p = c + Offset(cos(a) * radius * 1.12, sin(a) * radius * .72);
        if (type == 'ranged') {
          final shard = Path()..moveTo(p.dx, p.dy - 3.5)..lineTo(p.dx + 2.5, p.dy)..lineTo(p.dx, p.dy + 3.5)..lineTo(p.dx - 2.5, p.dy)..close();
          canvas.drawPath(shard, Paint()..color = color.withOpacity(.9));
        } else {
          canvas.drawCircle(p, attacking ? 2.7 : 1.7, Paint()..color = color.withOpacity(.85));
        }
      }
    } else if (type == 'tank') {
      for (var i = 0; i < 4; i++) {
        final a = i * pi / 2 + pi / 4;
        final p = c + Offset(cos(a) * radius * 1.04, sin(a) * radius * 1.04);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: p, width: 5, height: 5), const Radius.circular(1)), Paint()..color = color.withOpacity(.8));
      }
    }
  }

  @override
  bool shouldRepaint(covariant EnemyAuraPainter old) =>
      old.type != type || old.phase != phase || old.attacking != attacking || old.hit != hit;
}

class BossAuraPainter extends CustomPainter {
  final double phase;
  final bool attacking;
  const BossAuraPainter({required this.phase, required this.attacking});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final pulse = .5 + sin(phase) * .5;
    final radius = size.shortestSide * (.39 + pulse * .035);
    final glow = Paint()
      ..color = const Color(0xFFFF6B39).withOpacity(attacking ? .3 : .16)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9);
    canvas.drawCircle(center, radius, glow);
    final ring = Paint()
      ..color = const Color(0xFFFFB45B).withOpacity(attacking ? .85 : .42)
      ..style = PaintingStyle.stroke
      ..strokeWidth = attacking ? 2.5 : 1.4;
    canvas.drawCircle(center, radius * (1 + pulse * .08), ring);
    final innerRing = Paint()
      ..color = const Color(0xFFFFD98B).withOpacity(attacking ? .62 : .24)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius * .72, innerRing);
    // Four rotating ember sigils make the boss silhouette readable even in a crowded fight.
    for (var i = 0; i < 4; i++) {
      final angle = phase * (attacking ? 1.8 : .7) + i * pi / 2;
      final direction = Offset(cos(angle), sin(angle));
      final point = center + direction * radius;
      canvas.save();
      canvas.translate(point.dx, point.dy);
      canvas.rotate(angle + pi / 4);
      final sigil = Path()
        ..moveTo(0, -5)..lineTo(3.5, 0)..lineTo(0, 5)..lineTo(-3.5, 0)..close();
      canvas.drawPath(sigil, Paint()..color = const Color(0xFFFFD98B).withOpacity(.95));
      canvas.restore();
      canvas.drawCircle(point, attacking ? 4 : 2.5,
        Paint()..color = const Color(0xFFFF7B43).withOpacity(.7));
    }
    if (attacking) {
      final arc = Paint()
        ..color = const Color(0xFFFF7448).withOpacity(.72)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius * 1.18),
          phase * 1.4, pi * 1.25, false, arc);
    }
  }

  @override
  bool shouldRepaint(covariant BossAuraPainter oldDelegate) =>
      oldDelegate.phase != phase || oldDelegate.attacking != attacking;
}

class RangedProjectilePainter extends CustomPainter {
  const RangedProjectilePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final glow = Paint()
      ..color = const Color(0xFF42DFFF).withOpacity(.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
    canvas.drawCircle(center, 8, glow);
    final outer = Paint()
      ..color = const Color(0xFF8AF3FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawCircle(center, 7, outer);
    final crystal = Path()
      ..moveTo(center.dx, 1)
      ..lineTo(size.width - 3, center.dy)
      ..lineTo(center.dx, size.height - 1)
      ..lineTo(3, center.dy)
      ..close();
    canvas.drawPath(crystal, Paint()..color = const Color(0xFF24C8F2));
    canvas.drawCircle(center, 2.3, Paint()..color = Colors.white);
    final trail = Paint()
      ..color = const Color(0xFF72EFFF).withOpacity(.8)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(1, center.dy), Offset(5, center.dy), trail);
    canvas.drawLine(Offset(center.dx, 1), Offset(center.dx, 4), trail);
  }

  @override
  bool shouldRepaint(covariant RangedProjectilePainter oldDelegate) => false;
}

class ArrowSpritePainter extends CustomPainter {
  const ArrowSpritePainter();
  @override
  void paint(Canvas canvas, Size size) {
    final shaft = Paint()..color = const Color(0xFFFFE5A0)..strokeWidth = 2.4..strokeCap = StrokeCap.round;
    final glow = Paint()..color = const Color(0xFFFFA52F).withOpacity(.45)..strokeWidth = 6..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawLine(const Offset(2, 6), const Offset(21, 6), glow);
    canvas.drawLine(const Offset(2, 6), const Offset(21, 6), shaft);
    final head = Path()..moveTo(24, 6)..lineTo(16, 1)..lineTo(17, 6)..lineTo(16, 11)..close();
    canvas.drawPath(head, Paint()..color = const Color(0xFFFFA52F));
    canvas.drawLine(const Offset(5, 6), const Offset(1, 2), shaft);
    canvas.drawLine(const Offset(5, 6), const Offset(1, 10), shaft);
  }
  @override
  bool shouldRepaint(covariant ArrowSpritePainter oldDelegate) => false;
}

class CombatEffectPainter extends CustomPainter {
  final String type;
  final double progress;
  const CombatEffectPainter({required this.type, required this.progress});
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final boss = type == 'bossBurst' || type == 'bossHit' || type == 'bossTell';
    final impact = type == 'impact' || type.endsWith('Hit') || type == 'enemyAttack';
    final playerHit = type == 'playerHit';
    final telegraph = type == 'bossTell';
    final metal = type == 'metalHit';
    final shadow = type == 'shadowHit';
    final radius = size.width * (.12 + progress * (impact ? .30 : .43));
    final color = switch (type) {
      'bossBurst' || 'bossHit' || 'bossTell' => const Color(0xFFFF642F),
      'playerHit' => const Color(0xFFFF365D),
      'metalHit' => const Color(0xFFB9D5E8),
      'shadowHit' => const Color(0xFFB66BFF),
      'sparkHit' => const Color(0xFFFFC04D),
      'rangedShot' => const Color(0xFF55E8FF),
      'enemyAttack' => const Color(0xFFFF7043),
      'impact' => const Color(0xFFFFE58A),
      _ => const Color(0xFF8DDAFF),
    };
    final glow = Paint()..color = color.withOpacity((1 - progress) * .45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(center, radius, glow);
    final ring = Paint()..color = color.withOpacity(1 - progress)
      ..style = PaintingStyle.stroke..strokeWidth = boss ? 4 : 2.5;
    if (telegraph) {
      final warning = Paint()..color = color.withOpacity((1 - progress) * .85)
        ..style = PaintingStyle.stroke..strokeWidth = 4..strokeCap = StrokeCap.round;
      canvas.drawCircle(center, radius * (0.55 + progress * .45), warning);
      canvas.drawCircle(center, radius * .72, warning..strokeWidth = 2);
    } else if (playerHit) {
      final slash = Paint()..color = color.withOpacity(1 - progress)
        ..strokeWidth = 4..strokeCap = StrokeCap.round;
      canvas.drawLine(center + Offset(-radius, -radius * .55),
        center + Offset(radius, radius * .55), slash);
      canvas.drawLine(center + Offset(radius * .7, -radius * .7),
        center + Offset(-radius * .7, radius * .7), slash);
      final sparks = Paint()..color = const Color(0xFFFFC3D0).withOpacity(1 - progress)
        ..strokeWidth = 2.2..strokeCap = StrokeCap.round;
      for (var i = 0; i < 6; i++) {
        final angle = i * pi / 3 + progress * 1.8;
        final start = center + Offset(cos(angle) * radius * .35, sin(angle) * radius * .35);
        final end = center + Offset(cos(angle) * radius * .72, sin(angle) * radius * .72);
        canvas.drawLine(start, end, sparks);
      }
    } else if (shadow || metal) {
      // ضربات مميزة: شقوق ظل بنفسجية أو شرارات معدنية باردة.
      final slashPaint = Paint()
        ..color = color.withOpacity(1 - progress)
        ..style = PaintingStyle.stroke
        ..strokeWidth = metal ? 3.2 : 5.0
        ..strokeCap = StrokeCap.round;
      for (var i = 0; i < (shadow ? 3 : 5); i++) {
        final offset = (i - (shadow ? 1 : 2)) * (metal ? 7.0 : 9.0);
        final start = center + Offset(-radius * .58 + offset, radius * .42);
        final end = center + Offset(radius * .48 + offset, -radius * .48);
        canvas.drawLine(start, end, slashPaint);
      }
      if (shadow) {
        final crescent = Rect.fromCircle(center: center, radius: radius * .72);
        canvas.drawArc(crescent, -pi * .82 + progress, pi * .92, false,
          Paint()..color = color.withOpacity((1 - progress) * .9)
            ..style = PaintingStyle.stroke..strokeWidth = 3.5);
      } else {
        final glint = Paint()..color = const Color(0xFFEAF8FF).withOpacity(1 - progress)
          ..strokeWidth = 2..strokeCap = StrokeCap.round;
        for (var i = 0; i < 4; i++) {
          final a = i * pi / 2 + progress;
          final p = center + Offset(cos(a) * radius * .7, sin(a) * radius * .7);
          canvas.drawLine(p + Offset(-3, -3), p + Offset(3, 3), glint);
        }
      }
    } else if (type == 'defeat') {
      final burst = Paint()..color = const Color(0xFFFFD36B).withOpacity(1 - progress)
        ..strokeWidth = 2.4..strokeCap = StrokeCap.round;
      for (var i = 0; i < 10; i++) {
        final angle = i * pi / 5 + progress * .8;
        final inner = radius * (.25 + progress * .18);
        final outer = radius * (.55 + progress * .5);
        canvas.drawLine(
          center + Offset(cos(angle) * inner, sin(angle) * inner),
          center + Offset(cos(angle) * outer, sin(angle) * outer), burst);
      }
    } else if (type == 'enemyAttack') {
      final arc = Rect.fromCircle(center: center, radius: radius);
      canvas.drawArc(arc, -pi * .75, pi * .5, false,
        Paint()..color = color.withOpacity(1 - progress)
          ..style = PaintingStyle.stroke..strokeWidth = 5..strokeCap = StrokeCap.round);
    } else {
      canvas.drawCircle(center, radius, ring);
    }
    for (var i = 0; i < 8; i++) {
      final angle = i * pi / 4 + progress * 1.7;
      final inner = radius * .45;
      final outer = radius * (1.0 + (i.isEven ? .22 : -.08));
      canvas.drawLine(
        center + Offset(cos(angle) * inner, sin(angle) * inner),
        center + Offset(cos(angle) * outer, sin(angle) * outer),
        Paint()..color = const Color(0xFFFFE7A1).withOpacity(1 - progress)
          ..strokeWidth = boss ? 3 : 2
          ..strokeCap = StrokeCap.round,
      );
    }
  }
  @override
  bool shouldRepaint(covariant CombatEffectPainter oldDelegate) =>
      oldDelegate.type != type || oldDelegate.progress != progress;
}

// -----------------------------------------------------------------------------
// شخصيات قتالية مرسومة بأسلوب كرتوني أصلي (بدون أشكال دائرية أو أيقونات)
// -----------------------------------------------------------------------------
class FighterSpritePainter extends CustomPainter {
  final String kind;
  final Color tint;
  final int variant;
  final double phase;
  final bool attacking;
  final bool hitFlash;
  const FighterSpritePainter({required this.kind, required this.tint, this.variant = 0, this.phase = 0, this.attacking = false, this.hitFlash = false});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / 64;
    canvas.save();
    canvas.scale(scale);
    canvas.translate(0, sin(phase * 2) * 1.15);
    final boss = kind == 'boss';
    final tank = kind == 'tank';
    final runner = kind == 'runner';
    final stalker = kind == 'stalker';
    final hero = kind == 'hero';
    final dark = Paint()..color = const Color(0xFF171525);
    if (hitFlash) {
      canvas.drawCircle(const Offset(32, 32), 29,
        Paint()..color = Colors.white.withOpacity(.42)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
    }
    final heroArmor = switch (variant) {
      2 => const Color(0xFF71301F),
      3 => const Color(0xFF30234F),
      4 => const Color(0xFF164D55),
      _ => const Color(0xFF243C69),
    };
    final heroMetal = switch (variant) {
      2 => const Color(0xFFFF9A43),
      3 => const Color(0xFFB58CFF),
      4 => const Color(0xFF63F4DF),
      _ => const Color(0xFFFFD36B),
    };
    final armor = Paint()..color = hero ? heroArmor : Color.lerp(tint, Colors.black, 0.28)!;
    final light = Paint()..color = hero ? heroMetal : Color.lerp(tint, Colors.white, 0.38)!;
    final skin = Paint()..color = hero ? const Color(0xFFFFD5B2) : (boss ? const Color(0xFF6D244F) : const Color(0xFF83A84A));
    final cape = Paint()..color = hero ? (variant == 3 ? const Color(0xFF35204F) : variant == 4 ? const Color(0xFF12645E) : variant == 2 ? const Color(0xFF9A351E) : const Color(0xFFE33E35)) : (stalker ? const Color(0xFF39265F) : Color.lerp(tint, Colors.black, 0.48)!);
    final breathe = 1 + sin(phase * 2) * 0.018;

    // ظل أرضي يعطي الشخصية عمقاً.
    canvas.drawOval(const Rect.fromLTWH(10, 54, 44, 8),
        Paint()..color = Colors.black.withOpacity(0.30));
    // هالة وقرون خاصة بالزعيم.
    if (boss) {
      final pulse = .13 + (sin(phase * 2.4) + 1) * .055;
      canvas.drawCircle(const Offset(32, 32), 30 + sin(phase * 2) * 1.8,
        Paint()..color = const Color(0xFFFF542E).withOpacity(pulse)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
      canvas.drawCircle(const Offset(32, 32), 27 + sin(phase * 2) * 1.2,
        Paint()..color = const Color(0xFFFF9B45).withOpacity(.5)
          ..style = PaintingStyle.stroke..strokeWidth = 1.3);
      final horns = Path()
        ..moveTo(22, 13)..lineTo(7, -2)..lineTo(13, 20)..close()
        ..moveTo(42, 13)..lineTo(57, -2)..lineTo(51, 20)..close();
      canvas.drawPath(horns, Paint()..color = const Color(0xFFFF6A35));
      canvas.drawPath(horns, Paint()..color = const Color(0xFFFFD16B)
        ..style = PaintingStyle.stroke..strokeWidth = 1.5);
    }
    // عباءة/أجنحة خلف الجسم.
    final cloak = Path()
      ..moveTo(19, 23)..quadraticBezierTo(2, 35, 12, 57)
      ..lineTo(30, 48)..lineTo(45, 58)
      ..quadraticBezierTo(62, 34, 44, 22)..close();
    canvas.drawPath(cloak, cape);
    if (boss || stalker) {
      final wing = Path()
        ..moveTo(17, 27)..lineTo(1, 12)..lineTo(5, 38)..lineTo(20, 43)..close();
      canvas.drawPath(wing, Paint()..color = Color.lerp(tint, Colors.black, 0.28)!);
      canvas.save();
      canvas.translate(64, 0);
      canvas.scale(-1, 1);
      canvas.drawPath(wing, Paint()..color = Color.lerp(tint, Colors.black, 0.28)!);
      canvas.restore();
    }
    // الساقان والحذاء.
    final leg = Paint()..color = const Color(0xFF30283A);
    final stride = sin(phase) * (boss ? 2.0 : 3.0);
    canvas.save();
    canvas.translate(25, 43);
    canvas.rotate(stride * 0.035);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-5, 0, 10, 13), const Radius.circular(4)), leg);
    canvas.drawOval(const Rect.fromLTWH(-9, 8, 17, 7), dark);
    canvas.restore();
    canvas.save();
    canvas.translate(40, 43);
    canvas.rotate(-stride * 0.035);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-5, 0, 10, 13), const Radius.circular(4)), leg);
    canvas.drawOval(const Rect.fromLTWH(-8, 8, 17, 7), dark);
    canvas.restore();
    // دروع كتف ثقيلة للدبابة.
    if (tank) {
      final plate = Paint()..color = const Color(0xFF8796A3);
      final plateEdge = Paint()..color = const Color(0xFFD4E0E8)
        ..style = PaintingStyle.stroke..strokeWidth = 1.2;
      final leftPlate = RRect.fromRectAndRadius(
        const Rect.fromLTWH(7, 25, 17, 15), const Radius.circular(5));
      final rightPlate = RRect.fromRectAndRadius(
        const Rect.fromLTWH(40, 25, 17, 15), const Radius.circular(5));
      canvas.drawRRect(leftPlate, plate);
      canvas.drawRRect(rightPlate, plate);
      canvas.drawRRect(leftPlate, plateEdge);
      canvas.drawRRect(rightPlate, plateEdge);
      canvas.drawCircle(const Offset(15, 32), 3, light);
      canvas.drawCircle(const Offset(49, 32), 3, light);
      canvas.drawLine(const Offset(13, 28), const Offset(19, 36), plateEdge);
      canvas.drawLine(const Offset(43, 28), const Offset(49, 36), plateEdge);
    }
    // غطاء رأس وظلال مضيئة للمتخفي.
    if (stalker) {
      final hood = Path()
        ..moveTo(17, 20)..quadraticBezierTo(15, -2, 32, 0)
        ..quadraticBezierTo(50, -2, 47, 20)
        ..lineTo(42, 27)..lineTo(22, 27)..close();
      canvas.drawPath(hood, Paint()..color = const Color(0xFF241C3D));
      canvas.drawPath(hood, Paint()..color = const Color(0xFF9B6BCE).withOpacity(.7)
        ..style = PaintingStyle.stroke..strokeWidth = 1.2);
      canvas.drawOval(const Rect.fromLTWH(22, 16, 20, 7),
        Paint()..color = const Color(0xFFFF4CF0));
      canvas.drawCircle(const Offset(32, 20), 5,
        Paint()..color = const Color(0xFFFF4CF0).withOpacity(.16)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
    }
    if (runner) {
      final crest = Path()
        ..moveTo(23, 8)..lineTo(27, -2)..lineTo(31, 8)
        ..lineTo(37, -2)..lineTo(41, 9)..close();
      canvas.drawPath(crest, Paint()..color = const Color(0xFFFFD15C));
      final speedMark = Paint()..color = const Color(0xFFFFD15C).withOpacity(.8)
        ..strokeWidth = 2..strokeCap = StrokeCap.round;
      canvas.drawLine(const Offset(7, 44), const Offset(15, 41), speedMark);
      canvas.drawLine(const Offset(5, 49), const Offset(13, 46), speedMark);
    }
    // الجسم والدرع.
    final body = Path()
      ..moveTo(19, 25)..quadraticBezierTo(32, 18, 45, 25)
      ..lineTo(48, 46)..quadraticBezierTo(32, 53, 16, 46)..close();
    canvas.save();
    canvas.translate(32, 36);
    canvas.scale(1, breathe);
    canvas.translate(-32, -36);
    canvas.drawPath(body, armor);
    // حواف معدنية ولمعات تعطي الدرع طبقات وعمقاً بصرياً.
    final armorEdge = Paint()
      ..color = light.color.withOpacity(.72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.35;
    canvas.drawPath(body, armorEdge);
    final chestPlate = Path()
      ..moveTo(22, 27)..lineTo(32, 30)..lineTo(42, 27)
      ..lineTo(39, 43)..lineTo(32, 47)..lineTo(25, 43)..close();
    canvas.drawPath(chestPlate, Paint()..color = Colors.black.withOpacity(.16));
    canvas.drawPath(chestPlate, Paint()
      ..color = light.color.withOpacity(.55)
      ..style = PaintingStyle.stroke..strokeWidth = 1.1);
    canvas.drawLine(const Offset(23, 29), const Offset(19, 42),
      Paint()..color = Colors.white.withOpacity(.28)..strokeWidth = 2);
    // حزام ومشبك مركزي.
    canvas.drawRRect(RRect.fromRectAndRadius(
      const Rect.fromLTWH(19, 43, 26, 4), const Radius.circular(2)),
      Paint()..color = const Color(0xFF392A32));
    canvas.drawRRect(RRect.fromRectAndRadius(
      const Rect.fromLTWH(29, 42, 7, 6), const Radius.circular(1.5)),
      Paint()..color = const Color(0xFFFFD36B));
    canvas.drawPath(Path()..moveTo(32, 27)..lineTo(42, 31)..lineTo(39, 45)..lineTo(32, 48)..close(), light);
    canvas.drawCircle(const Offset(32, 37), 4, Paint()..color = hero ? const Color(0xFF54DDF5) : Color.lerp(tint, Colors.white, 0.55)!);
    if (hero) {
      canvas.drawCircle(const Offset(32, 37), 7 + sin(phase * 2) * 1.2, Paint()..color = const Color(0xFF54DDF5).withOpacity(.10 + (sin(phase * 2) + 1) * .035)..style = PaintingStyle.stroke..strokeWidth = 1.4);
    }
    // نقاط ضوء صغيرة على الدرع.
    canvas.drawCircle(const Offset(23, 31), 1.5, Paint()..color = Colors.white.withOpacity(.7));
    canvas.drawCircle(const Offset(41, 31), 1.5, Paint()..color = Colors.white.withOpacity(.7));
    canvas.restore();
    // الذراعان.
    canvas.save();
    canvas.translate(16, 31);
    canvas.rotate(attacking ? -0.72 : sin(phase) * 0.12);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-5, -3, 11, 19), const Radius.circular(5)), skin);
    canvas.drawCircle(const Offset(0, 15), 5, light);
    canvas.restore();
    canvas.save();
    canvas.translate(48, 31);
    canvas.rotate(attacking ? 0.95 : -sin(phase) * 0.12);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-5, -3, 11, 19), const Radius.circular(5)), skin);
    canvas.drawCircle(const Offset(0, 15), 5, light);
    canvas.restore();
    // الرأس والملامح.
    canvas.drawOval(const Rect.fromLTWH(19, 3, 26, 28), skin);
    canvas.drawOval(const Rect.fromLTWH(21, 4, 23, 11), hero ? (Paint()..color = const Color(0xFFE9F2FF)) : dark);
    if (!hero) {
      final horn = Path()..moveTo(23, 9)..lineTo(15, 0)..lineTo(19, 15)..close();
      canvas.drawPath(horn, light);
      canvas.save(); canvas.translate(64, 0); canvas.scale(-1, 1);
      canvas.drawPath(horn, light); canvas.restore();
    } else {
      final hair = Path()..moveTo(19, 16)..lineTo(13, 3)..lineTo(28, 8)..lineTo(39, 1)..lineTo(45, 14)..close();
      canvas.drawPath(hair, Paint()..color = const Color(0xFFFFC84A));
      canvas.drawPath(Path()..moveTo(20, 14)..quadraticBezierTo(30, 3, 43, 13), Paint()..color = const Color(0xFFFFE18A)..style = PaintingStyle.stroke..strokeWidth = 2.2..strokeCap = StrokeCap.round);
      final scarf = Path()..moveTo(19, 28)..lineTo(43, 27)..lineTo(57, 43)..lineTo(42, 39)..lineTo(32, 34)..close();
      canvas.drawPath(scarf, Paint()..color = const Color(0xFFE43B35));
      if (variant == 2) {
        final flame = Path()
          ..moveTo(18, 31)..quadraticBezierTo(4, 18, 18, 11)
          ..quadraticBezierTo(16, 25, 27, 27)..close();
        canvas.drawPath(flame, Paint()..color = const Color(0xFFFF762B));
      } else if (variant == 3) {
        canvas.drawPath(Path()..moveTo(18, 8)..lineTo(9, 1)..lineTo(14, 17)..close(),
          Paint()..color = const Color(0xFF9B73FF));
        canvas.drawPath(Path()..moveTo(44, 8)..lineTo(55, 1)..lineTo(49, 17)..close(),
          Paint()..color = const Color(0xFF9B73FF));
      } else if (variant == 4) {
        canvas.drawCircle(const Offset(32, 37), 9,
          Paint()..color = const Color(0xFF45E8D0).withOpacity(.28)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
      }
      // شارة كتف وهوية لونية مستقلة لكل بطل.
      final crestColor = Paint()..color = variant == 2
          ? const Color(0xFFFF8B35)
          : variant == 3 ? const Color(0xFFB58CFF)
          : variant == 4 ? const Color(0xFF62F2DE)
          : const Color(0xFFFFD36B);
      canvas.drawRRect(RRect.fromRectAndRadius(
        const Rect.fromLTWH(16, 34, 7, 11), const Radius.circular(2)), crestColor);
      canvas.drawRRect(RRect.fromRectAndRadius(
        const Rect.fromLTWH(41, 34, 7, 11), const Radius.circular(2)), crestColor);
    }
    final eyeGlow = Paint()
      ..color = (stalker || boss ? const Color(0xFFFF4CF0) : const Color(0xFF8DEBFF)).withOpacity(.32)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(const Offset(26, 19), 4, eyeGlow);
    canvas.drawCircle(const Offset(38, 19), 4, eyeGlow);
    final eye = Paint()..color = const Color(0xFF171525);
    canvas.drawOval(Rect.fromCenter(center: const Offset(26, 19), width: 3.2, height: 2.8), eye);
    canvas.drawOval(Rect.fromCenter(center: const Offset(38, 19), width: 3.2, height: 2.8), eye);
    canvas.drawCircle(const Offset(25.5, 18.5), .7, Paint()..color = Colors.white);
    canvas.drawCircle(const Offset(37.5, 18.5), .7, Paint()..color = Colors.white);
    canvas.drawArc(const Rect.fromLTWH(27, 21, 10, 5), 0, 3.14, false,
        Paint()..color = const Color(0xFF552D35)..strokeWidth = 1.5..style = PaintingStyle.stroke);
    // سلاح صغير واضح للشخصية.
    final weapon = Paint()..color = const Color(0xFFFFD76A)..strokeWidth = 3..strokeCap = StrokeCap.round;
    if (attacking) {
      final slash = Paint()..color = Colors.white.withOpacity(.82)
        ..style = PaintingStyle.stroke..strokeWidth = 3.2..strokeCap = StrokeCap.round;
      canvas.drawArc(const Rect.fromLTWH(35, 3, 34, 34), -1.1, 1.45, false, slash);
    }
    if (hero || runner) {
      canvas.drawLine(const Offset(49, 38), const Offset(57, 13), weapon);
      canvas.drawLine(const Offset(57, 13), const Offset(61, 22), weapon);
      canvas.drawLine(const Offset(57, 13), const Offset(51, 19), weapon);
    } else {
      canvas.drawLine(const Offset(50, 43), const Offset(59, 21), weapon);
      canvas.drawLine(const Offset(59, 21), const Offset(55, 24), weapon);
      canvas.drawLine(const Offset(59, 21), const Offset(62, 27), weapon);
    }
    if (boss || tank) {
      canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(7, 27, 50, 24), const Radius.circular(9)),
          Paint()..color = tint.withOpacity(0.18)..style = PaintingStyle.stroke..strokeWidth = 2);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant FighterSpritePainter oldDelegate) =>
      oldDelegate.kind != kind || oldDelegate.tint != tint || oldDelegate.variant != variant || oldDelegate.phase != phase || oldDelegate.attacking != attacking || oldDelegate.hitFlash != hitFlash;
}

// -----------------------------------------------------------------------------
// رسم أرضية ساحة القتال
// -----------------------------------------------------------------------------

class ArenaPainter extends CustomPainter {
  ArenaPainter({
    this.theme = WorldTheme.forest,
    this.animation,
  }) : super(repaint: animation);

  final WorldTheme theme;
  final Animation<double>? animation;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [theme.topColor, theme.midColor, theme.bottomColor],
      ).createShader(rect));

    // Outer mossy stone walls and corner towers.
    final wall = Paint()..color = const Color(0xFF59616A);
    final wallDark = Paint()..color = const Color(0xFF303D43);
    final moss = Paint()..color = theme.groundColor;
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(5, 72, size.width - 10, size.height - 80),
      const Radius.circular(24)), wallDark);
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(12, 80, size.width - 24, size.height - 96),
      const Radius.circular(20)), moss);

    // Irregular stone courtyard tiles.
    final tile = Paint()..color = theme.tileColor;
    final tileEdge = Paint()..color = const Color(0xFF46584D)
      ..style = PaintingStyle.stroke..strokeWidth = 1.4;
    const tileW = 54.0, tileH = 38.0;
    for (var row = 0; row < (size.height / tileH).ceil(); row++) {
      for (var col = 0; col < (size.width / tileW).ceil(); col++) {
        final x = col * tileW + (row.isOdd ? 14 : 0);
        final y = 82 + row * tileH;
        if (x > size.width - 14 || y > size.height - 8) continue;
        final r = Rect.fromLTWH(x + 2, y + 2, tileW - 5, tileH - 5);
        final path = Path()
          ..moveTo(r.left + 5, r.top)
          ..lineTo(r.right - 7, r.top + 1)
          ..lineTo(r.right, r.top + 8)
          ..lineTo(r.right - 3, r.bottom - 5)
          ..lineTo(r.left + 7, r.bottom)
          ..lineTo(r.left, r.bottom - 8)..close();
        canvas.drawPath(path, tile);
        canvas.drawPath(path, tileEdge);
      }
    }

    // Grass patches, tiny flowers and scattered stones.
    final grass = Paint()..color = theme.vegetationColor;
    final flower = Paint()..color = const Color(0xFFFFC5D7);
    final gold = Paint()..color = const Color(0xFFFFD36B);
    for (var i = 0; i < 34; i++) {
      final x = (i * 73.0 + 19) % size.width;
      final y = 100 + (i * 97.0 + 31) % (size.height - 110);
      canvas.drawOval(Rect.fromCenter(center: Offset(x, y), width: 15, height: 7), grass);
      if (i % 3 == 0) {
        canvas.drawCircle(Offset(x + 3, y - 3), 2.5, flower);
        canvas.drawCircle(Offset(x - 2, y - 4), 2, gold);
      }
    }

    // Decorative stone pillars with warm fire bowls.
    for (final x in [size.width * .12, size.width * .88]) {
      final baseY = size.height * .28;
      canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(x, baseY + 25), width: 48, height: 14),
        const Radius.circular(4)), wallDark);
      canvas.drawRect(Rect.fromCenter(center: Offset(x, baseY), width: 34, height: 42), wall);
      canvas.drawRect(Rect.fromCenter(center: Offset(x, baseY - 22), width: 46, height: 9), wall);
      canvas.drawCircle(Offset(x, baseY - 30), 8, Paint()..color = theme.accentColor
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12));
      final flame = Path()
        ..moveTo(x, baseY - 19)..quadraticBezierTo(x - 14, baseY - 42, x, baseY - 53)
        ..quadraticBezierTo(x + 13, baseY - 37, x, baseY - 19)..close();
      canvas.drawPath(flame, Paint()..color = const Color(0xFFFFB52E));
      canvas.drawPath(flame, Paint()..color = const Color(0xFFFFF0A1)
        ..style = PaintingStyle.stroke..strokeWidth = 1.2);
    }

    // شقوق دقيقة في البلاط تمنح الساحة مظهراً أقدم وأكثر واقعية.
    final crack = Paint()
      ..color = const Color(0xFF263A32).withOpacity(.58)
      ..strokeWidth = 1.25
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 18; i++) {
      final x = (i * 89.0 + 31) % size.width;
      final y = 118 + (i * 113.0 + 17) % (size.height - 135);
      canvas.drawLine(Offset(x, y), Offset(x + 5 + (i % 4) * 2, y + 3 + (i % 3) * 2), crack);
      canvas.drawLine(Offset(x + 5 + (i % 4) * 2, y + 3 + (i % 3) * 2),
          Offset(x + 10 + (i % 5) * 2, y + 1 + (i % 4) * 3), crack);
    }
    // جمرات صغيرة متناثرة قرب المشاعل.
    for (var i = 0; i < 16; i++) {
      final x = (i * 97.0 + 43) % size.width;
      final y = 96 + (i * 71.0 + 29) % (size.height - 110);
      canvas.drawCircle(Offset(x, y), i.isEven ? 1.5 : 1.0,
        Paint()..color = const Color(0xFFFFB34A).withOpacity(.22));
    }

    // Ruined blocks, vines and edge shading.
    for (var i = 0; i < 12; i++) {
      final x = (i * 131.0 + 8) % size.width;
      final y = i.isEven ? 91.0 : size.height - 18;
      final stone = Rect.fromLTWH(x, y, 28 + (i % 3) * 8, 15);
      canvas.drawRRect(RRect.fromRectAndRadius(stone, const Radius.circular(3)), wall);
      canvas.drawLine(Offset(stone.left + 3, stone.top + 4),
        Offset(stone.right - 4, stone.top + 4), Paint()..color = Colors.white.withOpacity(.16)..strokeWidth = 2);
    }

    // Forest-only dressing: layered trunks, leafy crowns and roots stay
    // against the outer rails so the central combat lane remains unobstructed.
    if (theme.id == 1 && size.width > 80 && size.height > 150) {
      final bark = Paint()..color = const Color(0xFF382F27);
      final barkLight = Paint()..color = const Color(0xFF70513A)
        ..strokeWidth = 2.2..strokeCap = StrokeCap.round;
      final deepLeaf = Paint()..color = const Color(0xFF183D2C);
      final leaf = Paint()..color = const Color(0xFF286342);
      final leafLight = Paint()..color = const Color(0xFF4D8950);
      final rootPaint = Paint()..color = const Color(0xFF4C6840)
        ..style = PaintingStyle.stroke..strokeWidth = 4..strokeCap = StrokeCap.round;

      for (final side in [0, 1]) {
        final x = side == 0 ? 17.0 : size.width - 17.0;
        final direction = side == 0 ? 1.0 : -1.0;
        // Two staggered trunks create depth without entering the arena lane.
        for (var layer = 0; layer < 2; layer++) {
          final trunkX = x + direction * (layer == 0 ? 0 : 13);
          final top = 88.0 + layer * 24;
          final bottom = size.height - (layer == 0 ? 34 : 72);
          final trunk = Path()
            ..moveTo(trunkX - 5, top)
            ..quadraticBezierTo(trunkX - 2, (top + bottom) / 2, trunkX - 7, bottom)
            ..lineTo(trunkX + 7, bottom)
            ..quadraticBezierTo(trunkX + 2, (top + bottom) / 2, trunkX + 5, top)
            ..close();
          canvas.drawPath(trunk, bark);
          canvas.drawLine(Offset(trunkX - 1, top + 12),
            Offset(trunkX - 3, bottom - 12), barkLight);
          final roots = Path()
            ..moveTo(trunkX, bottom - 5)
            ..quadraticBezierTo(trunkX - direction * 8, bottom + 1,
                trunkX - direction * 13, bottom + 5)
            ..moveTo(trunkX + direction * 2, bottom - 4)
            ..quadraticBezierTo(trunkX + direction * 10, bottom,
                trunkX + direction * 16, bottom + 3);
          canvas.drawPath(roots, rootPaint);
        }

        // Overlapping leaf clusters form a soft canopy at the top corners.
        for (var i = 0; i < 6; i++) {
          final cx = x + direction * (i % 3) * 11;
          final cy = 87.0 + (i ~/ 3) * 13;
          canvas.drawCircle(Offset(cx, cy), 15 - (i % 2) * 2, deepLeaf);
          canvas.drawCircle(Offset(cx + direction * 3, cy - 3),
              9, i.isEven ? leaf : leafLight);
        }

        // Thin hanging vines and small fern fronds along the side rail.
        final vine = Paint()..color = const Color(0xFF75A653)
          ..style = PaintingStyle.stroke..strokeWidth = 2
          ..strokeCap = StrokeCap.round;
        final vinePath = Path()
          ..moveTo(x + direction * 5, 103)
          ..cubicTo(x - direction * 7, 128, x + direction * 12, 143,
              x + direction * 3, 164);
        canvas.drawPath(vinePath, vine);
        for (var i = 0; i < 4; i++) {
          final fy = 119.0 + i * 10;
          canvas.drawLine(Offset(x + direction * 3, fy),
              Offset(x + direction * (12 + (i % 2) * 3), fy - 6), vine);
          canvas.drawLine(Offset(x + direction * 3, fy),
              Offset(x - direction * 5, fy + 5), vine);
        }

        // Tiny mushrooms and luminous spores near the lower corners.
        final cap = Paint()..color = const Color(0xFFC96A55);
        final stem = Paint()..color = const Color(0xFFE5D8B5);
        final mushroomX = x + direction * 8;
        final mushroomY = size.height - 53.0;
        canvas.drawRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(mushroomX - 2, mushroomY, 4, 9),
          const Radius.circular(2)), stem);
        canvas.drawArc(Rect.fromLTWH(mushroomX - 8, mushroomY - 7, 16, 12),
            3.14, 3.14, true, cap);
        canvas.drawCircle(Offset(x + direction * 23, size.height - 88),
            2.2, Paint()..color = const Color(0xFFB6E878).withOpacity(.65));
        canvas.drawCircle(Offset(x + direction * 29, size.height - 103),
            1.4, Paint()..color = const Color(0xFFD9F6A0).withOpacity(.55));
      }
    }

    if (theme.id == 1 && size.width > 80 && size.height > 150) {
      // Moss-covered stones anchor the forest border and break up the flat wall.
      final stoneFill = Paint()..color = const Color(0xFF52634A);
      final stoneShade = Paint()..color = const Color(0xFF344A39);
      final mossStroke = Paint()..color = const Color(0xFF8AA65A)
        ..style = PaintingStyle.stroke..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round;
      for (var i = 0; i < 5; i++) {
        for (final side in [0, 1]) {
          final x = side == 0 ? 29.0 + (i % 2) * 5 : size.width - 29.0 - (i % 2) * 5;
          final y = 190.0 + i * (size.height - 270).clamp(35.0, 90.0).toDouble();
          final stoneRect = Rect.fromCenter(
            center: Offset(x, y), width: 19 + (i % 3) * 4, height: 12 + (i % 2) * 3);
          canvas.drawOval(stoneRect, stoneShade);
          canvas.drawOval(stoneRect.deflate(2), stoneFill);
          canvas.drawArc(stoneRect.deflate(3), 3.4, 1.25, false, mossStroke);
        }
      }

      // Fern fans and tiny blue flowers decorate the lower side borders.
      final fernPaint = Paint()..color = const Color(0xFF6D9D55)
        ..style = PaintingStyle.stroke..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      final flowerBlue = Paint()..color = const Color(0xFF9BD8D0);
      for (final side in [0, 1]) {
        final direction = side == 0 ? 1.0 : -1.0;
        final base = Offset(side == 0 ? 24 : size.width - 24, size.height - 118);
        canvas.drawLine(base, base.translate(direction * 9, -27), fernPaint);
        for (var leafIndex = 0; leafIndex < 4; leafIndex++) {
          final t = leafIndex / 4;
          final point = Offset(base.dx + direction * 9 * t, base.dy - 27 * t);
          canvas.drawLine(point, point.translate(direction * 10, -5), fernPaint);
          canvas.drawLine(point, point.translate(-direction * 7, -7), fernPaint);
        }
        for (var dot = 0; dot < 3; dot++) {
          final flowerCenter = Offset(
            base.dx + direction * (17 + dot * 5),
            base.dy + 9 + dot * 4);
          canvas.drawCircle(flowerCenter, 2.2, flowerBlue);
          canvas.drawCircle(flowerCenter.translate(0, 0), .8,
              Paint()..color = const Color(0xFFFFE7A0));
        }
      }

      // Fireflies are fixed painter details, softly glowing rather than flashing.
      for (var i = 0; i < 11; i++) {
        final side = i.isEven ? 0 : 1;
        final x = side == 0
            ? 42.0 + (i % 3) * 8
            : size.width - 42.0 - (i % 3) * 8;
        final y = 205.0 + (i * 47.0) % (size.height - 245);
        final glow = Paint()..color = const Color(0xFFDAF69A).withOpacity(.16)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
        canvas.drawCircle(Offset(x, y), 4.5, glow);
        canvas.drawCircle(Offset(x, y), 1.4,
            Paint()..color = const Color(0xFFE6FFB0).withOpacity(.8));
      }
    }

    // Distinct environmental landmarks for the five remaining worlds.
    // All decorations are clipped to narrow side rails, keeping combat clear.
    if (size.width > 100 && size.height > 180 && theme.id >= 2 && theme.id <= 6) {
      for (final side in [0, 1]) {
        final left = side == 0;
        final direction = left ? 1.0 : -1.0;
        final railX = left ? 8.0 : size.width - 8.0;
        if (theme.id == 2) {
          // Volcano: basalt shards and glowing lava seams.
          final basalt = Paint()..color = const Color(0xFF34252A);
          final lava = Paint()..color = const Color(0xFFFF6A24)
            ..style = PaintingStyle.stroke..strokeWidth = 2.2
            ..strokeCap = StrokeCap.round;
          for (var i = 0; i < 6; i++) {
            final y = 132.0 + i * (size.height - 190) / 6;
            final shard = Path()
              ..moveTo(railX, y + 15)
              ..lineTo(railX + direction * 13, y - 5)
              ..lineTo(railX + direction * 25, y + 19)
              ..lineTo(railX + direction * 8, y + 29)..close();
            canvas.drawPath(shard, basalt);
            final seam = Path()
              ..moveTo(railX + direction * 31, y + 22)
              ..lineTo(railX + direction * 9, y + 14)
              ..lineTo(railX + direction * 15, y + 19);
            canvas.drawPath(seam, lava);
            canvas.drawCircle(Offset(railX + direction * 17, y + 4), 2.2,
              Paint()..color = const Color(0xFFFFB52E).withOpacity(.8));
          }
        } else if (theme.id == 3) {
          // Ice kingdom: translucent crystal clusters and frost glints.
          final crystal = Paint()..color = const Color(0xFFBCEEFF).withOpacity(.58);
          final edge = Paint()..color = const Color(0xFFE5FAFF).withOpacity(.8)
            ..style = PaintingStyle.stroke..strokeWidth = 1.2;
          for (var i = 0; i < 5; i++) {
            final x = railX + direction * (8 + (i % 2) * 5);
            final y = 145.0 + i * (size.height - 205) / 5;
            final h = 20.0 + (i % 3) * 7;
            final crystalPath = Path()
              ..moveTo(x, y - h)
              ..lineTo(x + direction * 7, y - 3)
              ..lineTo(x + direction * 3, y + 5)
              ..lineTo(x - direction * 4, y - 2)..close();
            canvas.drawPath(crystalPath, crystal);
            canvas.drawPath(crystalPath, edge);
            canvas.drawCircle(Offset(x + direction * 13, y - h - 3), 2,
              Paint()..color = const Color(0xFFE7FFFF).withOpacity(.85));
          }
        } else if (theme.id == 4) {
          // Desert: layered dunes, sandstone blocks and dry grass.
          final dune = Paint()..color = const Color(0xFFD6B477).withOpacity(.48);
          final duneShade = Paint()..color = const Color(0xFF755334).withOpacity(.45);
          for (var i = 0; i < 4; i++) {
            final y = 165.0 + i * (size.height - 220) / 4;
            final dunePath = Path()
              ..moveTo(railX, y + 25)
              ..quadraticBezierTo(railX + direction * 18, y - 12,
                  railX + direction * 35, y + 18)
              ..lineTo(railX + direction * 35, y + 31)
              ..close();
            canvas.drawPath(dunePath, dune);
            canvas.drawLine(Offset(railX, y + 27),
              Offset(railX + direction * 27, y + 24), duneShade..strokeWidth = 2);
            for (var dot = 0; dot < 3; dot++) {
              canvas.drawCircle(Offset(railX + direction * (8 + dot * 7),
                y + 35 + dot * 2), 1.3, duneShade);
            }
          }
        } else if (theme.id == 5) {
          // Shadow valley: dark monoliths and violet arcane wisps.
          final monolith = Paint()..color = const Color(0xFF28213A);
          final rune = Paint()..color = const Color(0xFFD6A0FF).withOpacity(.75)
            ..style = PaintingStyle.stroke..strokeWidth = 1.5;
          for (var i = 0; i < 5; i++) {
            final x = railX + direction * 12;
            final y = 150.0 + i * (size.height - 210) / 5;
            final stone = Path()
              ..moveTo(x - 5, y + 20)..lineTo(x - 3, y - 18)
              ..lineTo(x + 3, y - 25)..lineTo(x + 8, y + 20)..close();
            canvas.drawPath(stone, monolith);
            canvas.drawCircle(Offset(x + direction * 2, y - 2), 5, rune);
            canvas.drawLine(Offset(x - 2, y + 8), Offset(x + 4, y - 8), rune);
            canvas.drawCircle(Offset(railX + direction * 29, y + 28), 2.4,
              Paint()..color = const Color(0xFFC18BFF).withOpacity(.5)
                ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
          }
        } else if (theme.id == 6) {
          // Storm citadel: carved buttresses, cyan runes and lightning forks.
          final stone = Paint()..color = const Color(0xFF344C59);
          final rune = Paint()..color = const Color(0xFF75F4F0).withOpacity(.8)
            ..style = PaintingStyle.stroke..strokeWidth = 1.7;
          for (var i = 0; i < 5; i++) {
            final y = 145.0 + i * (size.height - 205) / 5;
            final buttress = Rect.fromLTWH(
              left ? 5 : size.width - 25, y, 20, 34);
            canvas.drawRRect(RRect.fromRectAndRadius(
              buttress, const Radius.circular(3)), stone);
            final bolt = Path()
              ..moveTo(railX + direction * 10, y + 5)
              ..lineTo(railX + direction * 2, y + 16)
              ..lineTo(railX + direction * 11, y + 16)
              ..lineTo(railX + direction * 4, y + 28);
            canvas.drawPath(bolt, rune);
            canvas.drawLine(Offset(railX, y + 33),
              Offset(railX + direction * 8, y + 38), rune);
          }
        }
      }
    }

    // Signature relics make each biome recognizable at a glance.
    final relicY = size.height * .19;
    if (theme.id == 2) {
      final bowl = Offset(size.width * .5, relicY);
      canvas.drawCircle(bowl, 13, Paint()..color = const Color(0xFFFF6A24).withOpacity(.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12));
      canvas.drawCircle(bowl, 5, Paint()..color = const Color(0xFFFFC15A));
    } else if (theme.id == 3) {
      final center = Offset(size.width * .5, relicY);
      final frost = Paint()..color = const Color(0xFFD9F8FF).withOpacity(.7)
        ..strokeWidth = 2..strokeCap = StrokeCap.round;
      for (var arm = 0; arm < 6; arm++) {
        final angle = arm * 3.141592653589793 / 3;
        final tip = Offset(center.dx + 12 * cos(angle),
            center.dy + 12 * sin(angle));
        canvas.drawLine(center, tip, frost);
      }
    } else if (theme.id == 4) {
      final x = size.width * .09;
      final y = size.height * .76;
      final cactus = Paint()..color = const Color(0xFF58764A)
        ..strokeWidth = 5..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(x, y + 14), Offset(x, y - 12), cactus);
      canvas.drawLine(Offset(x, y - 2), Offset(x - 7, y - 2), cactus);
      canvas.drawLine(Offset(x - 7, y - 2), Offset(x - 7, y - 8), cactus);
      canvas.drawLine(Offset(x, y + 4), Offset(x + 7, y + 4), cactus);
      canvas.drawLine(Offset(x + 7, y + 4), Offset(x + 7, y - 3), cactus);
    } else if (theme.id == 5) {
      final portal = Rect.fromCenter(
          center: Offset(size.width * .5, relicY), width: 38, height: 20);
      canvas.drawOval(portal, Paint()..color = const Color(0xFFB77BFF).withOpacity(.14)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9));
      canvas.drawOval(portal, Paint()..color = const Color(0xFFD7A7FF).withOpacity(.7)
        ..style = PaintingStyle.stroke..strokeWidth = 1.5);
    } else if (theme.id == 6) {
      final x = size.width * .09;
      final y = size.height * .22;
      canvas.drawLine(Offset(x, y - 12), Offset(x, y + 18),
          Paint()..color = const Color(0xFF344C59)..strokeWidth = 2);
      final flag = Path()
        ..moveTo(x, y - 11)..lineTo(x + 19, y - 6)
        ..lineTo(x, y + 1)..close();
      canvas.drawPath(flag, Paint()..color = const Color(0xFF55D6D1));
    }

    // Biome atmosphere: deterministic edge particles add depth without
    // covering the central combat lane or introducing per-frame randomness.
    if (size.width > 100 && size.height > 180) {
      final ambient = Paint()
        ..color = theme.accentColor.withOpacity(.42)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      final crisp = Paint()..color = theme.accentColor.withOpacity(.72);
      for (var i = 0; i < 9; i++) {
        final y = size.height * (.24 + i * .071);
        for (final side in [0, 1]) {
          final direction = side == 0 ? 1.0 : -1.0;
          final edgeX = side == 0 ? 39.0 : size.width - 39.0;
          final phase = animation?.value ?? 0.0;
          final drift = ((i * 13) % 17).toDouble() +
              sin((phase * 2 * 3.141592653589793) + i * .9) * 4;
          final floatY = y + cos((phase * 2 * 3.141592653589793) + i * 1.3) * 7;
          final point = Offset(edgeX + direction * drift, floatY);
          final radius = 1.2 + (i % 3) * .45 +
              (sin(phase * 6.283185307179586 + i) + 1) * .35;
          if (theme.id == 2 || theme.id == 6) {
            // Embers and storm sparks.
            canvas.drawLine(
              point.translate(-direction * 3, 3),
              point.translate(direction * 3, -3),
              Paint()..color = theme.accentColor.withOpacity(.55)
                ..strokeWidth = 1.2..strokeCap = StrokeCap.round,
            );
          } else if (theme.id == 3) {
            // Tiny ice diamonds.
            final diamond = Path()
              ..moveTo(point.dx, point.dy - 3)
              ..lineTo(point.dx + 2, point.dy)
              ..lineTo(point.dx, point.dy + 3)
              ..lineTo(point.dx - 2, point.dy)..close();
            canvas.drawPath(diamond, ambient);
          } else if (theme.id == 4) {
            // Fine drifting sand grains.
            canvas.drawCircle(point, radius * .7, crisp);
          } else if (theme.id == 5) {
            // Arcane motes.
            canvas.drawCircle(point, radius + 1, ambient);
            canvas.drawCircle(point, .8, crisp);
          } else {
            // Forest pollen.
            canvas.drawCircle(point, radius + 1.5, ambient);
            canvas.drawCircle(point, 1, crisp);
          }
        }
      }
    }

    final vignette = Paint()
      ..shader = RadialGradient(colors: [Colors.transparent, Colors.black.withOpacity(.48)],
        stops: const [0.55, 1]).createShader(rect);
    canvas.drawRect(rect, vignette);
  }

  @override
  bool shouldRepaint(covariant ArenaPainter oldDelegate) =>
      oldDelegate.theme.id != theme.id || oldDelegate.animation != animation;
}

/// Displays one cell from a horizontal vector sprite sheet.
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
