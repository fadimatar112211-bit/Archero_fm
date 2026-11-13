import 'package:flutter/material.dart';

import 'special_room_system.dart';

class SpecialRoomChoiceDialog extends StatelessWidget {
  const SpecialRoomChoiceDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('اختر وجهتك التالية'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('انتصرت على الزعيم! اختر غرفة خاصة قبل متابعة المغامرة.'),
          const SizedBox(height: 12),
          ...specialRoomOptions.map((option) => Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(option.type),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(option.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(option.description, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }
}

class MerchantRoomDialog extends StatelessWidget {
  const MerchantRoomDialog({super.key, required this.coins});

  final int coins;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('متجر التاجر'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('رصيدك: $coins عملة'),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(MerchantPurchase.attackBoost),
              child: const Text('تعزيز الهجوم +15% · 80 عملة'),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(MerchantPurchase.healingPotion),
              child: const Text('جرعة علاج +30% صحة · 50 عملة'),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('المغادرة دون شراء'),
          ),
        ],
      ),
    );
  }
}
