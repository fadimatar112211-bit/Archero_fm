enum EquipmentSlot { armor, helmet, ring, relic }

class EquipmentProfile {
  const EquipmentProfile({required this.id,required this.slot,required this.name,required this.rarity,required this.description,this.maxHpBonus=0,this.attackBonus=0,this.damageReduction=0,this.criticalChanceBonus=0,this.coinPickupRadiusBonus=0,this.coinRewardBonus=0});
  final int id;
  final EquipmentSlot slot;
  final String name, rarity, description;
  final double maxHpBonus, attackBonus, damageReduction, criticalChanceBonus, coinPickupRadiusBonus, coinRewardBonus;
}
class EquipmentStats {
  const EquipmentStats({this.maxHpBonus=0,this.attackBonus=0,this.damageReduction=0,this.criticalChanceBonus=0,this.coinPickupRadiusBonus=0,this.coinRewardBonus=0});
  final double maxHpBonus, attackBonus, damageReduction, criticalChanceBonus, coinPickupRadiusBonus, coinRewardBonus;
}
class EquipmentCatalog {
  const EquipmentCatalog._();
  static const armor=<EquipmentProfile>[
    EquipmentProfile(id:0,slot:EquipmentSlot.armor,name:'درع الرحّالة',rarity:'عادي',description:'درع متوازن لبداية المغامرة.'),
    EquipmentProfile(id:1,slot:EquipmentSlot.armor,name:'درع الحارس',rarity:'نادر',description:'صحة إضافية وتقليل ضرر الضربات.',maxHpBonus:35,damageReduction:.08),
    EquipmentProfile(id:2,slot:EquipmentSlot.armor,name:'درع العنقاء',rarity:'ملحمي',description:'صحة أكبر ومقاومة أعلى.',maxHpBonus:65,damageReduction:.14),
  ];
  static const helmets=<EquipmentProfile>[
    EquipmentProfile(id:0,slot:EquipmentSlot.helmet,name:'غطاء الرامي',rarity:'عادي',description:'خوذة خفيفة.'),
    EquipmentProfile(id:1,slot:EquipmentSlot.helmet,name:'خوذة الصقر',rarity:'نادر',description:'ترفع فرصة الضربة الحرجة.',criticalChanceBonus:.06),
    EquipmentProfile(id:2,slot:EquipmentSlot.helmet,name:'تاج العاصفة',rarity:'ملحمي',description:'دقة هجومية وفرصة حرجة أعلى.',criticalChanceBonus:.11,attackBonus:.04),
  ];
  static const rings=<EquipmentProfile>[
    EquipmentProfile(id:0,slot:EquipmentSlot.ring,name:'خاتم نحاسي',rarity:'عادي',description:'خاتم بسيط.'),
    EquipmentProfile(id:1,slot:EquipmentSlot.ring,name:'خاتم الصياد',rarity:'نادر',description:'يزيد قوة الهجوم.',attackBonus:.08),
    EquipmentProfile(id:2,slot:EquipmentSlot.ring,name:'خاتم الوفرة',rarity:'ملحمي',description:'يجمع العملات من مسافة أكبر ويزيد مكافآتها.',coinPickupRadiusBonus:24,coinRewardBonus:.15),
  ];
  static const relics=<EquipmentProfile>[
    EquipmentProfile(id:0,slot:EquipmentSlot.relic,name:'تميمة البداية',rarity:'عادي',description:'أثر قديم بلا تعزيز إضافي.'),
    EquipmentProfile(id:1,slot:EquipmentSlot.relic,name:'قلب الجبل',rarity:'نادر',description:'يزيد الصحة القصوى.',maxHpBonus:25),
    EquipmentProfile(id:2,slot:EquipmentSlot.relic,name:'شعلة الحرب',rarity:'ملحمي',description:'تعزز الهجوم والضربات الحرجة.',attackBonus:.07,criticalChanceBonus:.04),
  ];
  static const int defaultOwnedMask = 585;
  static int bitFor(EquipmentSlot slot, int id) => 1 << (slot.index * 3 + id);
  static bool isOwned(int mask, EquipmentProfile item) => (mask & bitFor(item.slot, item.id)) != 0;
  static bool canUnlock(int mask, EquipmentProfile item) =>
      item.id > 0 && (mask & bitFor(item.slot, item.id - 1)) != 0 &&
      !isOwned(mask, item);
  static int unlockCost(EquipmentProfile item) => item.id == 1 ? 180 : 450;
  static int shardUnlockCost(EquipmentProfile item) => item.id == 1 ? 8 : 20;
  static bool canUnlockWithShards(int mask, EquipmentProfile item, int shards) =>
      canUnlock(mask, item) && shards >= shardUnlockCost(item);
  static int unlock(int mask, EquipmentProfile item) {
    if (!canUnlock(mask, item)) return mask;
    return mask | bitFor(item.slot, item.id);
  }
  static EquipmentProfile byId(EquipmentSlot slot,int id) {
    final items=switch(slot){EquipmentSlot.armor=>armor,EquipmentSlot.helmet=>helmets,EquipmentSlot.ring=>rings,EquipmentSlot.relic=>relics};
    return items.firstWhere((item)=>item.id==id,orElse:()=>items.first);
  }
  static EquipmentStats stats({required int armorId,required int helmetId,required int ringId,required int relicId}) {
    final items=[byId(EquipmentSlot.armor,armorId),byId(EquipmentSlot.helmet,helmetId),byId(EquipmentSlot.ring,ringId),byId(EquipmentSlot.relic,relicId)];
    double sum(double Function(EquipmentProfile) read)=>items.fold(0.0,(v,item)=>v+read(item));
    return EquipmentStats(maxHpBonus:sum((i)=>i.maxHpBonus),attackBonus:sum((i)=>i.attackBonus),damageReduction:sum((i)=>i.damageReduction).clamp(0.0,.35).toDouble(),criticalChanceBonus:sum((i)=>i.criticalChanceBonus).clamp(0.0,.5).toDouble(),coinPickupRadiusBonus:sum((i)=>i.coinPickupRadiusBonus),coinRewardBonus:sum((i)=>i.coinRewardBonus).clamp(0.0,.5).toDouble());
  }
}