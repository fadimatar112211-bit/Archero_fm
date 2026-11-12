import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const ArcheroSoundApp());
}

class ArcheroSoundApp extends StatelessWidget {
  const ArcheroSoundApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Archero Sound Edition',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF090a0f),
        primarySwatch: Colors.amber,
      ),
      home: const MainMenuScreen(),
    );
  }
}

// Global Economy & Audio Engine
int globalCoins = 150;
int heroHpUpgrade = 0;
int heroAtkUpgrade = 0;
final AudioPlayer globalAudioPlayer = AudioPlayer();

// دالة تشغيل الأصوات الحقيقية أونلاين لتجنب مشاكل الملفات المفقودة
void playRealSound(String type) async {
  try {
    String url = '';
    if (type == 'shoot') {
      url = 'https://www.soundjay.com/buttons/sounds/button-16.mp3';
    } else if (type == 'hit') {
      url = 'https://www.soundjay.com/buttons/sounds/button-3.mp3';
    } else if (type == 'coin') {
      url = 'https://www.soundjay.com/buttons/sounds/button-7.mp3';
    } else if (type == 'special') {
      url = 'https://www.soundjay.com/buttons/sounds/beep-07.mp3';
    }
    
    if (url.isNotEmpty) {
      await globalAudioPlayer.stop();
      await globalAudioPlayer.play(UrlSource(url));
    }
  } catch (e) {
    // تجاهل أي خطأ مؤقت في الاتصال
  }
}

