// widgets/product_card.dart

import 'package:flutter/material.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/core/constants/currency.dart';
import 'package:zayrova/core/constants/extensions.dart';
import 'package:zayrova/core/themes/zay_theme.dart';
import 'package:zayrova/domain/entities/product_entity.dart';
import 'package:zayrova/presentation/components/zay_network_image.dart';

enum ProductCardVariant { compact, standard, horizontal }

class ProductCard extends StatelessWidget {
  final String imagePath;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final String price;
  final String? oldPrice;
  final String title;
  final double rating;
  final VoidCallback action;
  final double width;
  final String currencyCode;
  final bool showRating;
  final String? discountLabel;
  final ProductCardVariant variant;

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
    this.discountLabel,
    this.variant = ProductCardVariant.standard,
  });

  const ProductCard.compact({
    super.key,
    required this.imagePath,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.price,
    this.oldPrice,
    required this.title,
    required this.rating,
    required this.action,
    this.width = 148,
    this.currencyCode = r'$',
    this.showRating = true,
    this.discountLabel,
  }) : variant = ProductCardVariant.compact;

  const ProductCard.horizontal({
    super.key,
    required this.imagePath,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.price,
    this.oldPrice,
    required this.title,
    required this.rating,
    required this.action,
    this.width = double.infinity,
    this.currencyCode = r'$',
    this.showRating = true,
    this.discountLabel,
  }) : variant = ProductCardVariant.horizontal;

  factory ProductCard.fromProduct({
    Key? key,
    required Product product,
    required VoidCallback action,
    required VoidCallback onFavoriteToggle,
    bool? isFavorite,
    double width = 170,
    ProductCardVariant variant = ProductCardVariant.standard,
  }) {
    final imagePath =
        product.thumbnailUrl ??
        (product.imageUrls.isNotEmpty ? product.imageUrls.first : '');
    final discount = product.discountPercentage;
    final oldPrice = discount != null && discount > 0 && discount < 100
        ? (product.price / (1 - (discount / 100))).toStringAsFixed(2)
        : null;
    final discountLabel =
        discount != null && discount > 0 ? '-${discount.toStringAsFixed(0)}%' : null;

    return ProductCard(
      key: key,
      imagePath: imagePath,
      isFavorite: isFavorite ?? product.isFavorite,
      onFavoriteToggle: onFavoriteToggle,
      price: product.price.toStringAsFixed(2),
      oldPrice: oldPrice,
      title: product.title,
      rating: product.rating ?? 0,
      action: action,
      width: width,
      currencyCode: currencySymbol(product.currencyCode),
      showRating: product.rating != null,
      discountLabel: discountLabel,
      variant: variant,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (variant == ProductCardVariant.horizontal) {
      return _HorizontalProductCard(card: this);
    }

    final isCompact = variant == ProductCardVariant.compact;

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
                  aspectRatio: isCompact ? 1 : 1.05,
                  child: ZayNetworkImage(imageUrl: imagePath),
                ),
                if (discountLabel != null && discountLabel!.isNotEmpty)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: _DiscountBadge(label: discountLabel!),
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
              padding: EdgeInsets.all(isCompact ? 8 : 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.truncate(isCompact ? 24 : 34),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: ZayTheme.lightTheme.textTheme.displayMedium
                        ?.copyWith(
                          color: ZayColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 6),
                  if (showRating && !isCompact)
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
                  if (showRating && !isCompact) const SizedBox(height: 6),
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

class _HorizontalProductCard extends StatelessWidget {
  const _HorizontalProductCard({required this.card});

  final ProductCard card;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: card.action,
      child: Container(
        width: card.width,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: ZayColors.white,
          border: Border.all(color: ZayColors.inputBorder.withAlpha(120)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 86,
              height: 86,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ZayNetworkImage(
                      imageUrl: card.imagePath,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  if (card.discountLabel != null &&
                      card.discountLabel!.isNotEmpty)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: _DiscountBadge(label: card.discountLabel!),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.title.truncate(52),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
                      color: ZayColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (card.showRating)
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 15,
                          color: ZayColors.secondary,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          card.rating.toStringAsFixed(1),
                          style: ZayTheme.lightTheme.textTheme.displaySmall
                              ?.copyWith(color: ZayColors.textSecondary),
                        ),
                      ],
                    ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '${card.currencyCode}${card.price}',
                        style: ZayTheme.lightTheme.textTheme.displayLarge
                            ?.copyWith(
                          color: ZayColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (card.oldPrice != null &&
                          card.oldPrice!.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text(
                          '${card.currencyCode}${card.oldPrice}',
                          style: ZayTheme.lightTheme.textTheme.displaySmall
                              ?.copyWith(
                            color: ZayColors.textSecondary,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: card.onFavoriteToggle,
              icon: Icon(
                card.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: card.isFavorite
                    ? ZayColors.secondary
                    : ZayColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiscountBadge extends StatelessWidget {
  const _DiscountBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: ZayColors.secondary,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: ZayTheme.lightTheme.textTheme.displaySmall?.copyWith(
          color: ZayColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
