import 'package:flutter/material.dart';
import 'package:flutter_example_app/screens/counter/container.dart'; // パスは実際のファイルに合わせて
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CounterContainer', () {
    testWidgets('初期表示は0', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: CounterContainer()));

      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('カウントアップボタンで1になる', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: CounterContainer()));

      // 初期は0
      expect(find.text('0'), findsOneWidget);

      // ボタンをタップ
      await tester.tap(find.text('カウントアップ'));
      await tester.pump(); // setState後の再描画を反映

      // 1になっている
      expect(find.text('1'), findsOneWidget);
    });
  });
}
