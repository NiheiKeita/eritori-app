import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TopScreen extends StatelessWidget {
  const TopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TopScreen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Text('Top Screen'),
            TextButton(
              onPressed: () => context.go('/second'),
              child: const Text('Secondへ遷移'),
            ),
            TextButton(
              onPressed: () => context.go('/counter'),
              child: const Text('Counterへ遷移'),
            ),
          ],
        ),
      ),
    );
  }
}
