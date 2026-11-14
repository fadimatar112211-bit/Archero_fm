import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/hero_catalog.dart';

void main() {
  test('hero catalog has four uniquely identified playable heroes', () {
    expect(heroChoices, hasLength(4));
    expect(heroChoices.map((hero) => hero.id).toSet(), hasLength(4));
    expect(heroChoices.every((hero) => hero.name.isNotEmpty), isTrue);
    expect(heroChoices.every((hero) => hero.description.isNotEmpty), isTrue);
  });
}
