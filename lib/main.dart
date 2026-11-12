import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const ArcheroMultiplayerApp());
}

class ArcheroMultiplayerApp extends StatelessWidget {
  const ArcheroMultiplayerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Archero Multiplayer Sprites',
      theme: ThemeData.dark(),
      home: const LobbyScreen(),
    );
  }
}

// 1. شاشة اللوبي واختيار الغرفة والبطر
class LobbyScreen extends StatefulWidget {
  const LobbyScreen({Key? key}) : super(key: key);

  @override
  _LobbyScreenState createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  String selectedHero = 'archer';
  final TextEditingController _roomController = TextEditingController(text: 'room123');
  final TextEditingController _nameController = TextEditingController(text: 'Player1');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '🎮 Archero Multiplayer',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF38BDF8)),
              ),
              const SizedBox(height: 15),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'اسم اللاعب', labelStyle: TextStyle(color: Colors.grey)),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _roomController,
                      decoration: const InputDecoration(labelText: 'رقم أو اسم الغرفة (Room ID)', labelStyle: TextStyle(color: Colors.grey)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text('اختر بطلك الأسطوري', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 10),

              _buildHeroCard('archer', '🏹 الرامي السريع', const Color(0xFF0284C7)),
              _buildHeroCard('swordsman', '⚔️ السياف الفولاذي', const Color(0xFFD97706)),
              _buildHeroCard('mage', '🔮 الساحر الأركاني', const Color(0xFF7C3AED)),
              _buildHeroCard('bomber', '💣 قاذف القنابل', const Color(0xFF15803D)),
              
              const SizedBox(height: 25),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GameScreen(
                        heroType: selectedHero,
                        roomName: _roomController.text,
                        playerName: _nameController.text,
                      ),
                    ),
                  );
                },
                child: const Text('دخول المعركة الجماعية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(String id, String title, Color color) {
    bool isSelected = selectedHero == id;
    return GestureDetector(
      onTap: () => setState(() => selectedHero = id),
      child: Container(
        width: 280,
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E293B) : const Color(0xFF111827),
          border: Border.all(color: isSelected ? const Color(0xFF38BDF8) : Colors.grey.shade800, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
            Container(width: 14, height: 14, decoration: BoxDecoration(color: color, shape: BoxShape.circle))
          ],
        ),
      ),
    );
  }
}

// النماذج
class EnemyModel {
  Offset pos;
  double hp;
  double maxHp;
  double speed;
  bool isBoss;
  Color color;
  EnemyModel({required this.pos, required this.hp, required this.maxHp, required this.speed, this.isBoss = false, required this.color});
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

class RemotePlayer {
  String name;
  Offset pos;
  String heroType;
  RemotePlayer({required this.name, required this.pos, required this.heroType});
}

// 2. شاشة اللعب الجماعي
class GameScreen extends StatefulWidget {
  final String heroType;
  final String roomName;
  final String playerName;

