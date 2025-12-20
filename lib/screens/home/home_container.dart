import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/bottom_nav_presentation.dart';
import 'home_presentation.dart';

class HomeContainer extends StatelessWidget {
  const HomeContainer({
    super.key,
    required this.onNavSelected,
  });

  final ValueChanged<BottomNavItem> onNavSelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3E8),
      body: HomePresentation(
        onPlay: () => context.go('/level-select'),
      ),
      bottomNavigationBar: BottomNavPresentation(
        current: BottomNavItem.home,
        onTap: onNavSelected,
      ),
    );
  }
}
