import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:zayrova/core/constants/assets.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/core/themes/zay_theme.dart';
import 'package:zayrova/domain/entities/address_entity.dart';
import 'package:zayrova/presentation/components/top_navigation.dart';
import 'package:zayrova/presentation/providers/feature/address_controller.dart';
import 'package:zayrova/presentation/routes/zay_router.dart';
import 'package:zayrova/presentation/widgets/input.dart';

class LocationPage extends ConsumerStatefulWidget {
  const LocationPage({super.key});

  @override
  ConsumerState<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends ConsumerState<LocationPage> {
  final TextEditingController locationSearch = TextEditingController();
  String _locationQuery = '';

  @override
  void dispose() {
    locationSearch.dispose();
    super.dispose();
  }

  void _clearLocation() {
    locationSearch.clear();
    setState(() => _locationQuery = '');
  }

  void _showCurrentLocationComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Current location is unavailable right now. Enter your location manually.',
        ),
      ),
    );
  }

  void _saveManualLocation() {
    final location = locationSearch.text.trim();
    if (location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a location before saving.')),
      );
      return;
    }

    // Local/session save only. Replace with account address services or real
    // geocoding when location services are available.
    final address = Address(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      label: 'Manual Location',
      addressLine1: location,
      city: '',
      country: '',
    );

    ref.read(addressControllerProvider.notifier).addAddress(address);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Location saved for checkout.')),
    );
    ZayRouter.goBack();
  }

  @override
  Widget build(BuildContext context) {
    final hasTypedLocation = _locationQuery.trim().isNotEmpty;

    return Scaffold(
      appBar: null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              TopNavigation(text: 'Enter Your Location'),
              const SizedBox(height: 8),
              ZayTextInput.primary(
                "",
                controller: locationSearch,
                height: 60,
                border: Color(0xFFCDCBCB),
                leadingIconS: SizedBox(
                  width: 21,
                  height: 21,
                  child: SvgPicture.asset(ZayIcons.searchIcon),
                ),
                trailingIconS: Icon(
                  Icons.cancel_outlined,
                  color: ZayColors.primary,
                ),
                onTrailingIconTap: _clearLocation,
                onChanged: (value) {
                  setState(() => _locationQuery = value);
                },
                onSubmit: (_) => _saveManualLocation(),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _showCurrentLocationComingSoon,
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 21,
                      height: 21,
                      child: Image.asset(ZayIcons.locationIcon),
                    ),
                    SizedBox(width: 15),
                    Text(
                      'Use my current Location',
                      style: ZayTheme.lightTheme.textTheme.displayLarge
                          ?.copyWith(color: ZayColors.textPrimary),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15),
              Text(
                'search result'.toUpperCase(),
                style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
                  color: ZayColors.textPrimary,
                ),
              ),
              SizedBox(height: 15),
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasTypedLocation)
                      GestureDetector(
                        onTap: _saveManualLocation,
                        behavior: HitTestBehavior.opaque,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 21,
                                  height: 21,
                                  child: Image.asset(ZayIcons.locationIcon),
                                ),
                                SizedBox(width: 15),
                                Expanded(
                                  child: Text(
                                    _locationQuery.trim(),
                                    style: ZayTheme
                                        .lightTheme.textTheme.displayLarge
                                        ?.copyWith(
                                          color: ZayColors.textPrimary,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Padding(
                              padding: const EdgeInsets.only(left: 36),
                              child: Text(
                                'Use this manually entered location',
                                style: ZayTheme
                                    .lightTheme.textTheme.displayMedium
                                    ?.copyWith(
                                      color: ZayColors.textSecondary,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Text(
                        'Type a location to save it manually.',
                        style: ZayTheme.lightTheme.textTheme.displayMedium
                            ?.copyWith(
                              color: ZayColors.textSecondary,
                            ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
