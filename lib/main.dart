import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(const ArcheroApp());
}

class ArcheroApp extends StatelessWidget {
  const ArcheroApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Archero Flutter Game',
      theme: ThemeData.dark(),
      home: const HeroSelectionScreen(),
    );
  }
}

// 1. شاشة اختيار الأبطال الأربعة
class HeroSelectionScreen extends StatelessWidget {
  const HeroSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('اختر بطلَك الأسطوري', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.amber)),
            const SizedBox(height: 30),
            _buildHeroButton(context, 'البطل الأول (رامي متوازن)', 1),
            _buildHeroButton(context, 'فارس النارية (صحة عالية)', 2),
            _buildHeroButton(context, 'صياد الظل (سرعة فائقة)', 3),
            _buildHeroButton(context, 'حارس العواصف (سهم مزدوج)', 4),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroButton(BuildContext context, String title, int heroType) {
    return Container(
      width: 260,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade700,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => GameScreen(heroType: heroType)),
          );
        },
        child: Text(title, style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// 2. شاشة اللعبة الأساسية (محرك اللعبة داخل Flutter)
class GameScreen extends StatefulWidget {
  final int heroType;
  const GameScreen({Key? key, required this.heroType}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  double playerX = 200;
  double playerY = 500;
  double playerHp = 100;
  double playerMaxHp = 100;
  double playerSpeed = 3.5;
  
  int score = 0;
  int stage = 1;
  int specialCooldown = 0;
  Timer? gameLoopTimer;

  List> enemies = [];
  List> arrows = [];

  @override
  void initState() {
    super.initState();
    _initHeroStats();
    _spawnEnemies();
    
    // حلقة اللعبة الأساسية (Game Loop) للتحديث المستمر
    gameLoopTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      setState(() {
        _updateGame();
      });
    });

    // إطلاق السهام التلقائي
    Timer.periodic(const Duration(milliseconds: 750), (timer) {
      if (mounted && enemies.isNotEmpty) {
        _shootArrow();
      }
    });
  }

  void _initHeroStats() {
    if (widget.heroType == 2) { playerHp = 140; playerMaxHp = 140; }
    if (widget.heroType == 3) { playerSpeed = 5.0; }
    if (widget.heroType == 4) { playerHp = 120; playerMaxHp = 120; }
  }

  void _spawnEnemies() {
    enemies.clear();
    bool isBossStage = (stage % 5 == 0);
    if (isBossStage) {
      enemies.add({
        'x': 200.0, 
        'y': 100.0, 
        'hp': 200.0 + (stage * 30), 
        'maxHp': 200.0 + (stage * 30), 
        'type': 'boss', 
        'radius': 35.0
      });
    } else {
      int count = min(2 + (stage ~/ 2), 6);
      for (int i = 0; i < count; i++) {
        enemies.add({
          'x': Random().nextDouble() * 300 + 50,
          'y': Random().nextDouble() * 200 + 50,
          'hp': 40.0 + (stage * 15),
          'maxHp': 40.0 + (stage * 15),
          'type': Random().nextBool() ? 'melee' : 'ranged',
          'radius': 20.0
        });
      }
    }
  }

  void _shootArrow() {
    if (enemies.isEmpty) return;
    var target = enemies[0];
    double angle = atan2(target['y'] - playerY, target['x'] - playerX);
    
    int count = (widget.heroType == 4) ? 2 : 1;
    for (int i = 0; i < count; i++) {
      double offset = (i == 0) ? 0 : 0.25;
      arrows.add({
        'x': playerX,
        'y': playerY,
        'vx': cos(angle + offset) * 7,
        'vy': sin(angle + offset) * 7,
      });
    }
  }

  void _useSpecialSkill() {
    if (specialCooldown > 0) return;
    setState(() {
      score += enemies.length * 15;
      enemies.clear();
      specialCooldown = 12;
    });

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) { timer.cancel(); return; }
      setState(() {
        if (specialCooldown > 0) specialCooldown--;
        else timer.cancel();
      });
    });
  }

  void _updateGame() {
    // تحديث السهام
    for (int i = arrows.length - 1; i >= 0; i--) {
      arrows[i]['x'] += arrows[i]['vx'];
      arrows[i]['y'] += arrows[i]['vy'];

      // اصطدام السهم بالأعداء
      for (int j = enemies.length - 1; j >= 0; j--) {
        double dist = hypot(arrows[i]['x'] - enemies[j]['x'], arrows[i]['y'] - enemies[j]['y']);
        if (dist < enemies[j]['radius']) {
          enemies[j]['hp'] -= 35;
          arrows.removeAt(i);
          if (enemies[j]['hp'] <= 0) {
            enemies.removeAt(j);
            score += 10;
          }
          break;
        }
      }
    }

    // حركة الأعداء نحو البطل
    for (var en in enemies) {
      double angle = atan2(playerY - en['y'], playerX - en['x']);
      en['x'] += cos(angle) * (1.2 + (stage * 0.05));
      en['y'] += sin(angle) * (1.2 + (stage * 0.05));

      double dist = hypot(playerX - en['x'], playerY - en['y']);
      if (dist < 20 + en['radius']) {
        playerHp -= 0.4;
      }
    }

    // الانتقال للمرحلة التالية تلقائياً عند القضاء على الكل
    if (enemies.isEmpty) {
      stage++;
      playerHp = min(playerMaxHp, playerHp + 25);
      _spawnEnemies();
    }

    if (playerHp <= 0) {
      gameLoopTimer?.cancel();
      _showGameOverDialog();
    }
  }

  double hypot(double dx, double dy) => sqrt(dx * dx + dy * dy);

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('انتهت اللعبة'),
        content: Text('وصلت إلى المرحلة: $stage\nالنقاط الإجمالية: $score'),
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1e272e),
      body: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            playerX += details.delta.dx * (playerSpeed / 3.5);
            playerY += details.delta.dy * (playerSpeed / 3.5);
            playerX = playerX.clamp(25.0, 375.0);
            playerY = playerY.clamp(50.0, 550.0);
          });
        },
        child: Stack(
          children: [
            // واجهة العدادات العلوية
            Positioned(
              top: 40,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('المرحلة: $stage', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('النقاط: $score', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('الصحة: ${(playerHp / playerMaxHp * 100).toInt()}%', style: const TextStyle(fontSize: 16, color: Colors.redAccent, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            // رسم الأعداء أو الزعماء
            ...enemies.map((en) => Positioned(
              left: en['x'] - en['radius'],
              top: en['y'] - en['radius'],
              child: Container(
                width: en['radius'] * 2,
                height: en['radius'] * 2,
                decoration: BoxDecoration(
                  color: en['type'] == 'boss' ? Colors.purple : (en['type'] == 'ranged' ? Colors.orange : Colors.red),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text('${en['hp'].toInt()}', style: const TextStyle(fontSize: 10, color: Colors.white)),
                ),
              ),
            )),

            // رسم البطل
            Positioned(
              left: playerX - 20,
              top: playerY - 20,
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                ),
                child: const Center(child: Icon(Icons.person, color: Colors.white, size: 24)),
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
              right: 30,
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
