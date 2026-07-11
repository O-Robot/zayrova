import 'package:flutter/material.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/core/themes/zay_theme.dart';
import 'package:zayrova/features/tracking/models/tracking_model.dart';

class DeliveryProgress extends StatelessWidget {
  const DeliveryProgress({super.key, required this.tracking});

  final TrackingModel tracking;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progress of your Order',
          style: ZayTheme.lightTheme.textTheme.titleLarge?.copyWith(
            color: ZayColors.textPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          tracking.selectedAddress,
          style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
            color: ZayColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '${tracking.progressText} complete • ${tracking.courierStatus}',
          style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
            color: ZayColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 22),
        ...List.generate(tracking.milestones.length, (index) {
          final milestone = tracking.milestones[index];
          return _DeliveryProgressTile(
            milestone: milestone,
            courierVehicle: tracking.courierVehicle,
            isLast: index == tracking.milestones.length - 1,
          );
        }),
      ],
    );
  }
}

class _DeliveryProgressTile extends StatelessWidget {
  const _DeliveryProgressTile({
    required this.milestone,
    required this.courierVehicle,
    required this.isLast,
  });

  final TrackingMilestone milestone;
  final String courierVehicle;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final isCompleted = milestone.state == TrackingMilestoneState.completed;
    final isActive = milestone.state == TrackingMilestoneState.active;
    final indicatorColor =
        isCompleted || isActive ? ZayColors.primary : const Color(0xFFF1F2F6);
    final iconColor =
        isCompleted || isActive ? ZayColors.white : ZayColors.textSecondary;
    final lineColor = isCompleted ? ZayColors.primary : const Color(0xFFE4E7EF);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: indicatorColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _iconForState(milestone.title, courierVehicle),
                  color: iconColor,
                  size: 24,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 3,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    color: lineColor,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          milestone.title,
                          style: ZayTheme.lightTheme.textTheme.bodyLarge
                              ?.copyWith(
                                color: ZayColors.textPrimary,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ),
                      Text(
                        _trailingLabel(milestone.state),
                        style: ZayTheme.lightTheme.textTheme.displayLarge
                            ?.copyWith(
                              color:
                                  isActive
                                      ? ZayColors.primary
                                      : ZayColors.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    milestone.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
                      color: ZayColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForState(String title, String vehicle) {
    switch (title) {
      case 'Picked up':
        return Icons.storefront_outlined;
      case 'On the way':
        return _vehicleIcon(vehicle);
      case 'Delivered':
        return Icons.home_outlined;
      default:
        return Icons.location_on_outlined;
    }
  }

  IconData _vehicleIcon(String vehicle) {
    switch (vehicle.toLowerCase()) {
      case 'bike':
        return Icons.pedal_bike;
      case 'scooter':
        return Icons.electric_scooter;
      case 'motorcycle':
        return Icons.two_wheeler;
      case 'car':
        return Icons.directions_car_outlined;
      case 'van':
        return Icons.local_shipping_outlined;
      default:
        return Icons.delivery_dining;
    }
  }

  String _trailingLabel(TrackingMilestoneState state) {
    switch (state) {
      case TrackingMilestoneState.completed:
        return 'Done';
      case TrackingMilestoneState.active:
        return 'Active';
      case TrackingMilestoneState.upcoming:
        return 'Upcoming';
    }
  }
}
