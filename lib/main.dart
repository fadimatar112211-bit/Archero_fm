import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(const ArcheroCompleteEditionApp());
}

class ArcheroCompleteEditionApp extends StatelessWidget {
  const ArcheroCompleteEditionApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Archero Complete Edition',
      theme: ThemeData.dark(),
      home: const MainMenuScreen(),
    );
  }
}

// ==========================================
// 1. القائمة الرئيسية ومتجر التطوير (Upgrades Store)
// ==========================================
int globalCoins = 100; // العملات المجمعة التي تستخدمها للتطوير
int heroHpUpgrade = 0;
int heroAtkUpgrade = 0;

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({Key? key}) : super(key: key);

  @override
  _MainMenuScreenState createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('ARCHERO COMPLETE', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.amberAccent)),
              const SizedBox(height: 10),
              Text('العملات المتاحة: 🪙 $globalCoins', style: const TextStyle(fontSize: 16, color: Colors.yellow)),
              const SizedBox(height: 25),
              
              // زر متجر التطوير للأبطال
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.amber)),
                child: Column(
                  children: [
                    const Text('متجر تطوير العتاد والأبطال', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (globalCoins >= 50) {
                              setState(() { globalCoins -= 50; heroHpUpgrade += 20; });
                            }
                          },
                          child: Text('ترقية الصحة (+20) [50🪙]'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (globalCoins >= 70) {
                              setState(() { globalCoins -= 70; heroAtkUpgrade += 10; });
                            }
                          },
                          child: Text('ترقية الهجوم (+10) [70🪙]'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const Text('اختر بطلَك الأسطوري وانطلق', style: TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 15),
              
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14)),
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HeroSelectionScreen()));
                },
                child: const Text('ابدأ المعركة الآن', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
            const Text('اختر بطلَك', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.amber)),
            const SizedBox(height: 20),
            _heroBtn(context, 'البطل الأول (رامي متوازن)', 1, Colors.blue),
            _heroBtn(context, 'فارس النارية (صحة عالية)', 2, Colors.deepOrange),
            _heroBtn(context, 'صياد الظل (سرعة خارقة)', 3, Colors.purple),
            _heroBtn(context, 'حارس العواصف (سهم مزدوج)', 4, Colors.teal),
          ],
        ),
      ),
    );
  }

  Widget _heroBtn(BuildContext context, String title, int type, Color color) {
    return Container(
      width: 260,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: color),
        onPressed: () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => GameScreen(heroType: type)));
        },
        child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// ==========================================
// 2. شاشة المحرك واللعب الشاملة
// ==========================================
class GameScreen extends StatefulWidget {
  final int heroType;
  const GameScreen({Key? key, required this.heroType}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  double playerX = 200;
  double playerY = 500;
  double playerHp = 100 + heroHpUpgrade.toDouble();
  double playerMaxHp = 100 + heroHpUpgrade.toDouble();
  double playerSpeed = 3.5;
  double attackPowerMultiplier = 1.0 + (heroAtkUpgrade * 0.1);
  int extraArrows = 0;

  int score = 0;
  int stage = 1;
  int specialCooldown = 0;
  bool isPausedForPerk = false;
  bool showMysteryBoxModal = false;

  Timer? loopTimer;
  Timer? shootTimer;

  List> enemies = [];
  List> arrows = [];
  List> coins = [];

  @override
  void initState() {
    super.initState();
    if (widget.heroType == 2) { playerHp += 40; playerMaxHp += 40; }
    if (widget.heroType == 3) { playerSpeed = 5.2; }
    if (widget.heroType == 4) { extraArrows = 1; }

    _spawnEnemies();

    loopTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (mounted && !isPausedForPerk && !showMysteryBoxModal) {
        setState(() { _updateEngine(); });
      }
    });

