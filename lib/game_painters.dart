import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'world_theme.dart';
import 'room_layout.dart';
import 'game_render_rules.dart';

class EnemyAuraPainter extends CustomPainter {
  final String type;
  final double phase;
  final bool attacking;
  final bool hit;
  const EnemyAuraPainter({required this.type, required this.phase, required this.attacking, required this.hit});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final pulse = .5 + sin(phase * (type == 'runner' ? 2.2 : 1.25)) * .5;
    final color = switch (type) {
      'ranged' => const Color(0xFF55E8FF),
      'runner' => const Color(0xFFFFA33B),
      'tank' => const Color(0xFF75C8D8),
      'stalker' => const Color(0xFFB77AFF),
      _ => const Color(0xFFFF5B62),
    };
    final radius = size.shortestSide * (type == 'tank' ? .39 : .35);
    final glow = Paint()
      ..color = color.withOpacity(hit ? .42 : attacking ? .28 : .13 + pulse * .07)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(c, radius, glow);
    final ring = Paint()
      ..color = color.withOpacity(attacking ? .9 : .32 + pulse * .2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = type == 'tank' ? 2.6 : 1.5;
    canvas.drawCircle(c, radius * (1 + pulse * .055), ring);
    if (type == 'stalker' || type == 'runner' || type == 'ranged') {
      for (var i = 0; i < 3; i++) {
        final a = phase * (type == 'runner' ? 2.8 : type == 'ranged' ? 1.15 : .65) + i * 2 * pi / 3;
        final p = c + Offset(cos(a) * radius * 1.12, sin(a) * radius * .72);
        if (type == 'ranged') {
          final shard = Path()..moveTo(p.dx, p.dy - 3.5)..lineTo(p.dx + 2.5, p.dy)..lineTo(p.dx, p.dy + 3.5)..lineTo(p.dx - 2.5, p.dy)..close();
          canvas.drawPath(shard, Paint()..color = color.withOpacity(.9));
        } else {
          canvas.drawCircle(p, attacking ? 2.7 : 1.7, Paint()..color = color.withOpacity(.85));
        }
      }
    } else if (type == 'tank') {
      for (var i = 0; i < 4; i++) {
        final a = i * pi / 2 + pi / 4;
        final p = c + Offset(cos(a) * radius * 1.04, sin(a) * radius * 1.04);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: p, width: 5, height: 5), const Radius.circular(1)), Paint()..color = color.withOpacity(.8));
      }
    }
  }

  @override
  bool shouldRepaint(covariant EnemyAuraPainter old) =>
      old.type != type || old.phase != phase || old.attacking != attacking || old.hit != hit;
}

class BossAuraPainter extends CustomPainter {
  final double phase;
  final bool attacking;
  const BossAuraPainter({required this.phase, required this.attacking});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final pulse = .5 + sin(phase) * .5;
    final radius = size.shortestSide * (.39 + pulse * .035);
    final glow = Paint()
      ..color = const Color(0xFFFF6B39).withOpacity(attacking ? .3 : .16)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9);
    canvas.drawCircle(center, radius, glow);
    final ring = Paint()
      ..color = const Color(0xFFFFB45B).withOpacity(attacking ? .85 : .42)
      ..style = PaintingStyle.stroke
      ..strokeWidth = attacking ? 2.5 : 1.4;
    canvas.drawCircle(center, radius * (1 + pulse * .08), ring);
    final innerRing = Paint()
      ..color = const Color(0xFFFFD98B).withOpacity(attacking ? .62 : .24)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius * .72, innerRing);
    // Four rotating ember sigils make the boss silhouette readable even in a crowded fight.
    for (var i = 0; i < 4; i++) {
      final angle = phase * (attacking ? 1.8 : .7) + i * pi / 2;
      final direction = Offset(cos(angle), sin(angle));
      final point = center + direction * radius;
      canvas.save();
      canvas.translate(point.dx, point.dy);
      canvas.rotate(angle + pi / 4);
      final sigil = Path()
        ..moveTo(0, -5)..lineTo(3.5, 0)..lineTo(0, 5)..lineTo(-3.5, 0)..close();
      canvas.drawPath(sigil, Paint()..color = const Color(0xFFFFD98B).withOpacity(.95));
      canvas.restore();
      canvas.drawCircle(point, attacking ? 4 : 2.5,
        Paint()..color = const Color(0xFFFF7B43).withOpacity(.7));
    }
    if (attacking) {
      final arc = Paint()
        ..color = const Color(0xFFFF7448).withOpacity(.72)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius * 1.18),
          phase * 1.4, pi * 1.25, false, arc);
    }
  }

  @override
  bool shouldRepaint(covariant BossAuraPainter oldDelegate) =>
      oldDelegate.phase != phase || oldDelegate.attacking != attacking;
}

class RangedProjectilePainter extends CustomPainter {
  const RangedProjectilePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final glow = Paint()
      ..color = const Color(0xFF42DFFF).withOpacity(.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
    canvas.drawCircle(center, 8, glow);
    final outer = Paint()
      ..color = const Color(0xFF8AF3FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawCircle(center, 7, outer);
    final crystal = Path()
      ..moveTo(center.dx, 1)
      ..lineTo(size.width - 3, center.dy)
      ..lineTo(center.dx, size.height - 1)
      ..lineTo(3, center.dy)
      ..close();
    canvas.drawPath(crystal, Paint()..color = const Color(0xFF24C8F2));
    canvas.drawCircle(center, 2.3, Paint()..color = Colors.white);
    final trail = Paint()
      ..color = const Color(0xFF72EFFF).withOpacity(.8)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(1, center.dy), Offset(5, center.dy), trail);
    canvas.drawLine(Offset(center.dx, 1), Offset(center.dx, 4), trail);
  }

  @override
  bool shouldRepaint(covariant RangedProjectilePainter oldDelegate) => false;
}

class ArrowSpritePainter extends CustomPainter {
  const ArrowSpritePainter();
  @override
  void paint(Canvas canvas, Size size) {
    final shaft = Paint()..color = const Color(0xFFFFE5A0)..strokeWidth = 2.4..strokeCap = StrokeCap.round;
    final glow = Paint()..color = const Color(0xFFFFA52F).withOpacity(.45)..strokeWidth = 6..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawLine(const Offset(2, 6), const Offset(21, 6), glow);
    canvas.drawLine(const Offset(2, 6), const Offset(21, 6), shaft);
    final head = Path()..moveTo(24, 6)..lineTo(16, 1)..lineTo(17, 6)..lineTo(16, 11)..close();
    canvas.drawPath(head, Paint()..color = const Color(0xFFFFA52F));
    canvas.drawLine(const Offset(5, 6), const Offset(1, 2), shaft);
    canvas.drawLine(const Offset(5, 6), const Offset(1, 10), shaft);
  }
  @override
  bool shouldRepaint(covariant ArrowSpritePainter oldDelegate) => false;
}

