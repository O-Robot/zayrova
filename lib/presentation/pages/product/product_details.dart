import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zayrova/core/constants/assets.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/core/constants/currency.dart';
import 'package:zayrova/core/themes/zay_theme.dart';
import 'package:zayrova/presentation/components/cart_header_button.dart';
import 'package:zayrova/domain/entities/product_entity.dart';
import 'package:zayrova/presentation/components/empty_state.dart';
import 'package:zayrova/presentation/components/error_state.dart';
import 'package:zayrova/presentation/components/loading_state.dart';
import 'package:zayrova/presentation/components/zay_network_image.dart';
import 'package:zayrova/presentation/providers/feature/cart_controller.dart';
import 'package:zayrova/presentation/providers/feature/catalog_controller.dart';
import 'package:zayrova/presentation/providers/feature/wishlist_controller.dart';
import 'package:zayrova/presentation/routes/zay_router.dart';
import 'package:zayrova/presentation/routes/zay_routes.dart';

class ProductDetails extends ConsumerStatefulWidget {
  const ProductDetails({super.key, this.productId});

  final String? productId;

  @override
  ConsumerState<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends ConsumerState<ProductDetails> {
  bool _isExpanded = false;
  int _selectedSizeIndex = 0;
  int _selectedColorIndex = 0;
  int _selectedImageIndex = 0;
  int _quantity = 1;
  bool _isAddingToCart = false;

  int? get _parsedProductId {
    final productId = widget.productId;
    if (productId == null || productId.isEmpty) {
      return null;
    }

    return int.tryParse(productId);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProduct());
  }

  Future<void> _loadProduct() async {
    final parsedProductId = _parsedProductId;
    if (parsedProductId == null) {
      return;
    }

    setState(() {
      _selectedImageIndex = 0;
      _selectedSizeIndex = 0;
      _selectedColorIndex = 0;
    });

    await ref
        .read(catalogControllerProvider.notifier)
        .loadProductDetails(parsedProductId);
  }

  Future<void> _addToCart(Product product) async {
    final productId = int.tryParse(product.id);
    if (productId == null) {
      _showCartSnackBar('Unable to add this product to cart.');
      return;
    }

    setState(() => _isAddingToCart = true);
    await ref
        .read(cartControllerProvider.notifier)
        .addToCurrentUserCart(
          products: [
            {'id': productId, 'quantity': _quantity},
          ],
        );

    if (!mounted) {
      return;
    }

    final cartState = ref.read(cartControllerProvider);
    setState(() => _isAddingToCart = false);

    _showCartSnackBar(
      cartState.hasError
          ? cartState.errorMessage ?? 'Unable to add product to cart.'
          : 'Added to cart.',
    );
  }

  void _showCartSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: ZayColors.primary),
    );
  }

  @override
  Widget build(BuildContext context) {
    final parsedProductId = _parsedProductId;

    if (parsedProductId == null) {
      return const _ProductDetailsStateScaffold(
        child: _MissingProductIdState(),
      );
    }

    final catalogState = ref.watch(catalogControllerProvider);
    final wishlistState = ref.watch(wishlistControllerProvider);
    final product = catalogState.selectedProduct;
    final isCurrentProduct = product?.id == widget.productId;
    final shouldShowLoading = catalogState.isLoading || !isCurrentProduct;
    final shouldShowError = catalogState.hasError && !isCurrentProduct;

    if (shouldShowError) {
      return _ProductDetailsStateScaffold(
        child: ErrorStateWidget(
          title: 'Product unavailable',
          message: catalogState.errorMessage ?? 'Unable to load product.',
          onRetry: _loadProduct,
        ),
      );
    }

    if (shouldShowLoading || product == null) {
      return const _ProductDetailsStateScaffold(
        child: LoadingStateWidget(message: 'Loading product...'),
      );
    }

    return _ProductDetailsContent(
      product: product,
      isExpanded: _isExpanded,
      selectedImageIndex: _selectedImageIndex,
      selectedSizeIndex: _selectedSizeIndex,
      selectedColorIndex: _selectedColorIndex,
      quantity: _quantity,
      isAddingToCart: _isAddingToCart,
      isFavorite: wishlistState.contains(product.id),
      onToggleExpanded: () => setState(() => _isExpanded = !_isExpanded),
      onImageSelected: (index) => setState(() => _selectedImageIndex = index),
      onSizeSelected: (index) => setState(() => _selectedSizeIndex = index),
      onColorSelected: (index) => setState(() => _selectedColorIndex = index),
      onQuantityChanged: (quantity) => setState(() => _quantity = quantity),
      onAddToCart: () => _addToCart(product),
      onFavoriteToggle: () {
        ref.read(wishlistControllerProvider.notifier).toggleProduct(product);
      },
    );
  }
}

