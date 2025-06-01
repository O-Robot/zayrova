import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:zayrova/core/constants/assets.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/core/themes/zay_theme.dart';
import 'package:zayrova/presentation/components/top_navigation.dart';
import 'package:zayrova/presentation/routes/zay_router.dart';
import 'package:zayrova/presentation/widgets/input.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  final TextEditingController locationSearch = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
                onTrailingIconTap: () {},
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 21,
                    height: 21,
                    child: Image.asset(ZayIcons.locationIcon),
                  ),
                  SizedBox(width: 15),
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      'Use my current Location',
                      style: ZayTheme.lightTheme.textTheme.displayLarge
                          ?.copyWith(color: ZayColors.textPrimary),
                    ),
                  ),
                ],
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 21,
                          height: 21,
                          child: Image.asset(ZayIcons.locationIcon),
                        ),
                        SizedBox(width: 15),
                        GestureDetector(
                          onTap: () {},
                          child: Text(
                            'Golden Avenue',
                            style: ZayTheme.lightTheme.textTheme.displayLarge
                                ?.copyWith(color: ZayColors.textPrimary),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Text(
                      '8502 Preston Rd. Ingl..',
                      style: ZayTheme.lightTheme.textTheme.displayLarge
                          ?.copyWith(color: ZayColors.textPrimary),
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
