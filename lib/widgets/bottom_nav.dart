import 'package:flutter/material.dart';
import 'package:smbk/l10n/app_localizations.dart';
import '../theme.dart';

/// Bottom navigation bar for main app navigation
class VelocityBottomNav extends StatelessWidget {
  const VelocityBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.items,
  });

  final int currentIndex;
  final void Function(int) onTap;
  final List<BottomNavItem>? items;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final activeItems = items ?? [
      BottomNavItem(
        icon: Icons.map_rounded,
        label: l10n?.navMap ?? 'Map',
      ),
      BottomNavItem(
        icon: Icons.bookmark_rounded,
        label: l10n?.navBooked ?? 'Booked',
      ),
      BottomNavItem(
        icon: Icons.qr_code_scanner_rounded,
        label: l10n?.navScan ?? 'Scan',
        isActionButton: true,
      ),
      BottomNavItem(
        icon: Icons.history_rounded,
        label: l10n?.navRides ?? 'Rides',
      ),
      BottomNavItem(
        icon: Icons.person_rounded,
        label: l10n?.navProfile ?? 'Profile',
      ),
    ];
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      decoration: BoxDecoration(
        color: VelocityColors.surfaceCard.withOpacity(0.94),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: VelocityColors.primary.withOpacity(0.08),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: VelocityColors.primary.withOpacity(0.12),
            blurRadius: 30,
            spreadRadius: -4,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List.generate(
                activeItems.length,
                (index) {
                  final item = activeItems[index];
                  if (item.isActionButton) {
                    return _ActionButton(
                      item: item,
                      onTap: () => onTap(index),
                    );
                  }
                  return _NavItem(
                    item: item,
                    isActive: currentIndex == index,
                    onTap: () => onTap(index),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BottomNavItem {
  final IconData icon;
  final String label;
  final bool isActionButton;

  const BottomNavItem({
    required this.icon,
    required this.label,
    this.isActionButton = false,
  });
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  final BottomNavItem item;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isActive
                    ? VelocityColors.primary.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                item.icon,
                color: isActive ? VelocityColors.primary : VelocityColors.textMuted,
                size: isActive ? 24 : 22,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: VelocityText.labelSmall(
                color: isActive ? VelocityColors.primary : VelocityColors.textMuted,
              ).copyWith(
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                fontSize: 10,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.item,
    required this.onTap,
  });

  final BottomNavItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          gradient: VelocityColors.primaryButtonGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: VelocityColors.primary.withOpacity(0.3),
              blurRadius: 12,
              spreadRadius: 0,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(color: VelocityColors.surfaceCard, width: 2),
        ),
        child: const Icon(
          Icons.qr_code_scanner_rounded,
          color: Colors.white,
          size: 26,
        ),
      ),
    );
  }
}
