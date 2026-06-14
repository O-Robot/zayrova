import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/core/themes/zay_theme.dart';
import 'package:zayrova/domain/entities/product_entity.dart';
import 'package:zayrova/presentation/providers/feature/cart_controller.dart';
import 'package:zayrova/presentation/providers/feature/catalog_controller.dart';
import 'package:zayrova/presentation/routes/zay_router.dart';

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
    await ref.read(cartControllerProvider.notifier).addToCart(
      userId: temporaryDummyJsonCartUserId,
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
      SnackBar(
        content: Text(message),
        backgroundColor: ZayColors.primary,
      ),
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
    final product = catalogState.selectedProduct;
    final isCurrentProduct = product?.id == widget.productId;
    final shouldShowLoading = catalogState.isLoading || !isCurrentProduct;
    final shouldShowError = catalogState.hasError && !isCurrentProduct;

    if (shouldShowError) {
      return _ProductDetailsStateScaffold(
        child: _ProductDetailsErrorState(
          message: catalogState.errorMessage ?? 'Unable to load product.',
          onRetry: _loadProduct,
        ),
      );
    }

    if (shouldShowLoading || product == null) {
      return const _ProductDetailsStateScaffold(
        child: _ProductDetailsLoadingState(),
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
      onToggleExpanded: () => setState(() => _isExpanded = !_isExpanded),
      onImageSelected: (index) => setState(() => _selectedImageIndex = index),
      onSizeSelected: (index) => setState(() => _selectedSizeIndex = index),
      onColorSelected: (index) => setState(() => _selectedColorIndex = index),
      onQuantityChanged: (quantity) => setState(() => _quantity = quantity),
      onAddToCart: () => _addToCart(product),
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
    required this.onToggleExpanded,
    required this.onImageSelected,
    required this.onSizeSelected,
    required this.onColorSelected,
    required this.onQuantityChanged,
    required this.onAddToCart,
  });

  final Product product;
  final bool isExpanded;
  final int selectedImageIndex;
  final int selectedSizeIndex;
  final int selectedColorIndex;
  final int quantity;
  final bool isAddingToCart;
  final VoidCallback onToggleExpanded;
  final ValueChanged<int> onImageSelected;
  final ValueChanged<int> onSizeSelected;
  final ValueChanged<int> onColorSelected;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    final images = _productImages(product);
    final activeImageIndex =
        selectedImageIndex >= images.length ? 0 : selectedImageIndex;
    final activeImage = images.isNotEmpty ? images[activeImageIndex] : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      bottomNavigationBar: _AddToCart(
        product: product,
        quantity: quantity,
        isAddingToCart: isAddingToCart,
        onQuantityChanged: onQuantityChanged,
        onAddToCart: onAddToCart,
      ),
      body: Stack(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _MainProductImage(imageUrl: activeImage),
              ],
            ),
          ),
          const _ProductTopBar(),
          Positioned(
            top: 350,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              decoration: const BoxDecoration(
                color: ZayColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (images.isNotEmpty)
                      _ProductThumbnailList(
                        images: images,
                        selectedImageIndex: activeImageIndex,
                        onImageSelected: onImageSelected,
                      ),
                    const SizedBox(height: 16),
                    _ProductTitleAndRating(product: product),
                    const SizedBox(height: 8),
                    _ProductMeta(product: product),
                    const SizedBox(height: 12),
                    _ProductDescription(
                      description: product.description,
                      isExpanded: isExpanded,
                      onToggleExpanded: onToggleExpanded,
                    ),
                    if (product.availableSizes.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _OptionChips(
                        title: 'Variation',
                        options: product.availableSizes,
                        selectedIndex: selectedSizeIndex,
                        onSelected: onSizeSelected,
                      ),
                    ],
                    if (product.availableColors.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _OptionChips(
                        title: 'Select Colour',
                        options: product.availableColors,
                        selectedIndex: selectedColorIndex,
                        onSelected: onColorSelected,
                      ),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
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

class _MainProductImage extends StatelessWidget {
  const _MainProductImage({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final imageUrl = this.imageUrl;

    if (imageUrl == null || imageUrl.isEmpty) {
      return const SizedBox(
        height: 400,
        child: Center(child: Icon(Icons.broken_image)),
      );
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      height: 400,
      width: double.infinity,
      errorBuilder: (_, __, ___) {
        return const Center(child: Icon(Icons.broken_image));
      },
      loadingBuilder: (context, child, progress) {
        return progress == null
            ? child
            : const Center(
                child: CircularProgressIndicator(color: ZayColors.primary),
              );
      },
    );
  }
}

class _ProductTopBar extends StatelessWidget {
  const _ProductTopBar();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => ZayRouter.goBack(),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: ZayColors.white,
                ),
                child: const Icon(
                  Icons.chevron_left,
                  color: ZayColors.primary,
                ),
              ),
            ),
            Text(
              'Product Details',
              style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
                color: ZayColors.white,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: ZayColors.white,
              ),
              child: const Icon(
                Icons.favorite_border,
                color: ZayColors.secondary,
              ),
            ),
          ],
        ),
      ),
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
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => onImageSelected(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                border: Border.all(
                  color: selectedImageIndex == index
                      ? ZayColors.secondary
                      : ZayColors.inputBorder,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  images[index],
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return const Icon(Icons.broken_image, size: 24);
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProductTitleAndRating extends StatelessWidget {
  const _ProductTitleAndRating({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            product.title,
            style: ZayTheme.lightTheme.textTheme.bodyLarge?.copyWith(
              color: ZayColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Row(
          children: [
            const Icon(Icons.star, color: ZayColors.secondary, size: 20),
            const SizedBox(width: 4),
            Text((product.rating ?? 0).toStringAsFixed(1)),
          ],
        ),
      ],
    );
  }
}

class _ProductMeta extends StatelessWidget {
  const _ProductMeta({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final meta = <String>[
      if (product.brand != null && product.brand!.isNotEmpty) product.brand!,
      if (product.categoryName != null && product.categoryName!.isNotEmpty)
        product.categoryName!,
      if (product.stockQuantity != null) '${product.stockQuantity} in stock',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '\$${product.price.toStringAsFixed(2)}',
          style: ZayTheme.lightTheme.textTheme.titleLarge?.copyWith(
            color: ZayColors.primary,
          ),
        ),
        if (meta.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            meta.join(' • '),
            style: ZayTheme.lightTheme.textTheme.displayMedium?.copyWith(
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product Details',
          style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
            color: ZayColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        AnimatedCrossFade(
          crossFadeState:
              isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
          firstChild: Text(
            description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          secondChild: Text(description),
        ),
        GestureDetector(
          onTap: onToggleExpanded,
          child: Text(
            isExpanded ? 'Read less' : 'Read more',
            style: ZayTheme.lightTheme.textTheme.displayMedium?.copyWith(
              color: ZayColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _OptionChips extends StatelessWidget {
  const _OptionChips({
    required this.title,
    required this.options,
    required this.selectedIndex,
    required this.onSelected,
  });

  final String title;
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
            color: ZayColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(options.length, (index) {
            final isSelected = index == selectedIndex;

            return GestureDetector(
              onTap: () => onSelected(index),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? ZayColors.primary : ZayColors.cancel,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  options[index],
                  style: ZayTheme.lightTheme.textTheme.displayMedium?.copyWith(
                    color: isSelected ? ZayColors.white : ZayColors.textPrimary,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
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
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: ZayColors.textSecondary),
            ),
            child: const Icon(
              Icons.chevron_left,
              color: ZayColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Text(
              'Product Details',
              style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
                color: ZayColors.textPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }
}

class _ProductDetailsLoadingState extends StatelessWidget {
  const _ProductDetailsLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: ZayColors.primary),
    );
  }
}

class _ProductDetailsErrorState extends StatelessWidget {
  const _ProductDetailsErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              color: ZayColors.primary,
              size: 42,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: ZayTheme.lightTheme.textTheme.displayLarge,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => onRetry(),
              child: Text(
                'Retry',
                style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
                  color: ZayColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MissingProductIdState extends StatelessWidget {
  const _MissingProductIdState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Product details are unavailable because the product id is missing or invalid.',
          textAlign: TextAlign.center,
          style: ZayTheme.lightTheme.textTheme.displayLarge,
        ),
      ),
    );
  }
}

class _AddToCart extends StatelessWidget {
  const _AddToCart({
    required this.product,
    required this.quantity,
    required this.isAddingToCart,
    required this.onQuantityChanged,
    required this.onAddToCart,
  });

  final Product product;
  final int quantity;
  final bool isAddingToCart;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    final total = product.price * quantity;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: ZayColors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(80), blurRadius: 10),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Price',
                style: ZayTheme.lightTheme.textTheme.displayMedium?.copyWith(
                  color: ZayColors.textSecondary,
                ),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
                  color: ZayColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _QuantitySelector(
                quantity: quantity,
                onChanged: onQuantityChanged,
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: isAddingToCart ? null : onAddToCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isAddingToCart
                      ? ZayColors.primary.withAlpha(80)
                      : ZayColors.primary,
                  fixedSize: const Size(190, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: isAddingToCart
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: ZayColors.white,
                        ),
                      )
                    : const Icon(
                        Icons.shopping_bag_outlined,
                        color: ZayColors.white,
                        size: 20,
                      ),
                label: Text(
                  isAddingToCart ? 'Adding...' : 'Add to Cart',
                  style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
                    color: isAddingToCart
                        ? ZayColors.textSecondary
                        : ZayColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  const _QuantitySelector({
    required this.quantity,
    required this.onChanged,
  });

  final int quantity;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ZayColors.cancel,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QuantityButton(
            icon: Icons.remove,
            onTap: quantity > 1 ? () => onChanged(quantity - 1) : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '$quantity',
              style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
                color: ZayColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _QuantityButton(
            icon: Icons.add,
            onTap: () => onChanged(quantity + 1),
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
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(
          icon,
          size: 18,
          color: onTap == null ? ZayColors.textSecondary : ZayColors.primary,
        ),
      ),
    );
  }
}
