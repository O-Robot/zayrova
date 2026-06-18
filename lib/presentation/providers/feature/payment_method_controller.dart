import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zayrova/core/utils/local_storage.dart';
import 'package:zayrova/domain/entities/payment_method_entity.dart';

// Local/session payment method metadata for the checkout foundation.
// Replace this with secure payment/profile API use cases when payment
// integration is approved. Never store full card numbers or CVV here.
final paymentMethodControllerProvider =
    NotifierProvider<PaymentMethodController, PaymentMethodState>(
  PaymentMethodController.new,
);

class PaymentMethodState {
  const PaymentMethodState({
    this.methods = const [],
    this.selectedMethodId,
  });

  final List<PaymentMethod> methods;
  final String? selectedMethodId;

  PaymentMethod? get selectedMethod {
    for (final method in methods) {
      if (method.id == selectedMethodId) {
        return method;
      }
    }

    for (final method in methods) {
      if (method.isDefault) {
        return method;
      }
    }

    return methods.isEmpty ? null : methods.first;
  }

  PaymentMethodState copyWith({
    List<PaymentMethod>? methods,
    String? selectedMethodId,
  }) {
    return PaymentMethodState(
      methods: methods ?? this.methods,
      selectedMethodId: selectedMethodId ?? this.selectedMethodId,
    );
  }
}

class PaymentMethodController extends Notifier<PaymentMethodState> {
  static const String _storageKey = 'zayrova_checkout_payment_methods';

  @override
  PaymentMethodState build() {
    unawaited(_loadPersistedState());
    return const PaymentMethodState();
  }

  void addMethod(PaymentMethod method) {
    final safeMethod = _safePaymentMethod(method);
    final shouldSelect = method.isDefault || state.methods.isEmpty;
    final methods = [
      ...state.methods.map(
        (existing) => shouldSelect
            ? existing.copyWith(isDefault: false)
            : existing,
      ),
      safeMethod.copyWith(isDefault: shouldSelect || method.isDefault),
    ];

    state = state.copyWith(
      methods: methods,
      selectedMethodId: shouldSelect
          ? safeMethod.id
          : state.selectedMethodId,
    );
    unawaited(_persistState());
  }

  void selectMethod(String methodId) {
    state = state.copyWith(selectedMethodId: methodId);
    unawaited(_persistState());
  }

  void setDefaultMethod(String methodId) {
    final methods = state.methods.map((method) {
      return method.copyWith(isDefault: method.id == methodId);
    }).toList();

    state = PaymentMethodState(
      methods: methods,
      selectedMethodId: methodId,
    );
    unawaited(_persistState());
  }

  void removeMethod(String methodId) {
    final methods = state.methods
        .where((method) => method.id != methodId)
        .toList();
    final selectedMethod = _resolveSelectedMethod(
      methods,
      state.selectedMethodId == methodId ? null : state.selectedMethodId,
    );

    state = PaymentMethodState(
      methods: methods,
      selectedMethodId: selectedMethod?.id,
    );
    unawaited(_persistState());
  }

  Future<void> _loadPersistedState() async {
    final stored = await LocalStorage.get(_storageKey, Map);
    if (stored is! Map) {
      return;
    }

    final rawMethods = stored['methods'];
    final methods = rawMethods is List
        ? rawMethods
            .whereType<Map>()
            .map(_paymentMethodFromStorage)
            .whereType<PaymentMethod>()
            .toList()
        : <PaymentMethod>[];
    final selectedMethodId = _stringOrNull(stored['selectedMethodId']);
    final selectedMethod = _resolveSelectedMethod(methods, selectedMethodId);

    state = PaymentMethodState(
      methods: methods,
      selectedMethodId: selectedMethod?.id,
    );
  }

  Future<void> _persistState() {
    return LocalStorage.set(_storageKey, {
      'selectedMethodId': state.selectedMethodId,
      'methods': state.methods.map(_paymentMethodToStorage).toList(),
    });
  }

  PaymentMethod? _resolveSelectedMethod(
    List<PaymentMethod> methods,
    String? selectedMethodId,
  ) {
    for (final method in methods) {
      if (method.id == selectedMethodId) {
        return method;
      }
    }

    for (final method in methods) {
      if (method.isDefault) {
        return method;
      }
    }

    return methods.isEmpty ? null : methods.first;
  }

  PaymentMethod _safePaymentMethod(PaymentMethod method) {
    if (method.type != PaymentMethodType.card) {
      return method;
    }

    final lastFour = _safeLastFour(method.lastFourDigits);

    return PaymentMethod(
      id: method.id,
      type: PaymentMethodType.card,
      title: method.title,
      provider: method.provider ?? method.cardBrand,
      cardBrand: method.cardBrand ?? method.provider,
      lastFourDigits: lastFour,
      expiryMonth: method.expiryMonth,
      expiryYear: method.expiryYear,
      isDefault: method.isDefault,
    );
  }

  Map<String, dynamic> _paymentMethodToStorage(PaymentMethod method) {
    final safeMethod = _safePaymentMethod(method);

    return {
      'id': safeMethod.id,
      'type': safeMethod.type.name,
      'title': safeMethod.title,
      'provider': safeMethod.provider,
      'cardBrand': safeMethod.cardBrand,
      'lastFourDigits': safeMethod.lastFourDigits,
      'expiryMonth': safeMethod.expiryMonth,
      'expiryYear': safeMethod.expiryYear,
      'isDefault': safeMethod.isDefault,
    };
  }

  PaymentMethod? _paymentMethodFromStorage(Map data) {
    final id = data['id'];
    final title = data['title'];
    final typeName = data['type'];

    if (id is! String || title is! String || typeName is! String) {
      return null;
    }

    return PaymentMethod(
      id: id,
      type: _typeFromName(typeName),
      title: title,
      provider: _stringOrNull(data['provider']),
      cardBrand: _stringOrNull(data['cardBrand']),
      lastFourDigits: _safeLastFour(_stringOrNull(data['lastFourDigits'])),
      expiryMonth: _intOrNull(data['expiryMonth']),
      expiryYear: _intOrNull(data['expiryYear']),
      isDefault: data['isDefault'] == true,
    );
  }

  PaymentMethodType _typeFromName(String name) {
    for (final type in PaymentMethodType.values) {
      if (type.name == name) {
        return type;
      }
    }

    return PaymentMethodType.other;
  }

  String? _safeLastFour(String? value) {
    final digits = value?.replaceAll(RegExp(r'\D'), '');
    if (digits == null || digits.isEmpty) {
      return null;
    }

    if (digits.length <= 4) {
      return digits.padLeft(4, '*');
    }

    return digits.substring(digits.length - 4);
  }

  int? _intOrNull(Object? value) {
    return value is int ? value : null;
  }

  String? _stringOrNull(Object? value) {
    return value is String ? value : null;
  }
}
