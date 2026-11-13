import 'package:flutter/material.dart';

import 'game_progress.dart';
import 'hero_selection_screen.dart';
import 'progress_store.dart';
import 'shop_economy.dart';
import 'weapon_system.dart';
import 'equipment_system.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  Future<void> _buyHealth() async {
    final purchase = await commitUpgradePurchase(
      upgrade: ShopEconomy.health(heroHpUpgrade),
      currentCoins: globalCoins,
      currentUpgradeValue: heroHpUpgrade,
      persist: (coins, upgradeValue) => ProgressStore.save(
        coins: coins,
        hpUpgrade: upgradeValue,
        atkUpgrade: heroAtkUpgrade,
        bestStage: bestStage,
        bestScore: bestScore,
        equippedWeaponId: equippedWeaponId,
        equippedArmorId: equippedArmorId, equippedHelmetId: equippedHelmetId,
        equippedRingId: equippedRingId, equippedRelicId: equippedRelicId,
      ),
    );
    if (!purchase.purchased) {
      _message(switch (purchase.status) {
        ShopPurchaseStatus.maxLevel => 'وصلت إلى الحد الأقصى لترقية الصحة.',
        ShopPurchaseStatus.insufficientFunds => 'عملاتك لا تكفي لشراء ترقية الصحة.',
        ShopPurchaseStatus.persistenceFailed => 'تعذر حفظ عملية الشراء. لم يتم خصم العملات.',
        ShopPurchaseStatus.purchased => '',
      });
      return;
    }
    if (!mounted) return;
    setState(() {
      globalCoins = purchase.remainingCoins;
      heroHpUpgrade = purchase.updatedUpgradeValue;
    });
    await playRealSound('coin');
  }

  Future<void> _buyAttack() async {
    debugPrint('[Shop] attack purchase requested: coins=$globalCoins upgrade=$heroAtkUpgrade');
    final purchase = await commitUpgradePurchase(
      upgrade: ShopEconomy.attack(heroAtkUpgrade),
      currentCoins: globalCoins,
      currentUpgradeValue: heroAtkUpgrade,
      persist: (coins, upgradeValue) => ProgressStore.save(
        coins: coins,
        hpUpgrade: heroHpUpgrade,
        atkUpgrade: upgradeValue,
        bestStage: bestStage,
        bestScore: bestScore,
        equippedWeaponId: equippedWeaponId,
      ),
    );
    debugPrint('[Shop] attack purchase result: ${purchase.status} remaining=${purchase.remainingCoins}');
    if (!purchase.purchased) {
      _message(switch (purchase.status) {
        ShopPurchaseStatus.maxLevel => 'وصلت إلى الحد الأقصى لترقية الهجوم.',
        ShopPurchaseStatus.insufficientFunds => 'عملاتك لا تكفي لشراء ترقية الهجوم.',
        ShopPurchaseStatus.persistenceFailed => 'تعذر حفظ عملية الشراء. لم يتم خصم العملات.',
        ShopPurchaseStatus.purchased => '',
      });
      return;
    }
    if (!mounted) return;
    setState(() {
      globalCoins = purchase.remainingCoins;
      heroAtkUpgrade = purchase.updatedUpgradeValue;
    });
    await playRealSound('coin');
  }

  Future<void> _equipWeapon(WeaponProfile weapon) async {
    final previous = equippedWeaponId;
    setState(() => equippedWeaponId = weapon.id);
    try { await saveProgress(); await playRealSound('special'); }
    catch (_) { if (!mounted) return; setState(() => equippedWeaponId = previous); _message('تعذر حفظ السلاح المختار. بقي السلاح السابق مجهزاً.'); }
  }

  Widget _gearSlot(String title, List<EquipmentProfile> items, int equippedId) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ...items.map((item) { final selected = item.id == equippedId; return OutlinedButton(
        onPressed: selected ? null : () => _equipGear(item),
        style: OutlinedButton.styleFrom(alignment: Alignment.centerRight, side: BorderSide(color: selected ? Colors.lightBlueAccent : Colors.white24)),
        child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${item.name} · ${item.rarity}', style: TextStyle(color: selected ? Colors.lightBlueAccent : Colors.white, fontWeight: FontWeight.bold)), Text(item.description, style: const TextStyle(fontSize: 11, color: Colors.white70))])), if (selected) const Icon(Icons.check_circle, color: Colors.lightBlueAccent)]),
      );}),
    ]),
  );

  Future<void> _equipGear(EquipmentProfile item) async {
    final old = [equippedArmorId, equippedHelmetId, equippedRingId, equippedRelicId];
    setState(() { switch (item.slot) { case EquipmentSlot.armor: equippedArmorId=item.id; case EquipmentSlot.helmet: equippedHelmetId=item.id; case EquipmentSlot.ring: equippedRingId=item.id; case EquipmentSlot.relic: equippedRelicId=item.id; } });
    try { await saveProgress(); await playRealSound('special'); }
    catch (_) { if (!mounted) return; setState(() { equippedArmorId=old[0]; equippedHelmetId=old[1]; equippedRingId=old[2]; equippedRelicId=old[3]; }); _message('تعذر حفظ المعدّات. بقي التجهيز السابق.'); }
  }

  void _message(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF260044), Color(0xFF090A0F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(22),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  children: [
                    const Icon(
                      Icons.sports_esports_rounded,
                      size: 82,
                      color: Colors.amberAccent,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'ARCHERO: SOUND EDITION',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'قاتل، طوّر بطلك، وتجاوز المراحل',
                      style: TextStyle(color: Colors.amber, fontSize: 14),
                    ),
                    const SizedBox(height: 25),
                    _panel(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.monetization_on,
                              color: Colors.amber, size: 25),
                          const SizedBox(width: 9),
                          Text(
                            'رصيدك: $globalCoins',
                            style: const TextStyle(
                              color: Colors.yellowAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _panel(
                      child: Wrap(
                        alignment: WrapAlignment.spaceEvenly,
                        runAlignment: WrapAlignment.center,
                        spacing: 22,
                        runSpacing: 12,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.emoji_events, color: Colors.amber),
                              const SizedBox(height: 4),
                              Text('أفضل مرحلة: $bestStage',
                                  textAlign: TextAlign.center),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.stars, color: Colors.lightBlueAccent),
                              const SizedBox(height: 4),
                              Text('أفضل نتيجة: $bestScore',
                                  textAlign: TextAlign.center),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _panel(
                      child: Column(
                        children: [
                          const Text(
                            '🛠️ متجر تطوير القدرات',
                            style: TextStyle(
                              color: Colors.amberAccent,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('زيادة الصحة الحالية: +$heroHpUpgrade'),
                          Text('زيادة الهجوم الحالية: +$heroAtkUpgrade'),
                          const SizedBox(height: 14),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              FilledButton.icon(
                                onPressed: ShopEconomy.health(heroHpUpgrade).canPurchase(globalCoins)
                                    ? _buyHealth
                                    : null,
                                icon: const Icon(Icons.favorite),
                                label: Text(ShopEconomy.health(heroHpUpgrade).isMaxed
                                    ? 'الصحة: الحد الأقصى'
                                    : 'صحة +25 · المستوى ${ShopEconomy.health(heroHpUpgrade).level}/${ShopEconomy.health(heroHpUpgrade).maxLevel} · ${ShopEconomy.health(heroHpUpgrade).cost} عملة'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.blue.shade800,
                                ),
                              ),
                              FilledButton.icon(
                                onPressed: ShopEconomy.attack(heroAtkUpgrade).canPurchase(globalCoins)
                                    ? _buyAttack
                                    : null,
                                icon: const Icon(Icons.flash_on),
                                label: Text(ShopEconomy.attack(heroAtkUpgrade).isMaxed
                                    ? 'الهجوم: الحد الأقصى'
                                    : 'هجوم +15 · المستوى ${ShopEconomy.attack(heroAtkUpgrade).level}/${ShopEconomy.attack(heroAtkUpgrade).maxLevel} · ${ShopEconomy.attack(heroAtkUpgrade).cost} عملة'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.deepOrange.shade800,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _panel(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      const Text('⚔️ ترسانة الأسلحة',style:TextStyle(color:Colors.amberAccent,fontSize:18,fontWeight:FontWeight.bold)),
                      const SizedBox(height:6),
                      const Text('كل سلاح يغيّر الضرر وسرعة الإطلاق وسرعة المقذوف وانتشاره.',style:TextStyle(fontSize:12,color:Colors.white70)),
                      const SizedBox(height:12),
                      ...WeaponCatalog.all.map((weapon){final selected=equippedWeaponId==weapon.id;return Padding(padding:const EdgeInsets.only(bottom:8),child:OutlinedButton(onPressed:selected?null:()=>_equipWeapon(weapon),style:OutlinedButton.styleFrom(alignment:Alignment.centerRight,side:BorderSide(color:selected?Colors.amber:Colors.white24),backgroundColor:selected?Colors.amber.withOpacity(0.12):Colors.transparent,padding:const EdgeInsets.symmetric(horizontal:14,vertical:11)),child:Row(children:[Icon(selected?Icons.check_circle:Icons.sports_martial_arts,color:selected?Colors.amber:Colors.white70),const SizedBox(width:10),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(weapon.name,style:TextStyle(fontWeight:FontWeight.bold,color:selected?Colors.amber:Colors.white)),Text(weapon.description,style:const TextStyle(fontSize:11,color:Colors.white70))])),if(selected)const Text('مجهز',style:TextStyle(color:Colors.amber))])));}),
                    ])),
                    const SizedBox(height: 18),
                    _panel(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      const Text('🛡️ المعدات والآثار', style: TextStyle(color: Colors.lightBlueAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                      const Text('جهّز درعاً وخوذة وخاتماً وأثراً. كل قطعة تمنح خصائص مختلفة وتبقى محفوظة.', style: TextStyle(fontSize: 12, color: Colors.white70)),
                      const SizedBox(height: 10),
                      _gearSlot('الدروع', EquipmentCatalog.armor, equippedArmorId),
                      _gearSlot('الخوذ', EquipmentCatalog.helmets, equippedHelmetId),
                      _gearSlot('الخواتم', EquipmentCatalog.rings, equippedRingId),
                      _gearSlot('الآثار', EquipmentCatalog.relics, equippedRelicId),
                    ])),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        onPressed: () {
                          playRealSound('special');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HeroSelectionScreen(),
                            ),
                          ).then((_) {
                            if (mounted) setState(() {});
                          });
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          'اختيار البطل واللعب',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 19,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _panel({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: child,
    );
  }
}
