import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/weapon_system.dart';
void main(){
 group('WeaponCatalog',(){
  test('offers distinct combat trade-offs',(){
   final bow=WeaponCatalog.byId(0),rapid=WeaponCatalog.byId(1),heavy=WeaponCatalog.byId(2),spread=WeaponCatalog.byId(3);
   expect(rapid.attackSpeedMultiplier,greaterThan(bow.attackSpeedMultiplier));
   expect(rapid.damageMultiplier,lessThan(bow.damageMultiplier));
   expect(heavy.damageMultiplier,greaterThan(bow.damageMultiplier));
   expect(heavy.attackSpeedMultiplier,lessThan(bow.attackSpeedMultiplier));
   expect(spread.bonusArrows,1);expect(spread.spreadAngle,greaterThan(bow.spreadAngle));
  });
  test('falls back for unknown IDs',(){expect(WeaponCatalog.byId(-1).id,0);expect(WeaponCatalog.byId(99).id,0);});
  test('has unique IDs and valid stats',(){
   expect(WeaponCatalog.all.map((w)=>w.id).toSet(),hasLength(4));
   for(final w in WeaponCatalog.all){expect(w.name,isNotEmpty);expect(w.projectileSpeed,greaterThan(0));expect(w.damageMultiplier,greaterThan(0));expect(w.attackSpeedMultiplier,greaterThan(0));}
  });
 });
}