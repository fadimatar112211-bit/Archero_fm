export 'game_progress.dart';
export 'game_screen.dart';
export 'hero_selection_screen.dart';

import 'dart:async';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';

import 'game_diagnostics.dart';
import 'game_progress.dart';
import 'hero_selection_screen.dart';
import 'progress_store.dart';
import 'shop_economy.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    GameDiagnostics.record(
      details.exception,
      details.stack ?? StackTrace.current,
      source: 'flutter_framework',
    );
  };
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    GameDiagnostics.record(
      error,
      stackTrace,
      source: 'platform_dispatcher',
    );
    return true;
  };

  await runZonedGuarded<Future<void>>(() async {
    final progress = await loadProgressOrDefaults();
    globalCoins = progress.coins;
    heroHpUpgrade = progress.hpUpgrade;
    heroAtkUpgrade = progress.atkUpgrade;
    bestStage = progress.bestStage;
    bestScore = progress.bestScore;
    runApp(const ArcheroSoundApp());
  }, (error, stackTrace) {
    GameDiagnostics.record(
      error,
      stackTrace,
      source: 'uncaught_zone_error',
    );
  });
}

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
  Future<void> _buyHealth() async {
    final purchase = await commitUpgradePurchase(
      upgrade: ShopEconomy.health(heroHpUpgrade),
      currentCoins: globalCoins,
      currentUpgradeValue: heroHpUpgrade,
      persist: (coins, upgradeValue) => ProgressStore.save(
        coins: coins,
        hpUpgrade: upgradeValue,
        atkUpgrade: heroAtkUpgrade,
        bestStage: bestStage,
        bestScore: bestScore,
      ),
    );
    if (!purchase.purchased) {
      _message(switch (purchase.status) {
        ShopPurchaseStatus.maxLevel => 'وصلت إلى الحد الأقصى لترقية الصحة.',
        ShopPurchaseStatus.insufficientFunds => 'عملاتك لا تكفي لشراء ترقية الصحة.',
        ShopPurchaseStatus.persistenceFailed => 'تعذر حفظ عملية الشراء. لم يتم خصم العملات.',
        ShopPurchaseStatus.purchased => '',
      });
      return;
    }
    if (!mounted) return;
    setState(() {
      globalCoins = purchase.remainingCoins;
      heroHpUpgrade = purchase.updatedUpgradeValue;
    });
    await playRealSound('coin');
  }

  Future<void> _buyAttack() async {
    debugPrint('[Shop] attack purchase requested: coins=$globalCoins upgrade=$heroAtkUpgrade');
    final purchase = await commitUpgradePurchase(
      upgrade: ShopEconomy.attack(heroAtkUpgrade),
      currentCoins: globalCoins,
      currentUpgradeValue: heroAtkUpgrade,
      persist: (coins, upgradeValue) => ProgressStore.save(
        coins: coins,
        hpUpgrade: heroHpUpgrade,
        atkUpgrade: upgradeValue,
        bestStage: bestStage,
        bestScore: bestScore,
      ),
    );
    debugPrint('[Shop] attack purchase result: ${purchase.status} remaining=${purchase.remainingCoins}');
    if (!purchase.purchased) {
      _message(switch (purchase.status) {
        ShopPurchaseStatus.maxLevel => 'وصلت إلى الحد الأقصى لترقية الهجوم.',
        ShopPurchaseStatus.insufficientFunds => 'عملاتك لا تكفي لشراء ترقية الهجوم.',
        ShopPurchaseStatus.persistenceFailed => 'تعذر حفظ عملية الشراء. لم يتم خصم العملات.',
        ShopPurchaseStatus.purchased => '',
      });
      return;
    }
    if (!mounted) return;
    setState(() {
      globalCoins = purchase.remainingCoins;
      heroAtkUpgrade = purchase.updatedUpgradeValue;
    });
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
                                onPressed: ShopEconomy.health(heroHpUpgrade).canPurchase(globalCoins)
                                    ? _buyHealth
                                    : null,
                                icon: const Icon(Icons.favorite),
                                label: Text(ShopEconomy.health(heroHpUpgrade).isMaxed
                                    ? 'الصحة: الحد الأقصى'
                                    : 'صحة +25 · المستوى ${ShopEconomy.health(heroHpUpgrade).level}/${ShopEconomy.health(heroHpUpgrade).maxLevel} · ${ShopEconomy.health(heroHpUpgrade).cost} عملة'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.blue.shade800,
                                ),
                              ),
                              FilledButton.icon(
                                onPressed: ShopEconomy.attack(heroAtkUpgrade).canPurchase(globalCoins)
                                    ? _buyAttack
                                    : null,
                                icon: const Icon(Icons.flash_on),
                                label: Text(ShopEconomy.attack(heroAtkUpgrade).isMaxed
                                    ? 'الهجوم: الحد الأقصى'
                                    : 'هجوم +15 · المستوى ${ShopEconomy.attack(heroAtkUpgrade).level}/${ShopEconomy.attack(heroAtkUpgrade).maxLevel} · ${ShopEconomy.attack(heroAtkUpgrade).cost} عملة'),
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
