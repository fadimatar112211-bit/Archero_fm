export 'game_progress.dart';
export 'game_screen.dart';
export 'hero_selection_screen.dart';
export 'main_menu_screen.dart';

import 'dart:async';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';

import 'game_diagnostics.dart';
import 'game_progress.dart';
import 'main_menu_screen.dart';

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
    equippedWeaponId = progress.equippedWeaponId;
    equippedArmorId = progress.equippedArmorId;
    equippedHelmetId = progress.equippedHelmetId;
    equippedRingId = progress.equippedRingId;
    equippedRelicId = progress.equippedRelicId;
    ownedEquipmentMask = progress.ownedEquipmentMask;
    globalGems = progress.gems;
    globalKeys = progress.keys;
    globalEquipmentShards = progress.equipmentShards;
    unlockedHeroesMask = progress.unlockedHeroesMask;
    totalKills = progress.totalKills;
    totalBosses = progress.totalBosses;
    totalChests = progress.totalChests;
    totalRuns = progress.totalRuns;
    claimedAchievementsMask = progress.claimedAchievementsMask;
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