class _ProductDetailsContent extends StatelessWidget {
  const _ProductDetailsContent({
    required this.product,
    required this.isExpanded,
    required this.selectedImageIndex,
    required this.selectedSizeIndex,
    required this.selectedColorIndex,
    required this.quantity,
    required this.isAddingToCart,
    required this.isFavorite,
    required this.onToggleExpanded,
    required this.onImageSelected,
    required this.onSizeSelected,
    required this.onColorSelected,
    required this.onQuantityChanged,
    required this.onAddToCart,
    required this.onFavoriteToggle,
  });

  final Product product;
  final bool isExpanded;
  final int selectedImageIndex;
  final int selectedSizeIndex;
  final int selectedColorIndex;
  final int quantity;
  final bool isAddingToCart;
  final bool isFavorite;
  final VoidCallback onToggleExpanded;
  final ValueChanged<int> onImageSelected;
  final ValueChanged<int> onSizeSelected;
  final ValueChanged<int> onColorSelected;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onAddToCart;
  final VoidCallback onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    final images = _productImages(product);
    final activeImageIndex =
        selectedImageIndex >= images.length ? 0 : selectedImageIndex;
    final activeImage = images.isNotEmpty ? images[activeImageIndex] : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      bottomNavigationBar: _BottomActionBar(
        product: product,
        quantity: quantity,
        isAddingToCart: isAddingToCart,
        onAddToCart: onAddToCart,
      ),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _ProductHero(
                  imageUrl: activeImage,
                  images: images,
                  selectedImageIndex: activeImageIndex,
                  onImageSelected: onImageSelected,
                ),
              ),
              SliverToBoxAdapter(
                child: _ProductInfoSheet(
                  product: product,
                  quantity: quantity,
                  isExpanded: isExpanded,
                  selectedSizeIndex: selectedSizeIndex,
                  selectedColorIndex: selectedColorIndex,
                  onToggleExpanded: onToggleExpanded,
                  onSizeSelected: onSizeSelected,
                  onColorSelected: onColorSelected,
                  onQuantityChanged: onQuantityChanged,
                  isFavorite: isFavorite,
                  onFavoriteToggle: onFavoriteToggle,
                ),
              ),
            ],
          ),
          const _ProductTopBar(),
        ],
      ),
    );
  }

  List<String> _productImages(Product product) {
    final images = <String>[];
    final thumbnailUrl = product.thumbnailUrl;

    if (thumbnailUrl != null && thumbnailUrl.isNotEmpty) {
      images.add(thumbnailUrl);
    }

    for (final imageUrl in product.imageUrls) {
      if (imageUrl.isNotEmpty && !images.contains(imageUrl)) {
        images.add(imageUrl);
      }
    }

    return images;
  }
}

class _ProductHero extends StatelessWidget {
  const _ProductHero({
    required this.imageUrl,
    required this.images,
    required this.selectedImageIndex,
    required this.onImageSelected,
  });

  final String? imageUrl;
  final List<String> images;
  final int selectedImageIndex;
  final ValueChanged<int> onImageSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 520,
      child: Stack(
        children: [
          Positioned.fill(
            child: ZayNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholderAssetIcon: ZayIcons.cartIcon,
            ),
          ),
          if (images.length > 1)
            Positioned(
              left: 24,
              right: 24,
              bottom: 36,
              child: _ProductThumbnailList(
                images: images,
                selectedImageIndex: selectedImageIndex,
                onImageSelected: onImageSelected,
              ),
            ),
        ],
      ),
    );
  }
}

