import 'package:flutter/material.dart';

import '../../widgets/bottom_nav_presentation.dart';
import 'coming_soon_presentation.dart';

class ComingSoonContainer extends StatelessWidget {
  const ComingSoonContainer({
    super.key,
    required this.title,
    required this.onNavSelected,
  });

  final String title;
  final ValueChanged<BottomNavItem> onNavSelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3E8),
      body: ComingSoonPresentation(
        title: title,
        subtitle: '近日公開！',
      ),
      bottomNavigationBar: BottomNavPresentation(
        current: title == 'Ranking'
            ? BottomNavItem.rank
            : BottomNavItem.shop,
        onTap: onNavSelected,
      ),
    );
  }
}
