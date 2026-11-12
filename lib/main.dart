import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'progress_store.dart';

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

final AudioPlayer globalAudioPlayer = AudioPlayer();

Future<void> playRealSound(String type) async {
  const soundUrls = <String, String>{
    'shoot': 'https://www.soundjay.com/buttons/sounds/button-16.mp3',
    'hit': 'https://www.soundjay.com/buttons/sounds/button-3.mp3',
    'coin': 'https://www.soundjay.com/buttons/sounds/button-7.mp3',
    'special': 'https://www.soundjay.com/buttons/sounds/beep-07.mp3',
  };

  final url = soundUrls[type];
  if (url == null) return;

  try {
    await globalAudioPlayer.stop();
    await globalAudioPlayer.play(UrlSource(url));
  } catch (_) {
    // تستمر اللعبة حتى لو لم يتوفر اتصال بالإنترنت أو تعذر تحميل الصوت.
  }
}

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
  void _buyHealth() {
    if (globalCoins < 50) {
      _message('عملاتك لا تكفي لشراء ترقية الصحة.');
      return;
    }
    setState(() {
      globalCoins -= 50;
      heroHpUpgrade += 25;
    });
    saveProgress();
    playRealSound('coin');
  }

  void _buyAttack() {
    if (globalCoins < 70) {
      _message('عملاتك لا تكفي لشراء ترقية الهجوم.');
      return;
    }
    setState(() {
      globalCoins -= 70;
      heroAtkUpgrade += 15;
    });
    saveProgress();
    playRealSound('coin');
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Icon(Icons.emoji_events, color: Colors.amber),
                              const SizedBox(height: 4),
                              Text('أفضل مرحلة: $bestStage'),
                            ],
                          ),
                          Column(
                            children: [
                              const Icon(Icons.stars, color: Colors.lightBlueAccent),
                              const SizedBox(height: 4),
                              Text('أفضل نتيجة: $bestScore'),
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
              color: hero.color.withOpacity(0.18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(17),
                side: BorderSide(color: hero.color, width: 1.3),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(13),
                leading: CircleAvatar(
                  radius: 27,
                  backgroundColor: hero.color,
                  child: Icon(hero.icon, color: Colors.white),
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
                onTap: () {
                  playRealSound('special');
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GameScreen(heroType: hero.id),
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

  const GameScreen({super.key, required this.heroType});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final Random random = Random();

  double playerX = 180;
  double playerY = 430;
  double playerHp = 100;
  double playerMaxHp = 100;
  double playerSpeed = 3.5;
  DateTime? lastDamageAt;
  double attackPowerMultiplier = 1;
  int extraArrows = 0;
  int animationTicks = 0;
  final List<Map<String, dynamic>> combatEffects = [];

  int score = 0;
  int stage = 1;
  int specialCooldown = 0;

  bool isPaused = false;
  bool showMysteryChest = false;
  bool gameOverShown = false;
  bool stageTransitioning = false;

  Timer? gameLoop;
  Timer? shootLoop;
  Timer? cooldownLoop;

  final List<GameObject> enemies = [];
  final List<GameObject> arrows = [];
  final List<GameObject> coins = [];

  @override
  void initState() {
    super.initState();

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

    if (stage % 5 == 0) {
      final bossHp = 300.0 + stage * 50;
      enemies.add({
        'x': 180.0,
        'y': 105.0,
        'hp': bossHp,
        'maxHp': bossHp,
        'type': 'boss',
        'radius': 36.0,
        'speed': 0.85 + stage * 0.015,
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
          _ => 'enemy',
        };
        final baseHp = 50.0 + stage * 15;
        final hp = switch (enemyType) {
          'tank' => baseHp * 1.8,
          'runner' => baseHp * 0.72,
          'stalker' => baseHp * 0.9,
          _ => baseHp,
        };
        final speed = switch (enemyType) {
          'tank' => 0.55 + stage * 0.012,
          'runner' => 1.35 + stage * 0.035,
          'stalker' => 0.95 + stage * 0.025,
          _ => 0.8 + stage * 0.025,
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
    if (specialCooldown > 0 ||
        enemies.isEmpty ||
        isPaused ||
        showMysteryChest ||
        gameOverShown) {
      return;
    }

    setState(() {
      score += enemies.length * 30;
      for (final enemy in enemies) {
        coins.add({'x': enemy['x'], 'y': enemy['y']});
      }
      enemies.clear();
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

    // تحديث عمر المؤثرات القتالية.
    for (int i = combatEffects.length - 1; i >= 0; i--) {
      combatEffects[i]['life'] = (combatEffects[i]['life'] as int) - 1;
      if ((combatEffects[i]['life'] as int) <= 0) combatEffects.removeAt(i);
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
          enemy['hp'] = (enemy['hp'] as double) -
              (35 * attackPowerMultiplier);
          arrows.removeAt(i);
          arrowRemoved = true;

          if ((enemy['hp'] as double) <= 0) {
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

    // ذكاء قتالي متنوع: اندفاع السريع، التفاف المتخفي، واندفاعة الزعيم.
    for (final enemy in enemies) {
      final dx = playerX - (enemy['x'] as double);
      final dy = playerY - (enemy['y'] as double);
      final distance = sqrt(dx * dx + dy * dy);
      final angle = atan2(dy, dx);
      final type = enemy['type'] as String;
      var moveSpeed = enemy['speed'] as double;
      var moveAngle = angle;

      if (type == 'runner') {
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
          moveSpeed *= 2.65;
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
      if (distance < 23 + (enemy['radius'] as double)) {
        final now = DateTime.now();
        if (lastDamageAt == null ||
            now.difference(lastDamageAt!).inMilliseconds >= 450) {
          playerHp -= enemy['type'] == 'boss' ? 9.0 : 5.0;
          lastDamageAt = now;
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
      _endGame();
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
                    child: CustomPaint(painter: ArenaPainter()),
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

                  // الأعداء وأشرطة صحتهم.
                  ...enemies.map((enemy) {
                    final radius = enemy['radius'] as double;
                    final enemyType = enemy['type'] as String;
                    final isBoss = enemyType == 'boss';
                    final enemyColor = switch (enemyType) {
                      'runner' => Colors.orange,
                      'tank' => Colors.blueGrey,
                      'stalker' => Colors.purple,
                      'boss' => Colors.deepPurple,
                      _ => Colors.red,
                    };
                    final enemyIcon = switch (enemyType) {
                      'runner' => Icons.flash_on,
                      'tank' => Icons.shield,
                      'stalker' => Icons.visibility,
                      'boss' => Icons.whatshot,
                      _ => Icons.pest_control,
                    };
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
                            child: CustomPaint(
                              painter: FighterSpritePainter(
                                kind: enemyType,
                                tint: enemyColor,
                                phase: animationTicks * 0.13 + (enemy['x'] as double) * 0.03,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  // ومضات الاصطدام وانفجارات هزيمة الوحوش.
                  ...combatEffects.map((effect) {
                    final life = effect['life'] as int;
                    final type = effect['type'] as String;
                    final radius = type == 'bossBurst' ? 72.0 : ((type == 'defeat' || type == 'playerHit') ? 42.0 : 29.0);
                    return Positioned(
                      left: (effect['x'] as double) - radius,
                      top: (effect['y'] as double) - radius,
                      child: CustomPaint(
                        size: Size(radius * 2, radius * 2),
                        painter: CombatEffectPainter(
                          type: type,
                          progress: 1 - life / ((type == 'impact' || type.endsWith('Hit') || type == 'enemyAttack') ? (type == 'enemyAttack' ? 12 : 16) : 25),
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
                      child: CustomPaint(
                        painter: FighterSpritePainter(
                          kind: 'hero',
                          tint: _heroColor(),
                          variant: widget.heroType,
                          phase: animationTicks * 0.13,
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

  Color _heroColor() {
    switch (widget.heroType) {
      case 2:
        return Colors.deepOrange;
      case 3:
        return Colors.purple;
      case 4:
        return Colors.teal;
      default:
        return Colors.blue;
    }
  }

  IconData _heroIcon() {
    switch (widget.heroType) {
      case 2:
        return Icons.local_fire_department;
      case 3:
        return Icons.speed;
      case 4:
        return Icons.bolt;
      default:
        return Icons.person;
    }
  }
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
    canvas.drawPath(head, Paint()..color = const Color(0xFFFFB52E));
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
  const FighterSpritePainter({required this.kind, required this.tint, this.variant = 0, this.phase = 0});

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
    final armor = Paint()..color = hero ? const Color(0xFF243C69) : Color.lerp(tint, Colors.black, 0.28)!;
    final light = Paint()..color = hero ? const Color(0xFFFFD36B) : Color.lerp(tint, Colors.white, 0.38)!;
    final skin = Paint()..color = hero ? const Color(0xFFFFD5B2) : (boss ? const Color(0xFF6D244F) : const Color(0xFF83A84A));
    final cape = Paint()..color = hero ? const Color(0xFFE33E35) : (stalker ? const Color(0xFF39265F) : Color.lerp(tint, Colors.black, 0.48)!);

    // ظل أرضي يعطي الشخصية عمقاً.
    canvas.drawOval(const Rect.fromLTWH(10, 54, 44, 8),
        Paint()..color = Colors.black.withOpacity(0.30));
    // هالة وقرون خاصة بالزعيم.
    if (boss) {
      canvas.drawCircle(const Offset(32, 32), 29,
        Paint()..color = const Color(0xFFFF542E).withOpacity(.18)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7));
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
      canvas.drawRRect(RRect.fromRectAndRadius(
        const Rect.fromLTWH(7, 25, 17, 15), const Radius.circular(5)), plate);
      canvas.drawRRect(RRect.fromRectAndRadius(
        const Rect.fromLTWH(40, 25, 17, 15), const Radius.circular(5)), plate);
      canvas.drawCircle(const Offset(15, 32), 3, light);
      canvas.drawCircle(const Offset(49, 32), 3, light);
    }
    // غطاء رأس وظلال مضيئة للمتخفي.
    if (stalker) {
      final hood = Path()
        ..moveTo(17, 20)..quadraticBezierTo(15, -2, 32, 0)
        ..quadraticBezierTo(50, -2, 47, 20)
        ..lineTo(42, 27)..lineTo(22, 27)..close();
      canvas.drawPath(hood, Paint()..color = const Color(0xFF241C3D));
      canvas.drawOval(const Rect.fromLTWH(22, 16, 20, 7),
        Paint()..color = const Color(0xFFFF4CF0));
    }
    if (runner) {
      final crest = Path()
        ..moveTo(23, 8)..lineTo(27, -2)..lineTo(31, 8)
        ..lineTo(37, -2)..lineTo(41, 9)..close();
      canvas.drawPath(crest, Paint()..color = const Color(0xFFFFD15C));
    }
    // الجسم والدرع.
    final body = Path()
      ..moveTo(19, 25)..quadraticBezierTo(32, 18, 45, 25)
      ..lineTo(48, 46)..quadraticBezierTo(32, 53, 16, 46)..close();
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
    // نقاط ضوء صغيرة على الدرع.
    canvas.drawCircle(const Offset(23, 31), 1.5, Paint()..color = Colors.white.withOpacity(.7));
    canvas.drawCircle(const Offset(41, 31), 1.5, Paint()..color = Colors.white.withOpacity(.7));
    // الذراعان.
    canvas.save();
    canvas.translate(16, 31);
    canvas.rotate(sin(phase) * 0.12);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-5, -3, 11, 19), const Radius.circular(5)), skin);
    canvas.drawCircle(const Offset(0, 15), 5, light);
    canvas.restore();
    canvas.save();
    canvas.translate(48, 31);
    canvas.rotate(-sin(phase) * 0.12);
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
      canvas.drawPath(hair, Paint()..color = const Color(0xFFF4F5FF));
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
    }
    final eyeGlow = Paint()
      ..color = (stalker || boss ? const Color(0xFFFF4CF0) : const Color(0xFF8DEBFF)).withOpacity(.32)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(const Offset(26, 19), 4, eyeGlow);
    canvas.drawCircle(const Offset(38, 19), 4, eyeGlow);
    final eye = Paint()..color = const Color(0xFF171525);
    canvas.drawOval(const Rect.fromCenter(center: Offset(26, 19), width: 3.2, height: 2.8), eye);
    canvas.drawOval(const Rect.fromCenter(center: Offset(38, 19), width: 3.2, height: 2.8), eye);
    canvas.drawCircle(const Offset(25.5, 18.5), .7, Paint()..color = Colors.white);
    canvas.drawCircle(const Offset(37.5, 18.5), .7, Paint()..color = Colors.white);
    canvas.drawArc(const Rect.fromLTWH(27, 21, 10, 5), 0, 3.14, false,
        Paint()..color = const Color(0xFF552D35)..strokeWidth = 1.5..style = PaintingStyle.stroke);
    // سلاح صغير واضح للشخصية.
    final weapon = Paint()..color = const Color(0xFFFFD76A)..strokeWidth = 3..strokeCap = StrokeCap.round;
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
      oldDelegate.kind != kind || oldDelegate.tint != tint || oldDelegate.variant != variant || oldDelegate.phase != phase;
}

// -----------------------------------------------------------------------------
// رسم أرضية ساحة القتال
// -----------------------------------------------------------------------------

class ArenaPainter extends CustomPainter {
  const ArenaPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF172B35), Color(0xFF35513D), Color(0xFF182D2B)],
      ).createShader(rect));

    // Outer mossy stone walls and corner towers.
    final wall = Paint()..color = const Color(0xFF59616A);
    final wallDark = Paint()..color = const Color(0xFF303D43);
    final moss = Paint()..color = const Color(0xFF547A4A);
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(5, 72, size.width - 10, size.height - 80),
      const Radius.circular(24)), wallDark);
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(12, 80, size.width - 24, size.height - 96),
      const Radius.circular(20)), moss);

    // Irregular stone courtyard tiles.
    final tile = Paint()..color = const Color(0xFF89917A);
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
    final grass = Paint()..color = const Color(0xFF244D37);
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
      canvas.drawCircle(Offset(x, baseY - 30), 8, Paint()..color = const Color(0xFFFF8B27)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12));
      final flame = Path()
        ..moveTo(x, baseY - 19)..quadraticBezierTo(x - 14, baseY - 42, x, baseY - 53)
        ..quadraticBezierTo(x + 13, baseY - 37, x, baseY - 19)..close();
      canvas.drawPath(flame, Paint()..color = const Color(0xFFFFB52E));
      canvas.drawPath(flame, Paint()..color = const Color(0xFFFFF0A1)
        ..style = PaintingStyle.stroke..strokeWidth = 1.2);
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
    final vignette = Paint()
      ..shader = RadialGradient(colors: [Colors.transparent, Colors.black.withOpacity(.48)],
        stops: const [0.55, 1]).createShader(rect);
    canvas.drawRect(rect, vignette);
  }

  @override
  bool shouldRepaint(covariant ArenaPainter oldDelegate) => false;
}
