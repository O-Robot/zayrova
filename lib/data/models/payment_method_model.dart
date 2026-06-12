import 'package:zayrova/data/models/model_parse_helpers.dart';
import 'package:zayrova/domain/entities/payment_method_entity.dart';

class PaymentMethodModel extends PaymentMethod {
  const PaymentMethodModel({
    required super.id,
    required super.type,
    required super.title,
    super.subtitle,
    super.provider,
    super.cardBrand,
    super.lastFourDigits,
    super.expiryMonth,
    super.expiryYear,
    super.iconUrl,
    super.isDefault,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: stringValue(json['id']),
      type: _typeFromJson(json['type']),
      title: stringValue(json['title'], 'Payment method'),
      subtitle: nullableString(json['subtitle']),
      provider: nullableString(json['provider']),
      cardBrand: nullableString(json['cardBrand'] ?? json['brand']),
      lastFourDigits: nullableString(
        json['lastFourDigits'] ?? json['last4'],
      ),
      expiryMonth: json.containsKey('expiryMonth')
          ? intValue(json['expiryMonth'])
          : null,
      expiryYear: json.containsKey('expiryYear')
          ? intValue(json['expiryYear'])
          : null,
      iconUrl: nullableString(json['iconUrl']),
      isDefault: boolValue(json['isDefault']),
    );
  }

  PaymentMethod toEntity() => this;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': enumName(type),
      'title': title,
      'subtitle': subtitle,
      'provider': provider,
      'cardBrand': cardBrand,
      'lastFourDigits': lastFourDigits,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
      'iconUrl': iconUrl,
      'isDefault': isDefault,
    };
  }

  static PaymentMethodType _typeFromJson(dynamic value) {
    final type = stringValue(value).toLowerCase();

    switch (type) {
      case 'card':
      case 'credit_card':
      case 'debit_card':
        return PaymentMethodType.card;
      case 'bank_transfer':
      case 'banktransfer':
        return PaymentMethodType.bankTransfer;
      case 'cash_on_delivery':
      case 'cashondelivery':
        return PaymentMethodType.cashOnDelivery;
      case 'wallet':
        return PaymentMethodType.wallet;
      default:
        return PaymentMethodType.other;
    }
  }
}