class CombatEffectPainter extends CustomPainter {
  final String type;
  final double progress;
  const CombatEffectPainter({required this.type, required this.progress});
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final boss = type == 'bossBurst' || type == 'bossHit' || type == 'bossTell';
    final impact = type == 'impact' || type.endsWith('Hit') || type == 'enemyAttack';
    final playerHit = type == 'playerHit';
    final telegraph = type == 'bossTell';
    final metal = type == 'metalHit';
    final shadow = type == 'shadowHit';
    final radius = size.width * (.12 + progress * (impact ? .30 : .43));
    final color = switch (type) {
      'bossBurst' || 'bossHit' || 'bossTell' => const Color(0xFFFF642F),
      'playerHit' => const Color(0xFFFF365D),
      'metalHit' => const Color(0xFFB9D5E8),
      'shadowHit' => const Color(0xFFB66BFF),
      'sparkHit' => const Color(0xFFFFC04D),
      'rangedShot' => const Color(0xFF55E8FF),
      'enemyAttack' => const Color(0xFFFF7043),
      'impact' => const Color(0xFFFFE58A),
      _ => const Color(0xFF8DDAFF),
    };
    final glow = Paint()..color = color.withOpacity((1 - progress) * .45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(center, radius, glow);
    final ring = Paint()..color = color.withOpacity(1 - progress)
      ..style = PaintingStyle.stroke..strokeWidth = boss ? 4 : 2.5;
    if (telegraph) {
      final warning = Paint()..color = color.withOpacity((1 - progress) * .85)
        ..style = PaintingStyle.stroke..strokeWidth = 4..strokeCap = StrokeCap.round;
      canvas.drawCircle(center, radius * (0.55 + progress * .45), warning);
      canvas.drawCircle(center, radius * .72, warning..strokeWidth = 2);
    } else if (playerHit) {
      final slash = Paint()..color = color.withOpacity(1 - progress)
        ..strokeWidth = 4..strokeCap = StrokeCap.round;
      canvas.drawLine(center + Offset(-radius, -radius * .55),
        center + Offset(radius, radius * .55), slash);
      canvas.drawLine(center + Offset(radius * .7, -radius * .7),
        center + Offset(-radius * .7, radius * .7), slash);
      final sparks = Paint()..color = const Color(0xFFFFC3D0).withOpacity(1 - progress)
        ..strokeWidth = 2.2..strokeCap = StrokeCap.round;
      for (var i = 0; i < 6; i++) {
        final angle = i * pi / 3 + progress * 1.8;
        final start = center + Offset(cos(angle) * radius * .35, sin(angle) * radius * .35);
        final end = center + Offset(cos(angle) * radius * .72, sin(angle) * radius * .72);
        canvas.drawLine(start, end, sparks);
      }
    } else if (shadow || metal) {
      // ضربات مميزة: شقوق ظل بنفسجية أو شرارات معدنية باردة.
      final slashPaint = Paint()
        ..color = color.withOpacity(1 - progress)
        ..style = PaintingStyle.stroke
        ..strokeWidth = metal ? 3.2 : 5.0
        ..strokeCap = StrokeCap.round;
      for (var i = 0; i < (shadow ? 3 : 5); i++) {
        final offset = (i - (shadow ? 1 : 2)) * (metal ? 7.0 : 9.0);
        final start = center + Offset(-radius * .58 + offset, radius * .42);
        final end = center + Offset(radius * .48 + offset, -radius * .48);
        canvas.drawLine(start, end, slashPaint);
      }
      if (shadow) {
        final crescent = Rect.fromCircle(center: center, radius: radius * .72);
        canvas.drawArc(crescent, -pi * .82 + progress, pi * .92, false,
          Paint()..color = color.withOpacity((1 - progress) * .9)
            ..style = PaintingStyle.stroke..strokeWidth = 3.5);
      } else {
        final glint = Paint()..color = const Color(0xFFEAF8FF).withOpacity(1 - progress)
          ..strokeWidth = 2..strokeCap = StrokeCap.round;
        for (var i = 0; i < 4; i++) {
          final a = i * pi / 2 + progress;
          final p = center + Offset(cos(a) * radius * .7, sin(a) * radius * .7);
          canvas.drawLine(p + Offset(-3, -3), p + Offset(3, 3), glint);
        }
      }
    } else if (type == 'defeat') {
      final burst = Paint()..color = const Color(0xFFFFD36B).withOpacity(1 - progress)
        ..strokeWidth = 2.4..strokeCap = StrokeCap.round;
      for (var i = 0; i < 10; i++) {
        final angle = i * pi / 5 + progress * .8;
        final inner = radius * (.25 + progress * .18);
        final outer = radius * (.55 + progress * .5);
        canvas.drawLine(
          center + Offset(cos(angle) * inner, sin(angle) * inner),
          center + Offset(cos(angle) * outer, sin(angle) * outer), burst);
      }
    } else if (type == 'enemyAttack') {
      final arc = Rect.fromCircle(center: center, radius: radius);
      canvas.drawArc(arc, -pi * .75, pi * .5, false,
        Paint()..color = color.withOpacity(1 - progress)
          ..style = PaintingStyle.stroke..strokeWidth = 5..strokeCap = StrokeCap.round);
    } else {
      canvas.drawCircle(center, radius, ring);
    }
    for (var i = 0; i < 8; i++) {
      final angle = i * pi / 4 + progress * 1.7;
      final inner = radius * .45;
      final outer = radius * (1.0 + (i.isEven ? .22 : -.08));
      canvas.drawLine(
        center + Offset(cos(angle) * inner, sin(angle) * inner),
        center + Offset(cos(angle) * outer, sin(angle) * outer),
        Paint()..color = const Color(0xFFFFE7A1).withOpacity(1 - progress)
          ..strokeWidth = boss ? 3 : 2
          ..strokeCap = StrokeCap.round,
      );
    }
  }
  @override
  bool shouldRepaint(covariant CombatEffectPainter oldDelegate) =>
      oldDelegate.type != type || oldDelegate.progress != progress;
}

