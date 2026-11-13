import 'dart:math';

import 'package:flutter/material.dart';

import 'game_progress.dart';
import 'hero_selection_screen.dart';
import 'progress_store.dart';
import 'shop_economy.dart';
import 'weapon_system.dart';
import 'equipment_system.dart';
import 'resource_economy.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  bool _walletBusy = false;
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
        ownedEquipmentMask: ownedEquipmentMask,
        gems: globalGems,
        keys: globalKeys,
        equipmentShards: globalEquipmentShards,
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
        equippedArmorId: equippedArmorId, equippedHelmetId: equippedHelmetId,
        equippedRingId: equippedRingId, equippedRelicId: equippedRelicId,
        ownedEquipmentMask: ownedEquipmentMask,
        gems: globalGems,
        keys: globalKeys,
        equipmentShards: globalEquipmentShards,
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


  Future<void> _persistWallet({
    required int coins,
    required int gems,
    required int keys,
    required int equipmentShards,
  }) => ProgressStore.save(
    coins: coins,
    hpUpgrade: heroHpUpgrade,
    atkUpgrade: heroAtkUpgrade,
    bestStage: bestStage,
    bestScore: bestScore,
    equippedWeaponId: equippedWeaponId,
    equippedArmorId: equippedArmorId,
    equippedHelmetId: equippedHelmetId,
    equippedRingId: equippedRingId,
    equippedRelicId: equippedRelicId,
    ownedEquipmentMask: ownedEquipmentMask,
    gems: gems,
    keys: keys,
    equipmentShards: equipmentShards,
  );

  Future<void> _buyChestKey() async {
    if (_walletBusy) return;
    setState(() => _walletBusy = true);
    try {
      final result = await purchaseChestKey(
        coins: globalCoins,
        gems: globalGems,
        keys: globalKeys,
        equipmentShards: globalEquipmentShards,
        persist: _persistWallet,
      );
      if (!result.completed) {
        _message(result.status == ResourceTransactionStatus.insufficientCoins
            ? 'تحتاج إلى 180 عملة لشراء مفتاح.'
            : 'تعذر حفظ شراء المفتاح؛ لم يتم خصم العملات.');
        return;
      }
      globalCoins = result.coins;
      globalKeys = result.keys;
      try { await playRealSound('coin'); } catch (_) {}
      if (mounted) _message('اشتريت مفتاحاً جديداً للصناديق.');
    } finally {
      _walletBusy = false;
      if (mounted) setState(() {});
    }
  }

  Future<void> _buyChestKeyWithGems() async {
    if (_walletBusy) return;
    setState(() => _walletBusy = true);
    try {
      final result = await purchaseChestKeyWithGems(
        coins: globalCoins,
        gems: globalGems,
        keys: globalKeys,
        equipmentShards: globalEquipmentShards,
        persist: _persistWallet,
      );
      if (!result.completed) {
        _message(result.status == ResourceTransactionStatus.insufficientCoins
            ? 'تحتاج إلى 5 جواهر لشراء مفتاح.'
            : 'تعذر حفظ شراء المفتاح؛ لم يتم خصم الجواهر.');
        return;
      }
      globalGems = result.gems;
      globalKeys = result.keys;
      try { await playRealSound('coin'); } catch (_) {}
      if (mounted) _message('تم شراء مفتاح باستخدام الجواهر.');
    } finally {
      _walletBusy = false;
      if (mounted) setState(() {});
    }
  }

  Future<void> _openChest(ChestDefinition chest) async {
    if (_walletBusy || globalKeys < chest.keyCost) return;
    setState(() => _walletBusy = true);
    try {
      final result = await openRewardChest(
        chest: chest,
        coins: globalCoins,
        gems: globalGems,
        keys: globalKeys,
        equipmentShards: globalEquipmentShards,
        random: Random(),
        persist: _persistWallet,
      );
      if (!result.completed) {
        _message(result.status == ResourceTransactionStatus.insufficientKeys
            ? 'لا تملك مفاتيح كافية لهذا الصندوق.'
            : 'تعذر حفظ الصندوق؛ لم يتم استهلاك المفتاح.');
        return;
      }
      globalCoins = result.coins;
      globalGems = result.gems;
      globalKeys = result.keys;
      globalEquipmentShards = result.equipmentShards;
      try { await playRealSound('special'); } catch (_) {}
      final reward = result.reward!;
      if (mounted) {
        _message('مكافأة الصندوق: +${reward.coins} عملة، +${reward.gems} جوهرة، +${reward.equipmentShards} شظية معدات.');
      }
    } finally {
      _walletBusy = false;
      if (mounted) setState(() {});
    }
  }

  Future<void> _equipWeapon(WeaponProfile weapon) async {
    final previous = equippedWeaponId;
    setState(() => equippedWeaponId = weapon.id);
    try {
      await saveProgress();
    } catch (_) {
      equippedWeaponId = previous;
      if (mounted) {
        setState(() {});
        _message('تعذر حفظ السلاح المختار. بقي السلاح السابق مجهزاً.');
      }
      return;
    }
    try { await playRealSound('special'); } catch (_) {}
  }

  Widget _gearSlot(String title, List<EquipmentProfile> items, int equippedId) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ...items.map((item) {
        final selected = item.id == equippedId;
        final owned = EquipmentCatalog.isOwned(ownedEquipmentMask, item);
        final canUnlock = EquipmentCatalog.canUnlock(ownedEquipmentMask, item);
        return OutlinedButton(
          onPressed: owned
              ? (selected ? null : () => _equipGear(item))
              : (canUnlock ? () => _unlockGear(item) : null),
          style: OutlinedButton.styleFrom(
            alignment: Alignment.centerRight,
            side: BorderSide(color: selected ? Colors.lightBlueAccent : (owned ? Colors.white24 : Colors.amber.withOpacity(.45))),
          ),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${item.name} · ${item.rarity}', style: TextStyle(color: selected ? Colors.lightBlueAccent : Colors.white, fontWeight: FontWeight.bold)),
              Text(item.description, style: const TextStyle(fontSize: 11, color: Colors.white70)),
              if (!owned) Text(canUnlock ? 'فتح القطعة: ${EquipmentCatalog.unlockCost(item)} عملة' : 'افتح القطعة السابقة أولاً', style: const TextStyle(fontSize: 11, color: Colors.amber)),
            ])),
            if (selected) const Icon(Icons.check_circle, color: Colors.lightBlueAccent)
            else if (!owned) Icon(canUnlock ? Icons.lock_open : Icons.lock, color: Colors.amber),
          ]),
        );
      }),
    ]),
  );

  Future<void> _unlockGear(EquipmentProfile item) async {
    if (!EquipmentCatalog.canUnlock(ownedEquipmentMask, item)) return;
    final cost = EquipmentCatalog.unlockCost(item);
    if (globalCoins < cost) {
      _message('تحتاج إلى $cost عملة لفتح هذه القطعة.');
      return;
    }
    final previousCoins = globalCoins;
    final previousMask = ownedEquipmentMask;
    final previousSlots = [equippedArmorId, equippedHelmetId, equippedRingId, equippedRelicId];
    setState(() {
      globalCoins -= cost;
      ownedEquipmentMask = EquipmentCatalog.unlock(ownedEquipmentMask, item);
      switch (item.slot) {
        case EquipmentSlot.armor: equippedArmorId = item.id; break;
        case EquipmentSlot.helmet: equippedHelmetId = item.id; break;
        case EquipmentSlot.ring: equippedRingId = item.id; break;
        case EquipmentSlot.relic: equippedRelicId = item.id; break;
      }
    });
    try {
      await saveProgress();
    } catch (_) {
      globalCoins = previousCoins;
      ownedEquipmentMask = previousMask;
      equippedArmorId = previousSlots[0];
      equippedHelmetId = previousSlots[1];
      equippedRingId = previousSlots[2];
      equippedRelicId = previousSlots[3];
      if (mounted) {
        setState(() {});
        _message('تعذر حفظ فتح القطعة. لم يتم اعتماد الخصم.');
      }
      return;
    }
    try { await playRealSound('coin'); } catch (_) {}
    if (mounted) _message('تم فتح وتجهيز ${item.name}.');
  }

  Future<void> _equipGear(EquipmentProfile item) async {
    if (!EquipmentCatalog.isOwned(ownedEquipmentMask, item)) return;
    final old = [equippedArmorId, equippedHelmetId, equippedRingId, equippedRelicId];
    setState(() { switch (item.slot) { case EquipmentSlot.armor: equippedArmorId=item.id; break; case EquipmentSlot.helmet: equippedHelmetId=item.id; break; case EquipmentSlot.ring: equippedRingId=item.id; break; case EquipmentSlot.relic: equippedRelicId=item.id; break; } });
    try {
      await saveProgress();
    } catch (_) {
      equippedArmorId=old[0];
      equippedHelmetId=old[1];
      equippedRingId=old[2];
      equippedRelicId=old[3];
      if (mounted) {
        setState(() {});
        _message('تعذر حفظ المعدّات. بقي التجهيز السابق.');
      }
      return;
    }
    try { await playRealSound('special'); } catch (_) {}
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
                    _panel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            '💎 الموارد والصناديق',
                            style: TextStyle(color: Colors.amberAccent, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            alignment: WrapAlignment.spaceAround,
                            spacing: 14,
                            runSpacing: 10,
                            children: [
                              _resourceBadge(Icons.diamond, 'الجواهر', globalGems, Colors.lightBlueAccent),
                              _resourceBadge(Icons.vpn_key, 'المفاتيح', globalKeys, Colors.amber),
                              _resourceBadge(Icons.auto_awesome, 'شظايا المعدات', globalEquipmentShards, Colors.purpleAccent),
                            ],
                          ),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: _walletBusy ? null : _buyChestKey,
                            icon: const Icon(Icons.key),
                            label: Text(_walletBusy ? 'جارٍ حفظ العملية…' : 'شراء مفتاح · 180 عملة'),
                          ),
                          const SizedBox(height: 6),
                          OutlinedButton.icon(
                            onPressed: _walletBusy || globalGems < 5 ? null : _buyChestKeyWithGems,
                            icon: const Icon(Icons.diamond),
                            label: const Text('شراء مفتاح · 5 جواهر'),
                          ),
                          const SizedBox(height: 8),
                          ...chestDefinitions.map((chest) => Padding(
                            padding: const EdgeInsets.only(bottom: 7),
                            child: OutlinedButton.icon(
                              onPressed: !_walletBusy && globalKeys >= chest.keyCost ? () => _openChest(chest) : null,
                              icon: Icon(chest.type == RewardChestType.relic ? Icons.diamond : Icons.inventory_2),
                              label: Text('${chest.name} · ${chest.keyCost} مفتاح'),
                            ),
                          )),
                          const Text(
                            'الصناديق تمنح عملات وجواهر وشظايا معدات، وتُحفظ الموارد قبل اعتماد المكافأة.',
                            style: TextStyle(fontSize: 11, color: Colors.white70),
                            textAlign: TextAlign.center,
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

  Widget _resourceBadge(IconData icon, String label, int value, Color color) =>
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 3),
          Text('$value', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70)),
        ],
      );

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