class _ProductTopBar extends StatelessWidget {
  const _ProductTopBar();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => ZayRouter.goBack(),
              behavior: HitTestBehavior.opaque,
              child: const SizedBox(
                width: 42,
                height: 42,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Icon(
                    Icons.chevron_left,
                    color: ZayColors.textPrimary,
                    size: 36,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Text(
                'Detail Product',
                textAlign: TextAlign.center,
                style: ZayTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                  color: ZayColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const CartHeaderButton(),
          ],
        ),
      ),
    );
  }
}

class _ProductInfoSheet extends StatelessWidget {
  const _ProductInfoSheet({
    required this.product,
    required this.quantity,
    required this.isExpanded,
    required this.selectedSizeIndex,
    required this.selectedColorIndex,
    required this.onToggleExpanded,
    required this.onSizeSelected,
    required this.onColorSelected,
    required this.onQuantityChanged,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  final Product product;
  final int quantity;
  final bool isExpanded;
  final int selectedSizeIndex;
  final int selectedColorIndex;
  final VoidCallback onToggleExpanded;
  final ValueChanged<int> onSizeSelected;
  final ValueChanged<int> onColorSelected;
  final ValueChanged<int> onQuantityChanged;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -34),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 30, 24, 120),
        decoration: const BoxDecoration(
          color: ZayColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProductTitleRow(
              product: product,
              isFavorite: isFavorite,
              onFavoriteToggle: onFavoriteToggle,
            ),
            const SizedBox(height: 14),
            _RatingRow(product: product),
            const SizedBox(height: 24),
            _ProductDescription(
              description: product.description,
              isExpanded: isExpanded,
              onToggleExpanded: onToggleExpanded,
            ),
            _StoreMeta(product: product),
            const SizedBox(height: 24),
            const Divider(height: 1, color: ZayColors.cancel),
            const SizedBox(height: 24),
            if (product.availableColors.isNotEmpty) ...[
              _ColorSelector(
                colors: product.availableColors,
                selectedIndex: selectedColorIndex,
                onSelected: onColorSelected,
              ),
              const SizedBox(height: 24),
            ],
            if (product.availableSizes.isNotEmpty) ...[
              _SizeSelector(
                sizes: product.availableSizes,
                selectedIndex: selectedSizeIndex,
                onSelected: onSizeSelected,
              ),
              const SizedBox(height: 24),
            ],
            _QuantitySection(
              product: product,
              quantity: quantity,
              onChanged: onQuantityChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductTitleRow extends StatelessWidget {
  const _ProductTitleRow({
    required this.product,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  final Product product;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            product.title,
            style: ZayTheme.lightTheme.textTheme.titleLarge?.copyWith(
              color: ZayColors.textPrimary,
              fontWeight: FontWeight.w900,
              height: 1.18,
            ),
          ),
        ),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: onFavoriteToggle,
          child: Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(
              color: ZayColors.cancel,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? ZayColors.secondary : ZayColors.textPrimary,
              size: 30,
            ),
          ),
        ),
      ],
    );
  }
}

