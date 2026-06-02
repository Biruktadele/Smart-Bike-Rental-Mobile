import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../theme.dart';
import '../../../../widgets/custom_buttons.dart';
import '../../../../widgets/custom_inputs.dart';
import '../payment_providers.dart';

class AddCardScreen extends ConsumerStatefulWidget {
  const AddCardScreen({super.key});

  @override
  ConsumerState<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends ConsumerState<AddCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  
  bool _isLoading = false;
  String _cardBrand = 'Unknown';

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _updateCardBrand(String number) {
    String brand = 'Unknown';
    if (number.startsWith('4')) {
      brand = 'Visa';
    } else if (number.startsWith(RegExp(r'^5[1-5]'))) {
      brand = 'Mastercard';
    } else if (number.startsWith(RegExp(r'^3[47]'))) {
      brand = 'Amex';
    }
    
    if (_cardBrand != brand) {
      setState(() {
        _cardBrand = brand;
      });
    }
  }

  Future<void> _saveCard() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final numberStr = _cardNumberController.text.replaceAll(' ', '');
      final last4 = numberStr.length >= 4 ? numberStr.substring(numberStr.length - 4) : numberStr;
      
      await ref.read(paymentRepositoryProvider).addMethod(
        label: '$_cardBrand **** $last4',
        last4: last4,
        cardNumber: numberStr,
        cardHolderName: _cardHolderController.text.trim(),
        expiryDate: _expiryDateController.text.trim(),
        brand: _cardBrand,
      );
      
      // We need to invalidate the providers to show the new card in the list
      // Since _methodsProvider is private to payment_methods_screen.dart, 
      // we can invalidate it there when popping, or export it. 
      // We will invalidate paymentRepositoryProvider completely or rely on the caller to refresh.
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VelocityColors.background,
      appBar: AppBar(
        backgroundColor: VelocityColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: VelocityColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Add New Card',
          style: VelocityText.headlineSmall(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Visual Card Preview
                Container(
                  height: 200,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [VelocityColors.primary, VelocityColors.primaryDarker],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: VelocityColors.primary.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(Icons.contactless_rounded, color: Colors.white, size: 32),
                          Text(
                            _cardBrand,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        _cardNumberController.text.isEmpty 
                            ? 'XXXX XXXX XXXX XXXX' 
                            : _cardNumberController.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          letterSpacing: 2,
                          fontFamily: 'monospace',
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Card Holder',
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 10),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _cardHolderController.text.isEmpty ? 'NAME SURNAME' : _cardHolderController.text.toUpperCase(),
                                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Expires',
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 10),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _expiryDateController.text.isEmpty ? 'MM/YY' : _expiryDateController.text,
                                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Form Fields
                VelocityInputField(
                  controller: _cardNumberController,
                  label: 'Card Number',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(16),
                    _CardNumberFormatter(),
                  ],
                  onChanged: (val) {
                    _updateCardBrand(val);
                    setState(() {}); // Trigger rebuild to update preview
                  },
                  validator: (val) {
                    if (val == null || val.replaceAll(' ', '').length < 15) {
                      return 'Please enter a valid card number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                VelocityInputField(
                  controller: _cardHolderController,
                  label: 'Cardholder Name',
                  textCapitalization: TextCapitalization.words,
                  onChanged: (_) => setState(() {}),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter cardholder name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: VelocityInputField(
                        controller: _expiryDateController,
                        label: 'Expiry Date',
                        hint: 'MM/YY',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
                          LengthLimitingTextInputFormatter(5),
                          _ExpiryDateFormatter(),
                        ],
                        onChanged: (_) => setState(() {}),
                        validator: (val) {
                          if (val == null || val.length != 5) {
                            return 'Invalid date';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: VelocityInputField(
                        controller: _cvvController,
                        label: 'CVV',
                        keyboardType: TextInputType.number,
                        isPassword: true,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                        validator: (val) {
                          if (val == null || val.length < 3) {
                            return 'Invalid CVV';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                VelocityPrimaryButton(
                  label: 'Save Card',
                  onPressed: _isLoading ? null : _saveCard,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    String buffer = '';
    for (int i = 0; i < newValue.text.length; i++) {
      buffer += newValue.text[i];
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != newValue.text.length) {
        buffer += ' ';
      }
    }

    return TextEditingValue(
      text: buffer,
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text.replaceAll('/', '');
    if (text.length > 4) text = text.substring(0, 4);

    String buffer = '';
    for (int i = 0; i < text.length; i++) {
      buffer += text[i];
      if (i == 1 && text.length > 2) {
        buffer += '/';
      }
    }

    if (text.length == 2 && oldValue.text.length < newValue.text.length && !newValue.text.endsWith('/')) {
      buffer += '/';
    }

    if (oldValue.text.length == 3 && oldValue.text.endsWith('/') && newValue.text.length == 2) {
      buffer = text.substring(0, 1);
    }

    return TextEditingValue(
      text: buffer,
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
