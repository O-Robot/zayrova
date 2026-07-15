import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/core/themes/zay_theme.dart';
import 'package:zayrova/domain/entities/product_entity.dart';
import 'package:zayrova/presentation/components/bottom_navigation.dart';
import 'package:zayrova/presentation/components/empty_state.dart';
import 'package:zayrova/presentation/components/product_card.dart';
import 'package:zayrova/presentation/providers/feature/wishlist_controller.dart';
import 'package:zayrova/presentation/routes/zay_router.dart';
import 'package:zayrova/presentation/routes/zay_routes.dart';

enum _FavoriteSortOption { all, latest, popular, cheapest }

class WishlistScreen extends ConsumerStatefulWidget {
  const WishlistScreen({super.key});

  @override
  ConsumerState<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends ConsumerState<WishlistScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  _FavoriteSortOption _selectedSort = _FavoriteSortOption.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wishlistState = ref.watch(wishlistControllerProvider);
    final products = _sortProducts(_filterProducts(wishlistState.products));

    return Scaffold(
      appBar: null,
      backgroundColor: ZayColors.white,
      bottomNavigationBar: const BottomNavigation(),
      body: SafeArea(
        child: Column(
          children: [
            _FavoriteHeader(
              onNotification: () => ZayRouter.goto(ZayRoutes.notifications),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
              child: _FavoriteSearchBar(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
            const SizedBox(height: 28),
            _FavoriteSortChips(
              selectedOption: _selectedSort,
              onChanged: (option) => setState(() => _selectedSort = option),
            ),
            Expanded(
              child: _FavoriteBody(
                products: products,
                hasFavorites: wishlistState.products.isNotEmpty,
                isSearching: _query.trim().isNotEmpty,
                onRemove: (product) {
                  ref
                      .read(wishlistControllerProvider.notifier)
                      .removeProduct(product.id);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Product> _filterProducts(List<Product> products) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) {
      return products;
    }

    return products.where((product) {
      final category = product.categoryName?.toLowerCase() ?? '';
      final brand = product.brand?.toLowerCase() ?? '';
      return product.title.toLowerCase().contains(query) ||
          category.contains(query) ||
          brand.contains(query);
    }).toList();
  }

  List<Product> _sortProducts(List<Product> products) {
    final sorted = [...products];

    switch (_selectedSort) {
      case _FavoriteSortOption.all:
        return sorted;
      case _FavoriteSortOption.latest:
        return sorted.reversed.toList();
      case _FavoriteSortOption.popular:
        sorted.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
        return sorted;
      case _FavoriteSortOption.cheapest:
        sorted.sort((a, b) => a.price.compareTo(b.price));
        return sorted;
    }
  }
}

class _FavoriteHeader extends StatelessWidget {
  const _FavoriteHeader({required this.onNotification});

  final VoidCallback onNotification;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 20),
      child: Row(
        children: [
          const SizedBox(width: 44, height: 44),
          Expanded(
            child: Text(
              'My Favorite',
              textAlign: TextAlign.center,
              style: ZayTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                color: ZayColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          GestureDetector(
            onTap: onNotification,
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 44,
              height: 44,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.notifications_none_rounded,
                    color: ZayColors.textPrimary,
                    size: 30,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE30000),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteSearchBar extends StatelessWidget {
  const _FavoriteSearchBar({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: ZayColors.white,
        border: Border.all(color: ZayColors.inputBorder.withAlpha(150)),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.search_rounded,
            color: ZayColors.textPrimary,
            size: 34,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: 'Search something...',
                border: InputBorder.none,
                hintStyle: ZayTheme.lightTheme.textTheme.displayLarge
                    ?.copyWith(color: ZayColors.textSecondary),
              ),
              style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
                color: ZayColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Icon(
            Icons.tune_rounded,
            color: ZayColors.textPrimary,
            size: 30,
          ),
        ],
      ),
    );
  }
}

class _FavoriteSortChips extends StatelessWidget {
  const _FavoriteSortChips({
    required this.selectedOption,
    required this.onChanged,
  });

  final _FavoriteSortOption selectedOption;
  final ValueChanged<_FavoriteSortOption> onChanged;

  @override
  Widget build(BuildContext context) {
    final options = [
      (_FavoriteSortOption.all, 'All'),
      (_FavoriteSortOption.latest, 'Latest'),
      (_FavoriteSortOption.popular, 'Most Popular'),
      (_FavoriteSortOption.cheapest, 'Cheapest'),
    ];

    return SizedBox(
      height: 50,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final option = options[index];
          final selected = option.$1 == selectedOption;

          return GestureDetector(
            onTap: () => onChanged(option.$1),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              decoration: BoxDecoration(
                color: selected ? ZayColors.primary : ZayColors.white,
                border: Border.all(
                  color: selected
                      ? ZayColors.primary
                      : ZayColors.inputBorder.withAlpha(150),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                option.$2,
                style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
                  color: selected ? ZayColors.white : ZayColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FavoriteBody extends StatelessWidget {
  const _FavoriteBody({
    required this.products,
    required this.hasFavorites,
    required this.isSearching,
    required this.onRemove,
  });

  final List<Product> products;
  final bool hasFavorites;
  final bool isSearching;
  final ValueChanged<Product> onRemove;

  @override
  Widget build(BuildContext context) {
    if (!hasFavorites) {
      return EmptyStateWidget(
        icon: Icons.favorite_border_rounded,
        title: 'No favorites yet',
        message: 'Tap the heart on products you love and they will appear here.',
        actionText: 'Explore products',
        onAction: () => ZayRouter.goto(ZayRoutes.categories),
      );
    }

    if (products.isEmpty && isSearching) {
      return const EmptyStateWidget(
        icon: Icons.search_off_rounded,
        title: 'No favorites found',
        message: 'Try searching by product, category, or brand.',
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const spacing = 18.0;
          final cardWidth = (constraints.maxWidth - spacing) / 2;

          return Align(
            alignment: Alignment.topLeft,
            child: Wrap(
              alignment: WrapAlignment.start,
              spacing: spacing,
              runSpacing: 28,
              children: products.map((product) {
                return ProductCard.fromProduct(
                  product: product,
                  width: cardWidth,
                  variant: ProductCardVariant.compact,
                  isFavorite: true,
                  action: () => ZayRouter.goto(ZayRoutes.productDetails, {
                    'productId': product.id,
                  }),
                  onFavoriteToggle: () => onRemove(product),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
