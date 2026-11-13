import 'dart:math';

enum SkillId {
  extraArrow,
  attackPower,
  healing,
  vitality,
  frostAura,
  coinMagnet,
  criticalStrike,
  swiftHands,
}

enum SkillRarity { common, rare, epic }

class SkillOption {
  final SkillId id;
  final String title;
  final String description;
  final SkillRarity rarity;

  const SkillOption({
    required this.id,
    required this.title,
    required this.description,
    required this.rarity,
  });
}

class SkillSystem {
  const SkillSystem._();

  static const List<SkillOption> _catalog = [
    SkillOption(
      id: SkillId.extraArrow,
      title: 'وابل السهام',
      description: 'سهم إضافي في كل هجمة.',
      rarity: SkillRarity.common,
    ),
    SkillOption(
      id: SkillId.attackPower,
      title: 'قوة مدمرة',
      description: 'زيادة قوة الهجوم 25%.',
      rarity: SkillRarity.common,
    ),
    SkillOption(
      id: SkillId.healing,
      title: 'نبض الحياة',
      description: 'استعادة 55 نقطة صحة.',
      rarity: SkillRarity.common,
    ),
    SkillOption(
      id: SkillId.vitality,
      title: 'قلب العملاق',
      description: 'زيادة الصحة القصوى 25 واستعادة 25 صحة.',
      rarity: SkillRarity.rare,
    ),
    SkillOption(
      id: SkillId.frostAura,
      title: 'هالة الصقيع',
      description: 'إبطاء الأعداء في المراحل القادمة 10%.',
      rarity: SkillRarity.rare,
    ),
    SkillOption(
      id: SkillId.coinMagnet,
      title: 'جاذب الكنوز',
      description: 'زيادة مدى جمع العملات 45%.',
      rarity: SkillRarity.epic,
    ),
    SkillOption(
      id: SkillId.criticalStrike,
      title: 'ضربة حرجة',
      description: 'فرصة 15% لإحداث ضرر مضاعف.',
      rarity: SkillRarity.rare,
    ),
    SkillOption(
      id: SkillId.swiftHands,
      title: 'سرعة الرامي',
      description: 'زيادة سرعة إطلاق السهام 18%.',
      rarity: SkillRarity.epic,
    ),
  ];

  static List<SkillOption> rollOffers({
    required int stage,
    required Random random,
    int count = 3,
  }) {
    final remaining = List<SkillOption>.of(_catalog);
    final offers = <SkillOption>[];
    final safeCount = count.clamp(1, remaining.length);

    while (offers.length < safeCount) {
      final stageBonus = (stage < 1 ? 1 : stage).clamp(1, 20);
      final weights = remaining.map((skill) {
        final base = switch (skill.rarity) {
          SkillRarity.common => 70,
          SkillRarity.rare => 22 + stageBonus,
          SkillRarity.epic => 5 + stageBonus ~/ 2,
        };
        return base;
      }).toList();
      final totalWeight = weights.fold<int>(0, (sum, value) => sum + value);
      var roll = random.nextInt(totalWeight);
      var selectedIndex = 0;
      for (var i = 0; i < weights.length; i++) {
        roll -= weights[i];
        if (roll < 0) {
          selectedIndex = i;
          break;
        }
      }
      offers.add(remaining.removeAt(selectedIndex));
    }

    return List<SkillOption>.unmodifiable(offers);
  }
}

class SkillRuntimeStats {
  const SkillRuntimeStats({
    required this.extraArrows,
    required this.attackPowerMultiplier,
    required this.playerHp,
    required this.playerMaxHp,
    required this.enemySpeedMultiplier,
    required this.coinPickupRadius,
    required this.criticalChance,
    required this.attackSpeedMultiplier,
  });

  final int extraArrows;
  final double attackPowerMultiplier;
  final double playerHp;
  final double playerMaxHp;
  final double enemySpeedMultiplier;
  final double coinPickupRadius;
  final double criticalChance;
  final double attackSpeedMultiplier;
}

class SkillUpgradeResolution {
  const SkillUpgradeResolution({
    required this.stats,
    required this.requiresAttackLoopRestart,
  });

  final SkillRuntimeStats stats;
  final bool requiresAttackLoopRestart;
}

/// Applies a selected in-run upgrade without mutating widget state.
/// A null choice (for example, a dismissed dialog) leaves all stats unchanged.
SkillUpgradeResolution applySkillUpgrade({
  required SkillRuntimeStats current,
  required SkillId? choice,
}) {
  var extraArrows = current.extraArrows;
  var attackPowerMultiplier = current.attackPowerMultiplier;
  var playerHp = current.playerHp;
  var playerMaxHp = current.playerMaxHp;
  var enemySpeedMultiplier = current.enemySpeedMultiplier;
  var coinPickupRadius = current.coinPickupRadius;
  var criticalChance = current.criticalChance;
  var attackSpeedMultiplier = current.attackSpeedMultiplier;
  var requiresAttackLoopRestart = false;

  switch (choice) {
    case SkillId.extraArrow:
      extraArrows++;
    case SkillId.attackPower:
      attackPowerMultiplier += 0.25;
    case SkillId.healing:
      playerHp = (playerHp + 55).clamp(0.0, playerMaxHp).toDouble();
    case SkillId.vitality:
      playerMaxHp += 25;
      playerHp = (playerHp + 25).clamp(0.0, playerMaxHp).toDouble();
    case SkillId.frostAura:
      enemySpeedMultiplier *= 0.9;
    case SkillId.coinMagnet:
      coinPickupRadius *= 1.45;
    case SkillId.criticalStrike:
      criticalChance = (criticalChance + 0.15).clamp(0.0, 0.75).toDouble();
    case SkillId.swiftHands:
      attackSpeedMultiplier =
          (attackSpeedMultiplier * 1.18).clamp(1.0, 2.2).toDouble();
      requiresAttackLoopRestart = true;
    case null:
      break;
  }

  return SkillUpgradeResolution(
    stats: SkillRuntimeStats(
      extraArrows: extraArrows,
      attackPowerMultiplier: attackPowerMultiplier,
      playerHp: playerHp,
      playerMaxHp: playerMaxHp,
      enemySpeedMultiplier: enemySpeedMultiplier,
      coinPickupRadius: coinPickupRadius,
      criticalChance: criticalChance,
      attackSpeedMultiplier: attackSpeedMultiplier,
    ),
    requiresAttackLoopRestart: requiresAttackLoopRestart,
  );
}