class _RatingRow extends StatelessWidget {
  const _RatingRow({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final rating = product.rating;
    final reviewCount = product.reviewCount;

    return Row(
      children: [
        const Icon(Icons.star, color: ZayColors.secondary, size: 20),
        const SizedBox(width: 8),
        Text(
          rating == null ? 'No rating' : rating.toStringAsFixed(1),
          style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
            color: ZayColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (reviewCount != null) ...[
          const SizedBox(width: 4),
          Text(
            '($reviewCount Review)',
            style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
              color: ZayColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

class _ProductDescription extends StatelessWidget {
  const _ProductDescription({
    required this.description,
    required this.isExpanded,
    required this.onToggleExpanded,
  });

  final String? description;
  final bool isExpanded;
  final VoidCallback onToggleExpanded;

  @override
  Widget build(BuildContext context) {
    final description = this.description;

    if (description == null || description.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: ZayTheme.lightTheme.textTheme.bodyLarge?.copyWith(
              color: ZayColors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          AnimatedCrossFade(
            crossFadeState:
                isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
            firstChild: Text(
              description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
                color: ZayColors.textSecondary,
                height: 1.65,
              ),
            ),
            secondChild: Text(
              description,
              style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
                color: ZayColors.textSecondary,
                height: 1.65,
              ),
            ),
          ),
          GestureDetector(
            onTap: onToggleExpanded,
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                isExpanded ? 'Read Less' : 'Read More',
                style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
                  color: ZayColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoreMeta extends StatelessWidget {
  const _StoreMeta({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final title =
        product.brand?.isNotEmpty == true
            ? product.brand!
            : product.categoryName ?? '';
    final category = product.categoryName;

    if (title.isEmpty && category == null && product.stockQuantity == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: ZayColors.cancel,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.storefront_outlined,
              color: ZayColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title.isNotEmpty)
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
                      color: ZayColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  _metaText(product),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ZayTheme.lightTheme.textTheme.displayMedium?.copyWith(
                    color: ZayColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _metaText(Product product) {
    final meta = <String>[
      if (product.categoryName != null && product.categoryName!.isNotEmpty)
        product.categoryName!,
      if (product.stockQuantity != null) '${product.stockQuantity} in stock',
    ];

    return meta.isEmpty ? 'Product details' : meta.join('  ');
  }
}

class _ColorSelector extends StatelessWidget {
  const _ColorSelector({
    required this.colors,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> colors;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Color',
          style: ZayTheme.lightTheme.textTheme.bodyLarge?.copyWith(
            color: ZayColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 18,
          runSpacing: 12,
          children: List.generate(colors.length, (index) {
            final color = _parseColor(colors[index]);
            final isSelected = index == selectedIndex;

            if (color == null) {
              return _TextOptionChip(
                label: colors[index],
                isSelected: isSelected,
                onTap: () => onSelected(index),
              );
            }

            return GestureDetector(
              onTap: () => onSelected(index),
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? ZayColors.primary : ZayColors.cancel,
                    width: isSelected ? 3 : 1,
                  ),
                ),
                child:
                    isSelected
                        ? const Icon(
                          Icons.check,
                          color: ZayColors.white,
                          size: 26,
                        )
                        : null,
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _SizeSelector extends StatelessWidget {
  const _SizeSelector({
    required this.sizes,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> sizes;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Size',
          style: ZayTheme.lightTheme.textTheme.bodyLarge?.copyWith(
            color: ZayColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: List.generate(sizes.length, (index) {
            return _TextOptionChip(
              label: sizes[index],
              isSelected: index == selectedIndex,
              onTap: () => onSelected(index),
            );
          }),
        ),
      ],
    );
  }
}

class _TextOptionChip extends StatelessWidget {
  const _TextOptionChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? ZayColors.primary : ZayColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? ZayColors.primary : ZayColors.inputBorder,
          ),
        ),
        child: Text(
          label,
          style: ZayTheme.lightTheme.textTheme.displayMedium?.copyWith(
            color: isSelected ? ZayColors.white : ZayColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _QuantitySection extends StatelessWidget {
  const _QuantitySection({
    required this.product,
    required this.quantity,
    required this.onChanged,
  });

  final Product product;
  final int quantity;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final stockQuantity = product.stockQuantity;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose amount :',
                style: ZayTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                  color: ZayColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (stockQuantity != null) ...[
                const SizedBox(height: 8),
                Text(
                  stockQuantity > 0 ? 'Available in stock' : 'Out of stock',
                  style: ZayTheme.lightTheme.textTheme.displayMedium?.copyWith(
                    color: ZayColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        _QuantitySelector(quantity: quantity, onChanged: onChanged),
      ],
    );
  }
}

class _ProductThumbnailList extends StatelessWidget {
  const _ProductThumbnailList({
    required this.images,
    required this.selectedImageIndex,
    required this.onImageSelected,
  });

  final List<String> images;
  final int selectedImageIndex;
  final ValueChanged<int> onImageSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final isSelected = selectedImageIndex == index;

          return GestureDetector(
            onTap: () => onImageSelected(index),
            child: Container(
              width: 72,
              height: 72,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: ZayColors.white,
                border: Border.all(
                  color: isSelected ? ZayColors.primary : ZayColors.white,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ZayNetworkImage(
                imageUrl: images[index],
                borderRadius: BorderRadius.circular(14),
                placeholderAssetIcon: ZayIcons.cartIcon,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({
    required this.product,
    required this.quantity,
    required this.isAddingToCart,
    required this.onAddToCart,
  });

  final Product product;
  final int quantity;
  final bool isAddingToCart;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    final total = product.price * quantity;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 18),
        decoration: BoxDecoration(
          color: ZayColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(18),
              blurRadius: 18,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Price',
                    style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
                      color: ZayColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formatCurrency(total, product.currencyCode),
                    style: ZayTheme.lightTheme.textTheme.titleLarge?.copyWith(
                      color: ZayColors.textPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 18),
            Flexible(
              child: SizedBox(
                height: 58,
                child: ElevatedButton.icon(
                  onPressed: isAddingToCart ? null : onAddToCart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isAddingToCart
                            ? ZayColors.primary.withAlpha(80)
                            : ZayColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  icon:
                      isAddingToCart
                          ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: ZayColors.white,
                            ),
                          )
                          : SvgPicture.asset(
                            ZayIcons.cartIcon,
                            width: 24,
                            height: 24,
                            colorFilter: const ColorFilter.mode(
                              ZayColors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                  label: Text(
                    isAddingToCart ? 'Adding...' : 'Add to Cart',
                    style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
                      color: ZayColors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  const _QuantitySelector({required this.quantity, required this.onChanged});

  final int quantity;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: ZayColors.cancel,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QuantityButton(
            icon: Icons.remove,
            onTap: quantity > 1 ? () => onChanged(quantity - 1) : null,
          ),
          SizedBox(
            width: 38,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: ZayTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                color: ZayColors.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          _QuantityButton(
            icon: Icons.add,
            onTap: () => onChanged(quantity + 1),
            isPrimary: true,
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({
    required this.icon,
    this.onTap,
    this.isPrimary = false,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: isPrimary && enabled ? ZayColors.primary : ZayColors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 20,
          color:
              !enabled
                  ? ZayColors.textSecondary
                  : isPrimary
                  ? ZayColors.white
                  : ZayColors.textPrimary,
        ),
      ),
    );
  }
}

class _ProductDetailsStateScaffold extends StatelessWidget {
  const _ProductDetailsStateScaffold({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZayColors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 18, 24, 0),
              child: _PlainTopBar(),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _PlainTopBar extends StatelessWidget {
  const _PlainTopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => ZayRouter.goBack(),
          behavior: HitTestBehavior.opaque,
          child: const SizedBox(
            width: 42,
            height: 42,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Icon(
                Icons.chevron_left,
                color: ZayColors.textPrimary,
                size: 36,
              ),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Text(
              'Detail Product',
              style: ZayTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                color: ZayColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(width: 42),
      ],
    );
  }
}

class _MissingProductIdState extends StatelessWidget {
  const _MissingProductIdState();

  @override
  Widget build(BuildContext context) {
    return const EmptyStateWidget(
      icon: Icons.inventory_2_outlined,
      title: 'Product unavailable',
      message:
          'Product details are unavailable because the product id is missing or invalid.',
    );
  }
}

Color? _parseColor(String value) {
  final normalized = value.trim().toLowerCase();
  const namedColors = {
    'black': Colors.black,
    'white': Colors.white,
    'red': Colors.red,
    'green': Colors.green,
    'blue': Colors.blue,
    'yellow': Colors.yellow,
    'orange': Colors.orange,
    'purple': Colors.purple,
    'pink': Colors.pink,
    'brown': Colors.brown,
    'grey': Colors.grey,
    'gray': Colors.grey,
  };

  if (namedColors.containsKey(normalized)) {
    return namedColors[normalized];
  }

  final hex = normalized.replaceAll('#', '');
  if (hex.length == 6) {
    final parsedColor = int.tryParse('ff$hex', radix: 16);
    return parsedColor == null ? null : Color(parsedColor);
  }

  if (hex.length == 8) {
    final parsedColor = int.tryParse(hex, radix: 16);
    return parsedColor == null ? null : Color(parsedColor);
  }

  return null;
}
