import 'package:zayrova/domain/entities/address_entity.dart';

class UserProfile {
  const UserProfile({
    required this.id,
    this.firstName,
    this.lastName,
    this.fullName,
    this.email,
    this.phoneNumber,
    this.avatarUrl,
    this.dateOfBirth,
    this.gender,
    this.defaultAddress,
    this.addresses = const [],
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
  });

  final String id;
  final String? firstName;
  final String? lastName;
  final String? fullName;
  final String? email;
  final String? phoneNumber;
  final String? avatarUrl;
  final DateTime? dateOfBirth;
  final String? gender;
  final Address? defaultAddress;
  final List<Address> addresses;
  final bool isEmailVerified;
  final bool isPhoneVerified;

  String get displayName {
    if (fullName != null && fullName!.isNotEmpty) {
      return fullName!;
    }

    final name = [firstName, lastName].whereType<String>().join(' ').trim();

    if (name.isNotEmpty) {
      return name;
    }

    return email ?? phoneNumber ?? 'Customer';
  }

  UserProfile copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? avatarUrl,
    DateTime? dateOfBirth,
    String? gender,
    Address? defaultAddress,
    List<Address>? addresses,
    bool? isEmailVerified,
    bool? isPhoneVerified,
  }) {
    return UserProfile(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      defaultAddress: defaultAddress ?? this.defaultAddress,
      addresses: addresses ?? this.addresses,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
    );
  }
}
