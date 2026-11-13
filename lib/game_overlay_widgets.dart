import 'package:flutter/material.dart';

class GameHudWidget extends StatelessWidget {
  const GameHudWidget({
    super.key,
    required this.stage,
    required this.score,
    required this.coins,
    required this.isPaused,
    required this.playerHp,
    required this.playerMaxHp,
    required this.onPause,
  });

  final int stage;
  final int score;
  final int coins;
  final bool isPaused;
  final double playerHp;
  final double playerMaxHp;
  final VoidCallback onPause;

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          Positioned(
            top: 8,
            left: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.72),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.amber.withOpacity(0.4)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('المرحلة $stage',
                      style: const TextStyle(color: Colors.amber)),
                  Text('⭐ $score'),
                  Text('🪙 $coins'),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: onPause,
                    icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 65,
            left: 15,
            right: 15,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                minHeight: 10,
                value: playerMaxHp > 0
                    ? (playerHp / playerMaxHp).clamp(0.0, 1.0)
                    : 0,
                backgroundColor: Colors.red.shade900,
                color: Colors.greenAccent,
              ),
            ),
          ),
        ],
      );
}

class GamePauseOverlay extends StatelessWidget {
  const GamePauseOverlay({super.key, required this.onResume});

  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) => Positioned.fill(
        child: Container(
          color: Colors.black.withOpacity(0.78),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'اللعبة متوقفة',
                  style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                FilledButton.icon(
                  onPressed: onResume,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('متابعة اللعب'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  child: const Text('الخروج إلى القائمة'),
                ),
              ],
            ),
          ),
        ),
      );
}

class MysteryChestOverlay extends StatelessWidget {
  const MysteryChestOverlay({super.key, required this.onCollect});

  final VoidCallback onCollect;

  @override
  Widget build(BuildContext context) => Positioned.fill(
        child: Container(
          color: Colors.black.withOpacity(0.82),
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF241B05),
                border: Border.all(color: Colors.amber, width: 2),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.card_giftcard,
                      color: Colors.amber, size: 58),
                  const SizedBox(height: 12),
                  const Text(
                    'صندوق المكافآت الأسطوري!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.amberAccent,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('تحصل على 75 عملة مجانية'),
                  const SizedBox(height: 18),
                  FilledButton(
                    onPressed: onCollect,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('افتح الصندوق'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
