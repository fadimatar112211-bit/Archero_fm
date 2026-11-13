import 'package:flutter/material.dart';

import 'game_settings.dart';

class GameSettingsScreen extends StatefulWidget {
  const GameSettingsScreen({super.key});

  @override
  State<GameSettingsScreen> createState() => _GameSettingsScreenState();
}

class _GameSettingsScreenState extends State<GameSettingsScreen> {
  bool _audioEnabled = GameSettingsStore.audioEnabled;
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
      if (mounted) setState(() => _audioEnabled = GameSettingsStore.audioEnabled);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _setAudio(bool enabled) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await GameSettingsStore.setAudioEnabled(enabled);
      if (mounted) setState(() => _audioEnabled = enabled);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر حفظ إعداد الصوت.')),
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
              onChanged: _loading || _saving ? null : _setAudio,
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
