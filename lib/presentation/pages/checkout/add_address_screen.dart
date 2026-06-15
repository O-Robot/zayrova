import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/core/themes/zay_theme.dart';
import 'package:zayrova/domain/entities/address_entity.dart';
import 'package:zayrova/presentation/components/top_navigation.dart';
import 'package:zayrova/presentation/providers/feature/address_controller.dart';
import 'package:zayrova/presentation/routes/zay_router.dart';
import 'package:zayrova/presentation/widgets/button.dart';

class AddAddressScreen extends ConsumerStatefulWidget {
  const AddAddressScreen({super.key});

  @override
  ConsumerState<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends ConsumerState<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _postalCodeController = TextEditingController();
  bool _isDefault = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  void _saveAddress() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final address = Address(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      label: 'Delivery Address',
      recipientName: _fullNameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      addressLine1: _addressLine1Controller.text.trim(),
      addressLine2: _emptyToNull(_addressLine2Controller.text),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      country: _countryController.text.trim(),
      postalCode: _emptyToNull(_postalCodeController.text),
      isDefault: _isDefault,
    );

    // Temporary in-memory save. Later this should call profile/address APIs.
    ref.read(addressControllerProvider.notifier).addAddress(address);
    ZayRouter.goBack();
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
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
              const TopNavigation(text: 'Add Address'),
              const SizedBox(height: 24),
              _AddressTextField(
                label: 'Full Name',
                controller: _fullNameController,
                validator: _required,
                textInputAction: TextInputAction.next,
              ),
              _AddressTextField(
                label: 'Phone Number',
                controller: _phoneController,
                validator: _required,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
              ),
              _AddressTextField(
                label: 'Address Line 1',
                controller: _addressLine1Controller,
                validator: _required,
                textInputAction: TextInputAction.next,
              ),
              _AddressTextField(
                label: 'Address Line 2',
                controller: _addressLine2Controller,
                textInputAction: TextInputAction.next,
              ),
              _AddressTextField(
                label: 'City',
                controller: _cityController,
                validator: _required,
                textInputAction: TextInputAction.next,
              ),
              _AddressTextField(
                label: 'State',
                controller: _stateController,
                validator: _required,
                textInputAction: TextInputAction.next,
              ),
              _AddressTextField(
                label: 'Country',
                controller: _countryController,
                validator: _required,
                textInputAction: TextInputAction.next,
              ),
              _AddressTextField(
                label: 'Postal Code',
                controller: _postalCodeController,
                keyboardType: TextInputType.streetAddress,
              ),
              const SizedBox(height: 4),
              _DefaultAddressToggle(
                value: _isDefault,
                onChanged: (value) {
                  setState(() => _isDefault = value);
                },
              ),
              const SizedBox(height: 24),
              Center(
                child: ZayButton.primary(
                  action: _saveAddress,
                  text: 'Save Address',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddressTextField extends StatelessWidget {
  const _AddressTextField({
    required this.label,
    required this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
  });

  final String label;
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: ZayTheme.lightTheme.textTheme.displayMedium),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            validator: validator,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
              color: ZayColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: label,
              hintStyle: ZayTheme.lightTheme.textTheme.displayMedium?.copyWith(
                color: ZayColors.textSecondary,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: ZayColors.inputBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: ZayColors.primary),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: ZayColors.secondary),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: ZayColors.secondary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DefaultAddressToggle extends StatelessWidget {
  const _DefaultAddressToggle({
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
          const Icon(Icons.home_outlined, color: ZayColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Default Address',
                  style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
                    color: ZayColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Use this address first during checkout.',
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
