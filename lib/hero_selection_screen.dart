import 'package:flutter/material.dart';

import 'game_painters.dart';
import 'game_progress.dart';
import 'world_selection_screen.dart';
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

class HeroSelectionScreen extends StatefulWidget {
  const HeroSelectionScreen({super.key});

  @override
  State<HeroSelectionScreen> createState() => _HeroSelectionScreenState();
}

class _HeroSelectionScreenState extends State<HeroSelectionScreen> {
  bool _savingUnlock = false;

  bool _isUnlocked(int heroId) => (unlockedHeroesMask & (1 << (heroId - 1))) != 0;

  int _unlockCost(int heroId) => switch (heroId) { 2 => 50, 3 => 75, 4 => 100, _ => 0 };

  Future<void> _unlockHero(HeroInfo hero) async {
    if (_savingUnlock || _isUnlocked(hero.id)) return;
    final cost = _unlockCost(hero.id);
    if (globalGems < cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تحتاج إلى $cost جوهرة لفتح هذا البطل.')),
      );
      return;
    }
    final oldGems = globalGems;
    final oldMask = unlockedHeroesMask;
    setState(() {
      _savingUnlock = true;
      globalGems -= cost;
      unlockedHeroesMask |= 1 << (hero.id - 1);
    });
    try {
      await saveProgress();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم فتح ${hero.name} بنجاح!')),
        );
      }
    } catch (_) {
      globalGems = oldGems;
      unlockedHeroesMask = oldMask;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر حفظ فتح البطل؛ لم يتم اعتماد الخصم.')),
        );
      }
    } finally {
      _savingUnlock = false;
      if (mounted) setState(() {});
    }
  }

  Future<void> _startHero(HeroInfo hero) async {
    if (!_isUnlocked(hero.id) || _savingUnlock) return;
    try {
      await playRealSound('special');
    } catch (_) {}
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => WorldSelectionScreen(
          heroType: hero.id,
          heroName: hero.name,
        ),
      ),
    );
  }

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
            final unlocked = _isUnlocked(hero.id);
            final cost = _unlockCost(hero.id);
            return Card(
              clipBehavior: Clip.antiAlias,
              color: unlocked ? const Color(0xFF111725) : const Color(0xFF171923),
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
                  '${hero.name}${unlocked ? '' : ' · مقفل'}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    unlocked
                        ? '${hero.description}\n'
                          'النشطة: ${profile.activeSkillName} — ${profile.activeSkillDescription}\n'
                          'السلبية: ${profile.passiveSkillName} — ${profile.passiveSkillDescription}'
                        : 'افتح هذا البطل مقابل $cost جوهرة لتفعيل مهاراته واستخدامه في المعارك.',
                    style: const TextStyle(fontSize: 12, height: 1.35),
                  ),
                ),
                trailing: unlocked
                    ? const Icon(Icons.arrow_forward_ios, size: 17)
                    : FilledButton.tonalIcon(
                        onPressed: _savingUnlock ? null : () => _unlockHero(hero),
                        icon: const Icon(Icons.lock_open, size: 16),
                        label: Text('$cost 💎'),
                      ),
                onTap: unlocked ? () => _startHero(hero) : () => _unlockHero(hero),
              ),
            );
          },
        ),
      ),
    );
  }
}
