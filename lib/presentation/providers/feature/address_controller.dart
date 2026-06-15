import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zayrova/domain/entities/address_entity.dart';

// Temporary in-memory address state for checkout foundation.
// Replace this with profile/address API use cases when backend persistence is
// connected.
final addressControllerProvider =
    NotifierProvider<AddressController, AddressState>(AddressController.new);

class AddressState {
  const AddressState({
    this.addresses = const [],
    this.selectedAddressId,
  });

  final List<Address> addresses;
  final String? selectedAddressId;

  Address? get selectedAddress {
    for (final address in addresses) {
      if (address.id == selectedAddressId) {
        return address;
      }
    }

    for (final address in addresses) {
      if (address.isDefault) {
        return address;
      }
    }

    return addresses.isEmpty ? null : addresses.first;
  }

  AddressState copyWith({
    List<Address>? addresses,
    String? selectedAddressId,
  }) {
    return AddressState(
      addresses: addresses ?? this.addresses,
      selectedAddressId: selectedAddressId ?? this.selectedAddressId,
    );
  }
}

class AddressController extends Notifier<AddressState> {
  @override
  AddressState build() {
    return const AddressState();
  }

  void addAddress(Address address) {
    final shouldSelect = address.isDefault || state.addresses.isEmpty;
    final addresses = [
      ...state.addresses.map(
        (existing) => shouldSelect
            ? existing.copyWith(isDefault: false)
            : existing,
      ),
      address.copyWith(isDefault: shouldSelect || address.isDefault),
    ];

    state = state.copyWith(
      addresses: addresses,
      selectedAddressId: shouldSelect
          ? address.id
          : state.selectedAddressId,
    );
  }

  void selectAddress(String addressId) {
    state = state.copyWith(selectedAddressId: addressId);
  }

  void setDefaultAddress(String addressId) {
    final addresses = state.addresses.map((address) {
      return address.copyWith(isDefault: address.id == addressId);
    }).toList();

    state = AddressState(
      addresses: addresses,
      selectedAddressId: addressId,
    );
  }
}
