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
  final String? oldPrice;
  final String title;
  final double rating;
  final VoidCallback action;
  final double width;
  final String currencyCode;
  final bool showRating;

  const ProductCard({
    super.key,
    required this.imagePath,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.price,
    this.oldPrice,
    required this.title,
    required this.rating,
    required this.action,
    this.width = 170,
    this.currencyCode = r'$',
    this.showRating = true,
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
    final discount = product.discountPercentage;
    final oldPrice = discount != null && discount > 0 && discount < 100
        ? (product.price / (1 - (discount / 100))).toStringAsFixed(2)
        : null;

    return ProductCard(
      key: key,
      imagePath: imagePath,
      isFavorite: product.isFavorite,
      onFavoriteToggle: onFavoriteToggle,
      price: product.price.toStringAsFixed(2),
      oldPrice: oldPrice,
      title: product.title,
      rating: product.rating ?? 0,
      action: action,
      width: width,
      currencyCode: _currencySymbol(product.currencyCode),
      showRating: product.rating != null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: action,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: ZayColors.white,
          border: Border.all(color: ZayColors.inputBorder.withAlpha(120)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(14),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.05,
                  child: imagePath.isEmpty
                      ? const _ProductImageFallback()
                      : Image.network(
                          imagePath,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: ZayColors.primary,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const _ProductImageFallback();
                          },
                        ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onFavoriteToggle,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: ZayColors.white.withAlpha(230),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite
                            ? ZayColors.secondary
                            : ZayColors.textPrimary,
                        size: 18,
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
                  Text(
                    title.truncate(34),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: ZayTheme.lightTheme.textTheme.displayMedium
                        ?.copyWith(
                          color: ZayColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 6),
                  if (showRating)
                    Row(
                      children: [
                        const Icon(
                          size: 15,
                          Icons.star,
                          color: ZayColors.secondary,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          rating.toStringAsFixed(1),
                          style: ZayTheme.lightTheme.textTheme.displaySmall
                              ?.copyWith(color: ZayColors.textSecondary),
                        ),
                      ],
                    ),
                  if (showRating) const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '$currencyCode$price',
                        style: ZayTheme.lightTheme.textTheme.displayLarge
                            ?.copyWith(
                              color: ZayColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                  if (oldPrice != null && oldPrice!.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      '$currencyCode$oldPrice',
                      style: ZayTheme.lightTheme.textTheme.displaySmall
                          ?.copyWith(
                            color: ZayColors.textSecondary,
                            decoration: TextDecoration.lineThrough,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _currencySymbol(String currencyCode) {
  switch (currencyCode.toUpperCase()) {
    case 'USD':
      return r'$';
    default:
      return '$currencyCode ';
  }
}

class _ProductImageFallback extends StatelessWidget {
  const _ProductImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ZayColors.cancel,
      child: const Center(
        child: Icon(
          Icons.broken_image,
          color: ZayColors.textSecondary,
          size: 40,
        ),
      ),
    );
  }
}