  const GameScreen({Key? key, required this.heroType, required this.roomName, required this.playerName}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  Offset playerPos = const Offset(200, 400);
  double playerHp = 100;
  double playerMaxHp = 100;

  int roomNum = 1;
  int xpCount = 0;
  int currentLevel = 1;

  List<EnemyModel> enemies = [];
  List<BulletModel> bullets = [];
  List<ParticleFX> particles = [];
  List<RemotePlayer> otherPlayers = [];

  bool isMoving = false;
  int lastShotTick = 0;
  int syncTick = 0;
  
  bool hasDoubleShot = false;
  bool hasSideShot = false;
  bool hasFireArrows = false;
  bool showSkillDialog = false;
  bool isGameOver = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      initRoom();
      otherPlayers.add(RemotePlayer(name: 'صديقك (Peer)', pos: const Offset(150, 200), heroType: 'mage'));
    });

    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..addListener(_updateGameLoop)
      ..repeat();
  }

  void initRoom() {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    
    if (roomNum % 5 == 0) {
      enemies = [
        EnemyModel(
          pos: Offset(w * 0.5, h * 0.2),
          hp: 350 + (roomNum * 20),
          maxHp: 350 + (roomNum * 20),
          speed: 0.6 + (roomNum * 0.02),
          isBoss: true,
          color: const Color(0xFFDC2626),
        ),
      ];
    } else {
      int enemyCount = 3 + (roomNum ~/ 2);
      enemies = [];
      Random r = Random();
      for (int i = 0; i < enemyCount; i++) {
        enemies.add(EnemyModel(
          pos: Offset(r.nextDouble() * (w - 100) + 50, r.nextDouble() * (h * 0.4) + 50),
          hp: 40 + (roomNum * 10),
          maxHp: 40 + (roomNum * 10),
          speed: 0.8 + r.nextDouble() * 0.5,
          color: i % 2 == 0 ? const Color(0xFFEF4444) : const Color(0xFFA855F7),
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
      syncTick++;
      if (otherPlayers.isNotEmpty) {
        otherPlayers[0].pos += Offset(sin(syncTick * 0.05) * 1.5, cos(syncTick * 0.05) * 1.0);
      }

      for (var enemy in enemies) {
        final direction = (playerPos - enemy.pos);
        final distance = direction.distance;
        if (distance > 5) {
          final normalized = direction / distance;
          enemy.pos += normalized * enemy.speed;
        }

        if (distance < 30) {
          playerHp -= 0.5;
          if (playerHp <= 0) {
            playerHp = 0;
            isGameOver = true;
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
          double newAngle = currentAngle + (targetAngle - currentAngle) * 0.1;
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
            double damage = widget.heroType == 'swordsman' ? 45 : (bullets[i].isFire ? 35 : 20);
            enemies[j].hp -= damage;
            
            createExplosion(bullets[i].pos, bullets[i].isFire ? Colors.redAccent : Colors.orangeAccent);

            bullets.removeAt(i);
            if (enemies[j].hp <= 0) {
              xpCount += enemies[j].isBoss ? 100 : 25;
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
        int fireRate = widget.heroType == 'swordsman' ? 35 : (widget.heroType == 'archer' ? 15 : 25);
        if (lastShotTick > fireRate) {
          lastShotTick = 0;
          final target = enemies.first.pos;
          final baseAngle = atan2(target.dy - playerPos.dy, target.dx - playerPos.dx);

          bool isHomingMage = widget.heroType == 'mage';

          if (widget.heroType != 'swordsman') {
            bullets.add(BulletModel(pos: playerPos, velocity: Offset(cos(baseAngle) * 11, sin(baseAngle) * 11), isHoming: isHomingMage, isFire: hasFireArrows));

            if (hasDoubleShot) {
              bullets.add(BulletModel(pos: playerPos, velocity: Offset(cos(baseAngle + 0.25) * 11, sin(baseAngle + 0.25) * 11), isHoming: isHomingMage, isFire: hasFireArrows));
            }
            if (hasSideShot) {
              bullets.add(BulletModel(pos: playerPos, velocity: Offset(cos(baseAngle - 1.57) * 10, sin(baseAngle - 1.57) * 10), isHoming: isHomingMage, isFire: hasFireArrows));
              bullets.add(BulletModel(pos: playerPos, velocity: Offset(cos(baseAngle + 1.57) * 10, sin(baseAngle + 1.57) * 10), isHoming: isHomingMage, isFire: hasFireArrows));
            }
          } else {
            for (var enemy in enemies) {
              if ((playerPos - enemy.pos).distance < 70) {
                enemy.hp -= 45;
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF131B2E),
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
                otherPlayers: otherPlayers,
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
                    Text('الغرفة: ${widget.roomName} | لفل: $currentLevel', style: const TextStyle(color: Color(0xFF4ADE80), fontSize: 13, fontWeight: FontWeight.bold)),
                    Text('XP: $xpCount/50', style: const TextStyle(color: Colors.yellow, fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  height: 10,
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(5)),
                  child: Row(
                    children: [
                      Expanded(
                        flex: (playerHp).toInt(),
                        child: Container(decoration: BoxDecoration(color: Colors.greenAccent, borderRadius: BorderRadius.circular(5))),
                      ),
                      Expanded(
                        flex: (playerMaxHp - playerHp).toInt(),
                        child: Container(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 30,
            right: 30,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  for (var enemy in enemies) {
                    enemy.hp -= 120;
                    createExplosion(enemy.pos, Colors.red);
                  }
                  enemies.removeWhere((e) => e.hp <= 0);
                  if (enemies.isEmpty) {
                    roomNum++;
                    initRoom();
                  }
                });
              },
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFDC2626),
                  border: Border.all(color: Colors.yellow, width: 3),
                ),
                child: const Center(
                  child: Text('سبيشل\n🔥 قنبلة', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),

          if (isGameOver)
            Container(
              color: Colors.black87,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('💀 انتهت المعركة', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      onPressed: () {
                        setState(() {
                          playerHp = 100;
                          roomNum = 1;
                          currentLevel = 1;
                          xpCount = 0;
                          isGameOver = false;
                          initRoom();
                        });
                      },
                      child: const Text('إعادة المحاولة', style: TextStyle(fontSize: 16)),
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
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF38BDF8), width: 2),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🎉 لفل أب! اختر مهارة جديدة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.yellow)),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                        onPressed: () {
                          setState(() {
                            hasFireArrows = true;
                            showSkillDialog = false;
                          });
                        },
                        child: const Text('🔥 أسهم نارية حارقة'),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                        onPressed: () {
                          setState(() {
                            hasDoubleShot = true;
                            showSkillDialog = false;
                          });
                        },
                        child: const Text('🏹 طلقة مزدوجة'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// 3. رسام الشخصيات والأشكال الحقيقية للعبة (Sprites & Characters Painter)
class GamePainter extends CustomPainter {
  final Offset playerPos;
  final String playerName;
  final String heroType;
  final List<EnemyModel> enemies;
  final List<BulletModel> bullets;
  final List<ParticleFX> particles;
  final List<RemotePlayer> otherPlayers;

  GamePainter({
    required this.playerPos,
    required this.playerName,
    required this.heroType,
    required this.enemies,
    required this.bullets,
    required this.particles,
    required this.ot
