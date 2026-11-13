import 'package:flutter/material.dart';

import 'skill_system.dart';

Future<SkillId?> showSkillSelectionDialog(
  BuildContext context,
  List<SkillOption> offers,
) {
  return showDialog<SkillId>(
    context: context,
    barrierDismissible: false,
    builder: (_) => SkillSelectionDialog(offers: offers),
  );
}

class SkillSelectionDialog extends StatelessWidget {
  const SkillSelectionDialog({super.key, required this.offers});

  final List<SkillOption> offers;

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text(
          '✨ اختر مهارة للمرحلة القادمة',
          style: TextStyle(color: Colors.amber),
        ),
        content: SizedBox(
          width: 360,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'كل ترقية تمنحك ميزة تستمر خلال هذه الجولة. '
                  'تزداد فرصة ظهور المهارات النادرة مع تقدمك.',
                ),
                const SizedBox(height: 12),
                for (final skill in offers)
                  _SkillOfferCard(
                    skill: skill,
                    onSelected: () =>
                        Navigator.of(context).pop<SkillId>(skill.id),
                  ),
              ],
            ),
          ),
        ),
      );
}

class _SkillOfferCard extends StatelessWidget {
  const _SkillOfferCard({
    required this.skill,
    required this.onSelected,
  });

  final SkillOption skill;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final (rarityLabel, rarityColor, rarityIcon) = switch (skill.rarity) {
      SkillRarity.common => ('عادية', Colors.white70, Icons.circle_outlined),
      SkillRarity.rare => ('نادرة', Colors.lightBlueAccent, Icons.diamond_outlined),
      SkillRarity.epic => ('ملحمية', Colors.purpleAccent, Icons.auto_awesome),
    };

    return Card(
      margin: const EdgeInsets.only(top: 8),
      color: const Color(0xFF171B27),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: rarityColor.withOpacity(0.65)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onSelected,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(rarityIcon, color: rarityColor, size: 18),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      skill.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: rarityColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      child: Text(
                        rarityLabel,
                        style: TextStyle(
                          color: rarityColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              Text(
                skill.description,
                style: const TextStyle(color: Colors.white70, height: 1.25),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'اضغط لاختيار هذه المهارة',
                  style: TextStyle(
                    color: rarityColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
