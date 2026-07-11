import 'package:latlong2/latlong.dart';

enum TrackingDeliveryStatus { pickedUp, onTheWay, delivered }

enum TrackingMilestoneState { completed, active, upcoming }

class TrackingMilestone {
  const TrackingMilestone({
    required this.title,
    required this.subtitle,
    required this.state,
  });

  final String title;
  final String subtitle;
  final TrackingMilestoneState state;
}

class TrackingModel {
  const TrackingModel({
    required this.pickupLocation,
    required this.destinationLocation,
    required this.courierLocation,
    required this.routePoints,
    required this.progress,
    required this.deliveryStatus,
    required this.selectedAddress,
    required this.courierName,
    required this.courierAvatarUrl,
    required this.courierVehicle,
    required this.courierStatus,
    required this.pickupLabel,
    required this.pickupAddress,
  });

  final LatLng pickupLocation;
  final LatLng destinationLocation;
  final LatLng courierLocation;
  final List<LatLng> routePoints;
  final double progress;
  final TrackingDeliveryStatus deliveryStatus;
  final String selectedAddress;
  final String courierName;
  final String courierAvatarUrl;
  final String courierVehicle;
  final String courierStatus;
  final String pickupLabel;
  final String pickupAddress;

  int get progressPercentage => (progress * 100).round();

  String get progressText => '$progressPercentage%';

  List<TrackingMilestone> get milestones {
    return [
      TrackingMilestone(
        title: 'Picked up',
        subtitle: pickupAddress,
        state: TrackingMilestoneState.completed,
      ),
      TrackingMilestone(
        title: 'On the way',
        subtitle: '$courierName • $courierVehicle',
        state:
            deliveryStatus == TrackingDeliveryStatus.onTheWay
                ? TrackingMilestoneState.active
                : deliveryStatus == TrackingDeliveryStatus.delivered
                ? TrackingMilestoneState.completed
                : TrackingMilestoneState.upcoming,
      ),
      TrackingMilestone(
        title: 'Delivered',
        subtitle: selectedAddress,
        state:
            deliveryStatus == TrackingDeliveryStatus.delivered
                ? TrackingMilestoneState.completed
                : TrackingMilestoneState.upcoming,
      ),
    ];
  }
}
