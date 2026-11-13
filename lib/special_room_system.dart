enum SpecialRoomType { treasure, merchant, healing, challenge }

class SpecialRoomOption {
  const SpecialRoomOption({
    required this.type,
    required this.title,
    required this.description,
  });

  final SpecialRoomType type;
  final String title;
  final String description;
}

const specialRoomOptions = <SpecialRoomOption>[
  SpecialRoomOption(
    type: SpecialRoomType.treasure,
    title: 'غرفة الكنز',
    description: 'افتح الصندوق واحصل على 120 عملة.',
  ),
  SpecialRoomOption(
    type: SpecialRoomType.merchant,
    title: 'متجر التاجر',
    description: 'اشترِ تعزيز هجوم أو جرعة علاج بالعملات.',
  ),
  SpecialRoomOption(
    type: SpecialRoomType.healing,
    title: 'ملاذ العلاج',
    description: 'استعد 40% من صحتك القصوى.',
  ),
  SpecialRoomOption(
    type: SpecialRoomType.challenge,
    title: 'غرفة التحدي',
    description: 'واجه موجة إضافية مقابل مكافأة 150 عملة.',
  ),
];

class MerchantPurchaseResolution {
  const MerchantPurchaseResolution({
    required this.purchased,
    required this.remainingCoins,
    required this.updatedHp,
    required this.updatedAttackMultiplier,
  });

  final bool purchased;
  final int remainingCoins;
  final double updatedHp;
  final double updatedAttackMultiplier;
}

enum MerchantPurchase { attackBoost, healingPotion }

MerchantPurchaseResolution resolveMerchantPurchase({
  required MerchantPurchase purchase,
  required int coins,
  required double hp,
  required double maxHp,
  required double attackMultiplier,
}) {
  final cost = purchase == MerchantPurchase.attackBoost ? 80 : 50;
  if (coins < cost) {
    return MerchantPurchaseResolution(
      purchased: false,
      remainingCoins: coins,
      updatedHp: hp,
      updatedAttackMultiplier: attackMultiplier,
    );
  }
  if (purchase == MerchantPurchase.attackBoost) {
    return MerchantPurchaseResolution(
      purchased: true,
      remainingCoins: coins - cost,
      updatedHp: hp,
      updatedAttackMultiplier: attackMultiplier * 1.15,
    );
  }
  final safeMax = maxHp.isFinite && maxHp > 0 ? maxHp : 0.0;
  final safeHp = hp.isFinite ? hp : 0.0;
  return MerchantPurchaseResolution(
    purchased: true,
    remainingCoins: coins - cost,
    updatedHp: (safeHp + safeMax * .3).clamp(0.0, safeMax).toDouble(),
    updatedAttackMultiplier: attackMultiplier,
  );
}