// -----------------------------------------------------------------------------
// شخصيات قتالية مرسومة بأسلوب كرتوني أصلي (بدون أشكال دائرية أو أيقونات)
// -----------------------------------------------------------------------------
class FighterSpritePainter extends CustomPainter {
  final String kind;
  final Color tint;
  final int variant;
  final double phase;
  final bool attacking;
  final bool hitFlash;
  const FighterSpritePainter({required this.kind, required this.tint, this.variant = 0, this.phase = 0, this.attacking = false, this.hitFlash = false});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / 64;
    canvas.save();
    canvas.scale(scale);
    canvas.translate(0, sin(phase * 2) * 1.15);
    final boss = kind == 'boss';
    final tank = kind == 'tank';
    final runner = kind == 'runner';
    final stalker = kind == 'stalker';
    final hero = kind == 'hero';
    final dark = Paint()..color = const Color(0xFF171525);
    if (hitFlash) {
      canvas.drawCircle(const Offset(32, 32), 29,
        Paint()..color = Colors.white.withOpacity(.42)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
    }
    final heroArmor = switch (variant) {
      2 => const Color(0xFF71301F),
      3 => const Color(0xFF30234F),
      4 => const Color(0xFF164D55),
      _ => const Color(0xFF243C69),
    };
    final heroMetal = switch (variant) {
      2 => const Color(0xFFFF9A43),
      3 => const Color(0xFFB58CFF),
      4 => const Color(0xFF63F4DF),
      _ => const Color(0xFFFFD36B),
    };
    final armor = Paint()..color = hero ? heroArmor : Color.lerp(tint, Colors.black, 0.28)!;
    final light = Paint()..color = hero ? heroMetal : Color.lerp(tint, Colors.white, 0.38)!;
    final skin = Paint()..color = hero ? const Color(0xFFFFD5B2) : (boss ? const Color(0xFF6D244F) : const Color(0xFF83A84A));
    final cape = Paint()..color = hero ? (variant == 3 ? const Color(0xFF35204F) : variant == 4 ? const Color(0xFF12645E) : variant == 2 ? const Color(0xFF9A351E) : const Color(0xFFE33E35)) : (stalker ? const Color(0xFF39265F) : Color.lerp(tint, Colors.black, 0.48)!);
    final breathe = 1 + sin(phase * 2) * 0.018;

    // ظل أرضي يعطي الشخصية عمقاً.
    canvas.drawOval(const Rect.fromLTWH(10, 54, 44, 8),
        Paint()..color = Colors.black.withOpacity(0.30));
    // هالة وقرون خاصة بالزعيم.
    if (boss) {
      final pulse = .13 + (sin(phase * 2.4) + 1) * .055;
      canvas.drawCircle(const Offset(32, 32), 30 + sin(phase * 2) * 1.8,
        Paint()..color = const Color(0xFFFF542E).withOpacity(pulse)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
      canvas.drawCircle(const Offset(32, 32), 27 + sin(phase * 2) * 1.2,
        Paint()..color = const Color(0xFFFF9B45).withOpacity(.5)
          ..style = PaintingStyle.stroke..strokeWidth = 1.3);
      final horns = Path()
        ..moveTo(22, 13)..lineTo(7, -2)..lineTo(13, 20)..close()
        ..moveTo(42, 13)..lineTo(57, -2)..lineTo(51, 20)..close();
      canvas.drawPath(horns, Paint()..color = const Color(0xFFFF6A35));
      canvas.drawPath(horns, Paint()..color = const Color(0xFFFFD16B)
        ..style = PaintingStyle.stroke..strokeWidth = 1.5);
    }
    // عباءة/أجنحة خلف الجسم.
    final cloak = Path()
      ..moveTo(19, 23)..quadraticBezierTo(2, 35, 12, 57)
      ..lineTo(30, 48)..lineTo(45, 58)
      ..quadraticBezierTo(62, 34, 44, 22)..close();
    canvas.drawPath(cloak, cape);
    if (boss || stalker) {
      final wing = Path()
        ..moveTo(17, 27)..lineTo(1, 12)..lineTo(5, 38)..lineTo(20, 43)..close();
      canvas.drawPath(wing, Paint()..color = Color.lerp(tint, Colors.black, 0.28)!);
      canvas.save();
      canvas.translate(64, 0);
      canvas.scale(-1, 1);
      canvas.drawPath(wing, Paint()..color = Color.lerp(tint, Colors.black, 0.28)!);
      canvas.restore();
    }
    // الساقان والحذاء.
    final leg = Paint()..color = const Color(0xFF30283A);
    final stride = sin(phase) * (boss ? 2.0 : 3.0);
    canvas.save();
    canvas.translate(25, 43);
    canvas.rotate(stride * 0.035);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-5, 0, 10, 13), const Radius.circular(4)), leg);
    canvas.drawOval(const Rect.fromLTWH(-9, 8, 17, 7), dark);
    canvas.restore();
    canvas.save();
    canvas.translate(40, 43);
    canvas.rotate(-stride * 0.035);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-5, 0, 10, 13), const Radius.circular(4)), leg);
    canvas.drawOval(const Rect.fromLTWH(-8, 8, 17, 7), dark);
    canvas.restore();
    // دروع كتف ثقيلة للدبابة.
    if (tank) {
      final plate = Paint()..color = const Color(0xFF8796A3);
      final plateEdge = Paint()..color = const Color(0xFFD4E0E8)
        ..style = PaintingStyle.stroke..strokeWidth = 1.2;
      final leftPlate = RRect.fromRectAndRadius(
        const Rect.fromLTWH(7, 25, 17, 15), const Radius.circular(5));
      final rightPlate = RRect.fromRectAndRadius(
        const Rect.fromLTWH(40, 25, 17, 15), const Radius.circular(5));
      canvas.drawRRect(leftPlate, plate);
      canvas.drawRRect(rightPlate, plate);
      canvas.drawRRect(leftPlate, plateEdge);
      canvas.drawRRect(rightPlate, plateEdge);
      canvas.drawCircle(const Offset(15, 32), 3, light);
      canvas.drawCircle(const Offset(49, 32), 3, light);
      canvas.drawLine(const Offset(13, 28), const Offset(19, 36), plateEdge);
      canvas.drawLine(const Offset(43, 28), const Offset(49, 36), plateEdge);
    }
    // غطاء رأس وظلال مضيئة للمتخفي.
    if (stalker) {
      final hood = Path()
        ..moveTo(17, 20)..quadraticBezierTo(15, -2, 32, 0)
        ..quadraticBezierTo(50, -2, 47, 20)
        ..lineTo(42, 27)..lineTo(22, 27)..close();
      canvas.drawPath(hood, Paint()..color = const Color(0xFF241C3D));
      canvas.drawPath(hood, Paint()..color = const Color(0xFF9B6BCE).withOpacity(.7)
        ..style = PaintingStyle.stroke..strokeWidth = 1.2);
      canvas.drawOval(const Rect.fromLTWH(22, 16, 20, 7),
        Paint()..color = const Color(0xFFFF4CF0));
      canvas.drawCircle(const Offset(32, 20), 5,
        Paint()..color = const Color(0xFFFF4CF0).withOpacity(.16)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
    }
    if (runner) {
      final crest = Path()
        ..moveTo(23, 8)..lineTo(27, -2)..lineTo(31, 8)
        ..lineTo(37, -2)..lineTo(41, 9)..close();
      canvas.drawPath(crest, Paint()..color = const Color(0xFFFFD15C));
      final speedMark = Paint()..color = const Color(0xFFFFD15C).withOpacity(.8)
        ..strokeWidth = 2..strokeCap = StrokeCap.round;
      canvas.drawLine(const Offset(7, 44), const Offset(15, 41), speedMark);
      canvas.drawLine(const Offset(5, 49), const Offset(13, 46), speedMark);
    }
    // الجسم والدرع.
    final body = Path()
      ..moveTo(19, 25)..quadraticBezierTo(32, 18, 45, 25)
      ..lineTo(48, 46)..quadraticBezierTo(32, 53, 16, 46)..close();
    canvas.save();
    canvas.translate(32, 36);
    canvas.scale(1, breathe);
    canvas.translate(-32, -36);
    canvas.drawPath(body, armor);
    // حواف معدنية ولمعات تعطي الدرع طبقات وعمقاً بصرياً.
    final armorEdge = Paint()
      ..color = light.color.withOpacity(.72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.35;
    canvas.drawPath(body, armorEdge);
    final chestPlate = Path()
      ..moveTo(22, 27)..lineTo(32, 30)..lineTo(42, 27)
      ..lineTo(39, 43)..lineTo(32, 47)..lineTo(25, 43)..close();
    canvas.drawPath(chestPlate, Paint()..color = Colors.black.withOpacity(.16));
    canvas.drawPath(chestPlate, Paint()
      ..color = light.color.withOpacity(.55)
      ..style = PaintingStyle.stroke..strokeWidth = 1.1);
    canvas.drawLine(const Offset(23, 29), const Offset(19, 42),
      Paint()..color = Colors.white.withOpacity(.28)..strokeWidth = 2);
    // حزام ومشبك مركزي.
    canvas.drawRRect(RRect.fromRectAndRadius(
      const Rect.fromLTWH(19, 43, 26, 4), const Radius.circular(2)),
      Paint()..color = const Color(0xFF392A32));
    canvas.drawRRect(RRect.fromRectAndRadius(
      const Rect.fromLTWH(29, 42, 7, 6), const Radius.circular(1.5)),
      Paint()..color = const Color(0xFFFFD36B));
    canvas.drawPath(Path()..moveTo(32, 27)..lineTo(42, 31)..lineTo(39, 45)..lineTo(32, 48)..close(), light);
    canvas.drawCircle(const Offset(32, 37), 4, Paint()..color = hero ? const Color(0xFF54DDF5) : Color.lerp(tint, Colors.white, 0.55)!);
    if (hero) {
      canvas.drawCircle(const Offset(32, 37), 7 + sin(phase * 2) * 1.2, Paint()..color = const Color(0xFF54DDF5).withOpacity(.10 + (sin(phase * 2) + 1) * .035)..style = PaintingStyle.stroke..strokeWidth = 1.4);
    }
    // نقاط ضوء صغيرة على الدرع.
    canvas.drawCircle(const Offset(23, 31), 1.5, Paint()..color = Colors.white.withOpacity(.7));
    canvas.drawCircle(const Offset(41, 31), 1.5, Paint()..color = Colors.white.withOpacity(.7));
    canvas.restore();
    // الذراعان.
    canvas.save();
    canvas.translate(16, 31);
    canvas.rotate(attacking ? -0.72 : sin(phase) * 0.12);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-5, -3, 11, 19), const Radius.circular(5)), skin);
    canvas.drawCircle(const Offset(0, 15), 5, light);
    canvas.restore();
    canvas.save();
    canvas.translate(48, 31);
    canvas.rotate(attacking ? 0.95 : -sin(phase) * 0.12);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-5, -3, 11, 19), const Radius.circular(5)), skin);
    canvas.drawCircle(const Offset(0, 15), 5, light);
    canvas.restore();
    // الرأس والملامح.
    canvas.drawOval(const Rect.fromLTWH(19, 3, 26, 28), skin);
    canvas.drawOval(const Rect.fromLTWH(21, 4, 23, 11), hero ? (Paint()..color = const Color(0xFFE9F2FF)) : dark);
    if (!hero) {
      final horn = Path()..moveTo(23, 9)..lineTo(15, 0)..lineTo(19, 15)..close();
      canvas.drawPath(horn, light);
      canvas.save(); canvas.translate(64, 0); canvas.scale(-1, 1);
      canvas.drawPath(horn, light); canvas.restore();
    } else {
      final hair = Path()..moveTo(19, 16)..lineTo(13, 3)..lineTo(28, 8)..lineTo(39, 1)..lineTo(45, 14)..close();
      canvas.drawPath(hair, Paint()..color = const Color(0xFFFFC84A));
      canvas.drawPath(Path()..moveTo(20, 14)..quadraticBezierTo(30, 3, 43, 13), Paint()..color = const Color(0xFFFFE18A)..style = PaintingStyle.stroke..strokeWidth = 2.2..strokeCap = StrokeCap.round);
      final scarf = Path()..moveTo(19, 28)..lineTo(43, 27)..lineTo(57, 43)..lineTo(42, 39)..lineTo(32, 34)..close();
      canvas.drawPath(scarf, Paint()..color = const Color(0xFFE43B35));
      if (variant == 2) {
        final flame = Path()
          ..moveTo(18, 31)..quadraticBezierTo(4, 18, 18, 11)
          ..quadraticBezierTo(16, 25, 27, 27)..close();
        canvas.drawPath(flame, Paint()..color = const Color(0xFFFF762B));
      } else if (variant == 3) {
        canvas.drawPath(Path()..moveTo(18, 8)..lineTo(9, 1)..lineTo(14, 17)..close(),
          Paint()..color = const Color(0xFF9B73FF));
        canvas.drawPath(Path()..moveTo(44, 8)..lineTo(55, 1)..lineTo(49, 17)..close(),
          Paint()..color = const Color(0xFF9B73FF));
      } else if (variant == 4) {
        canvas.drawCircle(const Offset(32, 37), 9,
          Paint()..color = const Color(0xFF45E8D0).withOpacity(.28)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
      }
      // شارة كتف وهوية لونية مستقلة لكل بطل.
      final crestColor = Paint()..color = variant == 2
          ? const Color(0xFFFF8B35)
          : variant == 3 ? const Color(0xFFB58CFF)
          : variant == 4 ? const Color(0xFF62F2DE)
          : const Color(0xFFFFD36B);
      canvas.drawRRect(RRect.fromRectAndRadius(
        const Rect.fromLTWH(16, 34, 7, 11), const Radius.circular(2)), crestColor);
      canvas.drawRRect(RRect.fromRectAndRadius(
        const Rect.fromLTWH(41, 34, 7, 11), const Radius.circular(2)), crestColor);
    }
    final eyeGlow = Paint()
      ..color = (stalker || boss ? const Color(0xFFFF4CF0) : const Color(0xFF8DEBFF)).withOpacity(.32)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(const Offset(26, 19), 4, eyeGlow);
    canvas.drawCircle(const Offset(38, 19), 4, eyeGlow);
    final eye = Paint()..color = const Color(0xFF171525);
    canvas.drawOval(Rect.fromCenter(center: const Offset(26, 19), width: 3.2, height: 2.8), eye);
    canvas.drawOval(Rect.fromCenter(center: const Offset(38, 19), width: 3.2, height: 2.8), eye);
    canvas.drawCircle(const Offset(25.5, 18.5), .7, Paint()..color = Colors.white);
    canvas.drawCircle(const Offset(37.5, 18.5), .7, Paint()..color = Colors.white);
    canvas.drawArc(const Rect.fromLTWH(27, 21, 10, 5), 0, 3.14, false,
        Paint()..color = const Color(0xFF552D35)..strokeWidth = 1.5..style = PaintingStyle.stroke);
    // سلاح صغير واضح للشخصية.
    final weapon = Paint()..color = const Color(0xFFFFD76A)..strokeWidth = 3..strokeCap = StrokeCap.round;
    if (attacking) {
      final slash = Paint()..color = Colors.white.withOpacity(.82)
        ..style = PaintingStyle.stroke..strokeWidth = 3.2..strokeCap = StrokeCap.round;
      canvas.drawArc(const Rect.fromLTWH(35, 3, 34, 34), -1.1, 1.45, false, slash);
    }
    if (hero || runner) {
      canvas.drawLine(const Offset(49, 38), const Offset(57, 13), weapon);
      canvas.drawLine(const Offset(57, 13), const Offset(61, 22), weapon);
      canvas.drawLine(const Offset(57, 13), const Offset(51, 19), weapon);
    } else {
      canvas.drawLine(const Offset(50, 43), const Offset(59, 21), weapon);
      canvas.drawLine(const Offset(59, 21), const Offset(55, 24), weapon);
      canvas.drawLine(const Offset(59, 21), const Offset(62, 27), weapon);
    }
    if (boss || tank) {
      canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(7, 27, 50, 24), const Radius.circular(9)),
          Paint()..color = tint.withOpacity(0.18)..style = PaintingStyle.stroke..strokeWidth = 2);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant FighterSpritePainter oldDelegate) =>
      oldDelegate.kind != kind || oldDelegate.tint != tint || oldDelegate.variant != variant || oldDelegate.phase != phase || oldDelegate.attacking != attacking || oldDelegate.hitFlash != hitFlash;
}

