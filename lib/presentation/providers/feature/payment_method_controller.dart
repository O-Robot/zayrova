import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zayrova/domain/entities/payment_method_entity.dart';

// Temporary in-memory payment method state for checkout foundation.
// Replace this with secure payment/profile API use cases when payment
// integration is approved. Never store full card numbers here.
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
  @override
  PaymentMethodState build() {
    return const PaymentMethodState();
  }

  void addMethod(PaymentMethod method) {
    final shouldSelect = method.isDefault || state.methods.isEmpty;
    final methods = [
      ...state.methods.map(
        (existing) => shouldSelect
            ? existing.copyWith(isDefault: false)
            : existing,
      ),
      method.copyWith(isDefault: shouldSelect || method.isDefault),
    ];

    state = state.copyWith(
      methods: methods,
      selectedMethodId: shouldSelect
          ? method.id
          : state.selectedMethodId,
    );
  }

  void selectMethod(String methodId) {
    state = state.copyWith(selectedMethodId: methodId);
  }

  void setDefaultMethod(String methodId) {
    final methods = state.methods.map((method) {
      return method.copyWith(isDefault: method.id == methodId);
    }).toList();

    state = PaymentMethodState(
      methods: methods,
      selectedMethodId: methodId,
    );
  }
}
