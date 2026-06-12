// widgets/product_card.dart

import 'package:flutter/material.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/core/constants/extensions.dart';
import 'package:zayrova/core/themes/zay_theme.dart';
import 'package:zayrova/domain/entities/product_entity.dart';

class ProductCard extends StatelessWidget {
  final String imagePath;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final String price;
  final String title;
  final double rating;
  final VoidCallback action;
  final double width;

  const ProductCard({
    super.key,
    required this.imagePath,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.price,
    required this.title,
    required this.rating,
    required this.action,
    this.width = 170,
  });

  factory ProductCard.fromProduct({
    Key? key,
    required Product product,
    required VoidCallback action,
    required VoidCallback onFavoriteToggle,
    double width = 170,
  }) {
    final imagePath =
        product.thumbnailUrl ??
        (product.imageUrls.isNotEmpty ? product.imageUrls.first : '');

    return ProductCard(
      key: key,
      imagePath: imagePath,
      isFavorite: product.isFavorite,
      onFavoriteToggle: onFavoriteToggle,
      price: product.price.toStringAsFixed(2),
      title: product.title,
      rating: product.rating ?? 0,
      action: action,
      width: width,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      // margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: ZayColors.white,
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
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: SizedBox(
                    height: 120,
                    width: double.infinity,
                    child: imagePath.isEmpty
                        ? const _ProductImageFallback()
                        : Image.network(
                            imagePath,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                    Colors.grey,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const _ProductImageFallback();
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
                      Expanded(
                        child: Text(
                          title.truncate(24),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: ZayTheme.lightTheme.textTheme.displaySmall
                              ?.copyWith(color: ZayColors.textPrimary),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Row(
                        children: [
                          const Icon(
                            size: 15,
                            Icons.star,
                            color: ZayColors.secondary,
                          ),
                          const SizedBox(width: 2),
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

class _ProductImageFallback extends StatelessWidget {
  const _ProductImageFallback();

  @override
  Widget build(BuildContext context) {
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
  }
}
