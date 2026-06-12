String stringValue(dynamic value, [String fallback = '']) {
  if (value == null) {
    return fallback;
  }

  return value.toString();
}

String? nullableString(dynamic value) {
  if (value == null) {
    return null;
  }

  final text = value.toString();
  return text.isEmpty ? null : text;
}

int intValue(dynamic value, [int fallback = 0]) {
  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  if (value is String) {
    return int.tryParse(value) ?? fallback;
  }

  return fallback;
}

double doubleValue(dynamic value, [double fallback = 0]) {
  if (value is double) {
    return value;
  }

  if (value is num) {
    return value.toDouble();
  }

  if (value is String) {
    return double.tryParse(value) ?? fallback;
  }

  return fallback;
}

bool boolValue(dynamic value, [bool fallback = false]) {
  if (value is bool) {
    return value;
  }

  if (value is String) {
    return value.toLowerCase() == 'true';
  }

  if (value is num) {
    return value != 0;
  }

  return fallback;
}

List<String> stringListValue(dynamic value) {
  if (value is List) {
    return value.map((item) => item.toString()).toList();
  }

  return const [];
}

DateTime dateTimeValue(dynamic value) {
  return nullableDateTime(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
}

DateTime? nullableDateTime(dynamic value) {
  if (value is DateTime) {
    return value;
  }

  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }

  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value);
  }

  return null;
}

String enumName(Object value) => value.toString().split('.').last;
