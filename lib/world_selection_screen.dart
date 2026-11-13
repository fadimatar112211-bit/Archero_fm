import 'package:flutter/material.dart';

import 'game_progress.dart';
import 'game_screen.dart';
import 'run_checkpoint.dart';
import 'world_progression.dart';

class WorldSelectionScreen extends StatefulWidget {
  const WorldSelectionScreen({
    super.key,
    required this.heroType,
    required this.heroName,
  });

  final int heroType;
  final String heroName;

  @override
  State<WorldSelectionScreen> createState() => _WorldSelectionScreenState();
}

class _WorldSelectionScreenState extends State<WorldSelectionScreen> {
  late final WorldStageProgression _progression =
      WorldStageProgression(bestStage: bestStage);
  late int _selectedStage = _progression.maxUnlockedStage;
  late int _expandedWorld = ((_selectedStage - 1) ~/ 10) + 1;
  bool _starting = false;

  Future<void> _startSelectedStage() async {
    if (_starting || !_progression.isStageUnlocked(_selectedStage)) return;
    setState(() => _starting = true);
    try {
      await RunCheckpointStore.clear();
      if (!mounted) return;
      try {
        await playRealSound('special');
      } catch (_) {}
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => GameScreen(
            heroType: widget.heroType,
            initialStage: _selectedStage,
          ),
        ),
      );
    } catch (_) {
      if (mounted) {
        setState(() => _starting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر تجهيز الجولة الجديدة. حاول مرة ثانية.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedWorld = ((_selectedStage - 1) ~/ 10) + 1;
    return Scaffold(
      appBar: AppBar(
        title: const Text('اختر العالم والمرحلة'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Card(
                color: const Color(0xFF151D2B),
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  title: Text('البطل: ${widget.heroName}'),
                  subtitle: Text('تقدمك يفتح المراحل حتى ${_progression.maxUnlockedStage}.'),
                  trailing: const Icon(Icons.map_outlined),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                itemCount: WorldStageProgression.totalStages ~/ 10,
                itemBuilder: (context, index) {
                  final worldId = index + 1;
                  final theme = _progression.themeForWorld(worldId);
                  final unlocked = _progression.isWorldUnlocked(worldId);
                  final first = _progression.firstStageOfWorld(worldId);
                  final last = _progression.lastStageOfWorld(worldId);
                  final availableInWorld = List<int>.generate(10, (i) => first + i)
                      .where(_progression.isStageUnlocked)
                      .length;
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: BorderSide(
                        color: unlocked ? theme.accentColor.withOpacity(.75) : Colors.white12,
                      ),
                    ),
                    child: ExpansionTile(
                      key: PageStorageKey<int>(worldId),
                      initiallyExpanded: worldId == _expandedWorld,
                      onExpansionChanged: (expanded) {
                        if (expanded && unlocked) {
                          setState(() => _expandedWorld = worldId);
                        }
                      },
                      collapsedBackgroundColor: const Color(0xFF121A27),
                      backgroundColor: Color.alphaBlend(
                        theme.accentColor.withOpacity(.07),
                        const Color(0xFF121A27),
                      ),
                      leading: CircleAvatar(
                        backgroundColor: unlocked
                            ? theme.accentColor.withOpacity(.18)
                            : Colors.white10,
                        child: Icon(
                          unlocked ? Icons.public : Icons.lock,
                          color: unlocked ? theme.accentColor : Colors.white38,
                        ),
                      ),
                      title: Text(
                        theme.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: unlocked ? Colors.white : Colors.white54,
                        ),
                      ),
                      subtitle: Text(
                        unlocked
                            ? 'العالم $worldId · المراحل المفتوحة $availableInWorld/10'
                            : 'مقفل · افتح المرحلة $first للوصول إليه',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: unlocked
                          ? Icon(Icons.expand_more, color: theme.accentColor)
                          : const Icon(Icons.lock_outline, color: Colors.white30),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                          child: Wrap(
                            spacing: 9,
                            runSpacing: 9,
                            children: [
                              for (final stage in _progression.stagesForWorld(worldId))
                                _StageButton(
                                  stage: stage,
                                  unlocked: _progression.isStageUnlocked(stage),
                                  selected: _selectedStage == stage,
                                  accent: theme.accentColor,
                                  onTap: _progression.isStageUnlocked(stage)
                                      ? () => setState(() => _selectedStage = stage)
                                      : null,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              decoration: const BoxDecoration(
                color: Color(0xFF0D1420),
                border: Border(top: BorderSide(color: Colors.white12)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'الاختيار الحالي: العالم $selectedWorld — المرحلة $_selectedStage',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 9),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _starting ? null : _startSelectedStage,
                      icon: _starting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.play_arrow_rounded),
                      label: Text(_starting ? 'جارٍ التجهيز...' : 'ابدأ المرحلة $_selectedStage'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StageButton extends StatelessWidget {
  const _StageButton({
    required this.stage,
    required this.unlocked,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final int stage;
  final bool unlocked;
  final bool selected;
  final Color accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 58,
      height: 58,
      child: Material(
        color: selected
            ? accent.withOpacity(.24)
            : unlocked
                ? Colors.white.withOpacity(.06)
                : Colors.black26,
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(13),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: selected
                    ? accent
                    : unlocked
                        ? Colors.white24
                        : Colors.white10,
                width: selected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  unlocked ? Icons.flag_rounded : Icons.lock,
                  size: 17,
                  color: selected
                      ? accent
                      : unlocked
                          ? Colors.white70
                          : Colors.white24,
                ),
                const SizedBox(height: 2),
                Text(
                  '$stage',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: unlocked ? Colors.white : Colors.white30,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
