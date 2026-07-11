import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:zayrova/domain/entities/address_entity.dart';
import 'package:zayrova/domain/entities/order_entity.dart';
import 'package:zayrova/features/tracking/models/tracking_model.dart';
import 'package:zayrova/features/tracking/services/routing_service.dart';

final routingHttpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final routingServiceProvider = Provider<RoutingService>((ref) {
  return RoutingService(ref.watch(routingHttpClientProvider));
});

typedef TrackingRequest = ({Order order, Address? fallbackAddress});

final trackingModelProvider =
    FutureProvider.autoDispose.family<TrackingModel, TrackingRequest>((
      ref,
      request,
    ) async {
      return ref
          .watch(routingServiceProvider)
          .buildMockTracking(
            request.order,
            fallbackAddress: request.fallbackAddress,
          );
    });
