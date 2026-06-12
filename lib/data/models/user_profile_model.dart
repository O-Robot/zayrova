import 'package:zayrova/data/models/address_model.dart';
import 'package:zayrova/data/models/model_parse_helpers.dart';
import 'package:zayrova/domain/entities/address_entity.dart';
import 'package:zayrova/domain/entities/user_profile_entity.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    super.firstName,
    super.lastName,
    super.fullName,
    super.email,
    super.phoneNumber,
    super.avatarUrl,
    super.dateOfBirth,
    super.gender,
    super.defaultAddress,
    super.addresses,
    super.isEmailVerified,
    super.isPhoneVerified,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final addressMap = json['address'] is Map<String, dynamic>
        ? json['address'] as Map<String, dynamic>
        : null;
    final defaultAddress = addressMap == null
        ? null
        : AddressModel.fromJson({...addressMap, 'id': 'default'});

    return UserProfileModel(
      id: stringValue(json['id']),
      firstName: nullableString(json['firstName']),
      lastName: nullableString(json['lastName']),
      fullName: nullableString(json['fullName'] ?? json['name']),
      email: nullableString(json['email']),
      phoneNumber: nullableString(json['phone'] ?? json['phoneNumber']),
      avatarUrl: nullableString(json['image'] ?? json['avatarUrl']),
      dateOfBirth: nullableDateTime(json['birthDate'] ?? json['dateOfBirth']),
      gender: nullableString(json['gender']),
      defaultAddress: defaultAddress,
      addresses: defaultAddress == null ? const [] : [defaultAddress],
      isEmailVerified: boolValue(json['isEmailVerified']),
      isPhoneVerified: boolValue(json['isPhoneVerified']),
    );
  }

  UserProfile toEntity() => this;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'fullName': fullName,
      'email': email,
      'phone': phoneNumber,
      'image': avatarUrl,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'address': _addressToJson(defaultAddress),
      'addresses': addresses.map(_addressToJson).toList(),
      'isEmailVerified': isEmailVerified,
      'isPhoneVerified': isPhoneVerified,
    };
  }

  static Map<String, dynamic>? _addressToJson(Address? address) {
    if (address == null) {
      return null;
    }

    if (address is AddressModel) {
      return address.toJson();
    }

    return {
      'id': address.id,
      'label': address.label,
      'recipientName': address.recipientName,
      'addressLine1': address.addressLine1,
      'addressLine2': address.addressLine2,
      'city': address.city,
      'state': address.state,
      'postalCode': address.postalCode,
      'country': address.country,
      'phoneNumber': address.phoneNumber,
      'latitude': address.latitude,
      'longitude': address.longitude,
      'isDefault': address.isDefault,
    };
  }
}
