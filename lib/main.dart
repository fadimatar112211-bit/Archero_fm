import 'package:flutter/material.dart';
export 'combat_painters.dart';
export 'hero_catalog.dart';
export 'game_screen.dart';
export 'sprite_sheet_frame.dart';
import 'audio_service.dart';
import 'game_progress.dart';
import 'game_screen.dart';
import 'hero_catalog.dart';
import 'sprite_sheet_frame.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeGameProgress();
  runApp(const ArcheroSoundApp());
}

// -----------------------------------------------------------------------------
// إعدادات عامة وحفظ مؤقت للتقدم أثناء تشغيل التطبيق
// -----------------------------------------------------------------------------

class ArcheroSoundApp extends StatelessWidget {
  const ArcheroSoundApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Archero Sound Edition',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF090A0F),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.amber,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MainMenuScreen(),
    );
  }
}

// -----------------------------------------------------------------------------
// القائمة الرئيسية والمتجر
// -----------------------------------------------------------------------------

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  Future<void> _buyHealth() => _purchaseUpgrade(
    cost: 50,
    apply: () => heroHpUpgrade += 25,
    rollback: () => heroHpUpgrade -= 25,
    insufficientMessage: 'عملاتك لا تكفي لشراء ترقية الصحة.',
  );

  Future<void> _buyAttack() => _purchaseUpgrade(
    cost: 70,
    apply: () => heroAtkUpgrade += 15,
    rollback: () => heroAtkUpgrade -= 15,
    insufficientMessage: 'عملاتك لا تكفي لشراء ترقية الهجوم.',
  );

  Future<void> _purchaseUpgrade({
    required int cost,
    required void Function() apply,
    required void Function() rollback,
    required String insufficientMessage,
  }) async {
    if (globalCoins < cost) {
      _message(insufficientMessage);
      return;
    }

    setState(() {
      globalCoins -= cost;
      apply();
    });

    try {
      await saveProgress();
    } catch (_) {
      // Roll back the in-memory purchase when persistence fails. This keeps
      // the visible balance and upgrade values consistent with saved data.
      globalCoins += cost;
      rollback();
      if (!mounted) return;
      setState(() {});
      _message('تعذّر حفظ عملية الشراء. لم يتم اعتماد الترقية، حاول مجدداً.');
      return;
    }

    if (!mounted) return;
    await playRealSound('coin');
  }

  void _message(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF260044), Color(0xFF090A0F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(22),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  children: [
                    const Icon(
                      Icons.sports_esports_rounded,
                      size: 82,
                      color: Colors.amberAccent,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'ARCHERO: SOUND EDITION',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'قاتل، طوّر بطلك، وتجاوز المراحل',
                      style: TextStyle(color: Colors.amber, fontSize: 14),
                    ),
                    const SizedBox(height: 25),
                    _panel(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.monetization_on,
                              color: Colors.amber, size: 25),
                          const SizedBox(width: 9),
                          Text(
                            'رصيدك: $globalCoins',
                            style: const TextStyle(
                              color: Colors.yellowAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _panel(
                      child: Wrap(
                        alignment: WrapAlignment.spaceEvenly,
                        runAlignment: WrapAlignment.center,
                        spacing: 22,
                        runSpacing: 12,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.emoji_events, color: Colors.amber),
                              const SizedBox(height: 4),
                              Text('أفضل مرحلة: $bestStage',
                                  textAlign: TextAlign.center),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.stars, color: Colors.lightBlueAccent),
                              const SizedBox(height: 4),
                              Text('أفضل نتيجة: $bestScore',
                                  textAlign: TextAlign.center),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _panel(
                      child: Column(
                        children: [
                          const Text(
                            '🛠️ متجر تطوير القدرات',
                            style: TextStyle(
                              color: Colors.amberAccent,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('زيادة الصحة الحالية: +$heroHpUpgrade'),
                          Text('زيادة الهجوم الحالية: +$heroAtkUpgrade'),
                          const SizedBox(height: 14),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              FilledButton.icon(
                                onPressed: _buyHealth,
                                icon: const Icon(Icons.favorite),
                                label: const Text('صحة +25 (50)'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.blue.shade800,
                                ),
                              ),
                              FilledButton.icon(
                                onPressed: _buyAttack,
                                icon: const Icon(Icons.flash_on),
                                label: const Text('هجوم +15 (70)'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.deepOrange.shade800,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        onPressed: () {
                          playRealSound('special');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HeroSelectionScreen(),
                            ),
                          ).then((_) {
                            if (mounted) setState(() {});
                          });
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          'اختيار البطل واللعب',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 19,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _panel({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: child,
    );
  }
}

// -----------------------------------------------------------------------------
// اختيار الأبطال
// -----------------------------------------------------------------------------

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
                  child: Text(hero.description),
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

// -----------------------------------------------------------------------------
// بيانات اللعبة
// -----------------------------------------------------------------------------

