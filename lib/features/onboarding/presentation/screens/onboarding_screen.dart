import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../../core/onboarding/onboarding_service.dart';
import '../../../../theme.dart';
import '../../../../widgets/custom_buttons.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    required this.onSignup,
    required this.onLogin,
  });
  final void Function(BuildContext context) onSignup;
  final void Function(BuildContext context) onLogin;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageCtrl = PageController();
  int _page = 0;
  double _pageOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _pageCtrl.addListener(() {
      setState(() {
        _pageOffset = _pageCtrl.page ?? 0.0;
      });
    });
  }

  static const _pages = [
    _OnboardingData(
      step: 1,
      headline: 'Ride Smart,\nRide Easy 🚲',
      body: 'Find and unlock bicycles\ninstantly near you.',
      illustration: _Illustration.scanner,
    ),
    _OnboardingData(
      step: 2,
      headline: 'Scan. Unlock.\nRide.',
      body: 'Use your phone to unlock bikes safely\nusing QR technology.',
      illustration: _Illustration.scan,
    ),
    _OnboardingData(
      step: 3,
      headline: 'Track Your Ride',
      body: 'Track your rides and find nearby bikes\neasily.',
      illustration: _Illustration.map,
    ),
    _OnboardingData(
      step: 4,
      headline: 'Ready to\nRide?',
      body:
          'Join the community and experience\nthe city like never before. Effortless\nmotion, pure freedom.',
      illustration: _Illustration.hero,
    ),
  ];

  void _next() {
    if (_page < _pages.length - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      // Mark onboarding as completed before navigating to signup
      OnboardingService.completeOnboarding().then((_) {
        if (mounted) {
          widget.onSignup(context);
        }
      });
    }
  }

  void _skip() {
    // Mark onboarding as completed before skipping to signup
    OnboardingService.completeOnboarding().then((_) {
      if (mounted) {
        widget.onSignup(context);
      }
    });
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _pages.length - 1;

    return Scaffold(
      backgroundColor: VelocityColors.background,
      body: Stack(
        children: [
          // ── Kinetic Background Layers
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              height: MediaQuery.of(context).size.width * 0.85,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: VelocityColors.accent.withOpacity(0.18),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: -120,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.75,
              height: MediaQuery.of(context).size.width * 0.75,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: VelocityColors.primary.withOpacity(0.12),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.4,
            right: -50,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.width * 0.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: VelocityColors.surfaceMint.withOpacity(0.4),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: const SizedBox.expand(),
              ),
            ),
          ),

          // Page content
          Positioned.fill(
            bottom: 200, // Leave space for CTA area
            child: SafeArea(
              child: PageView.builder(
                controller: _pageCtrl,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) =>
                    _PageContent(data: _pages[i], offset: _pageOffset - i),
              ),
            ),
          ),

          // Top bar with logo + skip
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button (hidden on first page)
                  if (_page > 0)
                    GestureDetector(
                      onTap: () => _pageCtrl.previousPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOutCubic,
                      ),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: VelocityColors.cardSurface,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_back_rounded,
                          color: VelocityColors.primary,
                          size: 20,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 48),

                  // Skip button
                  GestureDetector(
                    onTap: _skip,
                    child: Text(
                      'Skip',
                      style: VelocityText.bodySmall(
                        color: VelocityColors.secondaryDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom action area (dots + CTA)
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(40),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.55),
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withOpacity(0.8),
                        width: 1.5,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Progress dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_pages.length, (i) {
                          final active = i == _page;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutQuart,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: active ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: active
                                  ? VelocityColors.primary
                                  : VelocityColors.primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(9999),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 32),

                      // CTA buttons
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        layoutBuilder: (currentChild, previousChildren) {
                          return Stack(
                            alignment: Alignment.center,
                            children: <Widget>[
                              ...previousChildren,
                              ?currentChild,
                            ],
                          );
                        },
                        child: isLast
                            ? Column(
                                key: const ValueKey('last_step'),
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  VelocityPrimaryButton(
                                    label: 'Sign Up',
                                    icon: Icons.person_add_rounded,
                                    onPressed: _next,
                                  ),
                                  const SizedBox(height: 12),
                                  GestureDetector(
                                    onTap: () => widget.onLogin(context),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 18,
                                      ),
                                      decoration: BoxDecoration(
                                        color: VelocityColors.primary
                                            .withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(
                                          9999,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Login to Account',
                                        style: VelocityText.labelLarge(
                                          color: VelocityColors.primaryDarker,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : SizedBox(
                                key: const ValueKey('next_step'),
                                width: double.infinity,
                                child: VelocityPrimaryButton(
                                  label: 'Continue',
                                  icon: Icons.arrow_forward_rounded,
                                  onPressed: _next,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Page Content ─────────────────────────────────────────────────────────-
class _PageContent extends StatelessWidget {
  const _PageContent({required this.data, required this.offset});
  final _OnboardingData data;
  final double offset; // Parallax offset relative to this page

  @override
  Widget build(BuildContext context) {
    // Parallax logic
    final double textSlide = offset * 150;
    final double imageScale = 1.0 - (offset.abs() * 0.2).clamp(0.0, 0.4);
    final double imageSlide = offset * 80;
    final double opacity = (1.0 - offset.abs() * 1.5).clamp(0.0, 1.0);

    return Column(
      children: [
        // Illustration takes ~55% of height
        Expanded(
          flex: 55,
          child: Transform.translate(
            offset: Offset(imageSlide, 0),
            child: Transform.scale(
              scale: imageScale,
              child: Opacity(
                opacity: (1.0 - offset.abs() * 0.8).clamp(0.0, 1.0),
                child: _IllustrationWidget(type: data.illustration),
              ),
            ),
          ),
        ),

        // Text section
        Expanded(
          flex: 45,
          child: Opacity(
            opacity: opacity,
            child: Transform.translate(
              offset: Offset(textSlide, 0),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        data.headline,
                        textAlign: TextAlign.center,
                        style: data.illustration == _Illustration.hero
                            ? VelocityText.displayLarge().copyWith(
                                fontSize: 42,
                                textBaseline: TextBaseline.alphabetic,
                                foreground: Paint()
                                  ..shader = VelocityColors
                                      .primaryButtonGradient
                                      .createShader(
                                        const Rect.fromLTWH(
                                          0.0,
                                          0.0,
                                          200.0,
                                          70.0,
                                        ),
                                      ),
                              )
                            : VelocityText.headlineLarge(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Text(
                          data.body,
                          textAlign: TextAlign.center,
                          style: VelocityText.bodyLarge(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Illustration Widget ─────────────────────────────────────────────────--
enum _Illustration { scanner, scan, map, hero }

class _IllustrationWidget extends StatefulWidget {
  const _IllustrationWidget({required this.type});
  final _Illustration type;

  @override
  State<_IllustrationWidget> createState() => _IllustrationWidgetState();
}

class _IllustrationWidgetState extends State<_IllustrationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, box) {
        return switch (widget.type) {
          _Illustration.scanner => _ScannerIllustration(
            ctrl: _ctrl,
            size: box.maxWidth,
          ),
          _Illustration.scan => _ScanStepsIllustration(
            ctrl: _ctrl,
            size: box.maxWidth,
          ),
          _Illustration.map => _MapIllustration(
            ctrl: _ctrl,
            size: box.maxWidth,
          ),
          _Illustration.hero => _HeroIllustration(
            ctrl: _ctrl,
            size: box.maxWidth,
          ),
        };
      },
    );
  }
}

// ─── Scanner illustration  (page 1) ─────────────────────────────────────--
class _ScannerIllustration extends StatelessWidget {
  const _ScannerIllustration({required this.ctrl, required this.size});
  final AnimationController ctrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final s = size * 0.82;
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Blurred circle glow
          AnimatedBuilder(
            animation: ctrl,
            builder: (_, _) => Container(
              width: s * 0.72 + ctrl.value * 20,
              height: s * 0.72 + ctrl.value * 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: VelocityColors.accent.withOpacity(0.12),
              ),
            ),
          ),
          // Card
          Container(
            width: s,
            height: s,
            decoration: BoxDecoration(
              color: VelocityColors.surfacePale,
              borderRadius: BorderRadius.circular(48),
              boxShadow: [
                BoxShadow(
                  color: VelocityColors.primary.withOpacity(0.10),
                  blurRadius: 60,
                  spreadRadius: -16,
                  offset: const Offset(0, 32),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.location_on_rounded,
                color: VelocityColors.primary,
                size: s * 0.3,
              ),
            ),
          ),
          // Decorative bike badge
          Positioned(
            right: size * 0.04,
            bottom: size * 0.04,
            child: Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: VelocityColors.accent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.pedal_bike_rounded,
                color: VelocityColors.primaryDark,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Scan steps illustration  (page 2) ─────────────────────────────────--
class _ScanStepsIllustration extends StatelessWidget {
  const _ScanStepsIllustration({required this.ctrl, required this.size});
  final AnimationController ctrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final steps = [
      (Icons.location_on_rounded, VelocityColors.cardSurface, 'FIND', false),
      (Icons.qr_code_scanner_rounded, VelocityColors.accent, 'SCAN', true),
      (Icons.pedal_bike_rounded, VelocityColors.cardSurface, 'RIDE', false),
    ];
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: steps.map((s) {
          final isHero = s.$4;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: ctrl,
                  builder: (_, _) => Transform.translate(
                    offset: Offset(0, isHero ? -8 * ctrl.value : 0),
                    child: Container(
                      width: isHero ? 96 : 64,
                      height: isHero ? 96 : 64,
                      decoration: BoxDecoration(
                        color: s.$2,
                        shape: BoxShape.circle,
                        boxShadow: isHero
                            ? [
                                BoxShadow(
                                  color: VelocityColors.primary.withOpacity(
                                    0.18,
                                  ),
                                  blurRadius: 32,
                                  offset: const Offset(0, 8),
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        s.$1,
                        color: VelocityColors.primary,
                        size: isHero ? 40 : 28,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  s.$3,
                  style: VelocityText.overline(
                    color: VelocityColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Map illustration  (page 3) ────────────────────────────────────────
class _MapIllustration extends StatelessWidget {
  const _MapIllustration({required this.ctrl, required this.size});
  final AnimationController ctrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final s = size * 0.85;
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: s,
            height: s,
            decoration: BoxDecoration(
              color: VelocityColors.surfacePale,
              borderRadius: BorderRadius.circular(48),
              boxShadow: [
                BoxShadow(
                  color: VelocityColors.primary.withOpacity(0.12),
                  blurRadius: 32,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
          ),
          Positioned(
            left: s * 0.2,
            top: s * 0.3,
            child: _MapPin(color: VelocityColors.primary, label: 'Start'),
          ),
          Positioned(
            right: s * 0.2,
            bottom: s * 0.25,
            child: _MapPin(color: VelocityColors.accent, label: 'End'),
          ),
          AnimatedBuilder(
            animation: ctrl,
            builder: (_, _) => CustomPaint(
              size: Size(s, s),
              painter: _PathPainter(progress: ctrl.value),
            ),
          ),
        ],
      ),
    );
  }
}

class _PathPainter extends CustomPainter {
  const _PathPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.25, size.height * 0.35)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.2,
        size.width * 0.75,
        size.height * 0.6,
      );
    final metrics = path.computeMetrics().first;
    final animPath = metrics.extractPath(0, metrics.length * progress);

    canvas.drawPath(
      animPath,
      Paint()
        ..color = VelocityColors.primary
        ..strokeWidth = 6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _PathPainter old) => old.progress != progress;
}

class _MapPin extends StatelessWidget {
  const _MapPin({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(height: 6),
        Text(label, style: VelocityText.overline(color: color)),
      ],
    );
  }
}

// ─── Hero illustration  (page 4) ───────────────────────────────────────
class _HeroIllustration extends StatelessWidget {
  const _HeroIllustration({required this.ctrl, required this.size});
  final AnimationController ctrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final s = size * 0.85;
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: s,
            height: s,
            decoration: BoxDecoration(
              color: VelocityColors.surfacePale,
              borderRadius: BorderRadius.circular(60),
              boxShadow: [
                BoxShadow(
                  color: VelocityColors.primary.withOpacity(0.14),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
          ),
          Transform.translate(
            offset: Offset(0, -10 + 10 * math.sin(ctrl.value * math.pi * 2)),
            child: Icon(
              Icons.pedal_bike_rounded,
              size: 120,
              color: VelocityColors.primary,
            ),
          ),
          Positioned(
            bottom: s * 0.22,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: VelocityColors.accent,
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Text(
                'READY?',
                style: VelocityText.overline(
                  color: VelocityColors.primaryDark,
                ).copyWith(letterSpacing: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Data ─────────────────────────────────────────────────────────────────
class _OnboardingData {
  const _OnboardingData({
    required this.step,
    required this.headline,
    required this.body,
    required this.illustration,
  });

  final int step;
  final String headline;
  final String body;
  final _Illustration illustration;
}
