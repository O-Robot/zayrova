import 'dart:convert';
import 'dart:math' as math;

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:zayrova/domain/entities/address_entity.dart';
import 'package:zayrova/domain/entities/order_entity.dart';
import 'package:zayrova/features/tracking/models/tracking_model.dart';

class RoutingService {
  RoutingService(this._client);

  final http.Client _client;
  final math.Random _random = math.Random();

  static const LatLng _usaFallbackLocation = LatLng(39.8283, -98.5795);
  static const Map<String, String> _requestHeaders = {
    'User-Agent': 'Zayrova/1.0 (com.example.zayrova)',
  };

  Future<TrackingModel> buildMockTracking(
    Order order, {
    Address? fallbackAddress,
  }) async {
    final orderAddress = order.shippingAddress;
    final deliveryAddress =
        orderAddress != null && orderAddress.formattedAddress.trim().isNotEmpty
            ? orderAddress
            : fallbackAddress;
    final selectedAddress = _resolveAddress(deliveryAddress);
    final destinationLocation = await _resolveDestination(deliveryAddress);
    final routeSeed = await _createRoutableVendorSeed(destinationLocation);
    final progress = _progressForOrder(order.id);
    final safeRoutePoints = routeSeed.routePoints;
    final courierLocation = _pointAlongRoute(safeRoutePoints, progress);
    final courier = _courierForOrder(order.id);
    final pickupLabel =
        order.items.isNotEmpty
            ? 'Picked up from ${order.items.first.product.title}'
            : 'Picked up from vendor';

    return TrackingModel(
      pickupLocation: routeSeed.vendor.location,
      destinationLocation: destinationLocation,
      courierLocation: courierLocation,
      routePoints: safeRoutePoints,
      progress: progress,
      deliveryStatus: TrackingDeliveryStatus.onTheWay,
      selectedAddress: selectedAddress,
      courierName: courier.name,
      courierAvatarUrl: courier.avatarUrl,
      courierVehicle: courier.vehicle,
      courierStatus: 'On the way',
      pickupLabel: pickupLabel,
      pickupAddress: routeSeed.vendor.address,
    );
  }

  Future<List<LatLng>?> _requestRoute({
    required LatLng start,
    required LatLng end,
  }) async {
    final uri = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/'
      '${start.longitude},${start.latitude};${end.longitude},${end.latitude}'
      '?overview=full&geometries=geojson',
    );

