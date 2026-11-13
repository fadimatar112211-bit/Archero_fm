import 'skill_system.dart';

typedef GameRunEntity = Map<String, dynamic>;

/// Mutable data owned by a single run, independent from Flutter widget state.
class GameRunState {
  GameRunState({int initialStage = 1}) : stage = initialStage < 1 ? 1 : initialStage;

  double arenaWidth = 360;
  double arenaHeight = 640;
  bool arenaInitialized = false;
  double playerX = 180;
  double playerY = 430;
  double playerHp = 100;
  double playerMaxHp = 100;
  double playerSpeed = 3.5;
  DateTime? lastDamageAt;
  double attackPowerMultiplier = 1;
  int extraArrows = 0;
  double criticalChance = 0;
  double attackSpeedMultiplier = 1;
  double enemySpeedMultiplier = 1;
  double coinPickupRadius = 34;
  int animationTicks = 0;
  int heroAttackTicks = 0;
  int playerMoveTicks = 0;
  final List<SkillId> selectedSkills = [];
  final Set<SkillSynergyId> activeSkillSynergies = {};
  final List<GameRunEntity> combatEffects = [];
  final List<GameRunEntity> defeatedSprites = [];

  int score = 0;
  int stage;
  int specialCooldown = 0;
  int playerDeathTicks = 0;
  int roomHazardCooldownTicks = 0;
  bool challengeRoomRewardPending = false;

  final List<GameRunEntity> enemies = [];
  final List<GameRunEntity> arrows = [];
  final List<GameRunEntity> enemyProjectiles = [];
  final List<GameRunEntity> coins = [];
}
