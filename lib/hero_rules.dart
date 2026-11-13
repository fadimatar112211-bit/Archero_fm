class HeroProfile {
  const HeroProfile({
    required this.id,
    required this.name,
    required this.summary,
    required this.activeSkillName,
    required this.activeSkillDescription,
    required this.activeSkillDamage,
    this.triggersDodge = false,
    required this.passiveSkillName,
    required this.passiveSkillDescription,
  });

  final int id;
  final String name;
  final String summary;
  final String activeSkillName;
  final String activeSkillDescription;
  final double activeSkillDamage;
  final bool triggersDodge;
  final String passiveSkillName;
  final String passiveSkillDescription;

  static const balanced = HeroProfile(
    id: 1,
    name: 'الرامي المتوازن',
    summary: 'صحة وسرعة وهجوم متوازنة.',
    activeSkillName: 'نبضة الطاقة',
    activeSkillDescription: 'تسبب 48 ضرراً أساسياً لجميع الأعداء.',
    activeSkillDamage: 48,
    passiveSkillName: 'تركيز الرامي',
    passiveSkillDescription: 'فرصة حرجة أساسية بنسبة 5%.',
  );

  static const flame = HeroProfile(
    id: 2,
    name: 'فارس النارية',
    summary: 'يبدأ بصحة إضافية قدرها 50.',
    activeSkillName: 'انفجار اللهب',
    activeSkillDescription: 'يسبب 70 ضرراً أساسياً لجميع الأعداء.',
    activeSkillDamage: 70,
    passiveSkillName: 'جلد اللهب',
    passiveSkillDescription: '50 نقطة صحة إضافية عند بدء الجولة.',
  );

  static const shadow = HeroProfile(
    id: 3,
    name: 'صياد الظل',
    summary: 'يمتلك سرعة حركة أعلى.',
    activeSkillName: 'خطوة الظل',
    activeSkillDescription: 'تفادي قصير مع 42 ضرراً أساسياً لجميع الأعداء.',
    activeSkillDamage: 42,
    triggersDodge: true,
    passiveSkillName: 'خطوة خفيفة',
    passiveSkillDescription: 'سرعة حركة أعلى من بقية الأبطال.',
  );

  static const storm = HeroProfile(
    id: 4,
    name: 'حارس العواصف',
    summary: 'يطلق سهماً إضافياً في كل هجمة.',
    activeSkillName: 'عاصفة السهام',
    activeSkillDescription: 'تسبب 54 ضرراً أساسياً لجميع الأعداء.',
    activeSkillDamage: 54,
    passiveSkillName: 'وتر العاصفة',
    passiveSkillDescription: 'سهم إضافي في كل هجمة.',
  );

  static const List<HeroProfile> all = [balanced, flame, shadow, storm];

  static HeroProfile forType(int heroType) {
    return switch (heroType) {
      2 => flame,
      3 => shadow,
      4 => storm,
      _ => balanced,
    };
  }
}

class HeroRunStats {
  const HeroRunStats({
    required this.playerHp,
    required this.playerMaxHp,
    required this.playerSpeed,
    required this.attackPowerMultiplier,
    required this.extraArrows,
    required this.criticalChance,
  });

  final double playerHp;
  final double playerMaxHp;
  final double playerSpeed;
  final double attackPowerMultiplier;
  final int extraArrows;
  final double criticalChance;
}

/// Resolves the initial stats and passive ability for a selected hero,
/// including permanent account upgrades.
HeroRunStats createHeroRunStats({
  required int heroType,
  required int hpUpgrade,
  required int attackUpgrade,
}) {
  final profile = HeroProfile.forType(heroType);
  final playerMaxHp = 100.0 + hpUpgrade + (profile.id == 2 ? 50 : 0);
  final playerSpeed = profile.id == 3 ? 5.2 : 3.5;
  final attackPowerMultiplier = 1.0 + attackUpgrade * 0.08;
  final extraArrows = profile.id == 4 ? 1 : 0;
  final criticalChance = profile.id == 1 ? 0.05 : 0.0;

  return HeroRunStats(
    playerHp: playerMaxHp,
    playerMaxHp: playerMaxHp,
    playerSpeed: playerSpeed,
    attackPowerMultiplier: attackPowerMultiplier,
    extraArrows: extraArrows,
    criticalChance: criticalChance,
  );
}
