class WeaponProfile {
  const WeaponProfile({required this.id,required this.name,required this.description,required this.damageMultiplier,required this.attackSpeedMultiplier,required this.projectileSpeed,required this.spreadAngle,this.bonusArrows=0});
  final int id; final String name; final String description;
  final double damageMultiplier, attackSpeedMultiplier, projectileSpeed, spreadAngle;
  final int bonusArrows;
}
class WeaponCatalog {
  const WeaponCatalog._();
  static const List<WeaponProfile> all=[
    WeaponProfile(id:0,name:'القوس المتوازن',description:'سلاح متوازن للضرر والسرعة والمدى.',damageMultiplier:1,attackSpeedMultiplier:1,projectileSpeed:8.5,spreadAngle:0.20),
    WeaponProfile(id:1,name:'القوس النابض',description:'إطلاق أسرع ومقذوفات أسرع مقابل ضرر أقل.',damageMultiplier:0.82,attackSpeedMultiplier:1.32,projectileSpeed:10.5,spreadAngle:0.14),
    WeaponProfile(id:2,name:'القوس الثقيل',description:'ضربات قوية ومقذوفات ثقيلة لكن الإطلاق أبطأ.',damageMultiplier:1.58,attackSpeedMultiplier:0.76,projectileSpeed:7.2,spreadAngle:0.10),
    WeaponProfile(id:3,name:'قوس الشظايا',description:'ينشر سهاماً بزاوية أوسع لتغطية مساحة أكبر.',damageMultiplier:0.92,attackSpeedMultiplier:0.96,projectileSpeed:9,spreadAngle:0.34,bonusArrows:1),
  ];
  static WeaponProfile byId(int id){for(final weapon in all){if(weapon.id==id)return weapon;}return all.first;}
}