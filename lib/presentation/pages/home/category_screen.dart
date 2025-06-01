import 'package:flutter/material.dart';
import 'package:zayrova/presentation/components/product_card.dart';
import 'package:zayrova/presentation/components/top_navigation.dart';
import 'package:zayrova/presentation/routes/zay_router.dart';
import 'package:zayrova/presentation/routes/zay_routes.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreen();
}

class _CategoryScreen extends State<CategoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TopNavigation(text: 'Category name'),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ProductCard(
                            action:
                                () => ZayRouter.goto(ZayRoutes.productDetails),
                            imagePath:
                                'https://images.pexels.com/photos/7974/pexels-photo.jpg',
                            isFavorite: true,
                            onFavoriteToggle: () {},
                            price: '899.00',
                            title: 'HP Elitebook 840',
                            rating: 0,
                          ),
                          ProductCard(
                            action:
                                () => ZayRouter.goto(ZayRoutes.productDetails),
                            imagePath:
                                'https://images.pexels.com/photos/7974/pexels-photo.jpg',
                            isFavorite: true,
                            onFavoriteToggle: () {},
                            price: '899.00',
                            title: 'HP Elitebook 840',
                            rating: 0,
                          ),
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
