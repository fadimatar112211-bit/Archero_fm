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
      title: 'Archero Ultimate Edition',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const CharacterSelectionScreen(),
    );
  }
}

// ==================== شاشة اختيار الشخصيات ====================
class CharacterSelectionScreen extends StatelessWidget {
  const CharacterSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List> heroes = [
      {'name': 'الرامي الرشيق (Archer)', 'color': Colors.redAccent, 'special': 'سهام متعددة وسريعة', 'hp': 5},
      {'name': 'الساحر القوي (Mage)', 'color': Colors.purpleAccent, 'special': 'كرة سحرية خارقة', 'hp': 4},
      {'name': 'المحارب الصلب (Warrior)', 'color': Colors.orangeAccent, 'special': 'درع دفاعي وصحة عالية', 'hp': 8},
      {'name': 'القاتل الخفي (Assassin)', 'color': Colors.cyanAccent, 'special': 'سرعة فائقة وهجوم خاطف', 'hp': 4},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('اختر بطلك الأسطوري'),
        backgroundColor: Colors.black54,
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: heroes.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final hero = heroes[index];
          return Card(
            color: const Color(0xFF1E1E1E),
            margin: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              leading: CircleAvatar(backgroundColor: hero['color'], radius: 25),
              title: Text(hero['name'], style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              subtitle: Text('القدرة: ${hero['special']}', style: const TextStyle(color: Colors.white70)),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GameScreen(heroName: hero['name'], heroColor: hero['color'], maxHp: hero['hp']),
                    ),
                  );
                },
                child: const Text('بدء القتال', style: TextStyle(color: Colors.white)),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ==================== شاشة اللعب الرئيسية ====================
class GameScreen extends StatefulWidget {
  final String heroName;
  final Color heroColor;
  final int maxHp;

  const GameScreen({Key? key, required this.heroName, required this.heroColor, required this.maxHp}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  Offset playerPos = const Offset(180, 500);
  List<Offset> arrows = [];
  List> monsters = [];
  
  final List<Rect> obstacles = [
    const Rect.fromLTWH(100, 200, 80, 30),
    const Rect.fromLTWH(220, 380, 90, 30),
  ];

  Timer? gameLoopTimer;
  int score = 0;
  int xp = 0;
  late int health;
  bool isGameOver = false;
  bool showSkillSelection = false;
  
  bool extraArrows = false;
  bool fastAttack = false;

  final Random random = Random();

  @override
  void initState() {
    super.initState();
    health = widget.maxHp;
    startGameLoop();
  }

  void startGameLoop() {
    gameLoopTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (isGameOver || showSkillSelection) return;

      setState(() {
        // 1. تحريك السهام
        List<Offset> nextArrows = [];
        for (var arrow in arrows) {
          if (arrow.dy > 0) {
            Offset nextA = Offset(arrow.dx, arrow.dy - 14);
            bool hitObstacle = false;
            for (var obs in obstacles) {
              if (obs.contains(nextA)) {
                hitObstacle = true;
                break;
              }
            }
            if (!hitObstacle) {
              nextArrows.add(nextA);
            }
          }
        }
        arrows = nextArrows;

        // 2. تحريك الوحوش والزعماء
        List> updatedMonstersList = [];
        for (var monster in monsters) {
          double speed = monster['isBoss'] ? 1.2 : 2.0;
          double newY = monster['pos'].dy + speed;
          Offset newPos = Offset(monster['pos'].dx, newY);

          bool hitObs = false;
          for (var obs in obstacles) {
            if (obs.contains(newPos)) {
              hitObs = true;
              break;
            }
          }

          if ((newPos - playerPos).distance < 35) {
            health -= monster['isBoss'] ? 2 : 1;
            if (health <= 0) {
              isGameOver = true;
            }
          } else if (!hitObs && newY < 680) {
            updatedMonstersList.add({
              'pos': newPos,
              'type': monster['type'],
              'hp': monster['hp'],
              'isBoss': monster['isBoss']
            });
          }
        }
        monsters = updatedMonstersList;

        // 3. فحص السهام والضربات
        List<Offset> survivingArrows = [];
        for (var arrow in arrows) {
          bool hit = false;
          List> survivingMonsters = [];
          for (var monster in monsters) {
            if (!hit && (arrow - monster['pos']).distance < (monster['isBoss'] ? 40 : 25)) {
              hit = true;
              monster['hp'] -= 1;
              if (monster['hp'] <= 0) {
                score += monster['isBoss'] ? 50 : 15;
                xp += 10;
                if (xp >= 50) {
                  xp = 0;
                  showSkillSelection = true;
                }
              }
            }
            if (monster['hp'] > 0) {
              survivingMonsters.add(monster);
            }
          }
          monsters = survivingMonsters;
          if (!hit) {
            survivingArrows.add(arrow);
          }
        }
        arrows = survivingArrows;

        // 4. إطلاق السهام
        int shootRate = fastAttack ? 15 : 22;
        if (random.nextInt(shootRate) == 0) {
          arrows.add(playerPos);
          if (widget.heroName.contains('الرامي') || extraArrows) {
            arrows.add(Offset(playerPos.dx - 18, playerPos.dy));
            arrows.add(Offset(playerPos.dx + 18, playerPos.dy));
          }
        }

        // 5. ظهور الوحوش
        if (random.nextInt(35) == 0) {
          double rx = random.nextInt(300).toDouble() + 40;
          bool isBossChance = score > 100 && random.nextInt(5) == 0;
          monsters.add({
            'pos': Offset(rx, 0),
            'type': isBossChance ? 'boss' : (random.nextBool() ? 'goblin' : 'orc'),
            'hp': isBossChance ? 8 : 2,
            'isBoss': isBossChance,
          });
        }
      });
    });
  }

