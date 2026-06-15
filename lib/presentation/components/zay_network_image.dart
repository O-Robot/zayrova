import 'package:flutter/material.dart';
import 'package:zayrova/core/constants/colors.dart';

class ZayNetworkImage extends StatelessWidget {
  const ZayNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius = BorderRadius.zero,
    this.placeholderIcon = Icons.broken_image,
  });

  final String? imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius borderRadius;
  final IconData placeholderIcon;

  @override
  Widget build(BuildContext context) {
    final imageUrl = this.imageUrl;

    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        width: width,
        height: height,
        child: imageUrl == null || imageUrl.isEmpty
            ? _ImageFallback(icon: placeholderIcon)
            : Image.network(
                imageUrl,
                fit: fit,
                width: width,
                height: height,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) {
                    return child;
                  }

                  return const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: ZayColors.primary,
                    ),
                  );
                },
                errorBuilder: (_, __, ___) {
                  return _ImageFallback(icon: placeholderIcon);
                },
              ),
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ZayColors.cancel,
      child: Center(
        child: Icon(
          icon,
          color: ZayColors.textSecondary,
          size: 32,
        ),
      ),
    );
  }
}
