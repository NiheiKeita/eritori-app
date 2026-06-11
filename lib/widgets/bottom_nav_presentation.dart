import 'package:flutter/material.dart';

enum BottomNavItem { home, rank, play, shop, settings }

class BottomNavPresentation extends StatelessWidget {
  const BottomNavPresentation({
    super.key,
    required this.current,
    required this.onTap,
  });

  final BottomNavItem current;
  final ValueChanged<BottomNavItem> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Color(0xFF1F6F75),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            label: 'Home',
            icon: Icons.home,
            isSelected: current == BottomNavItem.home,
            onTap: () => onTap(BottomNavItem.home),
          ),
          _NavItem(
            label: 'Rank',
            icon: Icons.emoji_events,
            isSelected: current == BottomNavItem.rank,
            onTap: () => onTap(BottomNavItem.rank),
          ),
          _PlayButton(onTap: () => onTap(BottomNavItem.play)),
          _NavItem(
            label: 'Shop',
            icon: Icons.storefront,
            isSelected: current == BottomNavItem.shop,
            onTap: () => onTap(BottomNavItem.shop),
          ),
          _NavItem(
            label: 'Settings',
            icon: Icons.settings,
            isSelected: current == BottomNavItem.settings,
            onTap: () => onTap(BottomNavItem.settings),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? Colors.white : Colors.white70;
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: const Color(0xFFFDE7A1),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.play_arrow,
          size: 32,
          color: Color(0xFF1F6F75),
        ),
      ),
    );
  }
}