    try {
      final response = await _client.get(uri, headers: _requestHeaders);
      if (response.statusCode != 200) {
        return null;
      }

      final payload = jsonDecode(response.body);
      final routes = payload['routes'];
      if (routes is! List || routes.isEmpty) {
        return null;
      }

      final geometry = routes.first['geometry'];
      final coordinates = geometry['coordinates'];
      if (coordinates is! List) {
        return null;
      }

      return coordinates
          .whereType<List>()
          .where((point) => point.length >= 2)
          .map(
            (point) => LatLng(
              (point[1] as num).toDouble(),
              (point[0] as num).toDouble(),
            ),
          )
          .toList();
    } catch (_) {
      return null;
    }
  }

  LatLng _pointAlongRoute(List<LatLng> points, double progress) {
    if (points.isEmpty) {
      return _usaFallbackLocation;
    }

    if (points.length == 1) {
      return points.first;
    }

    final clampedProgress = progress.clamp(0.0, 1.0);
    const distance = Distance();
    var totalDistance = 0.0;

    for (var index = 0; index < points.length - 1; index++) {
      totalDistance += distance.as(
        LengthUnit.Meter,
        points[index],
        points[index + 1],
      );
    }

    if (totalDistance == 0) {
      return points.first;
    }

    final targetDistance = totalDistance * clampedProgress;
    var coveredDistance = 0.0;

    for (var index = 0; index < points.length - 1; index++) {
      final start = points[index];
      final end = points[index + 1];
      final segmentDistance = distance.as(LengthUnit.Meter, start, end);

      if (coveredDistance + segmentDistance >= targetDistance) {
        final segmentProgress =
            (targetDistance - coveredDistance) / segmentDistance;
        return LatLng(
          start.latitude + ((end.latitude - start.latitude) * segmentProgress),
          start.longitude +
              ((end.longitude - start.longitude) * segmentProgress),
        );
      }

      coveredDistance += segmentDistance;
    }

    return points.last;
  }

  String _resolveAddress(Address? address) {
    final formatted = address?.formattedAddress.trim() ?? '';
    return formatted.isNotEmpty ? formatted : 'Delivery address unavailable';
  }

  Future<LatLng> _resolveDestination(Address? address) async {
    final latitude = address?.latitude;
    final longitude = address?.longitude;
    if (latitude != null && longitude != null) {
      return LatLng(latitude, longitude);
    }

    if (address == null) {
      return _usaFallbackLocation;
    }

    final queries = <String>{
      address.formattedAddress,
      [
        address.city,
        address.state,
        address.country,
      ].whereType<String>().where((part) => part.trim().isNotEmpty).join(', '),
      address.country,
    }..removeWhere((query) => query.trim().isEmpty);

    for (final query in queries) {
      final location = await _geocode(query);
      if (location != null) {
        return location;
      }
    }

    return _usaFallbackLocation;
  }

  Future<LatLng?> _geocode(String query) async {
    final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
      'q': query,
      'format': 'jsonv2',
      'limit': '1',
    });

    try {
      final response = await _client.get(uri, headers: _requestHeaders);
      if (response.statusCode != 200) return null;

      final results = jsonDecode(response.body);
      if (results is! List || results.isEmpty) return null;

      final result = results.first;
      final latitude = double.tryParse(result['lat']?.toString() ?? '');
      final longitude = double.tryParse(result['lon']?.toString() ?? '');
      return latitude == null || longitude == null
          ? null
          : LatLng(latitude, longitude);
    } catch (_) {
      return null;
    }
  }

  Future<_RouteSeed> _createRoutableVendorSeed(LatLng destination) async {
    for (var attempt = 0; attempt < 8; attempt++) {
      final candidate = _randomPointNear(destination);
      final snappedCandidate = await _snapToRoad(candidate);
      if (snappedCandidate == null) continue;

      final route = await _requestRoute(
        start: snappedCandidate,
        end: destination,
      );
      if (route == null || route.length < 2) continue;

      const distance = Distance();
      final distanceKm = distance.as(
        LengthUnit.Kilometer,
        snappedCandidate,
        destination,
      );
      if (distanceKm < 1.5 || distanceKm > 12) continue;

      return _RouteSeed(
        vendor: _VendorSeed(
          location: snappedCandidate,
          address: 'Vendor pickup • ${distanceKm.toStringAsFixed(1)} km away',
        ),
        routePoints: route,
      );
    }

    final fallback = _randomPointNear(destination, distanceKm: 3);
    return _RouteSeed(
      vendor: _VendorSeed(
        location: fallback,
        address: 'Vendor pickup • about 3 km away',
      ),
      routePoints: _fallbackRoutePoints(fallback, destination),
    );
  }

  LatLng _randomPointNear(LatLng destination, {double? distanceKm}) {
    final radiusKm = distanceKm ?? 3 + (_random.nextDouble() * 5);
    final bearing = _random.nextDouble() * 2 * math.pi;
    const kmPerDegreeLat = 111.32;
    final kmPerDegreeLon =
        111.32 * math.cos(destination.latitude * math.pi / 180).abs();
    final latitudeOffset = (radiusKm / kmPerDegreeLat) * math.cos(bearing);
    final longitudeOffset =
        (radiusKm / (kmPerDegreeLon == 0 ? 1 : kmPerDegreeLon)) *
        math.sin(bearing);
    return LatLng(
      destination.latitude + latitudeOffset,
      destination.longitude + longitudeOffset,
    );
  }

  Future<LatLng?> _snapToRoad(LatLng location) async {
    final uri = Uri.parse(
      'https://router.project-osrm.org/nearest/v1/driving/'
      '${location.longitude},${location.latitude}?number=1',
    );
    try {
      final response = await _client.get(uri, headers: _requestHeaders);
      if (response.statusCode != 200) return null;
      final payload = jsonDecode(response.body);
      final waypoints = payload['waypoints'];
      if (waypoints is! List || waypoints.isEmpty) return null;
      final coordinates = waypoints.first['location'];
      if (coordinates is! List || coordinates.length < 2) return null;
      return LatLng(
        (coordinates[1] as num).toDouble(),
        (coordinates[0] as num).toDouble(),
      );
    } catch (_) {
      return null;
    }
  }

  double _progressForOrder(String orderId) {
    final percentage = 15 + (_seedForOrder(orderId) % 45);
    return percentage / 100;
  }

  _CourierSeed _courierForOrder(String orderId) {
    const couriers = [
      _CourierSeed(name: 'John', vehicle: 'Bike', avatarId: 12),
      _CourierSeed(name: 'Maya', vehicle: 'Scooter', avatarId: 47),
      _CourierSeed(name: 'Daniel', vehicle: 'Motorcycle', avatarId: 11),
      _CourierSeed(name: 'Sofia', vehicle: 'Car', avatarId: 44),
      _CourierSeed(name: 'Marcus', vehicle: 'Van', avatarId: 68),
      _CourierSeed(name: 'Amara', vehicle: 'Bike', avatarId: 32),
    ];
    return couriers[_seedForOrder(orderId) % couriers.length];
  }

  int _seedForOrder(String orderId) {
    var seed = 0;
    for (final codeUnit in orderId.codeUnits) {
      seed = ((seed * 31) + codeUnit) & 0x7fffffff;
    }
    return seed;
  }

  List<LatLng> _fallbackRoutePoints(LatLng start, LatLng end) {
    final midOne = LatLng(
      start.latitude + ((end.latitude - start.latitude) * 0.22),
      start.longitude + ((end.longitude - start.longitude) * 0.08),
    );
    final midTwo = LatLng(
      start.latitude + ((end.latitude - start.latitude) * 0.48),
      start.longitude + ((end.longitude - start.longitude) * 0.42),
    );
    final midThree = LatLng(
      start.latitude + ((end.latitude - start.latitude) * 0.74),
      start.longitude + ((end.longitude - start.longitude) * 0.76),
    );

    return [start, midOne, midTwo, midThree, end];
  }
}

class _VendorSeed {
  const _VendorSeed({required this.location, required this.address});

  final LatLng location;
  final String address;
}

class _RouteSeed {
  const _RouteSeed({required this.vendor, required this.routePoints});

  final _VendorSeed vendor;
  final List<LatLng> routePoints;
}

class _CourierSeed {
  const _CourierSeed({
    required this.name,
    required this.vehicle,
    required this.avatarId,
  });

  final String name;
  final String vehicle;
  final int avatarId;

  String get avatarUrl =>
      'https://api.dicebear.com/9.x/micah/png?seed=courier-$avatarId'
      '&size=150';
}
