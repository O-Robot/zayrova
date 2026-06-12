class Address {
  const Address({
    required this.id,
    required this.label,
    required this.addressLine1,
    required this.city,
    required this.country,
    this.addressLine2,
    this.state,
    this.postalCode,
    this.phoneNumber,
    this.recipientName,
    this.latitude,
    this.longitude,
    this.isDefault = false,
  });

  final String id;
  final String label;
  final String? recipientName;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String? state;
  final String? postalCode;
  final String country;
  final String? phoneNumber;
  final double? latitude;
  final double? longitude;
  final bool isDefault;

  String get formattedAddress {
    return [
      addressLine1,
      addressLine2,
      city,
      state,
      postalCode,
      country,
    ].whereType<String>().where((part) => part.isNotEmpty).join(', ');
  }

  Address copyWith({
    String? id,
    String? label,
    String? recipientName,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    String? phoneNumber,
    double? latitude,
    double? longitude,
    bool? isDefault,
  }) {
    return Address(
      id: id ?? this.id,
      label: label ?? this.label,
      recipientName: recipientName ?? this.recipientName,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
