import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../theme.dart';
import '../../../../widgets/custom_buttons.dart';
import '../../../../widgets/custom_inputs.dart';
import '../../../../widgets/animated_background.dart';
import '../auth_providers.dart';
import 'login_screen.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  final TextEditingController _confirmPassCtrl = TextEditingController();
  bool _agreedToTerms = false;
  String? _formError;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _nameCtrl.addListener(_handleInputChange);
    _emailCtrl.addListener(_handleInputChange);
    _phoneCtrl.addListener(_handleInputChange);
    _passCtrl.addListener(_handleInputChange);
    _confirmPassCtrl.addListener(_handleInputChange);

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animCtrl,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animCtrl,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    _animCtrl.forward();
  }

  void _handleInputChange() {
    if (_formError != null) {
      setState(() => _formError = null);
    }
    ref.read(signupControllerProvider).resetError();
  }

  Future<void> _signup() async {
    if (!_agreedToTerms) {
      setState(() => _formError = 'Please accept the terms to continue.');
      return;
    }

    final password = _passCtrl.text.trim();
    if (password != _confirmPassCtrl.text.trim()) {
      setState(() => _formError = 'Passwords do not match.');
      return;
    }

    final success = await ref.read(signupControllerProvider).signup(
          name: _nameCtrl.text,
          email: _emailCtrl.text,
          phone: _phoneCtrl.text,
          password: _passCtrl.text,
        );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Registration successful. Please log in.'),
          backgroundColor: VelocityColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, _, _) => const LoginScreen(),
          transitionsBuilder: (_, anim, _, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const LoginScreen(),
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _nameCtrl.removeListener(_handleInputChange);
    _emailCtrl.removeListener(_handleInputChange);
    _phoneCtrl.removeListener(_handleInputChange);
    _passCtrl.removeListener(_handleInputChange);
    _confirmPassCtrl.removeListener(_handleInputChange);
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(signupControllerProvider);
    final errorMessage = _formError ?? controller.errorMessage;

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
                        'Create Account',
                        style: VelocityText.displayMedium(
                          color: VelocityColors.primaryDarker,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Join the flow and unlock the city.',
                        style: VelocityText.bodyLarge(),
                      ),
                      const SizedBox(height: 40),

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
                                  VelocityInputField(
                                    label: 'Full Name',
                                    hint: 'Jane Doe',
                                    controller: _nameCtrl,
                                    textInputAction: TextInputAction.next,
                                  ),
                                  const SizedBox(height: 20),
                                  VelocityInputField(
                                    label: 'Email',
                                    hint: 'jane@example.com',
                                    controller: _emailCtrl,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                  ),
                                  const SizedBox(height: 20),
                                  VelocityInputField(
                                    label: 'Phone Number',
                                    hint: '+1 (555) 000-0000',
                                    controller: _phoneCtrl,
                                    keyboardType: TextInputType.phone,
                                    textInputAction: TextInputAction.next,
                                  ),
                                  const SizedBox(height: 20),
                                  VelocityInputField(
                                    label: 'Password',
                                    hint: '••••••••',
                                    isPassword: true,
                                    controller: _passCtrl,
                                    textInputAction: TextInputAction.next,
                                  ),
                                  const SizedBox(height: 20),
                                  VelocityInputField(
                                    label: 'Confirm Password',
                                    hint: '••••••••',
                                    isPassword: true,
                                    controller: _confirmPassCtrl,
                                    textInputAction: TextInputAction.done,
                                  ),
                                  const SizedBox(height: 24),

                                  GestureDetector(
                                    onTap: () => setState(() {
                                      _agreedToTerms = !_agreedToTerms;
                                      if (_formError != null) _formError = null;
                                    }),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: _agreedToTerms
                                                ? VelocityColors.primary
                                                : Colors.white.withOpacity(0.5),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: _agreedToTerms
                                                  ? VelocityColors.primary
                                                  : Colors.white.withOpacity(0.8),
                                            ),
                                          ),
                                          child: _agreedToTerms
                                              ? const Icon(Icons.check_rounded,
                                                  size: 16, color: Colors.white)
                                              : null,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            'I agree to the Terms and Conditions',
                                            style: VelocityText.bodySmall(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  if (errorMessage != null) ...[
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 14),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: VelocityColors.errorBg,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: VelocityColors.error.withOpacity(0.3),
                                        ),
                                      ),
                                      child: Text(
                                        errorMessage,
                                        style: VelocityText.bodySmall(
                                          color: VelocityColors.error,
                                        ),
                                      ),
                                    ),
                                  ],

                                  VelocityPrimaryButton(
                                    label: controller.isLoading
                                        ? 'Creating account...'
                                        : 'Sign Up',
                                    onPressed:
                                        controller.isLoading ? null : _signup,
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
                            "Already have an account? ",
                            style: VelocityText.bodyMedium(),
                          ),
                          GestureDetector(
                            onTap: _goToLogin,
                            child: Text(
                              'Log in here',
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
