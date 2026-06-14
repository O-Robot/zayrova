import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/core/themes/zay_theme.dart';
import 'package:zayrova/domain/entities/product_entity.dart';
import 'package:zayrova/presentation/components/product_card.dart';
import 'package:zayrova/presentation/components/top_navigation.dart';
import 'package:zayrova/presentation/providers/feature/catalog_controller.dart';
import 'package:zayrova/presentation/routes/zay_router.dart';
import 'package:zayrova/presentation/routes/zay_routes.dart';

class CategoryScreen extends ConsumerStatefulWidget {
  const CategoryScreen({
    super.key,
    this.categorySlug,
    this.categoryName,
  });

  final String? categorySlug;
  final String? categoryName;

  @override
  ConsumerState<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends ConsumerState<CategoryScreen> {
  String? _requestedCategorySlug;

  String? get _safeCategorySlug {
    final categorySlug = widget.categorySlug;
    if (categorySlug == null || categorySlug.trim().isEmpty) {
      return null;
    }

    return categorySlug.trim();
  }

  String get _categoryTitle {
    final categoryName = widget.categoryName;
    if (categoryName == null || categoryName.trim().isEmpty) {
      return 'Category';
    }

    return categoryName.trim();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCategory());
  }

  Future<void> _loadCategory() async {
    final categorySlug = _safeCategorySlug;
    if (categorySlug == null) {
      return;
    }

    setState(() {
      _requestedCategorySlug = categorySlug;
    });

    await ref
        .read(catalogControllerProvider.notifier)
        .loadProductsByCategory(categorySlug);
  }

  @override
  Widget build(BuildContext context) {
    final categorySlug = _safeCategorySlug;
    final catalogState = ref.watch(catalogControllerProvider);

    return Scaffold(
      appBar: null,
      backgroundColor: ZayColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TopNavigation(text: _categoryTitle),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _FilterPlaceholderButton(
                onTap: () => ZayRouter.goto(ZayRoutes.filter),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _CategoryBody(
                categorySlug: categorySlug,
                requestedCategorySlug: _requestedCategorySlug,
                state: catalogState,
                onRetry: _loadCategory,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryBody extends StatelessWidget {
  const _CategoryBody({
    required this.categorySlug,
    required this.requestedCategorySlug,
    required this.state,
    required this.onRetry,
  });

  final String? categorySlug;
  final String? requestedCategorySlug;
  final CatalogState state;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    if (categorySlug == null) {
      return const _CategoryMessageState(
        icon: Icons.category_outlined,
        message: 'Category products are unavailable because the category is missing.',
      );
    }

    final isCurrentCategoryRequest = requestedCategorySlug == categorySlug;

    if (!isCurrentCategoryRequest ||
        (state.isLoading && !state.hasLoadedCategoryProducts)) {
      return const _CategoryLoadingState();
    }

    if (state.hasError && !state.hasLoadedCategoryProducts) {
      return _CategoryErrorState(
        message: state.errorMessage ?? 'Unable to load category products.',
        onRetry: onRetry,
      );
    }

    if (state.isCategoryProductsEmpty) {
      return const _CategoryMessageState(
        icon: Icons.inventory_2_outlined,
        message: 'No products found in this category yet.',
      );
    }

    return RefreshIndicator(
      color: ZayColors.primary,
      onRefresh: onRetry,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
        child: Column(
          children: [
            if (state.hasError)
              _InlineCategoryError(
                message: state.errorMessage ?? 'Unable to refresh category.',
                onRetry: onRetry,
              ),
            _CategoryProductGrid(products: state.categoryProducts),
          ],
        ),
      ),
    );
  }
}

class _CategoryProductGrid extends StatelessWidget {
  const _CategoryProductGrid({required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const _CategoryMessageState(
        icon: Icons.inventory_2_outlined,
        message: 'No products found in this category yet.',
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        final cardWidth = (constraints.maxWidth - spacing) / 2;

        return Wrap(
          spacing: spacing,
          runSpacing: 16,
          children: products.map((product) {
            return ProductCard.fromProduct(
              product: product,
              width: cardWidth,
              action: () => ZayRouter.goto(ZayRoutes.productDetails, {
                'productId': product.id,
              }),
              onFavoriteToggle: () {},
            );
          }).toList(),
        );
      },
    );
  }
}

class _FilterPlaceholderButton extends StatelessWidget {
  const _FilterPlaceholderButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: ZayColors.white,
            border: Border.all(color: ZayColors.inputBorder),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.tune, color: ZayColors.primary, size: 18),
              const SizedBox(width: 6),
              Text(
                'Filter',
                style: ZayTheme.lightTheme.textTheme.displayMedium?.copyWith(
                  color: ZayColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InlineCategoryError extends StatelessWidget {
  const _InlineCategoryError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: ZayColors.cancel,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: ZayTheme.lightTheme.textTheme.displayMedium?.copyWith(
                color: ZayColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () => onRetry(),
              child: Text(
                'Retry',
                style: ZayTheme.lightTheme.textTheme.displayMedium?.copyWith(
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

class _CategoryLoadingState extends StatelessWidget {
  const _CategoryLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: ZayColors.primary),
    );
  }
}

class _CategoryErrorState extends StatelessWidget {
  const _CategoryErrorState({
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

class _CategoryMessageState extends StatelessWidget {
  const _CategoryMessageState({
    required this.icon,
    required this.message,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: ZayColors.primary, size: 42),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: ZayTheme.lightTheme.textTheme.displayLarge,
            ),
          ],
        ),
      ),
    );
  }
}
