import 'package:flutter/material.dart';

class ComingSoonPresentation extends StatelessWidget {
  const ComingSoonPresentation({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFE9F7F2),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F6F75),
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
