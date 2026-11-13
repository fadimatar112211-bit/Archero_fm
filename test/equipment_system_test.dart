import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/equipment_system.dart';
void main(){
 group('EquipmentCatalog',(){
  test('offers armor, helmets, rings and relics',(){
   expect(EquipmentCatalog.armor,hasLength(3));expect(EquipmentCatalog.helmets,hasLength(3));expect(EquipmentCatalog.rings,hasLength(3));expect(EquipmentCatalog.relics,hasLength(3));
   expect(EquipmentCatalog.byId(EquipmentSlot.armor,1).damageReduction,greaterThan(0));
   expect(EquipmentCatalog.byId(EquipmentSlot.helmet,1).criticalChanceBonus,greaterThan(0));
   expect(EquipmentCatalog.byId(EquipmentSlot.ring,1).attackBonus,greaterThan(0));
   expect(EquipmentCatalog.byId(EquipmentSlot.relic,1).maxHpBonus,greaterThan(0));
  });
  test('combines equipment bonuses with safe caps',(){
   final s=EquipmentCatalog.stats(armorId:2,helmetId:2,ringId:2,relicId:2);
   expect(s.maxHpBonus,65);expect(s.attackBonus,closeTo(.11,.0001));expect(s.damageReduction,closeTo(.14,.0001));expect(s.criticalChanceBonus,closeTo(.15,.0001));expect(s.coinPickupRadiusBonus,24);expect(s.coinRewardBonus,.15);
  });
  test('unknown IDs fall back to base item',(){expect(EquipmentCatalog.byId(EquipmentSlot.relic,99).id,0); expect(EquipmentCatalog.byId(EquipmentSlot.relic,1).maxHpBonus,25);});
 });
}