import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zayrova/core/constants/assets.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/core/themes/zay_theme.dart';
import 'package:zayrova/domain/entities/product_entity.dart';
import 'package:zayrova/presentation/components/empty_state.dart';
import 'package:zayrova/presentation/components/error_state.dart';
import 'package:zayrova/presentation/components/loading_state.dart';
import 'package:zayrova/presentation/components/product_card.dart';
import 'package:zayrova/presentation/providers/feature/catalog_controller.dart';
import 'package:zayrova/presentation/providers/feature/wishlist_controller.dart';
import 'package:zayrova/presentation/pages/search/catalog_filter.dart';
import 'package:zayrova/presentation/routes/zay_router.dart';
import 'package:zayrova/presentation/routes/zay_routes.dart';

class AllProductsScreen extends ConsumerStatefulWidget {
  const AllProductsScreen({super.key});

  @override
  ConsumerState<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends ConsumerState<AllProductsScreen> {
  CatalogFilterValues _filters = const CatalogFilterValues();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProducts());
  }

  Future<void> _loadProducts() async {
    await ref.read(catalogControllerProvider.notifier).loadProducts(limit: 100);
  }

  Future<void> _openFilters() async {
    final result = await ZayRouter.goto(ZayRoutes.filter, {
      'filters': _filters.toMap(),
    });

    if (!mounted || result is! Map) {
      return;
    }

    setState(() => _filters = CatalogFilterValues.fromMap(result));
  }

  @override
  Widget build(BuildContext context) {
    final catalogState = ref.watch(catalogControllerProvider);
    final products = _filters.applyTo(catalogState.products);

    return Scaffold(
      appBar: null,
      backgroundColor: ZayColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CatalogHeader(
              onSearch: () => ZayRouter.goto(ZayRoutes.search),
              onFilter: _openFilters,
            ),
            const SizedBox(height: 22),
            _CatalogSortChips(
              selectedSort: _sortFromFilter(_filters.sort),
              onChanged: (sort) {
                setState(() {
                  _filters = _filters.copyWith(
                    sort: _filterSortFromCatalog(sort),
                  );
                });
              },
            ),
            const SizedBox(height: 22),
            Expanded(
              child: _CatalogBody(
                state: catalogState,
                products: products,
                hasActiveFilters: _filters.hasActiveFilters,
                onRetry: _loadProducts,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CatalogHeader extends StatelessWidget {
  const _CatalogHeader({
    required this.onSearch,
    required this.onFilter,
  });

  final VoidCallback onSearch;
  final VoidCallback onFilter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                  'All Products',
                  textAlign: TextAlign.center,
                  style: ZayTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    color: ZayColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 42),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onSearch,
                  child: Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      color: ZayColors.white,
                      border: Border.all(color: ZayColors.inputBorder),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          ZayIcons.searchIcon,
                          width: 28,
                          height: 28,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            'Search products',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: ZayTheme.lightTheme.textTheme.displayLarge
                                ?.copyWith(color: ZayColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: onFilter,
                child: Container(
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    color: ZayColors.white,
                    border: Border.all(color: ZayColors.inputBorder),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.tune,
                    color: ZayColors.textPrimary,
                    size: 28,
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

class _CatalogSortChips extends StatelessWidget {
  const _CatalogSortChips({
    required this.selectedSort,
    required this.onChanged,
  });

  final _CatalogSortOption selectedSort;
  final ValueChanged<_CatalogSortOption> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: _CatalogSortOption.values.map((sort) {
          final selected = sort == selectedSort;

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => onChanged(sort),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: selected ? ZayColors.primary : ZayColors.white,
                  border: Border.all(
                    color:
                        selected ? ZayColors.primary : ZayColors.inputBorder,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  sort.label,
                  style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
                    color:
                        selected ? ZayColors.white : ZayColors.textSecondary,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CatalogBody extends StatelessWidget {
  const _CatalogBody({
    required this.state,
    required this.products,
    required this.hasActiveFilters,
    required this.onRetry,
  });

  final CatalogState state;
  final List<Product> products;
  final bool hasActiveFilters;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && !state.hasLoadedProducts) {
      return const LoadingStateWidget(message: 'Loading products...');
    }

    if (state.hasError && !state.hasLoadedProducts) {
      return ErrorStateWidget(
        title: 'Products unavailable',
        message: state.errorMessage ?? 'Unable to load products.',
        onRetry: () => onRetry(),
      );
    }

    if (products.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.inventory_2_outlined,
        title: hasActiveFilters ? 'No matching products' : 'No products found',
        message: hasActiveFilters
            ? 'Try adjusting or resetting your filters.'
            : 'There are no products available right now.',
        actionText: 'Retry',
        onAction: () => onRetry(),
      );
    }

    return RefreshIndicator(
      color: ZayColors.primary,
      onRefresh: onRetry,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (state.hasError)
              _InlineCatalogError(
                message: state.errorMessage ?? 'Unable to refresh products.',
                onRetry: onRetry,
              ),
            _CatalogSummary(products: products),
            const SizedBox(height: 28),
            _CatalogProductGrid(products: products),
          ],
        ),
      ),
    );
  }
}

class _CatalogSummary extends StatelessWidget {
  const _CatalogSummary({required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: ZayColors.cancel,
            shape: BoxShape.circle,
            border: Border.all(color: ZayColors.inputBorder.withAlpha(80)),
          ),
          child: const Icon(
            Icons.shopping_bag_outlined,
            color: ZayColors.primary,
            size: 34,
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Zayrova Catalog',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ZayTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                  color: ZayColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${products.length} Products',
                style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
                  color: ZayColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const Icon(
          Icons.chevron_right,
          color: ZayColors.textSecondary,
          size: 32,
        ),
      ],
    );
  }
}

class _CatalogProductGrid extends StatelessWidget {
  const _CatalogProductGrid({required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 18.0;
        final cardWidth = (constraints.maxWidth - spacing) / 2;

        return Wrap(
          spacing: spacing,
          runSpacing: 28,
          children: products.map((product) {
            return Consumer(
              builder: (context, ref, _) {
                final wishlist = ref.watch(wishlistControllerProvider);

                return ProductCard.fromProduct(
                  product: product,
                  width: cardWidth,
                  variant: ProductCardVariant.compact,
                  isFavorite: wishlist.contains(product.id),
                  action: () => ZayRouter.goto(ZayRoutes.productDetails, {
                    'productId': product.id,
                  }),
                  onFavoriteToggle: () {
                    ref
                        .read(wishlistControllerProvider.notifier)
                        .toggleProduct(product);
                  },
                );
              },
            );
          }).toList(),
        );
      },
    );
  }
}

class _InlineCatalogError extends StatelessWidget {
  const _InlineCatalogError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
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

enum _CatalogSortOption {
  all('All'),
  latest('Latest'),
  mostPopular('Most Popular'),
  cheapest('Cheapest');

  const _CatalogSortOption(this.label);

  final String label;
}

_CatalogSortOption _sortFromFilter(CatalogFilterSort sort) {
  switch (sort) {
    case CatalogFilterSort.recommended:
      return _CatalogSortOption.all;
    case CatalogFilterSort.newest:
      return _CatalogSortOption.latest;
    case CatalogFilterSort.highestRated:
      return _CatalogSortOption.mostPopular;
    case CatalogFilterSort.priceLowToHigh:
      return _CatalogSortOption.cheapest;
    case CatalogFilterSort.priceHighToLow:
      return _CatalogSortOption.all;
  }
}

CatalogFilterSort _filterSortFromCatalog(_CatalogSortOption sort) {
  switch (sort) {
    case _CatalogSortOption.all:
      return CatalogFilterSort.recommended;
    case _CatalogSortOption.latest:
      return CatalogFilterSort.newest;
    case _CatalogSortOption.mostPopular:
      return CatalogFilterSort.highestRated;
    case _CatalogSortOption.cheapest:
      return CatalogFilterSort.priceLowToHigh;
  }
}
