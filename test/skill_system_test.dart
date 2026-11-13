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

    test('does not offer explicitly excluded skills', () {
      final offers = SkillSystem.rollOffers(
        stage: 4,
        random: Random(11),
        count: 8,
        excludedSkills: {SkillId.healing, SkillId.coinMagnet},
      );

      expect(offers.map((skill) => skill.id), isNot(contains(SkillId.healing)));
      expect(offers.map((skill) => skill.id), isNot(contains(SkillId.coinMagnet)));
      expect(offers, hasLength(6));
    });

    test('returns no offers when every skill is excluded', () {
      final offers = SkillSystem.rollOffers(
        stage: 1,
        random: Random(5),
        excludedSkills: SkillId.values.toSet(),
      );

      expect(offers, isEmpty);
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
