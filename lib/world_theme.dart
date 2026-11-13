import 'package:flutter/material.dart';

/// Data-driven visual identity for each ten-stage world.
class WorldTheme {
  const WorldTheme({
    required this.id,
    required this.name,
    required this.topColor,
    required this.midColor,
    required this.bottomColor,
    required this.groundColor,
    required this.tileColor,
    required this.accentColor,
    required this.vegetationColor,
  });

  final int id;
  final String name;
  final Color topColor;
  final Color midColor;
  final Color bottomColor;
  final Color groundColor;
  final Color tileColor;
  final Color accentColor;
  final Color vegetationColor;

  static const forest = WorldTheme(
    id: 1, name: 'الغابة المسحورة',
    topColor: Color(0xFF172B35), midColor: Color(0xFF35513D),
    bottomColor: Color(0xFF182D2B), groundColor: Color(0xFF547A4A),
    tileColor: Color(0xFF89917A), accentColor: Color(0xFFFFB52E),
    vegetationColor: Color(0xFF244D37),
  );
  static const volcano = WorldTheme(
    id: 2, name: 'البركان الملتهب',
    topColor: Color(0xFF351B24), midColor: Color(0xFF713326),
    bottomColor: Color(0xFF241923), groundColor: Color(0xFF663B32),
    tileColor: Color(0xFF98614A), accentColor: Color(0xFFFF6A24),
    vegetationColor: Color(0xFF492A28),
  );
  static const ice = WorldTheme(
    id: 3, name: 'مملكة الجليد',
    topColor: Color(0xFF18354B), midColor: Color(0xFF47758A),
    bottomColor: Color(0xFF172B42), groundColor: Color(0xFF47788B),
    tileColor: Color(0xFFB4D5DF), accentColor: Color(0xFF9CEBFF),
    vegetationColor: Color(0xFF35677A),
  );
  static const desert = WorldTheme(
    id: 4, name: 'الصحراء المنسية',
    topColor: Color(0xFF49301F), midColor: Color(0xFF9A7040),
    bottomColor: Color(0xFF49301F), groundColor: Color(0xFF9A7548),
    tileColor: Color(0xFFC5A16A), accentColor: Color(0xFFFFD36B),
    vegetationColor: Color(0xFF6D713D),
  );
  static const shadows = WorldTheme(
    id: 5, name: 'وادي الظلال',
    topColor: Color(0xFF201832), midColor: Color(0xFF49305D),
    bottomColor: Color(0xFF171526), groundColor: Color(0xFF493B5B),
    tileColor: Color(0xFF80708D), accentColor: Color(0xFFCB8CFF),
    vegetationColor: Color(0xFF302744),
  );
  static const citadel = WorldTheme(
    id: 6, name: 'قلعة العواصف',
    topColor: Color(0xFF172C3D), midColor: Color(0xFF3D6570),
    bottomColor: Color(0xFF172334), groundColor: Color(0xFF45616A),
    tileColor: Color(0xFF8B9FA0), accentColor: Color(0xFF62E8E8),
    vegetationColor: Color(0xFF2B5555),
  );

  static const all = [forest, volcano, ice, desert, shadows, citadel];

  static WorldTheme forStage(int stage) {
    final safeStage = stage < 1 ? 1 : stage;
    return all[((safeStage - 1) ~/ 10).clamp(0, all.length - 1)];
  }
}
