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
import 'package:zayrova/presentation/pages/search/catalog_filter.dart';
import 'package:zayrova/presentation/providers/feature/catalog_controller.dart';
import 'package:zayrova/presentation/providers/feature/wishlist_controller.dart';
import 'package:zayrova/presentation/routes/zay_router.dart';
import 'package:zayrova/presentation/routes/zay_routes.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _submittedQuery = '';
  CatalogFilterValues _filters = const CatalogFilterValues();

  bool get _hasSearched => _submittedQuery.isNotEmpty;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _searchFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submitSearch([String? value]) async {
    final query = (value ?? _searchController.text).trim();
    if (query.isEmpty) {
      setState(() => _submittedQuery = '');
      return;
    }

    setState(() {
      _submittedQuery = query;
    });
    await ref.read(catalogControllerProvider.notifier).searchProducts(query);
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
    final results = _filters.applyTo(catalogState.searchResults);

    return Scaffold(
      appBar: null,
      backgroundColor: ZayColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SearchHeader(
              controller: _searchController,
              focusNode: _searchFocusNode,
              hasSearched: _hasSearched,
              onSubmitted: _submitSearch,
              onFilterTap: _openFilters,
            ),
            Expanded(
              child: _SearchBody(
                state: catalogState,
                query: _submittedQuery,
                hasSearched: _hasSearched,
                products: results,
                hasActiveFilters: _filters.hasActiveFilters,
                selectedSort: _sortFromFilter(_filters.sort),
                onSortChanged: (sort) {
                  setState(() {
                    _filters = _filters.copyWith(
                      sort: _filterSortFromSearch(sort),
                    );
                  });
                },
                onRetry: _submitSearch,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchHeader extends StatelessWidget {
  const _SearchHeader({
    required this.controller,
    required this.focusNode,
    required this.hasSearched,
    required this.onSubmitted,
    required this.onFilterTap,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasSearched;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => ZayRouter.goBack(),
            behavior: HitTestBehavior.opaque,
            child: const SizedBox(
              width: 42,
              height: 56,
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
            child: _SearchField(
              controller: controller,
              focusNode: focusNode,
              showFilter: hasSearched,
              onSubmitted: onSubmitted,
              onFilterTap: onFilterTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.showFilter,
    required this.onSubmitted,
    required this.onFilterTap,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool showFilter;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: focusNode,
      builder: (context, _) {
        final isFocused = focusNode.hasFocus;

        return Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: ZayColors.white,
            border: Border.all(
              color: isFocused ? ZayColors.primary : ZayColors.inputBorder,
              width: isFocused ? 1.6 : 1,
            ),
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
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  textInputAction: TextInputAction.search,
                  onSubmitted: onSubmitted,
                  style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
                    color: ZayColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: '',
                    border: InputBorder.none,
                    isCollapsed: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 2),
                    hintStyle: ZayTheme.lightTheme.textTheme.displayLarge
                        ?.copyWith(color: ZayColors.textSecondary),
                  ),
                ),
              ),
              if (showFilter)
                GestureDetector(
                  onTap: onFilterTap,
                  child: const Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: Icon(
                      Icons.tune,
                      color: ZayColors.textPrimary,
                      size: 28,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _SearchBody extends StatelessWidget {
  const _SearchBody({
    required this.state,
    required this.query,
    required this.hasSearched,
    required this.products,
    required this.hasActiveFilters,
    required this.selectedSort,
    required this.onSortChanged,
    required this.onRetry,
  });

  final CatalogState state;
  final String query;
  final bool hasSearched;
  final List<Product> products;
  final bool hasActiveFilters;
  final _SearchSortOption selectedSort;
  final ValueChanged<_SearchSortOption> onSortChanged;
  final Future<void> Function([String? value]) onRetry;

  @override
  Widget build(BuildContext context) {
    if (!hasSearched) {
      return const _SearchLandingState();
    }

    if (state.isLoading && !state.hasLoadedSearchResults) {
      return const LoadingStateWidget(message: 'Searching products...');
    }

    if (state.hasError && !state.hasLoadedSearchResults) {
      return ErrorStateWidget(
        title: 'Search unavailable',
        message: state.errorMessage ?? 'Unable to search products.',
        onRetry: () => onRetry(),
      );
    }

    if (state.isSearchEmpty || products.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.search_off_rounded,
        title: hasActiveFilters ? 'No matching results' : 'No results found',
        message: hasActiveFilters
            ? 'No products match "$query" with the selected filters.'
            : 'No products found for "$query".',
        actionText: 'Retry',
        onAction: () => onRetry(),
      );
    }

    return RefreshIndicator(
      color: ZayColors.primary,
      onRefresh: () => onRetry(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SearchSortChips(
              selectedSort: selectedSort,
              onChanged: onSortChanged,
            ),
            const SizedBox(height: 28),
            if (state.hasError)
              _InlineSearchError(
                message: state.errorMessage ?? 'Unable to refresh search.',
                onRetry: onRetry,
              ),
            _SearchSummary(query: query, products: products),
            const SizedBox(height: 28),
            _SearchResultGrid(products: products),
          ],
        ),
      ),
    );
  }
}

class _SearchLandingState extends StatelessWidget {
  const _SearchLandingState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search',
            style: ZayTheme.lightTheme.textTheme.titleLarge?.copyWith(
              color: ZayColors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Enter a product name, brand, or category to start browsing.',
            style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
              color: ZayColors.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchSortChips extends StatelessWidget {
  const _SearchSortChips({
    required this.selectedSort,
    required this.onChanged,
  });

  final _SearchSortOption selectedSort;
  final ValueChanged<_SearchSortOption> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: _SearchSortOption.values.map((sort) {
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

class _SearchSummary extends StatelessWidget {
  const _SearchSummary({
    required this.query,
    required this.products,
  });

  final String query;
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
            Icons.search_rounded,
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
                query,
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

class _SearchResultGrid extends StatelessWidget {
  const _SearchResultGrid({required this.products});

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

class _InlineSearchError extends StatelessWidget {
  const _InlineSearchError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function([String? value]) onRetry;

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

enum _SearchSortOption {
  all('All'),
  latest('Latest'),
  mostPopular('Most Popular'),
  cheapest('Cheapest');

  const _SearchSortOption(this.label);

  final String label;
}

_SearchSortOption _sortFromFilter(CatalogFilterSort sort) {
  switch (sort) {
    case CatalogFilterSort.recommended:
      return _SearchSortOption.all;
    case CatalogFilterSort.newest:
      return _SearchSortOption.latest;
    case CatalogFilterSort.highestRated:
      return _SearchSortOption.mostPopular;
    case CatalogFilterSort.priceLowToHigh:
      return _SearchSortOption.cheapest;
    case CatalogFilterSort.priceHighToLow:
      return _SearchSortOption.all;
  }
}

CatalogFilterSort _filterSortFromSearch(_SearchSortOption sort) {
  switch (sort) {
    case _SearchSortOption.all:
      return CatalogFilterSort.recommended;
    case _SearchSortOption.latest:
      return CatalogFilterSort.newest;
    case _SearchSortOption.mostPopular:
      return CatalogFilterSort.highestRated;
    case _SearchSortOption.cheapest:
      return CatalogFilterSort.priceLowToHigh;
  }
}
