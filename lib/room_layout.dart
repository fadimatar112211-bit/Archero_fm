/// Deterministic room geometry and environmental hazards for each stage.
///
/// Coordinates are normalized so layouts remain consistent across phone,
/// tablet, portrait, and landscape arenas.
enum RoomHazardKind { thorns, lava, frost, sand, shadow, storm }

class RoomProp {
  const RoomProp({
    required this.centerX,
    required this.centerY,
    required this.width,
    required this.height,
    required this.rotation,
  });

  final double centerX;
  final double centerY;
  final double width;
  final double height;
  final double rotation;
}

class RoomHazard {
  const RoomHazard({
    required this.centerX,
    required this.centerY,
    required this.width,
    required this.height,
    required this.kind,
  });

  final double centerX;
  final double centerY;
  final double width;
  final double height;
  final RoomHazardKind kind;

  bool contains({
    required double x,
    required double y,
    required double arenaWidth,
    required double arenaHeight,
    double playerRadius = 15,
  }) {
    if (!x.isFinite ||
        !y.isFinite ||
        !arenaWidth.isFinite ||
        !arenaHeight.isFinite ||
        arenaWidth <= 0 ||
        arenaHeight <= 0) {
      return false;
    }
    final halfWidth = (width * arenaWidth / 2) + playerRadius;
    final halfHeight = (height * arenaHeight / 2) + playerRadius;
    final centerPx = centerX * arenaWidth;
    final centerPy = centerY * arenaHeight;
    return (x - centerPx).abs() <= halfWidth &&
        (y - centerPy).abs() <= halfHeight;
  }
}

class RoomLayout {
  const RoomLayout({
    required this.stage,
    required this.worldId,
    required this.variant,
    required this.name,
    required this.props,
    required this.hazard,
  });

  final int stage;
  final int worldId;
  final int variant;
  final String name;
  final List<RoomProp> props;
  final RoomHazard hazard;

  static RoomLayout forStage(int stage) {
    final safeStage = stage < 1 ? 1 : stage;
    final worldId = (((safeStage - 1) ~/ 10).clamp(0, 5) + 1).toInt();
    final variant = (safeStage - 1) % 4;
    final props = switch (variant) {
      0 => const [
          RoomProp(centerX: .27, centerY: .39, width: .12, height: .075, rotation: -.12),
          RoomProp(centerX: .73, centerY: .39, width: .12, height: .075, rotation: .12),
        ],
      1 => const [
          RoomProp(centerX: .34, centerY: .31, width: .10, height: .07, rotation: .18),
          RoomProp(centerX: .66, centerY: .49, width: .12, height: .075, rotation: -.18),
          RoomProp(centerX: .34, centerY: .61, width: .09, height: .06, rotation: -.08),
        ],
      2 => const [
          RoomProp(centerX: .50, centerY: .34, width: .16, height: .065, rotation: .10),
          RoomProp(centerX: .25, centerY: .53, width: .11, height: .07, rotation: -.22),
          RoomProp(centerX: .75, centerY: .53, width: .11, height: .07, rotation: .22),
        ],
      _ => const [
          RoomProp(centerX: .28, centerY: .30, width: .10, height: .07, rotation: -.16),
          RoomProp(centerX: .72, centerY: .30, width: .10, height: .07, rotation: .16),
          RoomProp(centerX: .28, centerY: .56, width: .12, height: .075, rotation: .16),
          RoomProp(centerX: .72, centerY: .56, width: .12, height: .075, rotation: -.16),
        ],
    };
    final hazardKind = switch (worldId) {
      1 => RoomHazardKind.thorns,
      2 => RoomHazardKind.lava,
      3 => RoomHazardKind.frost,
      4 => RoomHazardKind.sand,
      5 => RoomHazardKind.shadow,
      _ => RoomHazardKind.storm,
    };
    final hazardPosition = switch (variant) {
      0 => (.50, .56),
      1 => (.50, .43),
      2 => (.50, .66),
      _ => (.50, .43),
    };
    return RoomLayout(
      stage: safeStage,
      worldId: worldId,
      variant: variant,
      name: switch (variant) {
        0 => 'ساحة الأعمدة',
        1 => 'ممر الأطلال',
        2 => 'ساحة الشقوق',
        _ => 'باحة الحراس',
      },
      props: props,
      hazard: RoomHazard(
        centerX: hazardPosition.$1,
        centerY: hazardPosition.$2,
        width: .17,
        height: .085,
        kind: hazardKind,
      ),
    );
  }

  bool playerTouchesHazard({
    required double x,
    required double y,
    required double arenaWidth,
    required double arenaHeight,
  }) =>
      hazard.contains(
        x: x,
        y: y,
        arenaWidth: arenaWidth,
        arenaHeight: arenaHeight,
      );
}
