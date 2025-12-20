import 'package:flutter/material.dart';

class SettingsPresentation extends StatelessWidget {
  const SettingsPresentation({
    super.key,
    required this.showTutorial,
    required this.onToggleTutorial,
    required this.onResetProgress,
  });

  final bool showTutorial;
  final ValueChanged<bool> onToggleTutorial;
  final VoidCallback onResetProgress;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Settings',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              key: const ValueKey('settings_tutorial_toggle'),
              title: const Text('チュートリアルを表示'),
              subtitle: const Text('初回ヒント表示を切り替え'),
              value: showTutorial,
              onChanged: onToggleTutorial,
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              key: const ValueKey('settings_reset'),
              onPressed: onResetProgress,
              child: const Text('進捗をリセット'),
            ),
          ],
        ),
      ),
    );
  }
}