// ==========================================
// 1. القائمة الرئيسية ومتجر التطوير
// ==========================================
class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({Key? key}) : super(key: key);

  @override
  _MainMenuScreenState createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1a0033), Color(0xFF090a0f)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.volume_up_rounded, size: 80, color: Colors.amberAccent),
                const SizedBox(height: 10),
                const Text('ARCHERO: SOUND EDITION', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.white)),
                const Text('النسخة الكاملة مع المؤثرات الصوتية الحقيقية', style: TextStyle(fontSize: 13, color: Colors.amber)),
                const SizedBox(height: 20),
                
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.amber.withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.monetization_on, color: Colors.amber, size: 20),
                      const SizedBox(width: 8),
                      Text('الرصيد: $globalCoins 🪙', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.yellowAccent)),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    children: [
                      const Text('🛠️ متجر تطوير القدرات', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amberAccent)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade800),
                            onPressed: () {
                              if (globalCoins >= 50) {
                                setState(() { globalCoins -= 50; heroHpUpgrade += 25; });
                                playRealSound('coin');
                              }
                            },
                            icon: const Icon(Icons.favorite, size: 16),
                            label: const Text('صحة +25 [50]'),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange.shade800),
                            onPressed: () {
                              if (globalCoins >= 70) {
                                setState(() { globalCoins -= 70; heroAtkUpgrade += 15; });
                                playRealSound('coin');
                              }
                            },
                            icon: const Icon(Icons.flash_on, size: 16),
                            label: const Text('هجوم +15 [70]'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 8,
                    ),
                    onPressed: () {
                      playRealSound('coin');
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HeroSelectionScreen()));
                    },
                    child: const Text('دخول المعركة بالأصوات (Play)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 2. شاشة اختيار الأبطال الأربعة
// ==========================================
class HeroSelectionScreen extends StatelessWidget {
  const HeroSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اختر بطلك الأسطوري'), backgroundColor: Colors.transparent),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(child: _heroCard(context, 'البطل الأول: الرامي المتوازن', 'أداء ممتاز وثابت في كل المراحل', 1, Colors.blue, Icons.sports_martial_arts)),
            Expanded(child: _heroCard(context, 'البطل الثاني: فارس النارية', 'صحة عالية جداً لامتصاص ضربات الأعداء', 2, Colors.deepOrange, Icons.local_fire_department)),
            Expanded(child: _heroCard(context, 'البطل الثالث: صياد الظل', 'سرعة حركة فائقة لتفادي الهجمات', 3, Colors.purple, Icons.speed)),
            Expanded(child: _heroCard(context, 'البطل الرابع: حارس العواصف', 'يطلق سهمين مزدوجين مدمرين معاً', 4, Colors.teal, Icons.bolt)),
          ],
        ),
      ),
    );
  }

  Widget _heroCard(BuildContext context, String name, String desc, int type, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: () {
          playRealSound('special');
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => GameScreen(heroType: type)));
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color.withOpacity(0.7), color.withOpacity(0.2)]),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color, width: 1.5),
          ),
          child: Row(
            children: [
              CircleAvatar(backgroundColor: Colors.black45, radius: 28, child: Icon(icon, color: Colors.white, size: 28)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(desc, style: const TextStyle(fontSize: 12, color: Colors.white70)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 3. محرك اللعبة الرئيسي مع الأصوات الحية
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
  double attackPowerMultiplier = 1.0 + (heroAtkUpgrade * 0.08);
  int extraArrows = 0;

  int score = 0;
  int stage = 1;
  int specialCooldown = 0;
  bool isPaused = false;
  bool showMysteryChest = false;

  Timer? gameLoop;
  Timer? shootLoop;

  List> enemies = [];
  List> arrows = [];
  List> coins = [];

  @override
  void initState() {
    super.initState();
    if (widget.heroType == 2) { playerHp += 50; playerMaxHp += 50; }
    if (widget.heroType == 3) { playerSpeed = 5.2; }
    if (widget.heroType == 4) { extraArrows = 1; }

    _spawnEnemies();

    gameLoop = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (mounted && !isPaused && !showMysteryChest) {
        setState(() { _updateEngine(); });
      }
    });

    shootLoop = Timer.periodic(const Duration(milliseconds: 600), (timer) {
      if (mounted && enemies.isNotEmpty && !isPaused && !showMysteryChest) {
        _shootArrows();
      }
    });
  }

  void _spawnEnemies() {
    enemies.clear();
    arrows.clear();
    if (stage % 5 == 0) {
      enemies.add({'x': 200.0, 'y': 110.0, 'hp': 300.0 + (stage * 50), 'maxHp': 300.0 + (stage * 50), 'type': 'boss', 'radius': 40.0, 'speed': 1.15});
    } else {
      int count = min(2 + (stage ~/ 2), 6);
      for (int i = 0; i < count; i++) {
        enemies.add({'x': Random().nextDouble() * 300 + 40, 'y': Random().nextDouble() * 220 + 50, 'hp': 50.0 + (stage * 15), 'maxHp': 50.0 + (stage * 15), 'type': 'enemy', 'radius': 22.0, 'speed': 1.25});
      }
    }
  }

  void _shootArrows() {
    if (enemies.isEmpty) return;
    var target = enemies[0];
    double angle = atan2(target['y'] - playerY, target['x'] - playerX);
    int totalShots = 1 + extraArrows;
    for (int i = 0; i < totalShots; i++) {
      double spread = (i == 0) ? 0 : (i % 2 == 1 ? 0.25 : -0.25);
      arrows.add({'x': playerX, 'y': playerY, 'vx': cos(angle + spread) * 8.5, 'vy': sin(angle + spread) * 8.5});
    }
    playRealSound('shoot');
  }

  void _useSpecialSkill() {
    if (specialCooldown > 0) return;
    setState(() {
      score += enemies.length * 30;
      enemies.clear();
      specialCooldown = 15;
    });
    playRealSound('special');
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
            score += 20;
            playRealSound('hit');
          }
          break;
        }
      }
    }

    for (var en in enemies) {
      double angle = atan2(playerY - en['y'], playerX - en['x']);
      en['x'] += cos(angle) * en['speed'];
      en['y'] += sin(angle) * en['speed'];
      if (sqrt(pow(playerX - en['x'], 2) + pow(playerY - en['y'], 2)) < 22 + en['radius']) {
        playerHp -= 0.6;
      }
    }

    for (int c = coins.length - 1; c >= 0; c--) {
      if (sqrt(pow(playerX - coins[c]['x'], 2) + pow(playerY - coins[c]['y'], 2)) < 35) {
        globalCoins += 10;
        coins.removeAt(c);
        playRealSound('coin');
      }
    }

    if (enemies.isEmpty) {
      stage++;
      playerHp = min(playerMaxHp, playerHp + 35);
      if (stage % 2 == 0) {
        setState(() { showMysteryChest = true; });
        playRealSound('special');
      } else {
        _showPerksDialog();
      }
    }

    if (playerHp <= 0) {
      gameLoop?.cancel();
      shootLoop?.cancel();
      _showGameOver();
    }
  }

  void _showPerksDialog() {
    setState(() { isPaused = true; });
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('✨ ترقية مهارة أسطورية', style: TextStyle(color: Colors.amber)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
              onPressed: () { setState(() { extraArrows++; }); Navigator.pop(context); _resumeGame(); },
              child: const Text('سهم أمامي مزدوج إضافي'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () { setState(() { attackPowerMultiplier += 0.35; }); Navigator.pop(context); _resumeGame(); },
              child: const Text('قوة هجوم خارقة (+35%)'),
            ),
          ],
        ),
      ),
    );
  }

  void _resumeGame() {
    isPaused = false;
    _spawnEnemies();
  }

  void _showGameOver() {
    playRealSound('hit');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('انتهت المعركة', style: TextStyle(color: Colors.red)),
        content: Text('المرحلة التي وصلت لها: $stage\nالنقاط الإجمالية: $score\nتم حفظ العملات: 🪙 $globalCoins'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainMenuScreen()));
            },
            child: const Text('العودة للقائمة الرئيسية'),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    gameLoop?.cancel();
    shootLoop?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onPanUpdate: (details) {
          if (isPaused || showMysteryChest) return;
          setState(() {
            playerX = (playerX + details.delta.dx * (playerSpeed / 3.5)).clamp(25.0, 375.0);
            playerY = (playerY + details.delta.dy * (playerSpeed / 3.5)).clamp(80.0, 580.0);
          });
        },
        child: Stack(
          children: [
            Container(color: const Color(0xFF13151c)),

            Positioned(
              top: 45, left: 16, right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('الفصل / المرحلة: $stage', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
                    Text('🪙 $globalCoins', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.yellowAccent)),
                    Text('الصحة: ${(playerHp / playerMaxHp * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
                  ],
                ),
              ),
            ),

            if (showMysteryChest)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1a1500),
                    border: Border.all(color: Colors.amber, width: 2),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.amber.withOpacity(0.3), blurRadius: 20)],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.card_giftcard, size: 50, color: Colors.amber),
                      const SizedBox(height: 10),
                      const Text('🎁 صندوق المكافآت الأسطوري!', style: TextStyle(fontSize: 18, color: Colors.amberAccent, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
                        onPressed: () {
                          setState(() {
                            globalCoins += 75;
                            showMysteryChest = false;
                          });
                          playRealSound('coin');
                          _spawnEnemies();
                        },
                        child: const Text('احصل على 75 عملة مجانية!', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),

            ...coins.map((c) => Positioned(
              left: c['x'] - 10, top: c['y'] - 10,
              child: Container(
                width: 20, height: 20,
                decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
                child: const Center(child: Text('🪙', style: TextStyle(fontSize: 10))),
              ),
            )),

            ...enemies.map((en) => Positioned(
              left: en['x'] - en['radius'], top: en['y'] - en['radius'],
              child: Container(
                width: en['radius'] * 2, height: en['radius'] * 2,
                decoration: BoxDecoration(
