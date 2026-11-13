import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/game_run_lifecycle.dart';

void main() {
  group('GameRunLifecycle', () {
    test('starts active and toggles pause and resume', () {
      final lifecycle = GameRunLifecycle();
      expect(lifecycle.phase, GameRunPhase.active);
      expect(lifecycle.canPerformActions, isTrue);
      expect(lifecycle.canAdvanceGameClock, isTrue);
      expect(lifecycle.togglePause(), isTrue);
      expect(lifecycle.isPaused, isTrue);
      expect(lifecycle.togglePause(), isTrue);
      expect(lifecycle.phase, GameRunPhase.active);
    });

    test('routes stage completion through chest and skill reward phases', () {
      final lifecycle = GameRunLifecycle();
      expect(lifecycle.beginStageReward(mysteryChest: true), isTrue);
      expect(lifecycle.showMysteryChest, isTrue);
      expect(lifecycle.isStageTransitioning, isTrue);
      expect(lifecycle.collectChest(), isTrue);
      expect(lifecycle.phase, GameRunPhase.active);

      expect(lifecycle.beginStageReward(mysteryChest: false), isTrue);
      expect(lifecycle.isPaused, isTrue);
      expect(lifecycle.isStageTransitioning, isTrue);
      expect(lifecycle.completeSkillSelection(), isTrue);
      expect(lifecycle.phase, GameRunPhase.active);
    });

    test('death and game over block gameplay transitions', () {
      final lifecycle = GameRunLifecycle();
      expect(lifecycle.beginPlayerDeath(), isTrue);
      expect(lifecycle.isPlayerDying, isTrue);
      expect(lifecycle.canPerformActions, isFalse);
      expect(lifecycle.canAdvanceGameClock, isTrue);
      expect(lifecycle.togglePause(), isFalse);
      expect(lifecycle.beginStageReward(mysteryChest: false), isFalse);
      expect(lifecycle.finishRun(), isTrue);
      expect(lifecycle.isGameOver, isTrue);
      expect(lifecycle.canAdvanceGameClock, isFalse);
      expect(lifecycle.finishRun(), isFalse);
    });

    test('does not allow invalid reward completion or pause during rewards', () {
      final lifecycle = GameRunLifecycle();
      expect(lifecycle.collectChest(), isFalse);
      expect(lifecycle.completeSkillSelection(), isFalse);
      expect(lifecycle.beginStageReward(mysteryChest: false), isTrue);
      expect(lifecycle.togglePause(), isFalse);
      expect(lifecycle.collectChest(), isFalse);
      expect(lifecycle.completeSkillSelection(), isTrue);
    });

    test('does not allow repeated transitions out of terminal states', () {
      final lifecycle = GameRunLifecycle();
      lifecycle.finishRun();
      expect(lifecycle.pause(), isFalse);
      expect(lifecycle.resume(), isFalse);
      expect(lifecycle.beginPlayerDeath(), isFalse);
      expect(lifecycle.beginStageReward(mysteryChest: true), isFalse);
    });
    test('only active phase accepts gameplay actions', () {
      final lifecycle = GameRunLifecycle();
      expect(lifecycle.canPerformActions, isTrue);
      lifecycle.pause();
      expect(lifecycle.canPerformActions, isFalse);
      expect(lifecycle.canAdvanceGameClock, isFalse);
      lifecycle.resume();
      lifecycle.beginStageReward(mysteryChest: true);
      expect(lifecycle.canPerformActions, isFalse);
      lifecycle.collectChest();
      lifecycle.beginPlayerDeath();
      expect(lifecycle.canPerformActions, isFalse);
      lifecycle.finishRun();
      expect(lifecycle.canPerformActions, isFalse);
    });

  });
}