  void resetGame() {
    setState(() {
      playerPos = const Offset(180, 500);
      arrows.clear();
      monsters.clear();
      score = 0;
      xp = 0;
      health = widget.maxHp;
      isGameOver = false;
      showSkillSelection = false;
      extraArrows = false;
      fastAttack = false;
    });
  }

  @override
  void dispose() {
    gameLoopTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181818),
      appBar: AppBar(
        title: Text('${widget.heroName} | النقاط: $score | الصحة: $health ❤️'),
        backgroundColor: Colors.black87,
        centerTitle: true,
      ),
      body: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            double nx = playerPos.dx + details.delta.dx;
            double ny = playerPos.dy + details.delta.dy;
            Offset newP = Offset(nx.clamp(30.0, 370.0), ny.clamp(50.0, 670.0));
            
            bool collideObs = false;
            for (var obs in obstacles) {
              if (obs.inflate(15).contains(newP)) {
                collideObs = true;
                break;
              }
            }
            if (!collideObs) {
              playerPos = newP;
            }
          });
        },
        child: Stack(
          children: [
            CustomPaint(
              size: MediaQuery.of(context).size,
              painter: UltimateGamePainter(
                playerPos: playerPos,
                heroColor: widget.heroColor,
                arrows: arrows,
                monsters: monsters,
                obstacles: obstacles,
              ),
            ),
            if (showSkillSelection)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  width: 320,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade900,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.amber, width: 3),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('اختر مهارة جديدة! ⭐', style: TextStyle(color: Colors.amber, fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                        onPressed: () {
                          setState(() {
                            extraArrows = true;
                            showSkillSelection = false;
                          });
                        },
                        child: const Text('سهام جانبية إضافية', style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                        onPressed: () {
                          setState(() {
                            fastAttack = true;
                            showSkillSelection = false;
                          });
                        },
                        child: const Text('سرعة إطلاق نار خارقة', style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                        onPressed: () {
                          setState(() {
                            health += 2;
                            showSkillSelection = false;
                          });
                        },
                        child: const Text('زيادة نقاط الصحة (+2 HP)', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
            if (isGameOver)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.black90,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.red, width: 3),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('انتهت المعركة! 💀', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Text('مجموع النقاط: $score', style: const TextStyle(color: Colors.greenAccent, fontSize: 20)),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: resetGame,
                        child: const Text('إعادة المحاولة', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class UltimateGamePainter extends CustomPainter {
  final Offset playerPos;
  final Color heroColor;
  final List<Offset> arrows;
  final List> monsters;
  final List<Rect> obstacles;

  UltimateGamePainter({
    required this.playerPos,
    required this.heroColor,
    required this.arrows,
    required this.monsters,
    required this.obstacles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFF121212);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final borderPaint = Paint()..color = Colors.blueGrey..style = PaintingStyle.stroke..strokeWidth = 4;
    canvas.drawRect(Rect.fromLTWH(15, 15, size.width - 30, size.height - 80), borderPaint);

    final obsPaint = Paint()..color = Colors.brown.shade700;
    for (var obs in obstacles) {
      canvas.drawRRect(RRect.fromRectAndRadius(obs, const Radius.circular(8)), obsPaint);
    }

    final bodyPaint = Paint()..color = heroColor;
    final headPaint = Paint()..color = Colors.amber.shade200;
    canvas.drawRect(Rect.fromCenter(center: playerPos, width: 22, height: 32), bodyPaint);
    canvas.drawCircle(Offset(playerPos.dx, playerPos.dy - 22), 11, headPaint);
    final bowPaint = Paint()..color = Colors.brown..style = PaintingStyle.stroke..strokeWidth = 3;
    canvas.drawArc(Rect.fromCenter(center: playerPos, width: 38, height: 38), 0, pi, false, bowPaint);

    for (var monster in monsters) {
      Offset mPos = monster['pos'];
      bool isBoss = monster['isBoss'];
      
      final mPaint = Paint()..color = isBoss ? Colors.red.shade900 : Colors.deepPurple;
      double radius = isBoss ? 35 : 18;
      
      canvas.drawCircle(mPos, radius, mPaint);
      
      final hornP = Paint()..color = Colors.orange;
      canvas.drawCircle(Offset(mPos.dx - (isBoss ? 15 : 8), mPos.dy - (isBoss ? 25 : 12)), isBoss ? 10 : 5, hornP);
      canvas.drawCircle(Offset(mPos.dx + (isBoss ? 15 : 8), mPos.dy - (isBoss ? 25 : 12)), isBoss ? 10 : 5, hornP);
    }

    final arrowPaint = Paint()..color = Colors.yellowAccent..strokeWidth = 4..strokeCap = StrokeCap.round;
    for (var arrow in arrows) {
      canvas.drawLine(arrow, Offset(arrow.dx, arrow.dy - 18), arrowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant UltimateGamePainter oldDelegate) => true;
}
