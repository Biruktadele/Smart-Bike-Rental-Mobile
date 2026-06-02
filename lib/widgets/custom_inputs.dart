import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';

/// Custom text input field with label
class VelocityInputField extends StatefulWidget {
  const VelocityInputField({
    super.key,
    required this.label,
    this.hint,
    this.icon,
    this.isPassword = false,
    this.controller,
    this.validator,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.textInputAction,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
  });

  final String label;
  final String? hint;
  final IconData? icon;
  final bool isPassword;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final TextInputType keyboardType;
  final int maxLines;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;

  @override
  State<VelocityInputField> createState() => _VelocityInputFieldState();
}

class _VelocityInputFieldState extends State<VelocityInputField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          widget.label,
          style: VelocityText.labelMedium(
            color: VelocityColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),

        // Input field
        TextFormField(
          controller: widget.controller,
          obscureText: _obscureText,
          keyboardType: widget.keyboardType,
          maxLines: _obscureText ? 1 : widget.maxLines,
          validator: widget.validator,
          onChanged: widget.onChanged,
          textInputAction: widget.textInputAction,
          inputFormatters: widget.inputFormatters,
          textCapitalization: widget.textCapitalization,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: VelocityText.bodyMedium(
              color: VelocityColors.textMuted,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            fillColor: Colors.white.withOpacity(0.6),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.8),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.8),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: VelocityColors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: VelocityColors.error,
                width: 1,
              ),
            ),
            prefixIcon: widget.icon != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 12, right: 8),
                    child: Icon(
                      widget.icon,
                      color: VelocityColors.secondary,
                      size: 20,
                    ),
                  )
                : null,
            prefixIconConstraints: widget.icon != null
                ? const BoxConstraints(
                    minWidth: 0,
                    minHeight: 0,
                  )
                : null,
            suffixIcon: widget.isPassword
                ? GestureDetector(
                    onTap: () {
                      setState(() => _obscureText = !_obscureText);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Icon(
                        _obscureText
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: VelocityColors.secondary,
                        size: 20,
                      ),
                    ),
                  )
                : null,
          ),
          style: VelocityText.bodyMedium(
            color: VelocityColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// OTP input field for verification codes
class VelocityOtpField extends StatelessWidget {
  const VelocityOtpField({
    super.key,
    required this.onChanged,
    this.length = 6,
    this.controller,
  });

  final void Function(String) onChanged;
  final int length;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        length,
        (index) => SizedBox(
          width: 48,
          height: 56,
          child: TextFormField(
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            decoration: InputDecoration(
              counterText: '',
              contentPadding: EdgeInsets.zero,
              fillColor: VelocityColors.inputBg,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: VelocityColors.primary,
                  width: 2,
                ),
              ),
            ),
            style: VelocityText.titleLarge(
              color: VelocityColors.textPrimary,
            ),
            onChanged: (value) {
              if (value.isNotEmpty && index < length - 1) {
                FocusScope.of(context).nextFocus();
              }
              onChanged(value);
            },
          ),
        ),
      ),
    );
  }
}
