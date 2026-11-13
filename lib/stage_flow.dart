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