    shootTimer = Timer.periodic(const Duration(milliseconds: 650), (timer) {
      if (mounted && enemies.isNotEmpty && !isPausedForPerk && !showMysteryBoxModal) {
        _shoot();
      }
    });
  }

  void _spawnEnemies() {
    enemies.clear();
    arrows.clear();
    if (stage % 5 == 0) {
      enemies.add({'x': 200.0, 'y': 100.0, 'hp': 250.0 + (stage * 40), 'maxHp': 250.0 + (stage * 40), 'type': 'boss', 'radius': 35.0, 'speed': 1.1});
    } else {
      int count = min(2 + (stage ~/ 2), 6);
      for (int i = 0; i < count; i++) {
        enemies.add({'x': Random().nextDouble() * 300 + 50, 'y': Random().nextDouble() * 200 + 40, 'hp': 45.0 + (stage * 12), 'maxHp': 45.0 + (stage * 12), 'type': 'enemy', 'radius': 20.0, 'speed': 1.2});
      }
    }
  }

  void _shoot() {
    if (enemies.isEmpty) return;
    var target = enemies[0];
    double angle = atan2(target['y'] - playerY, target['x'] - playerX);
    int shots = 1 + extraArrows;
    for (int i = 0; i < shots; i++) {
      double spread = (i == 0) ? 0 : (i % 2 == 1 ? 0.22 : -0.22);
      arrows.add({'x': playerX, 'y': playerY, 'vx': cos(angle + spread) * 8.0, 'vy': sin(angle + spread) * 8.0});
    }
  }

  void _useSpecial() {
    if (specialCooldown > 0) return;
    setState(() {
      score += enemies.length * 20;
      enemies.clear();
      specialCooldown = 15;
    });
    Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() { if (specialCooldown > 0) specialCooldown--; else t.cancel(); });
    });
  }

  void _updateEngine() {
    for (int i = arrows.length - 1; i >= 0; i--) {
      arrows[i]['x'] += arrows[i]['vx'];
      arrows[i]['y'] += arrows[i]['vy'];

      for (int j = enemies.length - 1; j >= 0; j--) {
        double dist = sqrt(pow(arrows[i]['x'] - enemies[j]['x'], 2) + pow(arrows[i]['y'] - enemies[j]['y'], 2));
        if (dist < enemies[j]['radius']) {
          enemies[j]['hp'] -= (35 * attackPowerMultiplier);
          arrows.removeAt(i);
          if (enemies[j]['hp'] <= 0) {
            coins.add({'x': enemies[j]['x'], 'y': enemies[j]['y']});
            enemies.removeAt(j);
            score += 15;
          }
          break;
        }
      }
    }

    for (var en in enemies) {
      double angle = atan2(playerY - en['y'], playerX - en['x']);
      en['x'] += cos(angle) * en['speed'];
      en['y'] += sin(angle) * en['speed'];
      if (sqrt(pow(playerX - en['x'], 2) + pow(playerY - en['y'], 2)) < 20 + en['radius']) {
        playerHp -= 0.5;
      }
    }

    for (int c = coins.length - 1; c >= 0; c--) {
      if (sqrt(pow(playerX - coins[c]['x'], 2) + pow(playerY - coins[c]['y'], 2)) < 30) {
        globalCoins += 10;
        coins.removeAt(c);
      }
    }

    if (enemies.isEmpty) {
      stage++;
      playerHp = min(playerMaxHp, playerHp + 30);
      // ظهور صندوق المكافآت الغامض (Mystery Chest) عشوائياً بعد كل مرحلة كبرى
      if (stage % 2 == 0) {
        _triggerMysteryChest();
      } else {
        _triggerPerks();
      }
    }

    if (playerHp <= 0) {
      loopTimer?.cancel();
      shootTimer?.cancel();
      _gameOver();
    }
  }

  void _triggerMysteryChest() {
    setState(() { showMysteryBoxModal = true; });
  }

  void _triggerPerks() {
    setState(() { isPausedForPerk = true; });
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('✨ اختر مهارة جديدة', style: TextStyle(color: Colors.amber)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(onPressed: () { setState(() { extraArrows++; }); Navigator.pop(context); _resumeGame(); }, child: const Text('سهم أمامي إضافي')),
            const SizedBox(height: 6),
            ElevatedButton(onPressed: () { setState(() { attackPowerMultiplier += 0.3; }); Navigator.pop(context); _resumeGame(); }, child: const Text('قوة هجوم مضاعفة')),
          ],
        ),
      ),
    );
  }

  void _resumeGame() {
    isPausedForPerk = false;
    _spawnEnemies();
  }

  void _gameOver() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('انتهت المعركة'),
        content: Text('المرحلة: $stage\nالنقاط: $score\nتم حفظ العملات: 🪙 $globalCoins'),
        actions: [
          TextButton(onPressed: () { Navigator.pop(context); Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainMenuScreen())); }, child: const Text('العودة للرئيسية'))
        ],
      ),
    );
  }

  @override
  void dispose() {
    loopTimer?.cancel();
    shootTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1c23),
      body: GestureDetector(
        onPanUpdate: (details) {
          if (isPausedForPerk || showMysteryBoxModal) return;
          setState(() {
            playerX = (playerX + details.delta.dx * (playerSpeed / 3.5)).clamp(25.0, 375.0);
            playerY = (playerY + details.delta.dy * (playerSpeed / 3.5)).clamp(70.0, 560.0);
          });
        },
        child: Stack(
          children: [
            // لوحة المعلومات
            Positioned(
              top: 40, left: 15, right: 15,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(15)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('المرحلة: $stage', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
                    Text('🪙 $globalCoins', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.yellow)),
                    Text('الصحة: ${(playerHp / playerMaxHp * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
                  ],
                ),
              ),
            ),

            // صندوق المكافآت الغامض (Mystery Chest) إن ظهر
            if (showMysteryBoxModal)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(color: Colors.black, border: Border.all(color: Colors.amber, width: 2), borderRadius: BorderRadius.circular(15)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🎁 صندوق مكافآت غامض!', style: TextStyle(fontSize: 18, color: Colors.amber, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                        onPressed: () {
                          setState(() {
                            globalCoins += 50; // هدية صندوق المكافآت
                            showMysteryBoxModal = false;
                          });
                          _spawnEnemies();
                        },
                        child: const Text('افتح الصندوق واحصل على 50 عملة!', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),

            // عملات متساقطة
            ...coins.map((c) => Positioned(left: c['x'] - 8, top: c['y'] - 8, child: Container(width: 16, height: 16, decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle)))),

            // الأعداء
            ...enemies.map((en) => Positioned(
              left: en['x'] - en['radius'], top: en['y'] - en['radius'],
              child: Container(width: en['radius'] * 2, height: en['radius'] * 2, decoration: BoxDecoration(color: en['type'] == 'boss' ? Colors.purple : Colors.red, shape: BoxShape.circle)),
            )),

            // البطل
            Positioned(left: playerX - 20, top: playerY - 20, child: Container(width: 40, height: 40, decoration: const BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle))),

            // الأسهم
            ...arrows.map((arr) => Positioned(left: arr['x'] - 5, top: arr['y'] - 5, child: Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.yellow, shape: BoxShape.circle)))),

            // زر الضربة الخاصة
            Positioned(
              bottom: 30, right: 25,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: specialCooldown > 0 ? Colors.grey : Colors.red, shape: const CircleBorder(), padding: const EdgeInsets.all(20)),
                onPressed: specialCooldown > 0 ? null : _useSpecial,
                child: Text(specialCooldown > 0 ? '$specialCooldown' : 'خاصة', style: const TextStyle(fontSize: 12, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
