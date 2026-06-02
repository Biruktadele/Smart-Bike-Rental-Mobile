import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../theme.dart';
import '../../../../widgets/custom_buttons.dart';
import '../../../../widgets/custom_inputs.dart';
import '../auth_providers.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final TextEditingController _emailCtrl = TextEditingController();
  String? _message;
  bool _isLoading = false;

  Future<void> _submit() async {
    if (_emailCtrl.text.trim().isEmpty) {
      setState(() => _message = 'Please enter your email.');
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      await ref.read(passwordResetRepositoryProvider).requestReset(
            email: _emailCtrl.text.trim(),
          );
      setState(() => _message = 'Check your email for reset instructions.');
    } catch (e) {
      setState(() => _message = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VelocityColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              VelocityIconButton(
                icon: Icons.arrow_back_rounded,
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 32),
              Text('Reset Password', style: VelocityText.displayMedium()),
              const SizedBox(height: 12),
              Text(
                'Enter your email to receive reset instructions.',
                style: VelocityText.bodyLarge(),
              ),
              const SizedBox(height: 32),
              VelocityInputField(
                label: 'Email',
                hint: 'name@example.com',
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 16),
              if (_message != null)
                Text(
                  _message!,
                  style: VelocityText.bodySmall(color: VelocityColors.textSecondary),
                ),
              const SizedBox(height: 24),
              VelocityPrimaryButton(
                label: _isLoading ? 'Sending...' : 'Send Reset Link',
                onPressed: _isLoading ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
