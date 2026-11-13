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
