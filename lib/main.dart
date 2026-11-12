import 'package:flutter/material.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const ArcheroProApp());
}

class ArcheroProApp extends StatelessWidget {
  const ArcheroProApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Archero Pro - Ultimate',
      theme: ThemeData.dark(),
      home: const LobbyScreen(),
    );
  }
}

// 1. شاشة اللوبي واختيار الأبطال
class LobbyScreen extends StatefulWidget {
  const LobbyScreen({Key? key}) : super(key: key);

  @override
  _LobbyScreenState createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  String selectedHero = 'archer'; // 'archer', 'swordsman', 'mage'
  final TextEditingController _nameController = TextEditingController(text: 'HeroPlayer');
  
  int savedGold = 0;
  int extraDamageLevel = 0;
  int extraHpLevel = 0;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      savedGold = prefs.getInt('player_gold') ?? 0;
      extraDamageLevel = prefs.getInt('upgrade_damage') ?? 0;
      extraHpLevel = prefs.getInt('upgrade_hp') ?? 0;
    });
  }

  Future<void> _buyUpgrade(String type) async {
    final prefs = await SharedPreferences.getInstance();
    int cost = (type == 'damage' ? (extraDamageLevel + 1) * 50 : (extraHpLevel + 1) * 40);
    
    if (savedGold >= cost) {
      savedGold -= cost;
      if (type == 'damage') {
        extraDamageLevel++;
        await prefs.setInt('upgrade_damage', extraDamageLevel);
      } else {
        extraHpLevel++;
        await prefs.setInt('upgrade_hp', extraHpLevel);
      }
      await prefs.setInt('player_gold', savedGold);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '🛡️ ARCHERO: ULTIMATE EDITION ⚔️',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.amberAccent),
              ),
              const SizedBox(height: 8),
              Text('💰 رصيد الذهب: $savedGold', style: const TextStyle(fontSize: 18, color: Colors.yellow, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'اسم البطل', labelStyle: TextStyle(color: Colors.grey)),
                ),
              ),
              const SizedBox(height: 20),
              
              // متجر الترقيات الدائمة
              Container(
                width: 310,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber, width: 1.5),
                ),
                child: Column(
                  children: [
                    const Text('🛒 متجر العتاد والترقيات الدائمة', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('قوة الهجوم (Lv.$extraDamageLevel)', style: const TextStyle(fontSize: 12, color: Colors.white70)),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade800, padding: const EdgeInsets.symmetric(horizontal: 10)),
                          onPressed: () => _buyUpgrade('damage'),
                          child: Text('${(extraDamageLevel + 1) * 50} 🪙'),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('الصحة القصوى (Lv.$extraHpLevel)', style: const TextStyle(fontSize: 12, color: Colors.white70)),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade800, padding: const EdgeInsets.symmetric(horizontal: 10)),
                          onPressed: () => _buyUpgrade('hp'),
                          child: Text('${(extraHpLevel + 1) * 40} 🪙'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              const Text('اختر بطل المعركة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildHeroCard('archer', '🏹 رامي القوس', 'assets/images/hero_archer.png'),
                  _buildHeroCard('swordsman', '⚔️ السياف', 'assets/images/hero_sword.png'),
                  _buildHeroCard('mage', '🔮 الساحر', 'assets/images/hero_mage.png'),
                ],
              ),
              
              const SizedBox(height: 25),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GameScreen(
                        heroType: selectedHero,
                        playerName: _nameController.text,
                        extraDamage: extraDamageLevel * 6,
                        extraHp: extraHpLevel * 25,
                      ),
                    ),
                  );
                },
                child: const Text('بدء الغارة القتالية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(String id, String title, String assetPath) {
    bool isSelected = selectedHero == id;
    return GestureDetector(
      onTap: () => setState(() => selectedHero = id),
      child: Container(
        width: 95,
        height: 110,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF334155) : const Color(0xFF1E293B),
          border: Border.all(color: isSelected ? Colors.amber : Colors.grey.shade800, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // عرض صورة البطل أو أيقونة بديلة إن لم تتوفر الصورة بعد
            Expanded(
              child: Image.asset(
                assetPath,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 40, color: Colors.blueAccent),
              ),
            ),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}

// نماذج البيانات
class EnemyModel {
  Offset pos;
  double hp;
  double maxHp;
  double speed;
  bool isBoss;
  String type; // 'goblin', 'skeleton', 'boss'
  EnemyModel({required this.pos, required this.hp, required this.maxHp, required this.speed, this.isBoss = false, required this.type});
}

class BulletModel {
  Offset pos;
  Offset velocity;
  bool isHoming;
  bool isFire;
  BulletModel({required this.pos, required this.velocity, this.isHoming = false, this.isFire = false});
}

class ParticleFX {
  Offset pos;
  Offset velocity;
  double radius;
  Color color;
  int life;
  ParticleFX({required this.pos, required this.velocity, required this.radius, required this.color, this.life = 15});
}

// 2. شاشة القتال المتقدمة
class GameScreen extends StatefulWidget {
  final String heroType;
  final String playerName;
  final int extraDamage;
  final int extraHp;

  const GameScreen({
    Key? key,
    required this.heroType,
    required this.playerName,
    required this.extraDamage,
    required this.extraHp,
  }) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final AudioPlayer _audioPlayer = AudioPlayer();

  Offset playerPos = const Offset(200, 400);
  late double playerHp;
  late double playerMaxHp;

  int roomNum = 1;
  int xpCount = 0;
  int currentLevel = 1;
  int currentGold = 0;

  List<EnemyModel> enemies = [];
  List<BulletModel> bullets = [];
  List<ParticleFX> particles = [];

  bool isMoving = false;
  int lastShotTick = 0;
  
  bool hasDoubleShot = false;
  bool hasFireArrows = false;
  bool showSkillDialog = false;
  bool isGameOver = false;

  @override
  void initState() {
    super.initState();
    playerMaxHp = 120.0 + widget.extraHp;
    playerHp = playerMaxHp;

    Future.delayed(const Duration(milliseconds: 100), () {
      initRoom();
    });

    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..addListener(_updateGameLoop)
      ..repeat();
  }

  Future<void> _playSound(String soundName) async {
    try {
      // تشغيل المؤثرات الصوتية عند توفرها في assets/audio/
      // await _audioPlayer.play(AssetSource('audio/$soundName.mp3'));
    } catch (_) {}
  }

  Future<void> _saveGoldOnExit() async {
    final prefs = await SharedPreferences.getInstance();
    int totalGold = (prefs.getInt('player_gold') ?? 0) + currentGold;
    await prefs.setInt('player_gold', totalGold);
  }

  void initRoom() {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    
    if (roomNum % 5 == 0) {
      enemies = [
        EnemyModel(
          pos: Offset(w * 0.5, h * 0.2),
          hp: 450 + (roomNum * 30),
          maxHp: 450 + (roomNum * 30),
          speed: 0.7 + (roomNum * 0.02),
          isBoss: true,
          type: 'boss',
        ),
      ];
    } else {
      int enemyCount = 3 + (roomNum ~/ 2);
      enemies = [];
      Random r = Random();
      for (int i = 0; i < enemyCount; i++) {
        String type = i % 2 == 0 ? 'goblin' : 'skeleton';
        enemies.add(EnemyModel(
          pos: Offset(r.nextDouble() * (w - 100) + 50, r.nextDouble() * (h * 0.4) + 50),
          hp: 50 + (roomNum * 12),
          maxHp: 50 + (roomNum * 12),
          speed: 0.9 + r.nextDouble() * 0.4,
          type: type,
        ));
      }
    }
  }

  void createExplosion(Offset pos, Color color) {
    Random r = Random();
    for (int i = 0; i < 8; i++) {
      double angle = r.nextDouble() * 2 * pi;
      double speed = r.nextDouble() * 4 + 1;
      particles.add(ParticleFX(
        pos: pos,
        velocity: Offset(cos(angle) * speed, sin(angle) * speed),
        radius: r.nextDouble() * 4 + 2,
        color: color,
        life: 12 + r.nextInt(8),
      ));
    }
  }

  void _updateGameLoop() {
    if (!mounted || showSkillDialog || isGameOver) return;
    setState(() {
      for (var enemy in enemies) {
        final direction = (playerPos - enemy.pos);
        final distance = direction.distance;
        if (distance > 5) {
          enemy.pos += (direction / distance) * enemy.speed;
        }

        if (distance < 30) {
          playerHp -= 0.6;
          if (playerHp <= 0) {
            playerHp = 0;
            isGameOver = true;
            _saveGoldOnExit();
          }
        }
      }

      for (int i = particles.length - 1; i >= 0; i--) {
        particles[i].pos += particles[i].velocity;
        particles[i].life--;
        if (particles[i].life <= 0) particles.removeAt(i);
      }

      for (int i = bullets.length - 1; i >= 0; i--) {
        if (bullets[i].isHoming && enemies.isNotEmpty) {
          final target = enemies.first.pos;
          final currentAngle = atan2(bullets[i].velocity.dy, bullets[i].velocity.dx);
          final targetAngle = atan2(target.dy - bullets[i].pos.dy, target.dx - bullets[i].pos.dx);
          double newAngle = currentAngle + (targetAngle - currentAngle) * 0.12;
          double speed = bullets[i].velocity.distance;
          bullets[i].velocity = Offset(cos(newAngle) * speed, sin(newAngle) * speed);
        }

        bullets[i].pos += bullets[i].velocity;
        if (bullets[i].pos.dx < 0 || bullets[i].pos.dx > MediaQuery.of(context).size.width ||
            bullets[i].pos.dy < 0 || bullets[i].pos.dy > MediaQuery.of(context).size.height) {
          bullets.removeAt(i);
          continue;
        }

        for (int j = enemies.length - 1; j >= 0; j--) {
          double hitRadius = enemies[j].isBoss ? 35 : 20;
          if ((bullets[i].pos - enemies[j].pos).distance < hitRadius) {
            double baseDmg = widget.heroType == 'swordsman' ? 50 : (bullets[i].isFire ? 40 : 25);
            double damage = baseDmg + widget.extraDamage;
            
            enemies[j].hp -= damage;
            createExplosion(bullets[i].pos, bullets[i].isFire ? Colors.redAccent : Colors.amber);

            bullets.removeAt(i);
            if (enemies[j].hp <= 0) {
              xpCount += enemies[j].isBoss ? 100 : 25;
              currentGold += enemies[j].isBoss ? 60 : 12;
              createExplosion(enemies[j].pos, Colors.yellow);
              enemies.removeAt(j);
              
              if (enemies.isEmpty && !showSkillDialog) {
                roomNum++;
                initRoom();
              }

              if (xpCount >= 50 && !showSkillDialog) {
                xpCount = 0;
                currentLevel++;
                showSkillDialog = true;
              }
            }
            break;
          }
        }
      }

      if (!isMoving && enemies.isNotEmpty) {
        lastShotTick++;
        int fireRate = widget.heroType == 'swordsman' ? 30 : (widget.heroType == 'archer' ? 14 : 22);
        if (lastShotTick > fireRate) {
          lastShotTick = 0;
          final target = enemies.first.pos;
          final baseAngle = atan2(target.dy - playerPos.dy, target.dx - playerPos.dx);
          bool isHomingMage = widget.heroType == 'mage';

          _playSound('shoot');

          if (widget.heroType != 'swordsman') {
            bullets.add(BulletModel(pos: playerPos, velocity: Offset(cos(baseAngle) * 12, sin(baseAngle) * 12), isHoming: isHomingMage, isFire: hasFireArrows));
            if (hasDoubleShot) {
              bullets.add(BulletModel(pos: playerPos, velocity: Offset(cos(baseAngle + 0.25) * 12, sin(baseAngle + 0.25) * 12), isHoming: isHomingMage, isFire: hasFireArrows));
            }
          } else {
            for (var enemy in enemies) {
              if ((playerPos - enemy.pos).distance < 75) {
                enemy.hp -= (50 + widget.extraDamage);
                createExplosion(enemy.pos, Colors.orange);
              }
            }
            enemies.removeWhere((e) => e.hp <= 0);
            if (enemies.isEmpty) {
              roomNum++;
              initRoom();
            }
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          GestureDetector(
            onPanStart: (_) => setState(() => isMoving = true),
            onPanUpdate: (details) {
              setState(() {
                isMoving = true;
                playerPos += details.delta;
              });
            },
            onPanEnd: (_) => setState(() => isMoving = false),
            child: CustomPaint(
              size: MediaQuery.of(context).size,
              painter: GamePainter(
                playerPos: playerPos,
                playerName: widget.playerName,
                heroType: widget.heroType,
                enemies: enemies,
                bullets: bullets,
                particles: particles,
              ),
            ),
          ),
          
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('المرحلة (Room): $roomNum | لفل: $currentLevel', style: const TextStyle(color: Color(0xFF4ADE80), fontSize: 13, fontWeight: FontWeight.bold)),
                    Text('🪙 ذهب: $currentGold | XP: $xpCount/50', style: const TextStyle(color: Colors.yellow, fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  height: 10,
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(5)),
                  child: Row(
                    children: [
                      Expanded(
                        flex: (playerHp).clamp(0, playerMaxHp).toInt(),
                        child: Container(decoration: BoxDecoration(color: Colors.greenAccent, borderRadius: BorderRadius.circular(5))),
                      ),
                      Expanded(
                        flex: (playerMaxHp - playerHp).clamp(0, playerMaxHp).toInt(),
                        child: Container(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (isGameOver)
            Container(
              color: Colors.black87,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('💀 سقط البطل في المعركة', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                    const SizedBox(height: 10),
                    Text('تم حفظ أرباحك: $currentGold 🪙', style: const TextStyle(fontSize: 16, color: Colors.yellow)),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LobbyScreen()),
                        );
                      },
                      child: const Text('العودة للقائمة الرئيسية', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),

          if (showSkillDialog)
            Container(
              color: Colors.black54,
              child: Center(
                child: Container(
                  width: 320,
                  padding: const EdgeInsets.all(20),
                  dec