// -----------------------------------------------------------------------------
// رسم أرضية ساحة القتال
// -----------------------------------------------------------------------------

class ArenaPainter extends CustomPainter {
  ArenaPainter({
    this.theme = WorldTheme.forest,
    this.roomLayout,
    this.animation,
  }) : super(repaint: animation);

  final WorldTheme theme;
  final RoomLayout? roomLayout;
  final Animation<double>? animation;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [theme.topColor, theme.midColor, theme.bottomColor],
      ).createShader(rect));

    // Outer mossy stone walls and corner towers.
    final wall = Paint()..color = const Color(0xFF59616A);
    final wallDark = Paint()..color = const Color(0xFF303D43);
    final moss = Paint()..color = theme.groundColor;
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(5, 72, size.width - 10, size.height - 80),
      const Radius.circular(24)), wallDark);
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(12, 80, size.width - 24, size.height - 96),
      const Radius.circular(20)), moss);

    // Irregular stone courtyard tiles.
    final tile = Paint()..color = theme.tileColor;
    final tileEdge = Paint()..color = const Color(0xFF46584D)
      ..style = PaintingStyle.stroke..strokeWidth = 1.4;
    const tileW = 54.0, tileH = 38.0;
    for (var row = 0; row < (size.height / tileH).ceil(); row++) {
      for (var col = 0; col < (size.width / tileW).ceil(); col++) {
        final x = col * tileW + (row.isOdd ? 14 : 0);
        final y = 82 + row * tileH;
        if (x > size.width - 14 || y > size.height - 8) continue;
        final r = Rect.fromLTWH(x + 2, y + 2, tileW - 5, tileH - 5);
        final path = Path()
          ..moveTo(r.left + 5, r.top)
          ..lineTo(r.right - 7, r.top + 1)
          ..lineTo(r.right, r.top + 8)
          ..lineTo(r.right - 3, r.bottom - 5)
          ..lineTo(r.left + 7, r.bottom)
          ..lineTo(r.left, r.bottom - 8)..close();
        canvas.drawPath(path, tile);
        canvas.drawPath(path, tileEdge);
      }
    }

    // Grass patches, tiny flowers and scattered stones.
    final grass = Paint()..color = theme.vegetationColor;
    final flower = Paint()..color = const Color(0xFFFFC5D7);
    final gold = Paint()..color = const Color(0xFFFFD36B);
    for (var i = 0; i < 34; i++) {
      final x = (i * 73.0 + 19) % size.width;
      final y = 100 + (i * 97.0 + 31) % (size.height - 110);
      canvas.drawOval(Rect.fromCenter(center: Offset(x, y), width: 15, height: 7), grass);
      if (i % 3 == 0) {
        canvas.drawCircle(Offset(x + 3, y - 3), 2.5, flower);
        canvas.drawCircle(Offset(x - 2, y - 4), 2, gold);
      }
    }

    // Decorative stone pillars with warm fire bowls.
    for (final x in [size.width * .12, size.width * .88]) {
      final baseY = size.height * .28;
      canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(x, baseY + 25), width: 48, height: 14),
        const Radius.circular(4)), wallDark);
      canvas.drawRect(Rect.fromCenter(center: Offset(x, baseY), width: 34, height: 42), wall);
      canvas.drawRect(Rect.fromCenter(center: Offset(x, baseY - 22), width: 46, height: 9), wall);
      canvas.drawCircle(Offset(x, baseY - 30), 8, Paint()..color = theme.accentColor
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12));
      final flame = Path()
        ..moveTo(x, baseY - 19)..quadraticBezierTo(x - 14, baseY - 42, x, baseY - 53)
        ..quadraticBezierTo(x + 13, baseY - 37, x, baseY - 19)..close();
      canvas.drawPath(flame, Paint()..color = const Color(0xFFFFB52E));
      canvas.drawPath(flame, Paint()..color = const Color(0xFFFFF0A1)
        ..style = PaintingStyle.stroke..strokeWidth = 1.2);
    }

    // شقوق دقيقة في البلاط تمنح الساحة مظهراً أقدم وأكثر واقعية.
    final crack = Paint()
      ..color = const Color(0xFF263A32).withOpacity(.58)
      ..strokeWidth = 1.25
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 18; i++) {
      final x = (i * 89.0 + 31) % size.width;
      final y = 118 + (i * 113.0 + 17) % (size.height - 135);
      canvas.drawLine(Offset(x, y), Offset(x + 5 + (i % 4) * 2, y + 3 + (i % 3) * 2), crack);
      canvas.drawLine(Offset(x + 5 + (i % 4) * 2, y + 3 + (i % 3) * 2),
          Offset(x + 10 + (i % 5) * 2, y + 1 + (i % 4) * 3), crack);
    }
    // جمرات صغيرة متناثرة قرب المشاعل.
    for (var i = 0; i < 16; i++) {
      final x = (i * 97.0 + 43) % size.width;
      final y = 96 + (i * 71.0 + 29) % (size.height - 110);
      canvas.drawCircle(Offset(x, y), i.isEven ? 1.5 : 1.0,
        Paint()..color = const Color(0xFFFFB34A).withOpacity(.22));
    }

    // Ruined blocks, vines and edge shading.
    for (var i = 0; i < 12; i++) {
      final x = (i * 131.0 + 8) % size.width;
      final y = i.isEven ? 91.0 : size.height - 18;
      final stone = Rect.fromLTWH(x, y, 28 + (i % 3) * 8, 15);
      canvas.drawRRect(RRect.fromRectAndRadius(stone, const Radius.circular(3)), wall);
      canvas.drawLine(Offset(stone.left + 3, stone.top + 4),
        Offset(stone.right - 4, stone.top + 4), Paint()..color = Colors.white.withOpacity(.16)..strokeWidth = 2);
    }

    // Forest-only dressing: layered trunks, leafy crowns and roots stay
    // against the outer rails so the central combat lane remains unobstructed.
    if (theme.id == 1 && size.width > 80 && size.height > 150) {
      final bark = Paint()..color = const Color(0xFF382F27);
      final barkLight = Paint()..color = const Color(0xFF70513A)
        ..strokeWidth = 2.2..strokeCap = StrokeCap.round;
      final deepLeaf = Paint()..color = const Color(0xFF183D2C);
      final leaf = Paint()..color = const Color(0xFF286342);
      final leafLight = Paint()..color = const Color(0xFF4D8950);
      final rootPaint = Paint()..color = const Color(0xFF4C6840)
        ..style = PaintingStyle.stroke..strokeWidth = 4..strokeCap = StrokeCap.round;

      for (final side in [0, 1]) {
        final x = side == 0 ? 17.0 : size.width - 17.0;
        final direction = side == 0 ? 1.0 : -1.0;
        // Two staggered trunks create depth without entering the arena lane.
        for (var layer = 0; layer < 2; layer++) {
          final trunkX = x + direction * (layer == 0 ? 0 : 13);
          final top = 88.0 + layer * 24;
          final bottom = size.height - (layer == 0 ? 34 : 72);
          final trunk = Path()
            ..moveTo(trunkX - 5, top)
            ..quadraticBezierTo(trunkX - 2, (top + bottom) / 2, trunkX - 7, bottom)
            ..lineTo(trunkX + 7, bottom)
            ..quadraticBezierTo(trunkX + 2, (top + bottom) / 2, trunkX + 5, top)
            ..close();
          canvas.drawPath(trunk, bark);
          canvas.drawLine(Offset(trunkX - 1, top + 12),
            Offset(trunkX - 3, bottom - 12), barkLight);
          final roots = Path()
            ..moveTo(trunkX, bottom - 5)
            ..quadraticBezierTo(trunkX - direction * 8, bottom + 1,
                trunkX - direction * 13, bottom + 5)
            ..moveTo(trunkX + direction * 2, bottom - 4)
            ..quadraticBezierTo(trunkX + direction * 10, bottom,
                trunkX + direction * 16, bottom + 3);
          canvas.drawPath(roots, rootPaint);
        }

        // Overlapping leaf clusters form a soft canopy at the top corners.
        for (var i = 0; i < 6; i++) {
          final cx = x + direction * (i % 3) * 11;
          final cy = 87.0 + (i ~/ 3) * 13;
          canvas.drawCircle(Offset(cx, cy), 15 - (i % 2) * 2, deepLeaf);
          canvas.drawCircle(Offset(cx + direction * 3, cy - 3),
              9, i.isEven ? leaf : leafLight);
        }

        // Thin hanging vines and small fern fronds along the side rail.
        final vine = Paint()..color = const Color(0xFF75A653)
          ..style = PaintingStyle.stroke..strokeWidth = 2
          ..strokeCap = StrokeCap.round;
        final vinePath = Path()
          ..moveTo(x + direction * 5, 103)
          ..cubicTo(x - direction * 7, 128, x + direction * 12, 143,
              x + direction * 3, 164);
        canvas.drawPath(vinePath, vine);
        for (var i = 0; i < 4; i++) {
          final fy = 119.0 + i * 10;
          canvas.drawLine(Offset(x + direction * 3, fy),
              Offset(x + direction * (12 + (i % 2) * 3), fy - 6), vine);
          canvas.drawLine(Offset(x + direction * 3, fy),
              Offset(x - direction * 5, fy + 5), vine);
        }

        // Tiny mushrooms and luminous spores near the lower corners.
        final cap = Paint()..color = const Color(0xFFC96A55);
        final stem = Paint()..color = const Color(0xFFE5D8B5);
        final mushroomX = x + direction * 8;
        final mushroomY = size.height - 53.0;
        canvas.drawRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(mushroomX - 2, mushroomY, 4, 9),
          const Radius.circular(2)), stem);
        canvas.drawArc(Rect.fromLTWH(mushroomX - 8, mushroomY - 7, 16, 12),
            3.14, 3.14, true, cap);
        canvas.drawCircle(Offset(x + direction * 23, size.height - 88),
            2.2, Paint()..color = const Color(0xFFB6E878).withOpacity(.65));
        canvas.drawCircle(Offset(x + direction * 29, size.height - 103),
            1.4, Paint()..color = const Color(0xFFD9F6A0).withOpacity(.55));
      }
    }

    if (theme.id == 1 && size.width > 80 && size.height > 150) {
      // Moss-covered stones anchor the forest border and break up the flat wall.
      final stoneFill = Paint()..color = const Color(0xFF52634A);
      final stoneShade = Paint()..color = const Color(0xFF344A39);
      final mossStroke = Paint()..color = const Color(0xFF8AA65A)
        ..style = PaintingStyle.stroke..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round;
      for (var i = 0; i < 5; i++) {
        for (final side in [0, 1]) {
          final x = side == 0 ? 29.0 + (i % 2) * 5 : size.width - 29.0 - (i % 2) * 5;
          final y = 190.0 + i * (size.height - 270).clamp(35.0, 90.0).toDouble();
          final stoneRect = Rect.fromCenter(
            center: Offset(x, y), width: 19 + (i % 3) * 4, height: 12 + (i % 2) * 3);
          canvas.drawOval(stoneRect, stoneShade);
          canvas.drawOval(stoneRect.deflate(2), stoneFill);
          canvas.drawArc(stoneRect.deflate(3), 3.4, 1.25, false, mossStroke);
        }
      }

      // Fern fans and tiny blue flowers decorate the lower side borders.
      final fernPaint = Paint()..color = const Color(0xFF6D9D55)
        ..style = PaintingStyle.stroke..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      final flowerBlue = Paint()..color = const Color(0xFF9BD8D0);
      for (final side in [0, 1]) {
        final direction = side == 0 ? 1.0 : -1.0;
        final base = Offset(side == 0 ? 24 : size.width - 24, size.height - 118);
        canvas.drawLine(base, base.translate(direction * 9, -27), fernPaint);
        for (var leafIndex = 0; leafIndex < 4; leafIndex++) {
          final t = leafIndex / 4;
          final point = Offset(base.dx + direction * 9 * t, base.dy - 27 * t);
          canvas.drawLine(point, point.translate(direction * 10, -5), fernPaint);
          canvas.drawLine(point, point.translate(-direction * 7, -7), fernPaint);
        }
        for (var dot = 0; dot < 3; dot++) {
          final flowerCenter = Offset(
            base.dx + direction * (17 + dot * 5),
            base.dy + 9 + dot * 4);
          canvas.drawCircle(flowerCenter, 2.2, flowerBlue);
          canvas.drawCircle(flowerCenter.translate(0, 0), .8,
              Paint()..color = const Color(0xFFFFE7A0));
        }
      }

      // Fireflies are fixed painter details, softly glowing rather than flashing.
      for (var i = 0; i < 11; i++) {
        final side = i.isEven ? 0 : 1;
        final x = side == 0
            ? 42.0 + (i % 3) * 8
            : size.width - 42.0 - (i % 3) * 8;
        final y = 205.0 + (i * 47.0) % (size.height - 245);
        final glow = Paint()..color = const Color(0xFFDAF69A).withOpacity(.16)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
        canvas.drawCircle(Offset(x, y), 4.5, glow);
        canvas.drawCircle(Offset(x, y), 1.4,
            Paint()..color = const Color(0xFFE6FFB0).withOpacity(.8));
      }
    }

    // Distinct environmental landmarks for the five remaining worlds.
    // All decorations are clipped to narrow side rails, keeping combat clear.
    if (size.width > 100 && size.height > 180 && theme.id >= 2 && theme.id <= 6) {
      for (final side in [0, 1]) {
        final left = side == 0;
        final direction = left ? 1.0 : -1.0;
        final railX = left ? 8.0 : size.width - 8.0;
        if (theme.id == 2) {
          // Volcano: basalt shards and glowing lava seams.
          final basalt = Paint()..color = const Color(0xFF34252A);
          final lava = Paint()..color = const Color(0xFFFF6A24)
            ..style = PaintingStyle.stroke..strokeWidth = 2.2
            ..strokeCap = StrokeCap.round;
          for (var i = 0; i < 6; i++) {
            final y = 132.0 + i * (size.height - 190) / 6;
            final shard = Path()
              ..moveTo(railX, y + 15)
              ..lineTo(railX + direction * 13, y - 5)
              ..lineTo(railX + direction * 25, y + 19)
              ..lineTo(railX + direction * 8, y + 29)..close();
            canvas.drawPath(shard, basalt);
            final seam = Path()
              ..moveTo(railX + direction * 31, y + 22)
              ..lineTo(railX + direction * 9, y + 14)
              ..lineTo(railX + direction * 15, y + 19);
            canvas.drawPath(seam, lava);
            canvas.drawCircle(Offset(railX + direction * 17, y + 4), 2.2,
              Paint()..color = const Color(0xFFFFB52E).withOpacity(.8));
          }
        } else if (theme.id == 3) {
          // Ice kingdom: translucent crystal clusters and frost glints.
          final crystal = Paint()..color = const Color(0xFFBCEEFF).withOpacity(.58);
          final edge = Paint()..color = const Color(0xFFE5FAFF).withOpacity(.8)
            ..style = PaintingStyle.stroke..strokeWidth = 1.2;
          for (var i = 0; i < 5; i++) {
            final x = railX + direction * (8 + (i % 2) * 5);
            final y = 145.0 + i * (size.height - 205) / 5;
            final h = 20.0 + (i % 3) * 7;
            final crystalPath = Path()
              ..moveTo(x, y - h)
              ..lineTo(x + direction * 7, y - 3)
              ..lineTo(x + direction * 3, y + 5)
              ..lineTo(x - direction * 4, y - 2)..close();
            canvas.drawPath(crystalPath, crystal);
            canvas.drawPath(crystalPath, edge);
            canvas.drawCircle(Offset(x + direction * 13, y - h - 3), 2,
              Paint()..color = const Color(0xFFE7FFFF).withOpacity(.85));
          }
        } else if (theme.id == 4) {
          // Desert: layered dunes, sandstone blocks and dry grass.
          final dune = Paint()..color = const Color(0xFFD6B477).withOpacity(.48);
          final duneShade = Paint()..color = const Color(0xFF755334).withOpacity(.45);
          for (var i = 0; i < 4; i++) {
            final y = 165.0 + i * (size.height - 220) / 4;
            final dunePath = Path()
              ..moveTo(railX, y + 25)
              ..quadraticBezierTo(railX + direction * 18, y - 12,
                  railX + direction * 35, y + 18)
              ..lineTo(railX + direction * 35, y + 31)
              ..close();
            canvas.drawPath(dunePath, dune);
            canvas.drawLine(Offset(railX, y + 27),
              Offset(railX + direction * 27, y + 24), duneShade..strokeWidth = 2);
            for (var dot = 0; dot < 3; dot++) {
              canvas.drawCircle(Offset(railX + direction * (8 + dot * 7),
                y + 35 + dot * 2), 1.3, duneShade);
            }
          }
        } else if (theme.id == 5) {
          // Shadow valley: dark monoliths and violet arcane wisps.
          final monolith = Paint()..color = const Color(0xFF28213A);
          final rune = Paint()..color = const Color(0xFFD6A0FF).withOpacity(.75)
            ..style = PaintingStyle.stroke..strokeWidth = 1.5;
          for (var i = 0; i < 5; i++) {
            final x = railX + direction * 12;
            final y = 150.0 + i * (size.height - 210) / 5;
            final stone = Path()
              ..moveTo(x - 5, y + 20)..lineTo(x - 3, y - 18)
              ..lineTo(x + 3, y - 25)..lineTo(x + 8, y + 20)..close();
            canvas.drawPath(stone, monolith);
            canvas.drawCircle(Offset(x + direction * 2, y - 2), 5, rune);
            canvas.drawLine(Offset(x - 2, y + 8), Offset(x + 4, y - 8), rune);
            canvas.drawCircle(Offset(railX + direction * 29, y + 28), 2.4,
              Paint()..color = const Color(0xFFC18BFF).withOpacity(.5)
                ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
          }
        } else if (theme.id == 6) {
          // Storm citadel: carved buttresses, cyan runes and lightning forks.
          final stone = Paint()..color = const Color(0xFF344C59);
          final rune = Paint()..color = const Color(0xFF75F4F0).withOpacity(.8)
            ..style = PaintingStyle.stroke..strokeWidth = 1.7;
          for (var i = 0; i < 5; i++) {
            final y = 145.0 + i * (size.height - 205) / 5;
            final buttress = Rect.fromLTWH(
              left ? 5 : size.width - 25, y, 20, 34);
            canvas.drawRRect(RRect.fromRectAndRadius(
              buttress, const Radius.circular(3)), stone);
            final bolt = Path()
              ..moveTo(railX + direction * 10, y + 5)
              ..lineTo(railX + direction * 2, y + 16)
              ..lineTo(railX + direction * 11, y + 16)
              ..lineTo(railX + direction * 4, y + 28);
            canvas.drawPath(bolt, rune);
            canvas.drawLine(Offset(railX, y + 33),
              Offset(railX + direction * 8, y + 38), rune);
          }
        }
      }
    }

    // Signature relics make each biome recognizable at a glance.
    final relicY = size.height * .19;
    if (theme.id == 2) {
      final bowl = Offset(size.width * .5, relicY);
      canvas.drawCircle(bowl, 13, Paint()..color = const Color(0xFFFF6A24).withOpacity(.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12));
      canvas.drawCircle(bowl, 5, Paint()..color = const Color(0xFFFFC15A));
    } else if (theme.id == 3) {
      final center = Offset(size.width * .5, relicY);
      final frost = Paint()..color = const Color(0xFFD9F8FF).withOpacity(.7)
        ..strokeWidth = 2..strokeCap = StrokeCap.round;
      for (var arm = 0; arm < 6; arm++) {
        final angle = arm * 3.141592653589793 / 3;
        final tip = Offset(center.dx + 12 * cos(angle),
            center.dy + 12 * sin(angle));
        canvas.drawLine(center, tip, frost);
      }
    } else if (theme.id == 4) {
      final x = size.width * .09;
      final y = size.height * .76;
      final cactus = Paint()..color = const Color(0xFF58764A)
        ..strokeWidth = 5..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(x, y + 14), Offset(x, y - 12), cactus);
      canvas.drawLine(Offset(x, y - 2), Offset(x - 7, y - 2), cactus);
      canvas.drawLine(Offset(x - 7, y - 2), Offset(x - 7, y - 8), cactus);
      canvas.drawLine(Offset(x, y + 4), Offset(x + 7, y + 4), cactus);
      canvas.drawLine(Offset(x + 7, y + 4), Offset(x + 7, y - 3), cactus);
    } else if (theme.id == 5) {
      final portal = Rect.fromCenter(
          center: Offset(size.width * .5, relicY), width: 38, height: 20);
      canvas.drawOval(portal, Paint()..color = const Color(0xFFB77BFF).withOpacity(.14)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9));
      canvas.drawOval(portal, Paint()..color = const Color(0xFFD7A7FF).withOpacity(.7)
        ..style = PaintingStyle.stroke..strokeWidth = 1.5);
    } else if (theme.id == 6) {
      final x = size.width * .09;
      final y = size.height * .22;
      canvas.drawLine(Offset(x, y - 12), Offset(x, y + 18),
          Paint()..color = const Color(0xFF344C59)..strokeWidth = 2);
      final flag = Path()
        ..moveTo(x, y - 11)..lineTo(x + 19, y - 6)
        ..lineTo(x, y + 1)..close();
      canvas.drawPath(flag, Paint()..color = const Color(0xFF55D6D1));
    }

    // Biome atmosphere: deterministic edge particles add depth without
    // covering the central combat lane or introducing per-frame randomness.
    if (size.width > 100 && size.height > 180) {
      final ambient = Paint()
        ..color = theme.accentColor.withOpacity(.42)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      final crisp = Paint()..color = theme.accentColor.withOpacity(.72);
      for (var i = 0; i < 9; i++) {
        final y = size.height * (.24 + i * .071);
        for (final side in [0, 1]) {
          final direction = side == 0 ? 1.0 : -1.0;
          final edgeX = side == 0 ? 39.0 : size.width - 39.0;
          final phase = animation?.value ?? 0.0;
          final drift = ((i * 13) % 17).toDouble() +
              sin((phase * 2 * 3.141592653589793) + i * .9) * 4;
          final floatY = y + cos((phase * 2 * 3.141592653589793) + i * 1.3) * 7;
          final point = Offset(edgeX + direction * drift, floatY);
          final radius = 1.2 + (i % 3) * .45 +
              (sin(phase * 6.283185307179586 + i) + 1) * .35;
          if (theme.id == 2 || theme.id == 6) {
            // Embers and storm sparks.
            canvas.drawLine(
              point.translate(-direction * 3, 3),
              point.translate(direction * 3, -3),
              Paint()..color = theme.accentColor.withOpacity(.55)
                ..strokeWidth = 1.2..strokeCap = StrokeCap.round,
            );
          } else if (theme.id == 3) {
            // Tiny ice diamonds.
            final diamond = Path()
              ..moveTo(point.dx, point.dy - 3)
              ..lineTo(point.dx + 2, point.dy)
              ..lineTo(point.dx, point.dy + 3)
              ..lineTo(point.dx - 2, point.dy)..close();
            canvas.drawPath(diamond, ambient);
          } else if (theme.id == 4) {
            // Fine drifting sand grains.
            canvas.drawCircle(point, radius * .7, crisp);
          } else if (theme.id == 5) {
            // Arcane motes.
            canvas.drawCircle(point, radius + 1, ambient);
            canvas.drawCircle(point, .8, crisp);
          } else {
            // Forest pollen.
            canvas.drawCircle(point, radius + 1.5, ambient);
            canvas.drawCircle(point, 1, crisp);
          }
        }
      }
    }

    // Stage-specific room geometry and a visible, damaging environmental
    // hazard make each encounter layout mechanically distinct.
    final layout = roomLayout ?? RoomLayout.forStage(1);
    final propShadow = Paint()
      ..color = Colors.black.withOpacity(.32)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    final propBase = Paint()..color = const Color(0xFF29343B);
    final propTop = Paint()..color = theme.tileColor.withOpacity(.88);
    final propEdge = Paint()
      ..color = theme.accentColor.withOpacity(.62)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    for (final prop in layout.props) {
      final center = Offset(prop.centerX * size.width, prop.centerY * size.height);
      final propRect = Rect.fromCenter(
        center: center,
        width: prop.width * size.width,
        height: prop.height * size.height,
      );
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(prop.rotation);
      final local = Rect.fromCenter(
        center: Offset.zero,
        width: propRect.width,
        height: propRect.height,
      );
      final localRounded = RRect.fromRectAndRadius(local, const Radius.circular(9));
      canvas.drawRRect(localRounded.shift(const Offset(0, 5)), propShadow);
      canvas.drawRRect(localRounded, propBase);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          local.deflate(3).shift(const Offset(0, -2)),
          const Radius.circular(7),
        ),
        propTop,
      );
      canvas.drawLine(
        Offset(local.left + 7, local.top + 5),
        Offset(local.right - 7, local.top + 5),
        propEdge,
      );
      canvas.restore();
    }

    final hazard = layout.hazard;
    final hazardCenter = Offset(
      hazard.centerX * size.width,
      hazard.centerY * size.height,
    );
    final hazardRect = Rect.fromCenter(
      center: hazardCenter,
      width: hazard.width * size.width,
      height: hazard.height * size.height,
    );
    final hazardColor = switch (hazard.kind) {
      RoomHazardKind.thorns => const Color(0xFFB6E36B),
      RoomHazardKind.lava => const Color(0xFFFF542E),
      RoomHazardKind.frost => const Color(0xFF9CEBFF),
      RoomHazardKind.sand => const Color(0xFFE7C16C),
      RoomHazardKind.shadow => const Color(0xFFB77AFF),
      RoomHazardKind.storm => const Color(0xFF64E8F0),
    };
    final hazardGlow = Paint()
      ..color = hazardColor.withOpacity(.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    final hazardFill = Paint()..color = hazardColor.withOpacity(.22);
    final hazardStroke = Paint()
      ..color = hazardColor.withOpacity(.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final hazardRRect = RRect.fromRectAndRadius(
      hazardRect,
      const Radius.circular(10),
    );
    canvas.drawRRect(hazardRRect, hazardGlow);
    canvas.drawRRect(hazardRRect, hazardFill);
    canvas.drawRRect(hazardRRect, hazardStroke);
    final stripe = Paint()
      ..color = hazardColor.withOpacity(.8)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 4; i++) {
      final x = hazardRect.left + 8 + i * (hazardRect.width - 16) / 3;
      canvas.drawLine(
        Offset(x, hazardRect.top + 5),
        Offset(x + 7, hazardRect.bottom - 5),
        stripe,
      );
    }

    final vignette = Paint()
      ..shader = RadialGradient(colors: [Colors.transparent, Colors.black.withOpacity(.48)],
        stops: const [0.55, 1]).createShader(rect);
    canvas.drawRect(rect, vignette);
  }

  @override
  bool shouldRepaint(covariant ArenaPainter oldDelegate) =>
      oldDelegate.theme.id != theme.id ||
      oldDelegate.roomLayout?.stage != roomLayout?.stage ||
      oldDelegate.animation != animation;
}

/// Displays one cell from a horizontal vector sprite sheet.
class SpriteSheetFrame extends StatelessWidget {
  const SpriteSheetFrame({
    super.key,
    required this.asset,
    required this.frameCount,
    required this.frameIndex,
  });

  final String asset;
  final int frameCount;
  final int frameIndex;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        if (!width.isFinite || !height.isFinite || width <= 0 || height <= 0) {
          return const SizedBox.expand();
        }
        final safeFrameCount = frameCount > 0 ? frameCount : 1;
        final frame = normalizedSpriteFrameIndex(
          frameIndex: frameIndex,
          frameCount: safeFrameCount,
        );
        return ClipRect(
          child: SizedBox(
            width: width,
            height: height,
            child: OverflowBox(
              alignment: Alignment.centerLeft,
              minWidth: width * safeFrameCount,
              maxWidth: width * safeFrameCount,
              minHeight: height,
              maxHeight: height,
              child: Transform.translate(
                offset: Offset(-width * frame, 0),
                child: SizedBox(
                  width: width * safeFrameCount,
                  height: height,
                  child: SvgPicture.asset(asset, fit: BoxFit.fill),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
