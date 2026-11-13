import 'package:flutter/material.dart';

import 'equipment_system.dart';
import 'game_progress.dart';
import 'weapon_system.dart';

class LoadoutScreen extends StatefulWidget {
  const LoadoutScreen({super.key});

  @override
  State<LoadoutScreen> createState() => _LoadoutScreenState();
}

class _LoadoutScreenState extends State<LoadoutScreen> {
  bool _saving = false;

  Future<void> _changeLoadout(void Function() apply, void Function() rollback) async {
    if (_saving) return;
    setState(() {
      _saving = true;
      apply();
    });
    try {
      await saveProgress();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ التجهيز الجديد بنجاح.')),
        );
      }
    } catch (_) {
      rollback();
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر حفظ التجهيز؛ تمت استعادة الاختيار السابق.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  List<EquipmentProfile> _ownedItems(List<EquipmentProfile> items) =>
      items.where((item) => EquipmentCatalog.isOwned(ownedEquipmentMask, item)).toList();

  Widget _equipmentPicker({
    required String label,
    required List<EquipmentProfile> items,
    required int selectedId,
    required ValueChanged<int> onChanged,
  }) {
    final owned = _ownedItems(items);
    final selected = owned.any((item) => item.id == selectedId)
        ? selectedId
        : (owned.isEmpty ? 0 : owned.first.id);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<int>(
        value: selected,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white.withOpacity(.04),
        ),
        items: owned.map((item) => DropdownMenuItem<int>(
          value: item.id,
          child: Text('${item.name} · ${item.rarity}', overflow: TextOverflow.ellipsis),
        )).toList(),
        onChanged: _saving || owned.length < 2 ? null : (value) {
          if (value != null && value != selectedId) onChanged(value);
        },
      ),
    );
  }

  Widget _stat(String title, String value, IconData icon) => Container(
    constraints: const BoxConstraints(minWidth: 135),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(.055),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.white12),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: Colors.amberAccent, size: 19),
      const SizedBox(width: 8),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ]),
    ]),
  );

  @override
  Widget build(BuildContext context) {
    final weapon = WeaponCatalog.byId(equippedWeaponId);
    final armor = EquipmentCatalog.byId(EquipmentSlot.armor, equippedArmorId);
    final helmet = EquipmentCatalog.byId(EquipmentSlot.helmet, equippedHelmetId);
    final ring = EquipmentCatalog.byId(EquipmentSlot.ring, equippedRingId);
    final relic = EquipmentCatalog.byId(EquipmentSlot.relic, equippedRelicId);
    final stats = EquipmentCatalog.stats(
      armorId: equippedArmorId,
      helmetId: equippedHelmetId,
      ringId: equippedRingId,
      relicId: equippedRelicId,
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('تجهيزات البطل'), centerTitle: true),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  const Text('السلاح الرئيسي', style: TextStyle(color: Colors.amberAccent, fontSize: 17, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(weapon.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(weapon.description, style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    key: const ValueKey('weapon-selector'),
                    value: equippedWeaponId,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'اختيار السلاح', border: OutlineInputBorder()),
                    items: WeaponCatalog.all.map((item) => DropdownMenuItem<int>(
                      value: item.id,
                      child: Text(item.name),
                    )).toList(),
                    onChanged: _saving ? null : (value) {
                      if (value == null || value == equippedWeaponId) return;
                      final previous = equippedWeaponId;
                      _changeLoadout(() => equippedWeaponId = value, () => equippedWeaponId = previous);
                    },
                  ),
                  const SizedBox(height: 12),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    _stat('قوة الضرر', '×${weapon.damageMultiplier.toStringAsFixed(2)}', Icons.flash_on),
                    _stat('سرعة الإطلاق', '×${weapon.attackSpeedMultiplier.toStringAsFixed(2)}', Icons.speed),
                    _stat('سرعة المقذوف', weapon.projectileSpeed.toStringAsFixed(1), Icons.arrow_forward),
                    _stat('سهام إضافية', '+${weapon.bonusArrows}', Icons.control_point),
                  ]),
                ]),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  const Text('المعدات المجهزة', style: TextStyle(color: Colors.lightBlueAccent, fontSize: 17, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _equipmentPicker(label: 'الدرع · ${armor.name}', items: EquipmentCatalog.armor, selectedId: equippedArmorId, onChanged: (value) {
                    final previous = equippedArmorId;
                    _changeLoadout(() => equippedArmorId = value, () => equippedArmorId = previous);
                  }),
                  _equipmentPicker(label: 'الخوذة · ${helmet.name}', items: EquipmentCatalog.helmets, selectedId: equippedHelmetId, onChanged: (value) {
                    final previous = equippedHelmetId;
                    _changeLoadout(() => equippedHelmetId = value, () => equippedHelmetId = previous);
                  }),
                  _equipmentPicker(label: 'الخاتم · ${ring.name}', items: EquipmentCatalog.rings, selectedId: equippedRingId, onChanged: (value) {
                    final previous = equippedRingId;
                    _changeLoadout(() => equippedRingId = value, () => equippedRingId = previous);
                  }),
                  _equipmentPicker(label: 'الأثر · ${relic.name}', items: EquipmentCatalog.relics, selectedId: equippedRelicId, onChanged: (value) {
                    final previous = equippedRelicId;
                    _changeLoadout(() => equippedRelicId = value, () => equippedRelicId = previous);
                  }),
                  const Text('القطع المقفلة يمكن فتحها من قسم المعدات في القائمة الرئيسية.', style: TextStyle(color: Colors.white60, fontSize: 11)),
                ]),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  const Text('إجمالي تأثير المعدات', style: TextStyle(color: Colors.greenAccent, fontSize: 17, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    _stat('صحة إضافية', '+${stats.maxHpBonus.toStringAsFixed(0)}', Icons.favorite),
                    _stat('هجوم إضافي', '+${(stats.attackBonus * 100).toStringAsFixed(0)}%', Icons.bolt),
                    _stat('تقليل الضرر', '${(stats.damageReduction * 100).toStringAsFixed(0)}%', Icons.shield),
                    _stat('ضربة حرجة', '+${(stats.criticalChanceBonus * 100).toStringAsFixed(0)}%', Icons.stars),
                    _stat('مدى جمع العملات', '+${stats.coinPickupRadiusBonus.toStringAsFixed(0)}', Icons.monetization_on),
                    _stat('مكافأة العملات', '+${(stats.coinRewardBonus * 100).toStringAsFixed(0)}%', Icons.paid),
                  ]),
                ]),
              ),
            ),
            if (_saving) const Padding(padding: EdgeInsets.all(12), child: Center(child: CircularProgressIndicator())),
          ],
        ),
      ),
    );
  }
}
