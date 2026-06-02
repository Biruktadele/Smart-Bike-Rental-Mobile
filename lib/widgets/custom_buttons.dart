import 'package:flutter/material.dart';
import '../theme.dart';

/// Primary action button with gradient background and icon
class VelocityPrimaryButton extends StatefulWidget {
  const VelocityPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height = 56,
  });

  final String label;
  final Function? onPressed;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double height;

  @override
  State<VelocityPrimaryButton> createState() => _VelocityPrimaryButtonState();
}

class _VelocityPrimaryButtonState extends State<VelocityPrimaryButton> {
  bool _isLoading = false;

  Future<void> _handlePress() async {
    if (widget.onPressed == null) return;

    setState(() => _isLoading = true);
    try {
      final result = widget.onPressed!();
      if (result is Future) {
        await result;
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.isLoading || _isLoading || widget.onPressed == null;

    return GestureDetector(
      onTap: isDisabled ? null : _handlePress,
      child: Container(
        width: widget.width ?? double.infinity,
        height: widget.height,
        decoration: BoxDecoration(
          gradient: VelocityColors.primaryButtonGradient,
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isDisabled ? null : _handlePress,
            borderRadius: BorderRadius.circular(9999),
            child: Center(
              child: _isLoading || widget.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          VelocityColors.white,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(
                            widget.icon,
                            color: VelocityColors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          widget.label,
                          style: VelocityText.labelLarge(
                            color: VelocityColors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Icon button with circular background
class VelocityIconButton extends StatelessWidget {
  const VelocityIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 48,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? VelocityColors.cardSurface;
    final activeIconColor = iconColor ?? VelocityColors.primary;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: Icon(
              icon,
              color: activeIconColor,
              size: size * 0.4,
            ),
          ),
        ),
      ),
    );
  }
}

/// Secondary button variant
class VelocitySecondaryButton extends StatelessWidget {
  const VelocitySecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: VelocityColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(9999),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    color: VelocityColors.primaryDarker,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: VelocityText.labelLarge(
                    color: VelocityColors.primaryDarker,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
