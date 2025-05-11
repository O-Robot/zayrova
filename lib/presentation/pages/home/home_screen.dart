import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:zayrova/core/constants/assets.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/core/themes/zay_theme.dart';
import 'package:zayrova/presentation/components/banner_carousel.dart';
import 'package:zayrova/presentation/components/bottom_navigation.dart';
import 'package:zayrova/presentation/components/product_card.dart';
import 'package:zayrova/presentation/routes/zay_router.dart';
import 'package:zayrova/presentation/routes/zay_routes.dart';
import 'package:zayrova/presentation/widgets/input.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final categories = ['T-Shirt', 'Pant', 'Dress', 'Jacket'];
  final filters = [
    'All',
    'Computing',
    'Electronics',
    'Special Offers',
    'Fashion',
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      bottomNavigationBar: BottomNavigation(),
      extendBody: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // top side
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Location',
                            style: ZayTheme.lightTheme.textTheme.displaySmall
                                ?.copyWith(color: ZayColors.textSecondary),
                          ),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                color: ZayColors.primary,
                                size: 20,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'New York, USA',
                                style: ZayTheme
                                    .lightTheme
                                    .textTheme
                                    .displayMedium
                                    ?.copyWith(
                                      color: ZayColors.textPrimary,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                              Icon(Icons.keyboard_arrow_down),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: ZayColors.textSecondary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Icon(
                          Icons.notifications,
                          color: ZayColors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            ZayRouter.goto(ZayRoutes.search);
                          },
                          child: Container(
                            height: 45,
                            decoration: BoxDecoration(
                              color: ZayColors.white,
                              border: Border.all(color: ZayColors.inputBorder),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 21,
                                  height: 21,
                                  child: SvgPicture.asset(ZayIcons.searchIcon),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Search",
                                  style: TextStyle(
                                    color: ZayColors.textSecondary,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: ZayColors.primary,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: const Icon(Icons.tune, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // banner
                    BannerCarousel(
                      imageUrls: [
                        'https://images.pexels.com/photos/7974/pexels-photo.jpg',
                        'https://images.pexels.com/photos/7974/pexels-photo.jpg',
                        'https://images.pexels.com/photos/7974/pexels-photo.jpg',
                      ],
                    ),
                    SizedBox(height: 10),
                    // categories
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Category',
                                style: ZayTheme
                                    .lightTheme
                                    .textTheme
                                    .displayLarge
                                    ?.copyWith(color: ZayColors.textPrimary),
                              ),
                              Text(
                                'See All',
                                style: ZayTheme
                                    .lightTheme
                                    .textTheme
                                    .displayMedium
                                    ?.copyWith(color: ZayColors.textSecondary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children:
                                categories.map((title) {
                                  return Column(
                                    children: [
                                      CircleAvatar(
                                        radius: 35,
                                        backgroundColor: ZayColors.secondary,
                                        child: SvgPicture.asset(
                                          ZayIcons.logoIcon,
                                          colorFilter: ColorFilter.mode(
                                            ZayColors.white,
                                            BlendMode.srcIn,
                                          ),
                                          width: 30,
                                          height: 30,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        title,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  );
                                }).toList(),
                          ),
                        ],
                      ),
                    ),
                    // filters
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Text(
                                'Flash Sale',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Spacer(),
                              Text('Closing in : '),
                              _CountdownBox('24'),
                              Text(':'),
                              _CountdownBox('00'),
                              Text(':'),
                              _CountdownBox('00'),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children:
                                  filters.map((text) {
                                    final selected = text == 'Computing';
                                    return Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            selected
                                                ? Colors.green.shade800
                                                : Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      child: Text(
                                        text,
                                        style: TextStyle(
                                          color:
                                              selected
                                                  ? Colors.white
                                                  : Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // products
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ProductCard(
                            imagePath:
                                'https://images.pexels.com/photos/7974/pexels-photo.jpg',
                            isFavorite: true,
                            onFavoriteToggle: () {},
                            price: '899.00',
                            title: 'HP Elitebook 840',
                            rating: 0,
                          ),
                          ProductCard(
                            imagePath:
                                'https://images.pexels.com/photos/7974/pexels-photo.jpg',
                            isFavorite: false,
                            onFavoriteToggle: () {},
                            price: '899.00',
                            title: 'HP Elitebook 840',
                            rating: 0,
                          ),
                          // Add more cards here...
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ProductCard(
                            imagePath:
                                'https://images.pexels.com/photos/7974/pexels-photo.jpg',
                            isFavorite: true,
                            onFavoriteToggle: () {},
                            price: '899.00',
                            title: 'HP Elitebook 840',
                            rating: 0,
                          ),
                          ProductCard(
                            imagePath:
                                'https://images.pexels.com/photos/7974/pexels-photo.jpg',
                            isFavorite: false,
                            onFavoriteToggle: () {},
                            price: '899.00',
                            title: 'HP Elitebook 840',
                            rating: 0,
                          ),
                          // Add more cards here...
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountdownBox extends StatelessWidget {
  final String value;
  const _CountdownBox(this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        gradient: ZayColors.gradient,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
