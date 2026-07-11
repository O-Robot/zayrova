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
  static const Map<String, List<String>> _countryStates = {
    'United States': ['California', 'Florida', 'Georgia', 'New York', 'Texas'],
    'Nigeria': [
      'Abia',
      'Abuja FCT',
      'Adamawa',
      'Akwa Ibom',
      'Anambra',
      'Bauchi',
      'Bayelsa',
      'Benue',
      'Borno',
      'Cross River',
      'Delta',
      'Edo',
      'Ekiti',
      'Enugu',
      'Gombe',
      'Imo',
      'Kaduna',
      'Kano',
      'Katsina',
      'Kogi',
      'Kwara',
      'Lagos',
      'Nasarawa',
      'Niger',
      'Ogun',
      'Ondo',
      'Osun',
      'Oyo',
      'Plateau',
      'Rivers',
    ],
    'Ghana': ['Ashanti', 'Greater Accra', 'Northern', 'Upper East', 'Volta'],
    'Kenya': ['Mombasa', 'Kiambu', 'Kisumu', 'Nakuru', 'Nairobi'],
    'South Africa': [
      'Eastern Cape',
      'Gauteng',
      'KwaZulu-Natal',
      'Limpopo',
      'Western Cape',
    ],
  };

  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  String? _selectedCountry;
  String? _selectedState;
  bool _isDefault = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
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
      state: _selectedState?.trim(),
      country: (_selectedCountry ?? '').trim(),
      postalCode: _emptyToNull(_postalCodeController.text),
      isDefault: _isDefault,
    );

    // Local/session save. Later this should call profile/address APIs.
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

  String? _requiredSelection(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final stateOptions =
        _selectedCountry == null
            ? const <String>[]
            : _countryStates[_selectedCountry] ?? const <String>[];

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
                hint: 'Enter your full name',
                controller: _fullNameController,
                icon: Icons.person_outline,
                validator: _required,
                textInputAction: TextInputAction.next,
              ),
              _AddressTextField(
                label: 'Phone Number',
                hint: 'Enter your phone number',
                controller: _phoneController,
                icon: Icons.phone_outlined,
                validator: _required,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
              ),
              _AddressTextField(
                label: 'Address Line 1',
                hint: 'House number and street',
                controller: _addressLine1Controller,
                icon: Icons.home_outlined,
                validator: _required,
                textInputAction: TextInputAction.next,
              ),
              _AddressTextField(
                label: 'Address Line 2',
                hint: 'Apartment, suite, landmark',
                controller: _addressLine2Controller,
                icon: Icons.location_on_outlined,
                textInputAction: TextInputAction.next,
              ),
              _AddressTextField(
                label: 'City',
                hint: 'Enter your city',
                controller: _cityController,
                icon: Icons.location_city_outlined,
                validator: _required,
                textInputAction: TextInputAction.next,
              ),
              _AddressDropdownField(
                label: 'Country',
                hint: 'Select your country',
                icon: Icons.public_outlined,
                value: _selectedCountry,
                items: _countryStates.keys.toList(),
                validator: _requiredSelection,
                onChanged: (value) {
                  setState(() {
                    final nextStates =
                        value == null
                            ? const <String>[]
                            : _countryStates[value] ?? const <String>[];
                    _selectedCountry = value;
                    if (!nextStates.contains(_selectedState)) {
                      _selectedState = null;
                    }
                  });
                },
              ),
              _AddressDropdownField(
                label: 'State',
                hint:
                    _selectedCountry == null
                        ? 'Select country first'
                        : 'Select your state',
                icon: Icons.map_outlined,
                value: _selectedState,
                items: stateOptions,
                enabled: _selectedCountry != null,
                validator: _requiredSelection,
                onChanged: (value) {
                  setState(() => _selectedState = value);
                },
              ),
              _AddressTextField(
                label: 'Postal Code',
                hint: 'Enter postal code',
                controller: _postalCodeController,
                icon: Icons.markunread_mailbox_outlined,
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
    required this.hint,
    required this.controller,
    required this.icon,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData icon;
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

class _AddressDropdownField extends StatelessWidget {
  const _AddressDropdownField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.items,
    required this.onChanged,
    this.value,
    this.validator,
    this.enabled = true,
  });

  final String label;
  final String hint;
  final IconData icon;
  final List<String> items;
  final String? value;
  final ValueChanged<String?> onChanged;
  final FormFieldValidator<String>? validator;
  final bool enabled;

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
          DropdownButtonFormField<String>(
            value: items.contains(value) ? value : null,
            validator: enabled ? validator : null,
            onChanged: enabled ? onChanged : null,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFFA8B0C6),
            ),
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
              prefixIcon: Icon(
                icon,
                color: enabled ? ZayColors.primary : const Color(0xFFA8B0C6),
                size: 24,
              ),
              filled: true,
              fillColor:
                  enabled ? const Color(0xFFFBFBFD) : const Color(0xFFF4F5F8),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 18,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFF0F1F6)),
              ),
              disabledBorder: OutlineInputBorder(
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
            items:
                items
                    .map(
                      (item) => DropdownMenuItem<String>(
                        value: item,
                        child: Text(item, overflow: TextOverflow.ellipsis),
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }
}

class _DefaultAddressToggle extends StatelessWidget {
  const _DefaultAddressToggle({required this.value, required this.onChanged});

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
