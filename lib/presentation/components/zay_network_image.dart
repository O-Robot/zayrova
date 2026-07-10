import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
    this.placeholderAssetIcon,
  }) : assert(
         placeholderIcon != null || placeholderAssetIcon != null,
         'Either placeholderIcon or placeholderAssetIcon must be provided.',
       );

  final String? imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius borderRadius;
  final IconData? placeholderIcon;
  final String? placeholderAssetIcon;

  @override
  Widget build(BuildContext context) {
    final imageUrl = this.imageUrl;

    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        width: width,
        height: height,
        child: imageUrl == null || imageUrl.isEmpty
            ? _ImageFallback(
                icon: placeholderIcon,
                assetIcon: placeholderAssetIcon,
              )
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
                  return _ImageFallback(
                    icon: placeholderIcon,
                    assetIcon: placeholderAssetIcon,
                  );
                },
              ),
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback({this.icon, this.assetIcon})
    : assert(
        icon != null || assetIcon != null,
        'Either icon or assetIcon must be provided.',
      );

  final IconData? icon;
  final String? assetIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ZayColors.cancel,
      child: Center(
        child:
            assetIcon != null
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: SvgPicture.asset(
                      assetIcon!,
                      colorFilter: const ColorFilter.mode(
                        ZayColors.textSecondary,
                        BlendMode.srcIn,
                      ),
                    ),
                  )
                : Icon(
                    icon,
                    color: ZayColors.textSecondary,
                    size: 32,
                  ),
      ),
    );
  }
}
