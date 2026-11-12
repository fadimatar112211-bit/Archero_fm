import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(const ArcheroMasterApp());
}

class ArcheroMasterApp extends StatelessWidget {
  const ArcheroMasterApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Archero Flutter Ultimate Edition',
      theme: ThemeData.dark(),
      home: const HeroSelectionScreen(),
    );
  }
}

// ==========================================
// 1. شاشة اختيار الأبطال الأربعة الأسطوريين
// ==========================================
class HeroSelectionScreen extends StatelessWidget {
  const HeroSelectionScreen({Key? key}) : super(key: key);

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
              const Icon(Icons.shield, size: 60, color: Colors.amber),
              const SizedBox(height: 15),
              const Text(
                'اختر بطلك الأسطوري',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.amberAccent),
              ),
              const SizedBox(height: 8),
              const Text(
                'كل بطل يمتلك ميزات وقدرات فريدة لخوض المعركة',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 35),
              _buildHeroCard(context, 'البطل الأول: الرامي المتوازن', 'سرعة وصحة متوازنة للمعارك الكلاسيكية', 1, Colors.blue),
              _buildHeroCard(context, 'البطل الثاني: فارس النارية', 'صحة عالية جداً لتحمل ضربات الأعداء', 2, Colors.deepOrange),
              _buildHeroCard(context, 'البطل الثالث: صياد الظل', 'سرعة حركة فائقة للتفادي السريع', 3, Colors.purple),
              _buildHeroCard(context, 'البطل الرابع: حارس العواصف', 'إطلاق سهم مزدوج مدمر في كل ضربة', 4, Colors.teal),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context, String title, String desc, int type, Color color) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.8),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 5,
        ),
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => GameScreen(heroType: type)),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(desc, style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 2. محرك اللعبة الرئيسي والشاشات التفاعلية
// ==========================================
class GameScreen extends StatefulWidget {
  final int heroType;
  const GameScreen({Key? key, required this.heroType}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // خصائص البطل
  double playerX = 200;
  double playerY = 500;
  double playerHp = 100;
  double playerMaxHp = 100;
  double playerSpeed = 3.5;
  
  // حالة اللعبة والمراحل
  int score = 0;
  int stage = 1;
  int specialCooldown = 0;
  Timer? gameLoopTimer;
  Timer? shootTimer;

  // قوائم الكائنات داخل اللعبة
  List> enemies = [];
  List> arrows = [];
  List> enemyProjectiles = [];

  @override
  void initState() {
    super.initState();
    _applyHeroConfiguration();
    _generateStageContent();
    
    // تشغيل محرك اللعبة الأساسي (60 إطاراً في الثانية تقريباً)
    gameLoopTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (mounted) {
        setState(() {
          _updateGameEngine();
        });
      }
    });

    // إطلاق السهام التلقائي نحو الأعداء
    shootTimer = Timer.periodic(const Duration(milliseconds: 700), (timer) {
      if (mounted && enemies.isNotEmpty) {
        _triggerPlayerAttack();
      }
    });
  }

  // تخصيص إحصائيات الأبطال الأربعة بدقة
  void _applyHeroConfiguration() {
    if (widget.heroType == 2) {
      playerHp = 150;
      playerMaxHp = 150;
    } else if (widget.heroType == 3) {
      playerSpeed = 5.2;
    } else if (widget.heroType == 4) {
      playerHp = 120;
      playerMaxHp = 120;
    }
  }

  // توليد مراحل اللعبة والأعداء والزعماء
  void _generateStageContent() {
    enemies.clear();
    arrows.clear();
    enemyProjectiles.clear();

    bool isBossStage = (stage % 5 == 0);

    if (isBossStage) {
      // توليد زعيم ضخم في نهاية كل خمس مراحل
      enemies.add({
        'x': 200.0,
        'y': 120.0,
        'hp': 250.0 + (stage * 40),
        'maxHp': 250.0 + (stage * 40),
        'type': 'boss',
        'radius': 36.0,
        'speed': 1.1,
      });
    } else {
      // توليد أعداء متنوعين (رماة وقريبين)
      int enemyCount = min(2 + (stage ~/ 2), 7);
      for (int i = 0; i < enemyCount; i++) {
        bool isRanged = Random().nextBool();
        enemies.add({
          'x': Random().nextDouble() * 320 + 40,
          'y': Random().nextDouble() * 220 + 40,
          'hp': 45.0 + (stage * 15),
          'maxHp': 45.0 + (stage * 15),
          'type': isRanged ? 'ranged' : 'melee',
          'radius': 20.0,
          'speed': 1.2 + (stage * 0.04),
        });
      }
    }
  }

  // ميكانيكية إطلاق السهام والتصويب الذكي
  void _triggerPlayerAttack() {
    if (enemies.isEmpty) return;
    var target = enemies[0];
    double angle = atan2(target['y'] - playerY, target['x'] - playerX);

    // البطل الرابع يطلق سهمين مزدوجين تماماً مثل المواصفات المطلوبة
    int shootCount = (widget.heroType == 4) ? 2 : 1;
    for (int i = 0; i < shootCount; i++) {
      double spreadAngle = (i == 0) ? 0 : 0.22;
      arrows.add({
        'x': playerX,
        'y': playerY,
        'vx': cos(angle + spreadAngle) * 8.0,
        'vy': sin(angle + spreadAngle) * 8.0,
      });
    }
  }

  // ميكانيكية الضربة الخاصة الخارقة
  void _executeSpecialSkill() {
    if (specialCooldown > 0) return;
    setState(() {
      score += enemies.length * 20;
      enemies.clear();
      enemyProjectiles.clear();
      specialCooldown = 15; // فترة انتظار بالثواني
    });

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (specialCooldown > 0) {
          specialCooldown--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  // المعالج الحسابي لتحديث مواقع وحركات اللعبة بإستمرار
  void _updateGameEngine() {
    // 1. تحديث حركات السهام ومساراتها
    for (int i = arrows.length - 1; i >= 0; i--) {
      arrows[i]['x'] += arrows[i]['vx'];
      arrows[i]['y'] += arrows[i]['vy'];

      // التحقق من اصطدام السهم بالأعداء
      for (int j = enemies.length - 1; j >= 0; j--) {
        double distance = _calculateHypotenuse(arrows[i]['x'] - enemies[j]['x'], arrows[i]['y'] - enemies[j]['y']);
        if (distance < enemies[j]['radius']) {
          enemies[j]['hp'] -= 35;
          arrows.removeAt(i);
          if (enemies[j]['hp'] <= 0) {
            enemies.removeAt(j);
            score += 15;
          }
          break;
        }
      }
    }

    // 2. تحديث حركة الأعداء واقترابهم من البطل
    for (var en in enemies) {
      double angle = atan2(playerY - en['y'], playerX - en['x']);
      en['x'] += cos(angle) * en['speed'];
      en['y'] += sin(angle) * en['speed'];

      // اصطدام العدو بالبطل (خصم نقاط الصحة)
      double distToPlayer = _calculateHypotenuse(playerX - en['x'], playerY - en['y']);
      if (distToPlayer < 20 + en['radius']) {
        playerHp -= 0.5;
      }
    }

    // 3. التحقق من انتهاء أعداء المرحلة وانتقال مرحلي متسلسل
    if (enemies.isEmpty) {
      stage++;
      playerHp = min(playerMaxHp, playerHp + 25); // استعادة جزء من الصحة عند إنهاء المرحلة
      _generateStageContent();
    }

    // 4. فحص حالة خسارة اللاعب
    if (playerHp <= 0) {
      _terminateGameSession();
    }
  }

  double _calculateHypotenuse(double dx, double dy) => sqrt(dx * dx + dy * dy);

  void _terminateGameSession() {
    gameLoopTimer?.cancel();
    shootTimer?.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('انتهت المعركة', style: TextStyle(color: Colors.redAccent)),
        content: Text('لقد قاتلت بشجاعة حتى:\nالمرحلة رقم: $stage\nالنقاط الكلية: $score'),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HeroSelectionScreen()),
              );
            },
            child: const Text('العب من جديد'),
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
      backgroundColor: const Color(0xFF181b22),
      body: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            playerX += details.delta.dx * (playerSpeed / 3.5);
            playerY += details.delta.dy * (playerSpeed / 3.5);
            playerX = playerX.clamp(25.0, 375.0);
            playerY = playerY.clamp(70.0, 560.0);
          });
        },
        child: Stack(
          children: [
            // الشريط العلوي لمعلومات اللعبة (المرحلة، النقاط، الصحة)
            Positioned(
              top: 45,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('المرحلة: $stage', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
                    Text('النقاط: $score', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    Text('الصحة: ${(playerHp / playerMaxHp * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
                  ],
                ),
              ),
            ),

            // رسم الأعداء والزعماء على مسرح اللعب
            ...enemies.map((en) => Positioned(
              left: en['x'] - en['radius'],
              top: en['y'] - en['radius'],
              child: Column(
                children: [
                  Container(
                    width: en['radius'] * 2,
                    height: en['radius'] * 2,
                    decoration: BoxDecoration(
                      color: en['type'] == 'boss' ? Colors.deepPurple : (en['type'] == 'ranged' ? Colors.orangeAccent : Colors.red),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 6)],
                    ),
                    child: Center(
                      child: Icon(
                        en['type'] == 'boss' ? Icons.android : Icons.bug_report,
                        color: Colors.white,
                        size: en['radius'] * 0.9,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  // شريط حياة مصغر فوق رأس العدو
                  Container(
                    width: 35,
                    height: 4,
                    color: Colors.black54,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 35 * (en['hp'] / en['maxHp']).clamp(0.0, 1.0),
                        height: 4,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            )),

            // رسم البطل في الموقع الحالي
            Positioned(
              left: playerX - 20,
              top: playerY - 20,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: widget.heroType == 2 ? Colors.orange : (widget.heroType == 3 ? Colors.purple : Colors.blue),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Center(
                  child: Icon(Icons.navigation, color: Colors.white, size: 22),
                ),
              ),
            ),

            // رسم الأسهم المقذوفة نحو الأهداف
            ...arrows.map((arr) => Positioned(
              left: arr['x'] - 6,
              top: arr['y'] - 6,
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.yellowAccent,
                  shape: BoxShape.circle,
                ),
              ),
            )),

            // زر الضربة الخاصة الخارقة في الزاوية السفلى
            Positioned(
              bottom: 35,
              right: 25,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: specialCooldown > 0 ? Colors.grey : Colors.red,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(22),
                  elevation: 8,
                ),
                onPressed: specialCooldown > 0 ? null : _executeSpecialSkill,
                child: Text(
                  specialCooldown > 0 ? '$specialCooldown ث' : 'خاصة',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
