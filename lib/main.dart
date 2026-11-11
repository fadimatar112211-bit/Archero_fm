import 'package:flutter/material.dart';

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
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const GameHomeScreen(),
    );
  }
}

class GameHomeScreen extends StatefulWidget {
  const GameHomeScreen({Key? key}) : super(key: key);

  @override
  State<GameHomeScreen> createState() => _GameHomeScreenState();
}

class _GameHomeScreenState extends State<GameHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Archero Game - MultiPlayer'),
        backgroundColor: Colors.black54,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'لعبة Archero جاهزة للاستخدام!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 300,
                  height: 350,
                  child: CustomPaint(
                    painter: GamePainter(),
                  ),
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
  @override
  void paint(Canvas canvas, Size size) {
    // رسم خلفية ساحة اللعب
    final backgroundPaint = Paint()
      ..color = const Color(0xFF1E1E1E)
      ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);
    
    // رسم ساحة اللعب أو حدود الماب
    final mapBorderPaint = Paint()
      ..color = Colors.green.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawRect(Rect.fromLTWH(10, 10, size.width - 20, size.height - 20), mapBorderPaint);
    
    // رسم شكل اللاعب في المنتصف
    final playerPaint = Paint()
      ..color = Colors.redAccent
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 25, playerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
