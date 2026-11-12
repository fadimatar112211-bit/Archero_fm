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
      title: 'Archero Game',
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
      {'name': 'الرامي الرشيق', 'color': Colors.redAccent, 'hp': 5},
      {'name': 'الساحر القوي', 'color': Colors.purpleAccent, 'hp': 4},
      {'name': 'المحارب الصلب', 'color': Colors.orangeAccent, 'hp': 8},
      {'name': 'القاتل الخفي', 'color': Colors.cyanAccent, 'hp': 4},
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
  List<Offset> monsters = [];
  
  final List<Rect> obstacles = [
    const Rect.fromLTWH(100, 200, 80, 30),
    const Rect.fromLTWH(220, 380, 90, 30),
  ];

  Timer? gameLoopTimer;
  int score = 0;
  late int health;
  bool isGameOver = false;

  final Random random = Random();

  @override
  void initState() {
    super.initState();
    health = widget.maxHp;
    startGameLoop();
  }

  void startGameLoop() {
    gameLoopTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (isGameOver) return;

      setState(() {
        // 1. تحريك السهام للأعلى
        List<Offset> newArrows = [];
        for (var arrow in arrows) {
          if (arrow.dy > 0) {
            Offset nextA = Offset(arrow.dx, arrow.dy - 14);
            bool hitObs = false;
            for (var obs in obstacles) {
              if (obs.contains(nextA)) {
                hitObs = true;
                break;
              }
            }
            if (!hitObs) {
              newArrows.add(nextA);
            }
          }
        }
        arrows = newArrows;

        // 2. تحريك الوحوش للأسفل
        List<Offset> newMonsters = [];
        for (var monster in monsters) {
          double newY = monster.dy + 2.0;
          Offset newPos = Offset(monster.dx, newY);

          bool hitObs = false;
          for (var obs in obstacles) {
            if (obs.contains(newPos)) {
              hitObs = true;
              break;
            }
          }

          if ((newPos - playerPos).distance < 35) {
            health -= 1;
            if (health <= 0) {
              isGameOver = true;
            }
          } else if (!hitObs && newY < 680) {
            newMonsters.add(newPos);
          }
        }
        monsters = newMonsters;

        // 3. فحص ضربات السهام بالوحوش
        List<Offset> survivingArrows = [];
        for (var arrow in arrows) {
          bool hit = false;
          List<Offset> survivingMonsters = [];
          for (var monster in monsters) {
            if (!hit && (arrow - monster).distance < 25) {
              hit = true;
              score += 15;
            } else {
              survivingMonsters.add(monster);
            }
          }
          monsters = survivingMonsters;
          if (!hit) {
            survivingArrows.add(arrow);
          }
        }
        arrows = survivingArrows;

        // 4. إطلاق السهام تلقائياً
        if (random.nextInt(20) == 0) {
          arrows.add(playerPos);
          if (widget.heroName.contains('الرامي')) {
            arrows.add(Offset(playerPos.dx - 18, playerPos.dy));
            arrows.add(Offset(playerPos.dx + 18, playerPos.dy));
          }
        }

        // 5. ظهور الوحوش عشوائياً
        if (random.nextInt(35) == 0) {
          double rx = random.nextInt(300).toDouble() + 40;
          monsters.add(Offset(rx, 0));
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
      health = widget.maxHp;
      isGameOver = false;
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
              painter: GamePainter(
                playerPos: playerPos,
                heroColor: widget.heroColor,
                arrows: arrows,
                monsters: monsters,
                obstacles: obstacles,
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

class GamePainter extends CustomPainter {
  final Offset playerPos;
  final Color heroColor;
  final List<Offset> arrows;
  final List<Offset> monsters;
  final List<Rect> obstacles;

  GamePainter({
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

    // رسم اللاعب
    final bodyPaint = Paint()..color = heroColor;
    final headPaint = Paint()..color = Colors.amber.shade200;
    canvas.drawRect(Rect.fromCenter(center: playerPos, width: 22, height: 32), bodyPaint);
    canvas.drawCircle(Offset(playerPos.dx, playerPos.dy - 22), 11, headPaint);
    final bowPaint = Paint()..color = Colors.brown..style = PaintingStyle.stroke..strokeWidth = 3;
    canvas.drawArc(Rect.fromCenter(center: playerPos, width: 38, height: 38), 0, pi, false, bowPaint);

    // رسم الوحوش
    final monsterPaint = Paint()..color = Colors.deepPurple;
    final hornPaint = Paint()..color = Colors.orange;
    for (var mPos in monsters) {
      canvas.drawCircle(mPos, 18, monsterPaint);
      canvas.drawCircle(Offset(mPos.dx - 8, mPos.dy - 12), 5, hornPaint);
      canvas.drawCircle(Offset(mPos.dx + 8, mPos.dy - 12), 5, hornPaint);
    }

    // رسم السهام
    final arrowPaint = Paint()..color = Colors.yellowAccent..strokeWidth = 4..strokeCap = StrokeCap.round;
    for (var arrow in arrows) {
      canvas.drawLine(arrow, Offset(arrow.dx, arrow.dy - 18), arrowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant GamePainter oldDelegate) => true;
}
