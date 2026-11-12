import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(const ArcheroUltimateApp());
}

class ArcheroUltimateApp extends StatelessWidget {
  const ArcheroUltimateApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Archero Ultimate Flutter Edition',
      theme: ThemeData.dark(),
      home: const HeroSelectionScreen(),
    );
  }
}

// ==========================================
// 1. شاشة اختيار الأبطال الأربعة
// ==========================================
class HeroSelectionScreen extends StatelessWidget {
  const HeroSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.flash_on, size: 60, color: Colors.amber),
              const SizedBox(height: 15),
              const Text(
                'اختر بطلك الأسطوري',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.amberAccent),
              ),
              const SizedBox(height: 35),
              _buildHeroCard(context, 'البطل الأول: الرامي المتوازن', 1, Colors.blue),
              _buildHeroCard(context, 'البطل الثاني: فارس النارية (صحة عالية)', 2, Colors.deepOrange),
              _buildHeroCard(context, 'البطل الثالث: صياد الظل (سرعة خارقة)', 3, Colors.purple),
              _buildHeroCard(context, 'البطل الرابع: حارس العواصف (أسهم مزدوجة)', 4, Colors.teal),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context, String title, int type, Color color) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.85),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => GameScreen(heroType: type)),
          );
        },
        child: Text(title, style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// ==========================================
// 2. محرك اللعبة الرئيسي مع المهارات والعملات
// ==========================================
class GameScreen extends StatefulWidget {
  final int heroType;
  const GameScreen({Key? key, required this.heroType}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // إحصائيات البطل
  double playerX = 200;
  double playerY = 500;
  double playerHp = 100;
  double playerMaxHp = 100;
  double playerSpeed = 3.5;
  double attackPowerMultiplier = 1.0;
  int extraArrows = 0;

  // إدارة مراحل اللعبة والعملات
  int score = 0;
  int coins = 0;
  int stage = 1;
  int specialCooldown = 0;
  bool isShowingPerkDialog = false;

  Timer? gameLoopTimer;
  Timer? shootTimer;

  List> enemies = [];
  List> arrows = [];
  List> droppedCoins = [];

  @override
  void initState() {
    super.initState();
    _applyHeroStats();
    _spawnStageEnemies();

    // حلقة اللعبة الأساسية
    gameLoopTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (mounted && !isShowingPerkDialog) {
        setState(() {
          _updateGameEngine();
        });
      }
    });

    // مؤقت إطلاق السهام التلقائي
    shootTimer = Timer.periodic(const Duration(milliseconds: 650), (timer) {
      if (mounted && enemies.isNotEmpty && !isShowingPerkDialog) {
        _shootArrows();
      }
    });
  }

  void _applyHeroStats() {
    if (widget.heroType == 2) { playerHp = 150; playerMaxHp = 150; }
    if (widget.heroType == 3) { playerSpeed = 5.0; }
    if (widget.heroType == 4) { playerHp = 120; playerMaxHp = 120; extraArrows = 1; }
  }

  void _spawnStageEnemies() {
    enemies.clear();
    arrows.clear();

    bool isBossStage = (stage % 5 == 0);
    if (isBossStage) {
      enemies.add({
        'x': 200.0, 'y': 110.0,
        'hp': 300.0 + (stage * 50), 'maxHp': 300.0 + (stage * 50),
        'type': 'boss', 'radius': 38.0, 'speed': 1.15
      });
    } else {
      int count = min(2 + (stage ~/ 2), 6);
      for (int i = 0; i < count; i++) {
        enemies.add({
          'x': Random().nextDouble() * 320 + 40,
          'y': Random().nextDouble() * 220 + 40,
          'hp': 50.0 + (stage * 15), 'maxHp': 50.0 + (stage * 15),
          'type': Random().nextBool() ? 'ranged' : 'melee',
          'radius': 20.0, 'speed': 1.2 + (stage * 0.03)
        });
      }
    }
  }

  void _shootArrows() {
    if (enemies.isEmpty) return;
    var target = enemies[0];
    double baseAngle = atan2(target['y'] - playerY, target['x'] - playerX);

    int totalShots = 1 + extraArrows;
    for (int i = 0; i < totalShots; i++) {
      double spread = (i == 0) ? 0 : (i % 2 == 1 ? 0.2 : -0.2);
      arrows.add({
        'x': playerX, 'y': playerY,
        'vx': cos(baseAngle + spread) * 8.5,
        'vy': sin(baseAngle + spread) * 8.5,
      });
    }
  }

  void _useSpecialSkill() {
    if (specialCooldown > 0) return;
    setState(() {
      score += enemies.length * 25;
      enemies.clear();
      specialCooldown = 15;
    });

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) { timer.cancel(); return; }
      setState(() {
        if (specialCooldown > 0) specialCooldown--;
        else timer.cancel();
      });
    });
  }

  void _updateGameEngine() {
    // 1. تحريك وتحديث الأسهم
    for (int i = arrows.length - 1; i >= 0; i--) {
      arrows[i]['x'] += arrows[i]['vx'];
      arrows[i]['y'] += arrows[i]['vy'];

      for (int j = enemies.length - 1; j >= 0; j--) {
        double dist = sqrt(pow(arrows[i]['x'] - enemies[j]['x'], 2) + pow(arrows[i]['y'] - enemies[j]['y'], 2));
        if (dist < enemies[j]['radius']) {
          enemies[j]['hp'] -= (35 * attackPowerMultiplier);
          arrows.removeAt(i);
          if (enemies[j]['hp'] <= 0) {
            // إسقاط عملة معدنية مكان العدو المقتول
            droppedCoins.add({'x': enemies[j]['x'], 'y': enemies[j]['y']});
            enemies.removeAt(j);
            score += 15;
          }
          break;
        }
      }
    }

    // 2. تحريك الأعداء واصطدامهم بالبطل
    for (var en in enemies) {
      double angle = atan2(playerY - en['y'], playerX - en['x']);
      en['x'] += cos(angle) * en['speed'];
      en['y'] += sin(angle) * en['speed'];

      double distToPlayer = sqrt(pow(playerX - en['x'], 2) + pow(playerY - en['y'], 2));
      if (distToPlayer < 20 + en['radius']) {
        playerHp -= 0.55;
      }
    }

    // 3. جمع العملات تلقائياً عند الاقتراب منها
    for (int c = droppedCoins.length - 1; c >= 0; c--) {
      double dist = sqrt(pow(playerX - droppedCoins[c]['x'], 2) + pow(playerY - droppedCoins[c]['y'], 2));
      if (dist < 30) {
        coins += 5;
        droppedCoins.removeAt(c);
      }
    }

    // 4. إنهاء المرحلة وإظهار نافذة اختيار المهارات (Perks) تماماً مثل الأصلية
    if (enemies.isEmpty) {
      stage++;
      playerHp = min(playerMaxHp, playerHp + 25);
      _showPerkSelectionDialog();
    }

    if (playerHp <= 0) {
      _gameOver();
    }
  }

  // نظام اختيار المهارات عند الارتقاء بالمستوى (ميزة Archero الأساسية)
  void _showPerkSelectionDialog() {
    isShowingPerkDialog = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('✨ اختر مهارة جديدة!', style: TextStyle(color: Colors.amber)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
              onPressed: () {
                setState(() { extraArrows++; });
                Navigator.pop(context);
                _resumeAfterPerk();
              },
              child: const Text('سهم أمامي إضافي (Front Arrow)'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                setState(() { attackPowerMultiplier += 0.3; });
                Navigator.pop(context);
                _resumeAfterPerk();
              },
              child: const Text('زيادة قوة الهجوم (Attack Boost)'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              onPressed: () {
                setState(() { playerSpeed += 0.8; });
                Navigator.pop(context);
                _resumeAfterPerk();
              },
              child: const Text('سرعة حركة فائقة (Speed Boost)'),
            ),
          ],
        ),
      ),
    );
  }

  void _resumeAfterPerk() {
    isShowingPerkDialog = false;
    _spawnStageEnemies();
  }

  void _gameOver() {
    gameLoopTimer?.cancel();
    shootTimer?.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('انتهت اللعبة', style: TextStyle(color: Colors.red)),
        content: Text('وصلت للمرحلة: $stage\nالنقاط: $score\nالعملات المجمعة: $coins 🪙'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HeroSelectionScreen()));
            },
            child: const Text('إعادة المحاولة'),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    gameLoopTimer?.cancel();
    shootTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF191b22),
      body: GestureDetector(
        onPanUpdate: (details) {
          if (isShowingPerkDialog) return;
          setState(() {
            playerX += details.delta.dx * (playerSpeed / 3.5);
            playerY += details.delta.dy * (playerSpeed / 3.5);
            playerX = playerX.clamp(25.0, 375.0);
            playerY = playerY.clamp(75.0, 560.0);
          });
        },
        child: Stack(
          children: [
            // لوحة العدادات العلوية (المرحلة، النقاط، العملات، والصحة)
            Positioned(
              top: 40,
              left: 15,
              right: 15,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(15)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('المرحلة: $stage', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
                    Text('🪙 $coins', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.yellow)),
                    Text('الصحة: ${(playerHp / playerMaxHp * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
                  ],
                ),
              ),
            ),

            // رسم العملات المساقطة على الأرض
            ...droppedCoins.map((coin) => Positioned(
              left: coin['x'] - 10,
              top: coin['y'] - 10,
              child: Container(
                width: 20, height: 20,
                decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
                child: const Center(child: Text('©', style: TextStyle(fontSize: 10, color: Colors.black, fontWeight: FontWeight.bold))),
              ),
            )),

            // رسم الأعداء
            ...enemies.map((en) => Positioned(
              left: en['x'] - en['radius'],
              top: en['y'] - en['radius'],
              child: Column(
                children: [
                  Container(
                    width: en['radius'] * 2,
                    height: en['radius'] * 2,
                    decoration: BoxDecoration(
                      color: en['type'] == 'boss' ? Colors.deepPurple : Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Center(child: Text('${en['hp'].toInt()}', style: const TextStyle(fontSize: 9, color: Colors.white))),
                  ),
                ],
              ),
            )),

            // رسم البطل
            Positioned(
              left: playerX - 20,
              top: playerY - 20,
              child: Container(
                width: 40, height: 40,
                decoration: const BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
                child: const Center(child: Icon(Icons.person, color: Colors.white, size: 22)),
              ),
            ),

            // رسم الأسهم
            ...arrows.map((arr) => Positioned(
              left: arr['x'] - 5,
              top: arr['y'] - 5,
              child: Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.yellow, shape: BoxShape.circle)),
            )),

            // زر الضربة الخاصة
            Positioned(
              bottom: 30,
              right: 25,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: specialCooldown > 0 ? Colors.grey : Colors.red,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(20),
                ),
                onPressed: specialCooldown > 0 ? null : _useSpecialSkill,
                child: Text(specialCooldown > 0 ? '$specialCooldown' : 'خاصة', style: const TextStyle(fontSize: 12, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
