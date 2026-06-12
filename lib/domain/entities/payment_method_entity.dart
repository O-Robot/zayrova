enum PaymentMethodType { card, bankTransfer, cashOnDelivery, wallet, other }

class PaymentMethod {
  const PaymentMethod({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    this.provider,
    this.cardBrand,
    this.lastFourDigits,
    this.expiryMonth,
    this.expiryYear,
    this.iconUrl,
    this.isDefault = false,
  });

  final String id;
  final PaymentMethodType type;
  final String title;
  final String? subtitle;
  final String? provider;
  final String? cardBrand;
  final String? lastFourDigits;
  final int? expiryMonth;
  final int? expiryYear;
  final String? iconUrl;
  final bool isDefault;

  PaymentMethod copyWith({
    String? id,
    PaymentMethodType? type,
    String? title,
    String? subtitle,
    String? provider,
    String? cardBrand,
    String? lastFourDigits,
    int? expiryMonth,
    int? expiryYear,
    String? iconUrl,
    bool? isDefault,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      provider: provider ?? this.provider,
      cardBrand: cardBrand ?? this.cardBrand,
      lastFourDigits: lastFourDigits ?? this.lastFourDigits,
      expiryMonth: expiryMonth ?? this.expiryMonth,
      expiryYear: expiryYear ?? this.expiryYear,
      iconUrl: iconUrl ?? this.iconUrl,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
