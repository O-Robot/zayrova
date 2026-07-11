String currencySymbol(String currencyCode) {
  switch (currencyCode.toUpperCase()) {
    case 'USD':
      return r'$';
    default:
      return '$currencyCode ';
  }
}

String formatCurrency(double value, String currencyCode) {
  final symbol = currencySymbol(currencyCode);
  final parts = value.toStringAsFixed(2).split('.');
  final wholeNumber = parts[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );

  return '$symbol$wholeNumber.${parts[1]}';
}
