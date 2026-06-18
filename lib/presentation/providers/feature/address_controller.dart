import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zayrova/core/utils/local_storage.dart';
import 'package:zayrova/domain/entities/address_entity.dart';

// Local/session address persistence for the checkout foundation.
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
  static const String _storageKey = 'zayrova_checkout_addresses';

  @override
  AddressState build() {
    unawaited(_loadPersistedState());
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
    unawaited(_persistState());
  }

  void selectAddress(String addressId) {
    state = state.copyWith(selectedAddressId: addressId);
    unawaited(_persistState());
  }

  void setDefaultAddress(String addressId) {
    final addresses = state.addresses.map((address) {
      return address.copyWith(isDefault: address.id == addressId);
    }).toList();

    state = AddressState(
      addresses: addresses,
      selectedAddressId: addressId,
    );
    unawaited(_persistState());
  }

  void removeAddress(String addressId) {
    final addresses = state.addresses
        .where((address) => address.id != addressId)
        .toList();
    final selectedAddress = _resolveSelectedAddress(
      addresses,
      state.selectedAddressId == addressId ? null : state.selectedAddressId,
    );

    state = AddressState(
      addresses: addresses,
      selectedAddressId: selectedAddress?.id,
    );
    unawaited(_persistState());
  }

  Future<void> _loadPersistedState() async {
    final stored = await LocalStorage.get(_storageKey, Map);
    if (stored is! Map) {
      return;
    }

    final rawAddresses = stored['addresses'];
    final addresses = rawAddresses is List
        ? rawAddresses
            .whereType<Map>()
            .map(_addressFromStorage)
            .whereType<Address>()
            .toList()
        : <Address>[];
    final selectedAddressId = _stringOrNull(stored['selectedAddressId']);
    final selectedAddress = _resolveSelectedAddress(
      addresses,
      selectedAddressId,
    );

    state = AddressState(
      addresses: addresses,
      selectedAddressId: selectedAddress?.id,
    );
  }

  Future<void> _persistState() {
    return LocalStorage.set(_storageKey, {
      'selectedAddressId': state.selectedAddressId,
      'addresses': state.addresses.map(_addressToStorage).toList(),
    });
  }

  Address? _resolveSelectedAddress(
    List<Address> addresses,
    String? selectedAddressId,
  ) {
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

  Map<String, dynamic> _addressToStorage(Address address) {
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

  Address? _addressFromStorage(Map data) {
    final id = data['id'];
    final label = data['label'];
    final addressLine1 = data['addressLine1'];
    final city = data['city'];
    final country = data['country'];

    if (id is! String ||
        label is! String ||
        addressLine1 is! String ||
        city is! String ||
        country is! String) {
      return null;
    }

    return Address(
      id: id,
      label: label,
      recipientName: _stringOrNull(data['recipientName']),
      addressLine1: addressLine1,
      addressLine2: _stringOrNull(data['addressLine2']),
      city: city,
      state: _stringOrNull(data['state']),
      postalCode: _stringOrNull(data['postalCode']),
      country: country,
      phoneNumber: _stringOrNull(data['phoneNumber']),
      latitude: _numToDouble(data['latitude']),
      longitude: _numToDouble(data['longitude']),
      isDefault: data['isDefault'] == true,
    );
  }

  double? _numToDouble(Object? value) {
    return value is num ? value.toDouble() : null;
  }

  String? _stringOrNull(Object? value) {
    return value is String ? value : null;
  }
}
