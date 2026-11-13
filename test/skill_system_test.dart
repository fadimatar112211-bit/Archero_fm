import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/skill_system.dart';

void main() {
  group('SkillSystem.rollOffers', () {
    test('returns three distinct options by default', () {
      final offers = SkillSystem.rollOffers(
        stage: 4,
        random: Random(7),
      );

      expect(offers, hasLength(3));
      expect(offers.map((skill) => skill.id).toSet(), hasLength(3));
    });

    test('returns only valid catalog skills and is deterministic for a seed', () {
      final first = SkillSystem.rollOffers(stage: 8, random: Random(21));
      final second = SkillSystem.rollOffers(stage: 8, random: Random(21));

      expect(first.map((skill) => skill.id), second.map((skill) => skill.id));
      expect(first.every((skill) => skill.title.isNotEmpty), isTrue);
      expect(first.every((skill) => skill.description.isNotEmpty), isTrue);
    });

    test('supports a requested offer count within catalog bounds', () {
      expect(
        SkillSystem.rollOffers(
          stage: 1,
          random: Random(3),
          count: 1,
        ),
        hasLength(1),
      );
      expect(
        SkillSystem.rollOffers(
          stage: 1,
          random: Random(3),
          count: 99,
        ),
        hasLength(8),
      );
    });

    test('does not offer healing when health is already full', () {
      final offers = SkillSystem.rollOffers(
        stage: 8,
        random: Random(4),
        count: 8,
        currentHp: 125,
        maxHp: 125,
      );

      expect(offers, hasLength(7));
      expect(offers.any((skill) => skill.id == SkillId.healing), isFalse);
      expect(offers.map((skill) => skill.id).toSet(), hasLength(7));
    });

    test('keeps healing available while the player is injured', () {
      final offers = SkillSystem.rollOffers(
        stage: 8,
        random: Random(4),
        count: 8,
        currentHp: 80,
        maxHp: 125,
      );

      expect(offers, hasLength(8));
      expect(offers.any((skill) => skill.id == SkillId.healing), isTrue);
    });

    test('offers expose common, rare, and epic upgrade tiers', () {
      final all = SkillSystem.rollOffers(
        stage: 20,
        random: Random(2),
        count: 8,
      );

      expect(all.map((skill) => skill.rarity).toSet(), {
        SkillRarity.common,
        SkillRarity.rare,
        SkillRarity.epic,
      });
    });
  });
}
