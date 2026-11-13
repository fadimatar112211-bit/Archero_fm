export 'game_painters.dart';

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'game_settings.dart';

import 'game_progress.dart';
import 'stage_flow.dart';
import 'skill_system.dart';
import 'boss_combat.dart';
import 'world_rules.dart';
import 'world_theme.dart';
import 'combat_stats.dart';
import 'combat_targeting.dart';
import 'combat_effects.dart';
import 'coin_collection.dart';
import 'enemy_ai.dart';
import 'enemy_spawn.dart';
import 'enemy_attack_rules.dart';
import 'enemy_projectile_motion.dart';
import 'combat_collision.dart';
import 'boss_projectiles.dart';
import 'hero_rules.dart';
import 'combat_damage.dart';
import 'player_attack.dart';
import 'player_projectiles.dart';
import 'weapon_system.dart';
import 'equipment_system.dart';
import 'game_run_lifecycle.dart';
import 'game_run_session.dart';
import 'game_run_state.dart';
import 'run_checkpoint.dart';
import 'game_run_checkpoint_adapter.dart';
import 'game_timers.dart';
import 'room_flow.dart';
import 'room_layout.dart';
import 'player_movement.dart';
import 'enemy_hit_resolution.dart';
import 'skill_selection_dialog.dart';
import 'game_arena_view.dart';
import 'special_room_system.dart';
import 'special_room_dialog.dart';

typedef GameObject = Map<String, dynamic>;

class GameScreen extends StatefulWidget {
  final int heroType;
  final int initialStage;
  final RunCheckpoint? checkpoint;

