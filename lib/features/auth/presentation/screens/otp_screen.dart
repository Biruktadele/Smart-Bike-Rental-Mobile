import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../theme.dart';
import '../../../../widgets/custom_buttons.dart';
import '../../../../widgets/custom_inputs.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../auth_providers.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key, required this.email});

  final String email;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final TextEditingController _codeCtrl = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;

  Future<void> _verify() async {
    if (_codeCtrl.text.trim().length < 4) {
      setState(() => _errorMessage = 'Enter the 4-digit code.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(otpRepositoryProvider).verifyOtp(
            email: widget.email,
            code: _codeCtrl.text.trim(),
          );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resend() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await ref.read(otpRepositoryProvider).resendOtp(email: widget.email);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
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
              Text('Verify Account', style: VelocityText.displayMedium()),
              const SizedBox(height: 12),
              Text(
                'Enter the code sent to ${widget.email}.',
                style: VelocityText.bodyLarge(),
              ),
              const SizedBox(height: 32),
              VelocityInputField(
                label: 'OTP Code',
                hint: '1234',
                controller: _codeCtrl,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 16),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: VelocityText.bodySmall(color: VelocityColors.error),
                ),
              const SizedBox(height: 24),
              VelocityPrimaryButton(
                label: _isLoading ? 'Verifying...' : 'Verify',
                onPressed: _isLoading ? null : _verify,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _isLoading ? null : _resend,
                child: Text(
                  'Resend code',
                  style: VelocityText.labelMedium(
                    color: VelocityColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
