import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/core/themes/zay_theme.dart';
import 'package:zayrova/domain/entities/payment_method_entity.dart';
import 'package:zayrova/presentation/components/top_navigation.dart';
import 'package:zayrova/presentation/providers/feature/payment_method_controller.dart';
import 'package:zayrova/presentation/routes/zay_router.dart';
import 'package:zayrova/presentation/widgets/button.dart';

class AddPaymentMethodScreen extends ConsumerStatefulWidget {
  const AddPaymentMethodScreen({super.key});

  @override
  ConsumerState<AddPaymentMethodScreen> createState() =>
      _AddPaymentMethodScreenState();
}

class _AddPaymentMethodScreenState
    extends ConsumerState<AddPaymentMethodScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardHolderController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryMonthController = TextEditingController();
  final _expiryYearController = TextEditingController();
  final _cvvController = TextEditingController();
  bool _isDefault = false;
  bool _showCvv = false;

  @override
  void dispose() {
    _cardHolderController.dispose();
    _cardNumberController.dispose();
    _expiryMonthController.dispose();
    _expiryYearController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _savePaymentMethod() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final cardNumber = _digitsOnly(_cardNumberController.text);
    final lastFour = cardNumber.substring(cardNumber.length - 4);
    final expiryMonth = int.parse(_expiryMonthController.text.trim());
    final expiryYear = int.parse(_expiryYearController.text.trim());
    final brand = _detectCardBrand(cardNumber);

    final method = PaymentMethod(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      type: PaymentMethodType.card,
      title: _cardHolderController.text.trim(),
      provider: brand,
      cardBrand: brand,
      lastFourDigits: lastFour,
      expiryMonth: expiryMonth,
      expiryYear: expiryYear,
      isDefault: _isDefault,
    );

    // Local/session metadata save. Later this should call secure payment/profile
    // APIs. Full card number and CVV are intentionally not stored.
    ref.read(paymentMethodControllerProvider.notifier).addMethod(method);
    ZayRouter.goBack();
  }

  String _digitsOnly(String value) {
    return value.replaceAll(RegExp(r'\D'), '');
  }

  String _detectCardBrand(String cardNumber) {
    if (cardNumber.startsWith('4')) {
      return 'Visa';
    }
    if (cardNumber.startsWith('5')) {
      return 'Mastercard';
    }
    if (cardNumber.startsWith('34') || cardNumber.startsWith('37')) {
      return 'American Express';
    }

    return 'Card';
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }

    return null;
  }

  String? _validateCardNumber(String? value) {
    final requiredError = _required(value);
    if (requiredError != null) {
      return requiredError;
    }

    final digits = _digitsOnly(value!);
    if (digits.length < 13 || digits.length > 19) {
      return 'Enter a valid card number';
    }

    return null;
  }

  String? _validateExpiryMonth(String? value) {
    final requiredError = _required(value);
    if (requiredError != null) {
      return requiredError;
    }

    final month = int.tryParse(value!.trim());
    if (month == null || month < 1 || month > 12) {
      return 'Invalid month';
    }

    return null;
  }

  String? _validateExpiryYear(String? value) {
    final requiredError = _required(value);
    if (requiredError != null) {
      return requiredError;
    }

    final year = int.tryParse(value!.trim());
    if (year == null || year < 24 || year > 99) {
      return 'Invalid year';
    }

    return null;
  }

  String? _validateCvv(String? value) {
    final requiredError = _required(value);
    if (requiredError != null) {
      return requiredError;
    }

    final digits = _digitsOnly(value!);
    if (digits.length < 3 || digits.length > 4) {
      return 'Invalid CVV';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZayColors.white,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 30, 16, 24),
            children: [
              const TopNavigation(text: 'Add New Card'),
              const SizedBox(height: 24),
              _PaymentTextField(
                label: 'Card Holder Name',
                hint: 'Enter card holder name',
                controller: _cardHolderController,
                icon: Icons.person_outline,
                validator: _required,
                textInputAction: TextInputAction.next,
              ),
              _PaymentTextField(
                label: 'Card Number',
                hint: 'Enter card number',
                controller: _cardNumberController,
                icon: Icons.credit_card_outlined,
                validator: _validateCardNumber,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(19),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _PaymentTextField(
                      label: 'Expiry Month',
                      hint: 'MM',
                      controller: _expiryMonthController,
                      icon: Icons.calendar_today_outlined,
                      validator: _validateExpiryMonth,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PaymentTextField(
                      label: 'Expiry Year',
                      hint: 'YY',
                      controller: _expiryYearController,
                      icon: Icons.event_outlined,
                      validator: _validateExpiryYear,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2),
                      ],
                    ),
                  ),
                ],
              ),
              _PaymentTextField(
                label: 'CVV',
                hint: 'Enter CVV',
                controller: _cvvController,
                icon: Icons.lock_outline,
                validator: _validateCvv,
                keyboardType: TextInputType.number,
                obscureText: !_showCvv,
                trailingIcon:
                    _showCvv ? Icons.visibility_off : Icons.visibility,
                onTrailingTap: () {
                  setState(() => _showCvv = !_showCvv);
                },
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
              ),
              const SizedBox(height: 4),
              _DefaultPaymentToggle(
                value: _isDefault,
                onChanged: (value) {
                  setState(() => _isDefault = value);
                },
              ),
              const SizedBox(height: 24),
              Center(
                child: ZayButton.primary(
                  action: _savePaymentMethod,
                  text: 'Save Card',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentTextField extends StatelessWidget {
  const _PaymentTextField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.inputFormatters,
    this.obscureText = false,
    this.trailingIcon,
    this.onTrailingTap,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData icon;
  final FormFieldValidator<String>? validator;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final IconData? trailingIcon;
  final VoidCallback? onTrailingTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
              color: ZayColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: controller,
            validator: validator,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            inputFormatters: inputFormatters,
            obscureText: obscureText,
            style: ZayTheme.lightTheme.textTheme.displayMedium?.copyWith(
              color: ZayColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: ZayTheme.lightTheme.textTheme.displayMedium?.copyWith(
                color: const Color(0xFFA8B0C6),
                fontWeight: FontWeight.w500,
              ),
              prefixIcon: Icon(icon, color: ZayColors.primary, size: 24),
              suffixIcon:
                  trailingIcon == null
                      ? null
                      : IconButton(
                        onPressed: onTrailingTap,
                        icon: Icon(
                          trailingIcon,
                          color: const Color(0xFFA8B0C6),
                          size: 24,
                        ),
                      ),
              filled: true,
              fillColor: const Color(0xFFFBFBFD),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 18,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFF0F1F6)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: ZayColors.primary,
                  width: 1.2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: ZayColors.secondary),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: ZayColors.secondary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DefaultPaymentToggle extends StatelessWidget {
  const _DefaultPaymentToggle({
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ZayColors.cancel,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.credit_card_outlined, color: ZayColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Default Payment Method',
                  style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
                    color: ZayColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Use this card first during checkout.',
                  style: ZayTheme.lightTheme.textTheme.displayMedium?.copyWith(
                    color: ZayColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: ZayColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
