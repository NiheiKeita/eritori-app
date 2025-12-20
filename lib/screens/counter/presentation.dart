import 'package:flutter/material.dart';

class CounterPresentation extends StatelessWidget {
  const CounterPresentation({
    super.key,
    required this.count,
    required this.onIncrement,
  });

  final int count;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CounterScreen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text('$count'),
            TextButton(onPressed: onIncrement, child: const Text('カウントアップ')),
          ],
        ),
      ),
    );
  }
}
