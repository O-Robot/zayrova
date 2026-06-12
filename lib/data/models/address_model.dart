import 'package:zayrova/data/models/model_parse_helpers.dart';
import 'package:zayrova/domain/entities/address_entity.dart';

class AddressModel extends Address {
  const AddressModel({
    required super.id,
    required super.label,
    required super.addressLine1,
    required super.city,
    required super.country,
    super.addressLine2,
    super.state,
    super.postalCode,
    super.phoneNumber,
    super.recipientName,
    super.latitude,
    super.longitude,
    super.isDefault,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    final coordinates = json['coordinates'] is Map<String, dynamic>
        ? json['coordinates'] as Map<String, dynamic>
        : <String, dynamic>{};

    return AddressModel(
      id: stringValue(json['id'] ?? json['label'], 'address'),
      label: stringValue(json['label'], 'Home'),
      recipientName: nullableString(json['recipientName'] ?? json['name']),
      addressLine1: stringValue(
        json['addressLine1'] ?? json['address'] ?? json['street'],
      ),
      addressLine2: nullableString(json['addressLine2']),
      city: stringValue(json['city']),
      state: nullableString(json['state'] ?? json['stateCode']),
      postalCode: nullableString(json['postalCode'] ?? json['zip']),
      country: stringValue(json['country']),
      phoneNumber: nullableString(json['phoneNumber'] ?? json['phone']),
      latitude: json.containsKey('latitude') || coordinates.containsKey('lat')
          ? doubleValue(json['latitude'] ?? coordinates['lat'])
          : null,
      longitude: json.containsKey('longitude') || coordinates.containsKey('lng')
          ? doubleValue(json['longitude'] ?? coordinates['lng'])
          : null,
      isDefault: boolValue(json['isDefault']),
    );
  }

  Address toEntity() => this;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'recipientName': recipientName,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
      'phoneNumber': phoneNumber,
      'latitude': latitude,
      'longitude': longitude,
      'isDefault': isDefault,
    };
  }
}