  const GameScreen({
    super.key,
    required this.heroType,
    this.initialStage = 1,
    this.checkpoint,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  String get playerSpritePrefix => switch (widget.heroType) {
    2 => 'assets/spritesheets/player_flame',
    3 => 'assets/spritesheets/player_shadow',
    4 => 'assets/spritesheets/player_storm',
    _ => 'assets/spritesheets/player',
  };

  final Random random = Random();
  late final AnimationController worldAnimationController;

  late final GameRunSession runSession = GameRunSession(
    initialStage: widget.checkpoint?.stage ?? widget.initialStage,
    restoredState: widget.checkpoint == null
        ? null
        : restoreRunCheckpointState(widget.checkpoint!),
  );
  GameRunState get runState => runSession.state;
  EquipmentStats get gearStats => EquipmentCatalog.stats(armorId: equippedArmorId, helmetId: equippedHelmetId, ringId: equippedRingId, relicId: equippedRelicId);

  double get arenaWidth => runState.arenaWidth;
  set arenaWidth(double value) => runState.arenaWidth = value;
  double get arenaHeight => runState.arenaHeight;
  set arenaHeight(double value) => runState.arenaHeight = value;
  bool get _arenaInitialized => runState.arenaInitialized;
  set _arenaInitialized(bool value) => runState.arenaInitialized = value;
  double get playerX => runState.playerX;
  set playerX(double value) => runState.playerX = value;
  double get playerY => runState.playerY;
  set playerY(double value) => runState.playerY = value;
  double get playerHp => runState.playerHp;
  set playerHp(double value) => runState.playerHp = value;
  double get playerMaxHp => runState.playerMaxHp;
  set playerMaxHp(double value) => runState.playerMaxHp = value;
  double get playerSpeed => runState.playerSpeed;
  set playerSpeed(double value) => runState.playerSpeed = value;
  DateTime? get lastDamageAt => runState.lastDamageAt;
  set lastDamageAt(DateTime? value) => runState.lastDamageAt = value;
  double get attackPowerMultiplier => runState.attackPowerMultiplier;
  set attackPowerMultiplier(double value) => runState.attackPowerMultiplier = value;
  int get extraArrows => runState.extraArrows;
  set extraArrows(int value) => runState.extraArrows = value;
  double get criticalChance => runState.criticalChance;
  set criticalChance(double value) => runState.criticalChance = value;
  double get attackSpeedMultiplier => runState.attackSpeedMultiplier;
  set attackSpeedMultiplier(double value) => runState.attackSpeedMultiplier = value;
  double get enemySpeedMultiplier => runState.enemySpeedMultiplier;
  set enemySpeedMultiplier(double value) => runState.enemySpeedMultiplier = value;
  double get coinPickupRadius => runState.coinPickupRadius;
  List<SkillId> get selectedSkills => runState.selectedSkills;
  Set<SkillSynergyId> get activeSkillSynergies => runState.activeSkillSynergies;
  set coinPickupRadius(double value) => runState.coinPickupRadius = value;
  int get animationTicks => runState.animationTicks;
  set animationTicks(int value) => runState.animationTicks = value;
  int get heroAttackTicks => runState.heroAttackTicks;
  set heroAttackTicks(int value) => runState.heroAttackTicks = value;
  int get playerMoveTicks => runState.playerMoveTicks;
  set playerMoveTicks(int value) => runState.playerMoveTicks = value;
  List<Map<String, dynamic>> get combatEffects => runState.combatEffects;
  List<Map<String, dynamic>> get defeatedSprites => runState.defeatedSprites;
  int get score => runState.score;
  set score(int value) => runState.score = value;
  int get stage => runState.stage;
  set stage(int value) => runState.stage = value;
  int get specialCooldown => runState.specialCooldown;
  set specialCooldown(int value) => runState.specialCooldown = value;
  int get playerDeathTicks => runState.playerDeathTicks;
  bool get challengeRoomRewardPending => runState.challengeRoomRewardPending;
  set challengeRoomRewardPending(bool value) => runState.challengeRoomRewardPending = value;
  set playerDeathTicks(int value) => runState.playerDeathTicks = value;

  GameRunLifecycle get runLifecycle => runSession.lifecycle;
  bool get isPaused => runLifecycle.isPaused;
  bool get showMysteryChest => runLifecycle.showMysteryChest;
  bool get gameOverShown => runLifecycle.isGameOver;
  bool get playerDying => runLifecycle.isPlayerDying;
  bool get stageTransitioning => runLifecycle.isStageTransitioning;
  GameTimerRegistry get timers => runSession.timers;
  bool _pausedForAppLifecycle = false;
  int _roomHazardCooldownTicks = 0;

  List<GameObject> get enemies => runState.enemies;
  List<GameObject> get arrows => runState.arrows;
  List<GameObject> get enemyProjectiles => runState.enemyProjectiles;
  List<GameObject> get coins => runState.coins;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_pausedForAppLifecycle && runLifecycle.resume()) {
        _pausedForAppLifecycle = false;
        if (mounted) setState(() {});
      }
      return;
    }

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused) {
      if (runLifecycle.pause()) {
        _pausedForAppLifecycle = true;
        if (mounted) setState(() {});
      }
      if (runLifecycle.phase == GameRunPhase.active ||
          runLifecycle.phase == GameRunPhase.paused) {
        unawaited(_persistRunCheckpoint());
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    worldAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    if (runSession.isRestored) {
      final hazardTicks = widget.checkpoint!.state['hazardCooldownTicks'];
      if (hazardTicks is int && hazardTicks >= 0) _roomHazardCooldownTicks = hazardTicks;
    } else {
      final heroStats = createHeroRunStats(
        heroType: widget.heroType,
        hpUpgrade: heroHpUpgrade,
        attackUpgrade: heroAtkUpgrade,
      );
      final gear = EquipmentCatalog.stats(armorId: equippedArmorId, helmetId: equippedHelmetId, ringId: equippedRingId, relicId: equippedRelicId);
      playerMaxHp = heroStats.playerMaxHp + gear.maxHpBonus;
      playerHp = heroStats.playerHp + gear.maxHpBonus;
      playerSpeed = heroStats.playerSpeed;
      attackPowerMultiplier = heroStats.attackPowerMultiplier * (1 + gear.attackBonus);
      extraArrows = heroStats.extraArrows;
      criticalChance = (heroStats.criticalChance + gear.criticalChanceBonus).clamp(0.0, 0.75).toDouble();
      coinPickupRadius += gear.coinPickupRadiusBonus;
    }

    timers.periodic('game', const Duration(milliseconds: 16), () {
      if (!mounted || !runLifecycle.canAdvanceGameClock) return;
      if (playerDying) {
        playerDeathTicks++;
        if (playerDeathTicks >= 24) _endGame();
        if (mounted) setState(() {});
        return;
      }
      _updateEngine();
    });

    _restartShootLoop();
    timers.periodic('checkpoint', const Duration(seconds: 5), () {
      if (runLifecycle.phase == GameRunPhase.active ||
          runLifecycle.phase == GameRunPhase.paused) {
        unawaited(_persistRunCheckpoint());
      }
    });
    if (runSession.isRestored) unawaited(saveProgressSafely());
  }

  Future<void> _persistRunCheckpoint() async {
    if (gameOverShown ||
        (runLifecycle.phase != GameRunPhase.active &&
            runLifecycle.phase != GameRunPhase.paused)) return;
    try {
      await RunCheckpointStore.save(captureRunCheckpoint(
        heroType: widget.heroType,
        run: runState,
        hazardCooldownTicks: _roomHazardCooldownTicks,
      ));
    } catch (error, stackTrace) {
      debugPrint('Active run checkpoint save failed: $error\\n$stackTrace');
    }
  }

  void _spawnEnemies({bool notify = true, bool challenge = false}) {
    enemies.clear();
    arrows.clear();
    enemyProjectiles.clear();
    enemies.addAll(createEnemyWave(
      stage: stage,
      arenaWidth: arenaWidth,
      arenaHeight: arenaHeight,
      enemySpeedMultiplier: enemySpeedMultiplier,
      random: random,
    ));
    if (challenge) {
      final extraWave = createEnemyWave(
        stage: stage + 2,
        arenaWidth: arenaWidth,
        arenaHeight: arenaHeight,
        enemySpeedMultiplier: enemySpeedMultiplier * 1.12,
        random: random,
      ).take(2);
      for (final enemy in extraWave) {
        final hp = enemy['hp'];
        if (hp is num) enemy['hp'] = hp.toDouble() * 1.2;
        enemies.add(enemy);
      }
      challengeRoomRewardPending = true;
    }

    if (notify && mounted) setState(() {});
  }

  void _syncArenaSize(double width, double height) {
    if (!width.isFinite || !height.isFinite || width <= 0 || height <= 0) return;
    if (!_arenaInitialized) {
      arenaWidth = width;
      arenaHeight = height;
      playerX = width / 2;
      playerY = height * 0.72;
      _arenaInitialized = true;
      _spawnEnemies(notify: false);
      return;
    }
    if ((arenaWidth - width).abs() < 0.5 && (arenaHeight - height).abs() < 0.5) return;

    final scaleX = width / arenaWidth;
    final scaleY = height / arenaHeight;
    playerX = (playerX * scaleX).clamp(22.0, max(22.0, width - 22.0)).toDouble();
    playerY = (playerY * scaleY).clamp(105.0, max(105.0, height - 35.0)).toDouble();
    for (final collection in [enemies, arrows, enemyProjectiles, coins, combatEffects, defeatedSprites]) {
      for (final item in collection) {
        final x = item['x'];
        final y = item['y'];
        if (x is num) item['x'] = (x.toDouble() * scaleX).clamp(-20.0, width + 20.0).toDouble();
        if (y is num) item['y'] = (y.toDouble() * scaleY).clamp(-20.0, height + 20.0).toDouble();
      }
    }
    arenaWidth = width;
    arenaHeight = height;
  }

  void _shootArrows() {
    if (enemies.isEmpty) return;

    final origin = CombatPoint(playerX, playerY);
    final targetIndex = nearestTargetIndex(
      origin: origin,
      targets: enemies
          .map((enemy) => CombatPoint(
                enemy['x'] as double,
                enemy['y'] as double,
              ))
          .toList(growable: false),
    );
    if (targetIndex == null) return;
    final target = enemies[targetIndex];

    heroAttackTicks = 12;
    final weapon = WeaponCatalog.byId(equippedWeaponId);
    final volley = createPlayerArrowVolley(
      origin: origin,
      target: CombatPoint(
        target['x'] as double,
        target['y'] as double,
      ),
      extraArrows: extraArrows + weapon.bonusArrows,
      projectileSpeed: weapon.projectileSpeed,
      spreadAngle: weapon.spreadAngle,
    );
    for (final arrow in volley) {
      arrows.add({
        'x': arrow.origin.x,
        'y': arrow.origin.y,
        'vx': arrow.velocity.x,
        'vy': arrow.velocity.y,
      });
    }
    playRealSound('shoot');
  }

  void _triggerHaptic() {
    if (!GameSettingsStore.vibrationEnabled) return;
    unawaited(HapticFeedback.mediumImpact().catchError((Object _) {}));
  }

  void _restartShootLoop() {
    final weapon = WeaponCatalog.byId(equippedWeaponId);
    final intervalMs = CombatBalance.shootIntervalMs(attackSpeedMultiplier * weapon.attackSpeedMultiplier);
    timers.periodic('shoot', Duration(milliseconds: intervalMs), () {
      if (!mounted || !runLifecycle.canPerformActions || enemies.isEmpty) {
        return;
      }
      _shootArrows();
    });
  }

  void _useSpecialSkill() {
    if (specialCooldown > 0 || enemies.isEmpty ||
        !runLifecycle.canPerformActions) return;

    setState(() {
      final heroProfile = HeroProfile.forType(widget.heroType);
      final skillDamage =
          heroProfile.activeSkillDamage * attackPowerMultiplier;

      if (heroProfile.triggersDodge) {
        playerMoveTicks = 36;
        combatEffects.add({
          'x': playerX, 'y': playerY, 'type': 'dodge', 'life': 24,
        });
      }

      for (int i = enemies.length - 1; i >= 0; i--) {
        final enemy = enemies[i];
        final isBoss = enemy['type'] == 'boss';
        final hit = resolveEnemyHit(
          currentHp: enemy['hp'] as double,
          baseDamage: skillDamage * WeaponCatalog.byId(equippedWeaponId).damageMultiplier,
          attackMultiplier: 1,
          criticalChance: 0,
          criticalRoll: 1,
          isBoss: isBoss,
          bossDamageMultiplier: 0.65,
        );
        enemy['hp'] = hit.updatedHp;
        enemy['hitTicks'] = 10;
        combatEffects.add({
          'x': enemy['x'], 'y': enemy['y'],
          'type': widget.heroType == 2 ? 'bossHit' :
              widget.heroType == 3 ? 'shadowHit' :
              widget.heroType == 4 ? 'metalHit' : 'sparkHit',
          'life': 22,
        });

        if (hit.isDefeated) {
          final x = enemy['x'];
          final y = enemy['y'];
          final type = enemy['type'] as String;
          defeatedSprites.add({
            'x': x, 'y': y, 'type': type, 'boss': isBoss, 'life': 24,
          });
          combatEffects.add({
            'x': x, 'y': y, 'type': isBoss ? 'bossBurst' : 'defeat',
            'life': 25,
          });
          if (hit.dropsCoin) coins.add({'x': x, 'y': y});
          score += hit.scoreAward;
          totalKills++;
          if (isBoss) totalBosses++;
          enemies.removeAt(i);
        }
      }
      specialCooldown = 15;
    });

    _triggerHaptic();
    playRealSound('special');
    _checkStageComplete();
    timers.cancel('cooldown');
    timers.periodic('cooldown', const Duration(seconds: 1), () {
      if (!mounted) {
        timers.cancel('cooldown');
        return;
      }
      if (isPaused || showMysteryChest || gameOverShown) return;
      if (specialCooldown <= 1) {
        setState(() => specialCooldown = 0);
        timers.cancel('cooldown');
      } else {
        setState(() => specialCooldown--);
      }
    });
  }

  void _updateEngine() {
    if (!mounted || gameOverShown || stageTransitioning) return;
    animationTicks++;
    if (heroAttackTicks > 0) heroAttackTicks--;
    if (playerMoveTicks > 0) playerMoveTicks--;

    // Advance short-lived combat visuals through the standalone timing system.
    CombatEffectManager.advance(defeatedSprites);
    CombatEffectManager.advance(combatEffects);

    // تحريك مقذوفات الأعداء وفحص إصابة اللاعب.
    for (int i = enemyProjectiles.length - 1; i >= 0; i--) {
      final shot = enemyProjectiles[i];
      final step = advanceEnemyProjectile(
        x: shot['x'] as double,
        y: shot['y'] as double,
        velocityX: shot['vx'] as double,
        velocityY: shot['vy'] as double,
        life: shot['life'] as int,
        targetX: playerX,
        targetY: playerY,
        arenaWidth: arenaWidth,
        arenaHeight: arenaHeight,
      );
      shot['x'] = step.x;
      shot['y'] = step.y;
      shot['life'] = step.life;

      if (step.hitTarget) {
        // Keep the 260ms hit-protection window in the game loop; collision
        // outcome and HP mutation are resolved by the pure combat module.
        final now = DateTime.now();
        final canTakeDamage = lastDamageAt == null ||
            now.difference(lastDamageAt!).inMilliseconds >= 260;
        final resolution = resolveProjectileHit(
          playerHp: playerHp,
          projectileDamage: ((shot['damage'] as double?) ?? 6.0) * (1 - gearStats.damageReduction),
          isDodging: playerMoveTicks > 0,
          canTakeDamage: canTakeDamage,
        );
        playerHp = resolution.updatedPlayerHp;
        switch (resolution.status) {
          case ProjectileHitStatus.damaged:
            _triggerHaptic();
            lastDamageAt = now;
            combatEffects.add({
              'x': playerX, 'y': playerY, 'type': 'playerHit', 'life': 20,
            });
            playRealSound('hit');
          case ProjectileHitStatus.dodged:
            combatEffects.add({
              'x': playerX, 'y': playerY, 'type': 'dodge', 'life': 14,
            });
          case ProjectileHitStatus.invulnerable:
            combatEffects.add({
              'x': playerX, 'y': playerY, 'type': 'dodge', 'life': 10,
            });
        }
      }
      if (step.shouldRemove) enemyProjectiles.removeAt(i);
    }

    // تحريك الأسهم وفحص اصطدامها بالأعداء.
    for (int i = arrows.length - 1; i >= 0; i--) {
      final arrow = arrows[i];
      final movement = advancePlayerProjectile(
        x: arrow['x'] as double,
        y: arrow['y'] as double,
        velocityX: arrow['vx'] as double,
        velocityY: arrow['vy'] as double,
        arenaWidth: arenaWidth,
        arenaHeight: arenaHeight,
        targets: enemies.map((enemy) => CombatCircle(
          x: enemy['x'] as double,
          y: enemy['y'] as double,
          radius: enemy['radius'] as double,
        )).toList(growable: false),
      );
      arrow['x'] = movement.x;
      arrow['y'] = movement.y;

      if (movement.shouldRemove) {
        arrows.removeAt(i);
        continue;
      }

      final hitIndex = movement.hitTargetIndex;
      if (hitIndex == null) continue;

      final enemy = enemies[hitIndex];
      final hitType = switch (enemy['type']) {
        'tank' => 'metalHit',
        'stalker' => 'shadowHit',
        'runner' => 'sparkHit',
        'boss' => 'bossHit',
        _ => 'impact',
      };
      combatEffects.add({
        'x': enemy['x'], 'y': enemy['y'], 'type': hitType, 'life': 16,
      });
      enemy['hitTicks'] = 9;
      final hit = resolveEnemyHit(
        currentHp: enemy['hp'] as double,
        baseDamage: 35 * WeaponCatalog.byId(equippedWeaponId).damageMultiplier,
        attackMultiplier: attackPowerMultiplier,
        criticalChance: criticalChance,
        criticalRoll: random.nextDouble(),
        isBoss: enemy['type'] == 'boss',
      );
      enemy['hp'] = hit.updatedHp;
      if (hit.isCritical) {
        combatEffects.add({
          'x': enemy['x'],
          'y': enemy['y'],
          'type': 'criticalHit',
          'life': 22,
        });
      }
      arrows.removeAt(i);

      if (hit.isDefeated) {
        defeatedSprites.add({
          'x': enemy['x'],
          'y': enemy['y'],
          'type': enemy['type'],
          'boss': enemy['type'] == 'boss',
          'life': 24,
        });
        combatEffects.add({
          'x': enemy['x'],
          'y': enemy['y'],
          'type': enemy['type'] == 'boss' ? 'bossBurst' : 'defeat',
          'life': 25,
        });
        if (hit.dropsCoin) coins.add({'x': enemy['x'], 'y': enemy['y']});
        score += hit.scoreAward;
        totalKills++;
        if (enemy['type'] == 'boss') totalBosses++;
        enemies.removeAt(hitIndex);
        playRealSound('hit');
      }
    }

    // إطفاء ومضة الإصابة تدريجياً حتى لا تبقى الشخصية مضيئة.
    for (final enemy in enemies) {
      final hitTicks = (enemy['hitTicks'] as int?) ?? 0;
      if (hitTicks > 0) enemy['hitTicks'] = hitTicks - 1;
    }

    // ذكاء قتالي متنوع: اندفاع السريع، التفاف المتخفي، واندفاعة الزعيم.
    for (final enemy in enemies) {
      final dx = playerX - (enemy['x'] as double);
      final dy = playerY - (enemy['y'] as double);
      final distance = sqrt(dx * dx + dy * dy);
      final angle = atan2(dy, dx);
      final type = enemy['type'] as String;
      final bossPhase = type == 'boss'
          ? BossCombat.phaseForHealth(
              hp: enemy['hp'] as double,
              maxHp: enemy['maxHp'] as double,
            )
          : 1;
      final bossConfig = BossCombat.configForPhase(bossPhase);
      final previousBossPhase = (enemy['bossPhase'] as int?) ?? 1;
      final bossEnraged = bossPhase == 3;
      if (type == 'boss' && bossPhase != previousBossPhase) {
        enemy['bossPhase'] = bossPhase;
        combatEffects.add({
          'x': enemy['x'], 'y': enemy['y'],
          'type': 'bossBurst', 'life': 30,
        });
      }
      var bossVolleyCooldown =
          (enemy['bossVolleyCooldown'] as int?) ?? 90;
      if (type == 'boss' && bossPhase >= 2) {
        if (bossVolleyCooldown > 0) bossVolleyCooldown--;
        if (bossVolleyCooldown == 0 && distance <= 320) {
          final volley = createBossFanVolley(
            originX: enemy['x'] as double,
            originY: enemy['y'] as double,
            targetX: playerX,
            targetY: playerY,
            count: bossConfig.volleyCount,
            speed: bossConfig.projectileSpeed,
            damage: bossConfig.projectileDamage,
          );
          for (final projectile in volley) {
            enemyProjectiles.add({
              'x': projectile.x,
              'y': projectile.y,
              'vx': projectile.velocityX,
              'vy': projectile.velocityY,
              'damage': projectile.damage,
              'life': projectile.lifetimeTicks,
            });
          }
          bossVolleyCooldown = bossConfig.volleyCooldownTicks;
          combatEffects.add({
            'x': enemy['x'], 'y': enemy['y'],
            'type': 'bossTell', 'life': 16,
          });
        }
      }
      enemy['bossVolleyCooldown'] = bossVolleyCooldown;
      var attackTicks = (enemy['attackTicks'] as int?) ?? 0;
      var attackCooldown = (enemy['attackCooldown'] as int?) ?? 0;
      if (attackTicks > 0) attackTicks--;
      if (attackCooldown > 0) attackCooldown--;
      final attackRange = EnemyAttackRules.attackRange(
        enemyRadius: enemy['radius'] as double,
      );
      var areaAttackTicks = (enemy['areaAttackTicks'] as int?) ?? 0;
      if (areaAttackTicks > 0) areaAttackTicks--;
      if (type == 'ranged' && distance >= 105 && distance <= 255 && attackCooldown == 0) {
        final shotAngle = atan2(dy, dx);
        enemyProjectiles.add({
          'x': enemy['x'], 'y': enemy['y'],
          // مقذوف أبطأ قليلاً ليمنح اللاعب وقتاً أوضح للمراوغة.
          'vx': cos(shotAngle) * 3.8, 'vy': sin(shotAngle) * 3.8,
          'damage': 6.0,
          'life': 110,
        });
        attackTicks = 12;
        attackCooldown = 108;
        combatEffects.add({'x': enemy['x'], 'y': enemy['y'], 'type': 'rangedShot', 'life': 12});
      }
      if (type == 'boss' &&
          distance <= 220 &&
          areaAttackTicks == 0 &&
          attackCooldown == 0) {
        areaAttackTicks = EnemyAttackRules.attackDurationTicks(isBoss: true);
        attackCooldown = EnemyAttackRules.attackCooldownTicks(
          isBoss: true,
          bossEnraged: bossEnraged,
        );
        enemy['areaHitDone'] = false;
        combatEffects.add({
          'x': enemy['x'], 'y': enemy['y'],
          'type': 'bossTell', 'life': 32,
        });
      } else if (type != 'boss' && type != 'ranged' &&
          distance <= attackRange &&
          attackCooldown == 0) {
        attackTicks = EnemyAttackRules.attackDurationTicks(isBoss: false);
        attackCooldown = EnemyAttackRules.attackCooldownTicks(
          isBoss: false,
          bossEnraged: false,
        );
        enemy['attackHitDone'] = false;
        combatEffects.add({
          'x': enemy['x'], 'y': enemy['y'],
          'type': 'enemyAttack', 'life': 12,
        });
      }
      enemy['areaAttackTicks'] = areaAttackTicks;
      enemy['attackTicks'] = attackTicks;
      enemy['attackCooldown'] = attackCooldown;
      if (type == 'boss' &&
          areaAttackTicks == 8 &&
          enemy['areaHitDone'] != true) {
        enemy['areaHitDone'] = true;
        final blastDx = playerX - (enemy['x'] as double);
        final blastDy = playerY - (enemy['y'] as double);
        final blastDistance = sqrt(blastDx * blastDx + blastDy * blastDy);
        final areaHit = resolveAreaAttackHit(
          playerHp: playerHp,
          distanceToPlayer: blastDistance,
          attackRadius: EnemyAttackRules.bossAreaRadius(
            bossEnraged: bossEnraged,
          ),
          damage: EnemyAttackRules.bossAreaDamage(
            bossEnraged: bossEnraged,
          ) * (1 - gearStats.damageReduction),
          isDodging: playerMoveTicks > 0,
          lastDamageAt: lastDamageAt,
        );
        switch (areaHit.status) {
          case AreaAttackHitStatus.outOfRange:
            break;
          case AreaAttackHitStatus.dodged:
          case AreaAttackHitStatus.invulnerable:
            combatEffects.add({
              'x': playerX, 'y': playerY, 'type': 'dodge', 'life': 18,
            });
          case AreaAttackHitStatus.damaged:
            _triggerHaptic();
            playerHp = areaHit.updatedPlayerHp;
            lastDamageAt = areaHit.resolvedAt;
            combatEffects.add({
              'x': playerX, 'y': playerY, 'type': 'playerHit', 'life': 22,
            });
            playRealSound('hit');
        }
        combatEffects.add({
          'x': enemy['x'], 'y': enemy['y'],
          'type': 'bossBurst', 'life': 24,
        });
      }
      final movement = decideEnemyMovement(
        type: type,
        distanceToPlayer: distance,
        baseAngle: angle,
        enemyX: enemy['x'] as double,
        animationTicks: animationTicks,
        bossEnraged: bossEnraged,
        bossPhaseMovementMultiplier: bossConfig.movementMultiplier,
      );
      final moveSpeed =
          (enemy['speed'] as double) * movement.speedMultiplier;
      final moveAngle = movement.angle;

      // Keep telegraph visuals in the game layer; steering itself is pure.
      if (type == 'runner' && animationTicks % 105 == 0) {
        combatEffects.add({
          'x': enemy['x'], 'y': enemy['y'],
          'type': 'enemyAttack', 'life': 12,
        });
      } else if (type == 'boss' && animationTicks % 180 == 0 &&
          animationTicks % 180 < 28) {
        combatEffects.add({
          'x': enemy['x'], 'y': enemy['y'],
          'type': 'bossTell', 'life': 28,
        });
      }

      enemy['x'] = (enemy['x'] as double) + cos(moveAngle) * moveSpeed;
      enemy['y'] = (enemy['y'] as double) + sin(moveAngle) * moveSpeed;
      // دورة مشي مستقلة تتقدم بحسب سرعة الحركة الفعلية لكل عدو.
      enemy['walkPhase'] = ((enemy['walkPhase'] as double?) ?? 0.0) +
          moveSpeed.abs() * (type == 'runner' ? 0.16 : 0.11);
      // لحظة الضرر تقع في منتصف ضربة الهجوم، مرة واحدة لكل دورة.
      final impactDistance = EnemyAttackRules.impactRange(
        enemyRadius: enemy['radius'] as double,
      );
      final impactFrame = EnemyAttackRules.attackImpactFrame(
        isBoss: type == 'boss',
      );
      final contactHit = resolveEnemyContactHit(
        enemyType: type,
        attackTicks: attackTicks,
        impactFrame: impactFrame,
        hitAlreadyResolved: enemy['attackHitDone'] == true,
        distanceToPlayer: distance,
        impactRange: impactDistance,
        playerIsDodging: playerMoveTicks > 0,
        lastDamageAt: lastDamageAt,
        // The resolver samples the clock only after confirming an impact.
        now: null,
        damage: EnemyAttackRules.contactDamage(
          enemyType: type,
          bossEnraged: bossEnraged,
        ) * (1 - gearStats.damageReduction),
      );
      switch (contactHit.status) {
        case EnemyContactHitStatus.notReady:
        case EnemyContactHitStatus.invulnerable:
          break;
        case EnemyContactHitStatus.dodged:
          enemy['attackHitDone'] = true;
          combatEffects.add({
            'x': playerX, 'y': playerY, 'type': 'dodge', 'life': 14,
          });
        case EnemyContactHitStatus.damaged:
          playerHp -= contactHit.damageApplied;
          lastDamageAt = contactHit.resolvedAt;
          enemy['attackHitDone'] = true;
          combatEffects.add({
            'x': playerX, 'y': playerY, 'type': 'playerHit', 'life': 20,
          });
          combatEffects.add({
            'x': enemy['x'], 'y': enemy['y'],
            'type': 'enemyAttack', 'life': 12,
          });
      }
    }

    // Resolve pickups in a pure module; remove descending indices safely.
    final collection = resolveCoinCollection(
      playerX: playerX,
      playerY: playerY,
      coins: coins.map((coin) => CoinPosition(
        x: coin['x'] as double,
        y: coin['y'] as double,
      )).toList(growable: false),
      pickupRadius: coinPickupRadius,
      rewardPerCoin: 10 * WorldRules.forStage(stage).coinRewardMultiplier * (1 + gearStats.coinRewardBonus),
    );
    globalCoins += collection.reward;
    for (final index in collection.collectedIndices) {
      coins.removeAt(index);
      playRealSound('coin');
    }
    if (collection.collectedAny) unawaited(saveProgressSafely());

    // Environmental hazards are room-specific and can be dodged with the
    // existing movement i-frames. The cooldown is tick-based, not timer-based.
    if (_roomHazardCooldownTicks > 0) _roomHazardCooldownTicks--;
    final roomLayout = RoomLayout.forStage(stage);
    if (_roomHazardCooldownTicks == 0 &&
        roomLayout.playerTouchesHazard(
          x: playerX,
          y: playerY,
          arenaWidth: arenaWidth,
          arenaHeight: arenaHeight,
        )) {
      _roomHazardCooldownTicks = 45;
      if (playerMoveTicks > 0) {
        combatEffects.add({
          'x': playerX, 'y': playerY, 'type': 'dodge', 'life': 16,
        });
      } else {
        playerHp = (playerHp - 8 * (1 - gearStats.damageReduction)).clamp(0.0, playerMaxHp).toDouble();
        lastDamageAt = DateTime.now();
        combatEffects.add({
          'x': playerX, 'y': playerY, 'type': 'playerHit', 'life': 20,
        });
        playRealSound('hit');
      }
    }

    if (playerHp <= 0) {
      playerHp = 0;
      runLifecycle.beginPlayerDeath();
      timers.cancel('shoot');
      playerDeathTicks = 0;
      playRealSound('hit');
      if (mounted) setState(() {});
      return;
    }

    if (enemies.isEmpty) {
      _checkStageComplete();
    }

    if (mounted) setState(() {});
  }

  void _checkStageComplete() {
    if (stageTransitioning || enemies.isNotEmpty || gameOverShown) return;
    if (challengeRoomRewardPending) {
      challengeRoomRewardPending = false;
      globalCoins += 150;
      // The normal stage-completion save below persists this reward together
      // with the stage/best-stage update as one ordered snapshot.
      playRealSound('coin');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('أنهيت التحدي! حصلت على 150 عملة إضافية.')),
        );
      }
    }
    final transition = RoomFlow.complete(stage);
    final completion = resolveStageCompletion(
      currentStage: stage,
      playerHp: playerHp,
      playerMaxHp: playerMaxHp,
      bestStage: bestStage,
    );
    final advance = transition.stageAdvance;
    if (transition.currentRoom.isBoss && runLifecycle.beginSpecialRoomChoice()) {
      unawaited(RunCheckpointStore.clear());
      stage = transition.nextRoom.stage;
      _roomHazardCooldownTicks = 0;
      bestStage = completion.updatedBestStage;
      playerHp = completion.updatedPlayerHp;
      unawaited(saveProgressSafely());
      setState(() {});
      playRealSound('special');
      unawaited(_showSpecialRoomChoice());
      return;
    }
    runLifecycle.beginStageReward(
      mysteryChest: advance.reward == StageRewardType.mysteryChest,
    );
    unawaited(RunCheckpointStore.clear());
    stage = transition.nextRoom.stage;
    _roomHazardCooldownTicks = 0;
    bestStage = completion.updatedBestStage;
    playerHp = completion.updatedPlayerHp;
    unawaited(saveProgressSafely());

    if (advance.reward == StageRewardType.mysteryChest) {
      setState(() {});
      playRealSound('special');
    } else {
      _showPerksDialog();
    }
  }

  Future<void> _showSpecialRoomChoice() async {
    final selected = await showDialog<SpecialRoomType>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const SpecialRoomChoiceDialog(),
    );
    if (!mounted || gameOverShown) return;

    final previousCoins = globalCoins;
    final previousHp = playerHp;
    final previousAttackMultiplier = attackPowerMultiplier;
    var challenge = false;
    switch (selected) {
      case SpecialRoomType.treasure:
        globalCoins += 120;
        break;
      case SpecialRoomType.healing:
        playerHp = (playerHp + playerMaxHp * .4)
            .clamp(0.0, playerMaxHp).toDouble();
        break;
      case SpecialRoomType.merchant:
        final purchase = await showDialog<MerchantPurchase>(
          context: context,
          builder: (_) => MerchantRoomDialog(coins: globalCoins),
        );
        if (!mounted || gameOverShown) return;
        if (purchase != null) {
          final result = resolveMerchantPurchase(
            purchase: purchase,
            coins: globalCoins,
            hp: playerHp,
            maxHp: playerMaxHp,
            attackMultiplier: attackPowerMultiplier,
          );
          if (result.purchased) {
            globalCoins = result.remainingCoins;
            playerHp = result.updatedHp;
            attackPowerMultiplier = result.updatedAttackMultiplier;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('عملاتك لا تكفي لهذا الشراء.')),
            );
          }
        }
        break;
      case SpecialRoomType.challenge:
        challenge = true;
        break;
      case null:
        break;
    }

    final saved = await saveProgressSafely();
    if (!saved) {
      globalCoins = previousCoins;
      playerHp = previousHp;
      attackPowerMultiplier = previousAttackMultiplier;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر حفظ مكافأة الغرفة؛ تمت استعادة الحالة السابقة.')),
        );
      }
    }
    runLifecycle.completeSpecialRoomChoice();
    _spawnEnemies(challenge: challenge);
    if (mounted) setState(() {});
    await _persistRunCheckpoint();
  }

  Future<void> _showPerksDialog() async {
    if (!mounted || gameOverShown) return;
    setState(() {});

    final offers = SkillSystem.rollOffers(
      stage: stage,
      random: random,
      currentHp: playerHp,
      maxHp: playerMaxHp,
    );
    final choice = await showSkillSelectionDialog(context, offers);

    if (!mounted || gameOverShown) return;
    final upgrade = applySkillUpgrade(
      current: SkillRuntimeStats(
        extraArrows: extraArrows,
        attackPowerMultiplier: attackPowerMultiplier,
        playerHp: playerHp,
        playerMaxHp: playerMaxHp,
        enemySpeedMultiplier: enemySpeedMultiplier,
        coinPickupRadius: coinPickupRadius,
        criticalChance: criticalChance,
        attackSpeedMultiplier: attackSpeedMultiplier,
        selectedSkills: selectedSkills,
        activeSynergies: activeSkillSynergies,
      ),
      choice: choice,
    );
    final newlyActivatedSynergies =
        upgrade.stats.activeSynergies.difference(activeSkillSynergies.toSet());
    setState(() {
      selectedSkills
        ..clear()
        ..addAll(upgrade.stats.selectedSkills);
      activeSkillSynergies
        ..clear()
        ..addAll(upgrade.stats.activeSynergies);
      extraArrows = upgrade.stats.extraArrows;
      attackPowerMultiplier = upgrade.stats.attackPowerMultiplier;
      playerHp = upgrade.stats.playerHp;
      playerMaxHp = upgrade.stats.playerMaxHp;
      enemySpeedMultiplier = upgrade.stats.enemySpeedMultiplier;
      coinPickupRadius = upgrade.stats.coinPickupRadius;
      criticalChance = upgrade.stats.criticalChance;
      attackSpeedMultiplier = upgrade.stats.attackSpeedMultiplier;
      runLifecycle.completeSkillSelection();
    });
    if (upgrade.requiresAttackLoopRestart) _restartShootLoop();
    if (newlyActivatedSynergies.isNotEmpty && mounted) {
      final names = newlyActivatedSynergies.map(skillSynergyName).join(' · ');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تآزر جديد: $names')),
      );
    }
    _spawnEnemies();
    await _persistRunCheckpoint();
  }

  void _collectChest() {
    totalChests++;
    setState(() {
      globalCoins += (75 * WorldRules.forStage(max(1, stage - 1)).coinRewardMultiplier).round();
      runLifecycle.collectChest();
    });
    unawaited(saveProgressSafely());
    playRealSound('coin');
    _spawnEnemies();
  }

  Future<void> _endGame() async {
    if (gameOverShown) return;
    runLifecycle.finishRun();
    try { await RunCheckpointStore.clear(); } catch (_) {}
    bestStage = max(bestStage, stage);
    bestScore = max(bestScore, score);
    totalRuns++;
    unawaited(saveProgressSafely());
    timers.cancelAll();
    playRealSound('hit');

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'انتهت المعركة',
          style: TextStyle(color: Colors.redAccent),
        ),
        content: Text(
          'المرحلة التي وصلت إليها: $stage\n'
          'النقاط الإجمالية: $score\n'
          'رصيد العملات: 🪙 $globalCoins',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => GameScreen(
                    heroType: widget.heroType,
                    initialStage: stage,
                  ),
                ),
              );
            },
            child: const Text('إعادة المحاولة'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text('العودة للقائمة الرئيسية'),
          ),
        ],
      ),
    );
  }

  void _togglePause() {
    if (showMysteryChest || gameOverShown) return;
    setState(() => runLifecycle.togglePause());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    runSession.dispose();
    worldAnimationController.dispose();
    super.dispose();
  }

  void _handlePlayerDrag(Offset delta, double width, double height) {
    if (!runLifecycle.canPerformActions) return;
    final movement = resolvePlayerDrag(
      currentX: playerX,
      currentY: playerY,
      deltaX: delta.dx,
      deltaY: delta.dy,
      arenaWidth: width,
      arenaHeight: height,
      currentMoveTicks: playerMoveTicks,
    );
    setState(() {
      playerX = movement.x;
      playerY = movement.y;
      playerMoveTicks = movement.moveTicks;
    });
  }

  @override
  Widget build(BuildContext context) => GameArenaView(
        stage: stage,
        score: score,
        coins: globalCoins,
        isPaused: isPaused,
        playerHp: playerHp,
        playerMaxHp: playerMaxHp,
        worldAnimation: worldAnimationController,
        worldTheme: WorldTheme.forStage(stage),
        roomLayout: RoomLayout.forStage(stage),
        coinActors: coins,
        playerArrows: arrows,
        enemyProjectiles: enemyProjectiles,
        enemies: enemies,
        defeatedSprites: defeatedSprites,
        combatEffects: combatEffects,
        playerX: playerX,
        playerY: playerY,
        heroSpritePrefix: playerSpritePrefix,
        animationTicks: animationTicks,
        heroAttackTicks: heroAttackTicks,
        playerMoveTicks: playerMoveTicks,
        playerDying: playerDying,
        playerDeathTicks: playerDeathTicks,
        specialCooldown: specialCooldown,
        showMysteryChest: showMysteryChest,
        onArenaSizeChanged: _syncArenaSize,
        onPlayerDrag: _handlePlayerDrag,
        onPause: _togglePause,
        onSpecialSkill: _useSpecialSkill,
        onCollectChest: _collectChest,
      );

}

