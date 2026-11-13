import 'package:flutter/material.dart';

import 'game_painters.dart';
import 'game_progress.dart';
import 'game_screen.dart';
import 'hero_rules.dart';

class HeroInfo {
  final int id;
  final String name;
  final String description;
  final Color color;
  final IconData icon;

  const HeroInfo(
    this.id,
    this.name,
    this.description,
    this.color,
    this.icon,
  );
}

const heroChoices = <HeroInfo>[
  HeroInfo(
    1,
    'الرامي المتوازن',
    'صحة وسرعة وهجوم متوازنة.',
    Colors.blue,
    Icons.sports_martial_arts,
  ),
  HeroInfo(
    2,
    'فارس النارية',
    'يبدأ بصحة إضافية قدرها 50.',
    Colors.deepOrange,
    Icons.local_fire_department,
  ),
  HeroInfo(
    3,
    'صياد الظل',
    'يمتلك سرعة حركة أعلى.',
    Colors.purple,
    Icons.speed,
  ),
  HeroInfo(
    4,
    'حارس العواصف',
    'يطلق سهماً إضافياً في كل هجمة.',
    Colors.teal,
    Icons.bolt,
  ),
];

class HeroSelectionScreen extends StatelessWidget {
  const HeroSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اختر بطلك الأسطوري')),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: heroChoices.length,
          itemBuilder: (context, index) {
            final hero = heroChoices[index];
            final profile = HeroProfile.forType(hero.id);
            return Card(
              clipBehavior: Clip.antiAlias,
              color: const Color(0xFF111725),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(19),
                side: BorderSide(color: hero.color.withOpacity(.9), width: 1.4),
              ),
              elevation: 7,
              shadowColor: hero.color.withOpacity(.28),
              child: ListTile(
                contentPadding: const EdgeInsets.all(13),
                leading: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      hero.color.withOpacity(.42),
                      const Color(0xFF101522),
                    ]),
                    border: Border.all(color: hero.color.withOpacity(.9), width: 1.5),
                    boxShadow: [
                      BoxShadow(color: hero.color.withOpacity(.32), blurRadius: 14, spreadRadius: 1),
                    ],
                  ),
                  padding: const EdgeInsets.all(7),
                  child: SpriteSheetFrame(
                    asset: switch (hero.id) {
                      2 => 'assets/spritesheets/player_flame_idle.svg',
                      3 => 'assets/spritesheets/player_shadow_idle.svg',
                      4 => 'assets/spritesheets/player_storm_idle.svg',
                      _ => 'assets/spritesheets/player_idle.svg',
                    },
                    frameCount: 4,
                    frameIndex: 0,
                  ),
                ),
                title: Text(
                  hero.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    '${hero.description}\n'
                    'النشطة: ${profile.activeSkillName} — ${profile.activeSkillDescription}\n'
                    'السلبية: ${profile.passiveSkillName} — ${profile.passiveSkillDescription}',
                    style: const TextStyle(fontSize: 12, height: 1.35),
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 17),
                onTap: () async {
                  playRealSound('special');
                  var selectedStage = 1;
                  if (bestStage > 1) {
                    final choice = await showDialog<int>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('اختر طريقة اللعب'),
                        content: Text(
                          'أفضل تقدم محفوظ لديك هو المرحلة $bestStage.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext, 1),
                            child: const Text('مغامرة جديدة'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(
                              dialogContext,
                              bestStage,
                            ),
                            child: Text('متابعة من المرحلة $bestStage'),
                          ),
                        ],
                      ),
                    );
                    if (!context.mounted || choice == null) return;
                    selectedStage = choice;
                  }
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GameScreen(
                        heroType: hero.id,
                        initialStage: selectedStage,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
