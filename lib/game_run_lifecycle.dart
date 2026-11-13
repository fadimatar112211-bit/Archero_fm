enum GameRunPhase {
  active,
  paused,
  chestReward,
  skillReward,
  dying,
  gameOver,
}

/// Owns the mutually exclusive lifecycle phase of one game run.
class GameRunLifecycle {
  GameRunPhase _phase = GameRunPhase.active;

  GameRunPhase get phase => _phase;
  bool get isPaused =>
      _phase == GameRunPhase.paused || _phase == GameRunPhase.skillReward;
  bool get showMysteryChest => _phase == GameRunPhase.chestReward;
  bool get isGameOver => _phase == GameRunPhase.gameOver;
  bool get isPlayerDying => _phase == GameRunPhase.dying;
  bool get isStageTransitioning =>
      _phase == GameRunPhase.chestReward ||
      _phase == GameRunPhase.skillReward;

  bool pause() {
    if (_phase != GameRunPhase.active) return false;
    _phase = GameRunPhase.paused;
    return true;
  }

  bool resume() {
    if (_phase != GameRunPhase.paused) return false;
    _phase = GameRunPhase.active;
    return true;
  }

  bool togglePause() {
    if (_phase == GameRunPhase.active) return pause();
    if (_phase == GameRunPhase.paused) return resume();
    return false;
  }

  bool beginPlayerDeath() {
    if (_phase != GameRunPhase.active) return false;
    _phase = GameRunPhase.dying;
    return true;
  }

  bool beginStageReward({required bool mysteryChest}) {
    if (_phase != GameRunPhase.active) return false;
    _phase = mysteryChest
        ? GameRunPhase.chestReward
        : GameRunPhase.skillReward;
    return true;
  }

  bool completeSkillSelection() {
    if (_phase != GameRunPhase.skillReward) return false;
    _phase = GameRunPhase.active;
    return true;
  }

  bool collectChest() {
    if (_phase != GameRunPhase.chestReward) return false;
    _phase = GameRunPhase.active;
    return true;
  }

  bool finishRun() {
    if (_phase == GameRunPhase.gameOver) return false;
    _phase = GameRunPhase.gameOver;
    return true;
  }
}
