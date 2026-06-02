import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme.dart';

class AnimatedMeshBackground extends StatefulWidget {
  const AnimatedMeshBackground({super.key});

  @override
  State<AnimatedMeshBackground> createState() => _AnimatedMeshBackgroundState();
}

class _AnimatedMeshBackgroundState extends State<AnimatedMeshBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Container(color: VelocityColors.background),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              children: [
                Positioned(
                  top: -100 + sin(_controller.value * 2 * pi) * 50,
                  left: -100 + cos(_controller.value * 2 * pi) * 50,
                  child: Container(
                    width: size.width * 0.9,
                    height: size.width * 0.9,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: VelocityColors.accent.withOpacity(0.2),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -150 + cos(_controller.value * 2 * pi) * 50,
                  right: -100 + sin(_controller.value * 2 * pi) * 50,
                  child: Container(
                    width: size.width,
                    height: size.width,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: VelocityColors.primary.withOpacity(0.15),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
