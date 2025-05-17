// widgets/product_card.dart

import 'package:flutter/material.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/core/constants/extensions.dart';
import 'package:zayrova/core/themes/zay_theme.dart';

class ProductCard extends StatelessWidget {
  final String imagePath;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final String price;
  final String title;
  final double rating;
  final VoidCallback action;

  const ProductCard({
    super.key,
    required this.imagePath,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.price,
    required this.title,
    required this.rating,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      // margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: GestureDetector(
        onTap: () {
          action();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  child: SizedBox(
                    height: 120,
                    width: double.infinity,
                    child: Image.network(
                      imagePath,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.grey,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                              size: 40,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onFavoriteToggle,
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: ZayColors.secondary.withAlpha(90),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color:
                            isFavorite
                                ? ZayColors.secondary
                                : ZayColors.secondary,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title.truncate(24),
                        style: ZayTheme.lightTheme.textTheme.displaySmall
                            ?.copyWith(color: ZayColors.textPrimary),
                      ),
                      Row(
                        children: [
                          Icon(
                            size: 15,
                            Icons.star,
                            color: ZayColors.secondary,
                          ),
                          SizedBox(width: 2),
                          Text(
                            rating.toStringAsFixed(1),
                            style: ZayTheme.lightTheme.textTheme.displaySmall
                                ?.copyWith(color: ZayColors.textPrimary),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    '\$$price',
                    style: ZayTheme.lightTheme.textTheme.displayMedium
                        ?.copyWith(color: ZayColors.textPrimary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
