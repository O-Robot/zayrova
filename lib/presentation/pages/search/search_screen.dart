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

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _submittedQuery = '';

  bool get _hasSearched => _submittedQuery.isNotEmpty;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _submitSearch([String? value]) async {
    final query = (value ?? _searchController.text).trim();
    if (query.isEmpty) {
      setState(() => _submittedQuery = '');
      return;
    }

    setState(() => _submittedQuery = query);
    await ref.read(catalogControllerProvider.notifier).searchProducts(query);
  }

  @override
  Widget build(BuildContext context) {
    final catalogState = ref.watch(catalogControllerProvider);

    return Scaffold(
      appBar: null,
      backgroundColor: ZayColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: TopNavigation(text: 'Search'),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _SearchInput(
                controller: _searchController,
                onSubmitted: _submitSearch,
                onFilterTap: () => ZayRouter.goto(ZayRoutes.filter),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _SearchBody(
                state: catalogState,
                query: _submittedQuery,
                hasSearched: _hasSearched,
                onRetry: _submitSearch,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchInput extends StatelessWidget {
  const _SearchInput({
    required this.controller,
    required this.onSubmitted,
    required this.onFilterTap,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: ZayColors.white,
              border: Border.all(color: ZayColors.inputBorder),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.search,
              onSubmitted: onSubmitted,
              style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
                color: ZayColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search products',
                hintStyle: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
                  color: ZayColors.textSecondary,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: ZayColors.textSecondary,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 13),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onFilterTap,
          child: Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: ZayColors.primary,
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(Icons.tune, color: ZayColors.white),
          ),
        ),
      ],
    );
  }
}

class _SearchBody extends StatelessWidget {
  const _SearchBody({
    required this.state,
    required this.query,
    required this.hasSearched,
    required this.onRetry,
  });

  final CatalogState state;
  final String query;
  final bool hasSearched;
  final Future<void> Function([String? value]) onRetry;

  @override
  Widget build(BuildContext context) {
    if (!hasSearched) {
      return const _SearchMessageState(
        icon: Icons.search,
        message: 'Search for products by name, brand, or category.',
      );
    }

    if (state.isLoading && !state.hasLoadedSearchResults) {
      return const _SearchLoadingState();
    }

    if (state.hasError && !state.hasLoadedSearchResults) {
      return _SearchErrorState(
        message: state.errorMessage ?? 'Unable to search products.',
        onRetry: onRetry,
      );
    }

    if (state.isSearchEmpty) {
      return _SearchMessageState(
        icon: Icons.inventory_2_outlined,
        message: 'No products found for "$query".',
      );
    }

    return RefreshIndicator(
      color: ZayColors.primary,
      onRefresh: () => onRetry(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (state.hasError)
              _InlineSearchError(
                message: state.errorMessage ?? 'Unable to refresh search.',
                onRetry: onRetry,
              ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Results for "$query"',
                style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
                  color: ZayColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            _SearchResultGrid(products: state.searchResults),
          ],
        ),
      ),
    );
  }
}

class _SearchResultGrid extends StatelessWidget {
  const _SearchResultGrid({required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const _SearchMessageState(
        icon: Icons.inventory_2_outlined,
        message: 'No products found.',
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

class _SearchLoadingState extends StatelessWidget {
  const _SearchLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: ZayColors.primary),
    );
  }
}

class _SearchErrorState extends StatelessWidget {
  const _SearchErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function([String? value]) onRetry;

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

class _SearchMessageState extends StatelessWidget {
  const _SearchMessageState({
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
