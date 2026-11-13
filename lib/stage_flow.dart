enum StageRewardType {
  mysteryChest,
  skillChoice,
}

class StageAdvance {
  final int completedStage;
  final int nextStage;
  final StageRewardType reward;

  const StageAdvance({
    required this.completedStage,
    required this.nextStage,
    required this.reward,
  });
}

class StageFlow {
  const StageFlow._();

  /// Advances exactly one stage and alternates between chest and skill rewards.
  static StageAdvance complete(int currentStage) {
    final completedStage = currentStage < 1 ? 1 : currentStage;
    return StageAdvance(
      completedStage: completedStage,
      nextStage: completedStage + 1,
      reward: completedStage.isOdd
          ? StageRewardType.mysteryChest
          : StageRewardType.skillChoice,
    );
  }
}

class StageCompletionResolution {
  const StageCompletionResolution({
    required this.advance,
    required this.updatedPlayerHp,
    required this.updatedBestStage,
    required this.healingApplied,
  });

  final StageAdvance advance;
  final double updatedPlayerHp;
  final int updatedBestStage;
  final double healingApplied;
}

/// Resolves the progression and healing rewards for a completed stage without
/// mutating the live game state. The caller remains responsible for persistence
/// and presenting the reward UI.
StageCompletionResolution resolveStageCompletion({
  required int currentStage,
  required double playerHp,
  required double playerMaxHp,
  required int bestStage,
  double healingReward = 35,
}) {
  final advance = StageFlow.complete(currentStage);
  final safeMaxHp = playerMaxHp.isFinite && playerMaxHp > 0
      ? playerMaxHp
      : 0.0;
  final safeHp = playerHp.isFinite ? playerHp : 0.0;
  final safeHealing = healingReward.isFinite && healingReward > 0
      ? healingReward
      : 0.0;
  final updatedHp = (safeHp + safeHealing).clamp(0.0, safeMaxHp).toDouble();

  return StageCompletionResolution(
    advance: advance,
    updatedPlayerHp: updatedHp,
    updatedBestStage: bestStage < advance.nextStage
        ? advance.nextStage
        : bestStage,
    healingApplied: updatedHp - safeHp.clamp(0.0, safeMaxHp).toDouble(),
  );
}
