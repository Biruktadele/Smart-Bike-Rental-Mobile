import 'dart:io' show Platform;
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/auth_service.dart';
import '../../../../theme.dart';
import '../../../../widgets/custom_buttons.dart';
import '../../../../widgets/custom_inputs.dart';
import '../../../../widgets/animated_background.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../auth_providers.dart';
import 'forgot_password_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _emailCtrl.addListener(_handleInputChange);
    _passCtrl.addListener(_handleInputChange);

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animCtrl,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animCtrl,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _animCtrl.forward();
  }

  void _handleInputChange() {
    ref.read(loginControllerProvider).resetError();
  }

  Future<void> _login() async {
    final success = await ref
        .read(loginControllerProvider)
        .login(email: _emailCtrl.text, password: _passCtrl.text);

    if (!mounted) return;

    if (success) {
      await AuthService.saveLoginStatus(_emailCtrl.text);
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
  }

  void _goToSignUp() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const SignupScreen(),
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _emailCtrl.removeListener(_handleInputChange);
    _passCtrl.removeListener(_handleInputChange);
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  bool get _isIOS => Platform.isIOS;

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(loginControllerProvider);

    return Scaffold(
      backgroundColor: VelocityColors.background,
      body: Stack(
        children: [
          const AnimatedMeshBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Welcome Back',
                        style: VelocityText.displayMedium(
                          color: VelocityColors.primaryDarker,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Unlock your ride and find your flow. Please enter your details.',
                        style: VelocityText.bodyLarge(),
                      ),
                      const SizedBox(height: 48),

                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: VelocityColors.primary.withOpacity(0.06),
                              blurRadius: 32,
                              offset: const Offset(0, 16),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                            child: Container(
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(32),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.7),
                                  width: 1.5,
                                ),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withOpacity(0.6),
                                    Colors.white.withOpacity(0.2),
                                  ],
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (_isIOS) ...[
                                    _CupertinoInputField(
                                      label: 'Email',
                                      hint: 'Enter your email',
                                      controller: _emailCtrl,
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                    ),
                                    const SizedBox(height: 24),
                                    _CupertinoInputField(
                                      label: 'Password',
                                      hint: '••••••••',
                                      isPassword: true,
                                      controller: _passCtrl,
                                      textInputAction: TextInputAction.done,
                                    ),
                                  ] else ...[
                                    VelocityInputField(
                                      label: 'Email',
                                      hint: 'Enter your email',
                                      controller: _emailCtrl,
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                    ),
                                    const SizedBox(height: 24),
                                    VelocityInputField(
                                      label: 'Password',
                                      hint: '••••••••',
                                      isPassword: true,
                                      controller: _passCtrl,
                                      textInputAction: TextInputAction.done,
                                    ),
                                  ],
                                  const SizedBox(height: 16),

                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const ForgotPasswordScreen(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        'Forgot Password?',
                                        style: VelocityText.labelMedium(
                                          color: VelocityColors.primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 36),

                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      if (controller.errorMessage != null) ...[
                                        Container(
                                          margin: const EdgeInsets.only(
                                            bottom: 14,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: VelocityColors.errorBg,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: VelocityColors.error
                                                  .withOpacity(0.3),
                                            ),
                                          ),
                                          child: Text(
                                            controller.errorMessage!,
                                            style: VelocityText.bodySmall(
                                              color: VelocityColors.error,
                                            ),
                                          ),
                                        ),
                                      ],
                                      if (_isIOS)
                                        _CupertinoPrimaryButton(
                                          label: controller.isLoading
                                              ? 'Logging in...'
                                              : 'Login',
                                          onPressed: controller.isLoading
                                              ? null
                                              : _login,
                                          isLoading: controller.isLoading,
                                        )
                                      else
                                        VelocityPrimaryButton(
                                          label: controller.isLoading
                                              ? 'Logging in...'
                                              : 'Login',
                                          onPressed: controller.isLoading
                                              ? null
                                              : _login,
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: VelocityText.bodyMedium(),
                          ),
                          GestureDetector(
                            onTap: _goToSignUp,
                            child: Text(
                              'Sign Up →',
                              style: VelocityText.labelMedium(
                                color: VelocityColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
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

class _CupertinoInputField extends StatefulWidget {
  const _CupertinoInputField({
    required this.label,
    required this.hint,
    required this.controller,
    this.isPassword = false,
    this.keyboardType,
    this.textInputAction,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final bool isPassword;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  @override
  State<_CupertinoInputField> createState() => _CupertinoInputFieldState();
}

class _CupertinoInputFieldState extends State<_CupertinoInputField> {
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _obscure = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(widget.label, style: VelocityText.labelMedium()),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.8)),
          ),
          child: CupertinoTextField(
            controller: widget.controller,
            placeholder: widget.hint,
            obscureText: widget.isPassword ? _obscure : false,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            style: VelocityText.bodyLarge(color: VelocityColors.textPrimary),
            placeholderStyle: VelocityText.bodyLarge(
              color: VelocityColors.textMuted,
            ),
            decoration: null,
            suffix: widget.isPassword
                ? CupertinoButton(
                    padding: const EdgeInsets.only(right: 10),
                    onPressed: () => setState(() => _obscure = !_obscure),
                    minimumSize: Size(28, 28),
                    child: Icon(
                      _obscure
                          ? CupertinoIcons.eye_slash_fill
                          : CupertinoIcons.eye_fill,
                      size: 18,
                      color: VelocityColors.secondary,
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}

class _CupertinoPrimaryButton extends StatelessWidget {
  const _CupertinoPrimaryButton({
    required this.label,
    required this.onPressed,
    required this.isLoading,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      color: VelocityColors.primary,
      borderRadius: BorderRadius.circular(999),
      padding: const EdgeInsets.symmetric(vertical: 16),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isLoading) ...[
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 10),
          ],
          Text(label, style: VelocityText.labelLarge(color: Colors.white)),
        ],
      ),
    );
  }
}
