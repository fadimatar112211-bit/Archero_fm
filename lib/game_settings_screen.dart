import 'package:flutter/material.dart';

import 'game_settings.dart';

class GameSettingsScreen extends StatefulWidget {
  const GameSettingsScreen({super.key});

  @override
  State<GameSettingsScreen> createState() => _GameSettingsScreenState();
}

class _GameSettingsScreenState extends State<GameSettingsScreen> {
  bool _audioEnabled = GameSettingsStore.audioEnabled;
  bool _vibrationEnabled = GameSettingsStore.vibrationEnabled;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      await GameSettingsStore.load();
      if (mounted) {
        setState(() {
          _audioEnabled = GameSettingsStore.audioEnabled;
          _vibrationEnabled = GameSettingsStore.vibrationEnabled;
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveSetting(Future<void> Function() save, VoidCallback update) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await save();
      if (mounted) setState(update);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر حفظ الإعداد. حاول مرة أخرى.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: SwitchListTile(
              secondary: Icon(
                _audioEnabled ? Icons.volume_up : Icons.volume_off,
                color: Colors.amber,
              ),
              title: const Text('أصوات اللعبة'),
              subtitle: Text(
                _audioEnabled
                    ? 'الأصوات والمؤثرات مفعّلة.'
                    : 'تم كتم جميع مؤثرات اللعبة.',
              ),
              value: _audioEnabled,
              onChanged: _loading || _saving
                  ? null
                  : (enabled) => _saveSetting(
                        () => GameSettingsStore.setAudioEnabled(enabled),
                        () => _audioEnabled = enabled,
                      ),
            ),
          ),
          Card(
            child: SwitchListTile(
              secondary: Icon(
                _vibrationEnabled ? Icons.vibration : Icons.phone_android,
                color: Colors.lightBlueAccent,
              ),
              title: const Text('الاهتزاز'),
              subtitle: Text(
                _vibrationEnabled
                    ? 'اهتزاز خفيف عند تلقي الضرر واستخدام المهارة.'
                    : 'اهتزازات اللعبة متوقفة.',
              ),
              value: _vibrationEnabled,
              onChanged: _loading || _saving
                  ? null
                  : (enabled) => _saveSetting(
                        () => GameSettingsStore.setVibrationEnabled(enabled),
                        () => _vibrationEnabled = enabled,
                      ),
            ),
          ),
          if (_loading || _saving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
