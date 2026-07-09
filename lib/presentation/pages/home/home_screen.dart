import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zayrova/core/constants/assets.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/core/themes/zay_theme.dart';
import 'package:zayrova/domain/entities/category_entity.dart';
import 'package:zayrova/domain/entities/product_entity.dart';
import 'package:zayrova/presentation/components/bottom_navigation.dart';
import 'package:zayrova/presentation/components/empty_state.dart';
import 'package:zayrova/presentation/components/error_state.dart';
import 'package:zayrova/presentation/components/loading_state.dart';
import 'package:zayrova/presentation/components/zay_network_image.dart';
import 'package:zayrova/presentation/providers/feature/auth_controller.dart';
import 'package:zayrova/presentation/providers/feature/catalog_controller.dart';
import 'package:zayrova/presentation/providers/feature/wishlist_controller.dart';
import 'package:zayrova/presentation/routes/zay_router.dart';
import 'package:zayrova/presentation/routes/zay_routes.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCatalog());
  }

  Future<void> _loadCatalog() async {
    final controller = ref.read(catalogControllerProvider.notifier);
    await controller.loadCategories();
    await controller.loadProducts(limit: 20);
  }

  @override
  Widget build(BuildContext context) {
    final catalogState = ref.watch(catalogControllerProvider);
    final user = ref.watch(authControllerProvider).currentUser;
    final isInitialLoading =
        catalogState.isLoading &&
        (!catalogState.hasLoadedProducts || !catalogState.hasLoadedCategories);
    final hasCatalogContent =
        catalogState.products.isNotEmpty || catalogState.categories.isNotEmpty;
    final shouldShowError = catalogState.hasError && !hasCatalogContent;
    final shouldShowEmpty =
        catalogState.hasLoadedProducts &&
        catalogState.hasLoadedCategories &&
        !hasCatalogContent;

    return Scaffold(
      appBar: null,
      bottomNavigationBar: const BottomNavigation(),
      extendBody: true,
      backgroundColor: ZayColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HomeHeader(
              selectedTab: _selectedTab,
              greetingName: user?.displayName,
              avatarUrl: user?.avatarUrl,
              onTabChanged: (index) => setState(() => _selectedTab = index),
            ),
            Expanded(
              child: _HomeBody(
                state: catalogState,
                selectedTab: _selectedTab,
                isInitialLoading: isInitialLoading,
                shouldShowError: shouldShowError,
                shouldShowEmpty: shouldShowEmpty,
                onRetry: _loadCatalog,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.selectedTab,
    required this.greetingName,
    required this.avatarUrl,
    required this.onTabChanged,
  });

  final int selectedTab;
  final String? greetingName;
  final String? avatarUrl;
  final ValueChanged<int> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 50,
                height: 50,
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: ZayColors.cancel,
                  backgroundImage:
                      avatarUrl == null || avatarUrl!.isEmpty
                          ? null
                          : NetworkImage(avatarUrl!),
                  child:
                      avatarUrl == null || avatarUrl!.isEmpty
                          ? const Icon(
                            Icons.person,
                            color: ZayColors.textSecondary,
                            size: 30,
                          )
                          : null,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi, ${_firstName(greetingName)}',
                      style: ZayTheme.lightTheme.textTheme.displayLarge
                          ?.copyWith(
                            color: ZayColors.textPrimary,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Let's go shopping",
                      style: ZayTheme.lightTheme.textTheme.displaySmall
                          ?.copyWith(color: ZayColors.textSecondary),
                    ),
                  ],
                ),
              ),
              _HeaderIconButton(
                onTap: () => ZayRouter.goto(ZayRoutes.search),
                child: SvgPicture.asset(
                  ZayIcons.searchIcon,
                  width: 24,
                  height: 24,
                ),
              ),
              const SizedBox(width: 10),
              _NotificationButton(
                onTap: () => ZayRouter.goto(ZayRoutes.notifications),
              ),
            ],
          ),
          const SizedBox(height: 42),
          _HomeTabs(selectedTab: selectedTab, onTabChanged: onTabChanged),
        ],
      ),
    );
  }

  String _firstName(String? name) {
    final trimmedName = name?.trim();
    if (trimmedName == null || trimmedName.isEmpty) {
      return 'Customer';
    }

    return trimmedName.split(RegExp(r'\s+')).first;
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(width: 36, height: 36, child: Center(child: child)),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _HeaderIconButton(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(
            Icons.notifications_outlined,
            color: ZayColors.textPrimary,
            size: 30,
          ),
          Positioned(
            top: 2,
            right: 2,
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
    );
  }
}

class _HomeTabs extends StatelessWidget {
  const _HomeTabs({required this.selectedTab, required this.onTabChanged});

  final int selectedTab;
  final ValueChanged<int> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _HomeTabButton(
            label: 'Home',
            isActive: selectedTab == 0,
            onTap: () => onTabChanged(0),
          ),
        ),
        Expanded(
          child: _HomeTabButton(
            label: 'Category',
            isActive: selectedTab == 1,
            onTap: () => onTabChanged(1),
          ),
        ),
      ],
    );
  }
}

class _HomeTabButton extends StatelessWidget {
  const _HomeTabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: ZayTheme.lightTheme.textTheme.bodyLarge?.copyWith(
              color: isActive ? ZayColors.textPrimary : ZayColors.textSecondary,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 2,
            width: 110,
            decoration: BoxDecoration(
              color: isActive ? ZayColors.primary : ZayColors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody({
    required this.state,
    required this.selectedTab,
    required this.isInitialLoading,
    required this.shouldShowError,
    required this.shouldShowEmpty,
    required this.onRetry,
  });

  final CatalogState state;
  final int selectedTab;
  final bool isInitialLoading;
  final bool shouldShowError;
  final bool shouldShowEmpty;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    if (isInitialLoading) {
      return const _HomeLoadingState();
    }

    if (shouldShowError) {
      return _HomeErrorState(
        message: state.errorMessage ?? 'Unable to load catalog.',
        onRetry: onRetry,
      );
    }

    if (shouldShowEmpty) {
      return const _HomeEmptyState();
    }

    return RefreshIndicator(
      color: ZayColors.primary,
      onRefresh: onRetry,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 38, 24, 128),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (state.hasError)
              _InlineErrorState(
                message: state.errorMessage ?? 'Unable to refresh catalog.',
                onRetry: onRetry,
              ),
            if (selectedTab == 0)
              _HomeProductsView(products: state.products)
            else
              _HomeCategoryView(
                categories: state.categories,
                products: state.products,
              ),
          ],
        ),
      ),
    );
  }
}

class _HomeProductsView extends StatelessWidget {
  const _HomeProductsView({required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PromoCard(product: products.isNotEmpty ? products.first : null),
        const SizedBox(height: 26),
        _SectionHeader(
          title: 'New Arrivals',
          actionText: 'See All',
          onAction: () => ZayRouter.goto(ZayRoutes.categories),
        ),
        const SizedBox(height: 24),
        if (products.isEmpty)
          const _InlineEmptyState(message: 'No products available yet.')
        else
          _HomeProductGrid(products: products),
      ],
    );
  }
}

class _PromoCard extends StatelessWidget {
  const _PromoCard({required this.product});

  final Product? product;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 146,
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F2),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Stack(
            children: [
              Positioned(
                left: -58,
                bottom: -66,
                child: Container(
                  width: 158,
                  height: 158,
                  decoration: BoxDecoration(
                    color: ZayColors.primary.withAlpha(45),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                left: 78,
                top: 36,
                right: 88,
                child: Column(
                  children: [
                    Text(
                      '24% off shipping today\non bag purchases',
                      textAlign: TextAlign.center,
                      style: ZayTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                        color: ZayColors.textPrimary,
                        fontWeight: FontWeight.w800,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'By Kutuku Store',
                      style: ZayTheme.lightTheme.textTheme.displayMedium
                          ?.copyWith(color: ZayColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: -6,
                top: 0,
                bottom: 0,
                width: 104,
                child: ZayNetworkImage(
                  imageUrl: _productImage(product),
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            _PromoDot(isActive: true),
            SizedBox(width: 8),
            _PromoDot(),
            SizedBox(width: 8),
            _PromoDot(),
          ],
        ),
      ],
    );
  }
}

class _PromoDot extends StatelessWidget {
  const _PromoDot({this.isActive = false});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 9,
      height: 9,
      decoration: BoxDecoration(
        color: isActive ? ZayColors.primary : ZayColors.inputBorder,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _HomeProductGrid extends StatelessWidget {
  const _HomeProductGrid({required this.products});

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
          children:
              products.map((product) {
                return Consumer(
                  builder: (context, ref, _) {
                    final wishlist = ref.watch(wishlistControllerProvider);

                    return _HomeProductCard(
                      product: product,
                      width: cardWidth,
                      isFavorite: wishlist.contains(product.id),
                      onFavoriteToggle: () {
                        ref
                            .read(wishlistControllerProvider.notifier)
                            .toggleProduct(product);
                      },
                      onTap:
                          () => ZayRouter.goto(ZayRoutes.productDetails, {
                            'productId': product.id,
                          }),
                    );
                  },
                );
              }).toList(),
        );
      },
    );
  }
}

class _HomeProductCard extends StatelessWidget {
  const _HomeProductCard({
    required this.product,
    required this.width,
    required this.onTap,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  final Product product;
  final double width;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    final subtitle =
        product.brand?.isNotEmpty == true
            ? product.brand!
            : product.categoryName ?? '';

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: ZayColors.textSecondary.withAlpha(20),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ZayNetworkImage(
                        imageUrl: _productImage(product),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: onFavoriteToggle,
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: ZayColors.textSecondary.withAlpha(190),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? ZayColors.red : ZayColors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              product.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
                color: ZayColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 3),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: ZayTheme.lightTheme.textTheme.displayMedium?.copyWith(
                  color: ZayColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
            const SizedBox(height: 3),
            Text(
              '${_currencySymbol(product.currencyCode)}${product.price.toStringAsFixed(2)}',
              textAlign: TextAlign.center,
              style: ZayTheme.lightTheme.textTheme.displayMedium?.copyWith(
                color: ZayColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeCategoryView extends StatelessWidget {
  const _HomeCategoryView({required this.categories, required this.products});

  final List<Category> categories;
  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty && products.isEmpty) {
      return const _InlineEmptyState(message: 'No categories available yet.');
    }

    return Column(
      children: [
        _CategoryHeroCard(
          title: 'New Arrivals',
          count: products.length,
          imageUrl: _productImage(products.isNotEmpty ? products.first : null),
          textAlignment: _CategoryCardTextAlignment.left,
          onTap: () => ZayRouter.goto(ZayRoutes.categories),
        ),
        const SizedBox(height: 18),
        ...categories.asMap().entries.map((entry) {
          final index = entry.key;
          final category = entry.value;
          final categoryProducts =
              products
                  .where((product) => _matchesCategory(product, category))
                  .toList();
          final imageProduct =
              categoryProducts.isNotEmpty ? categoryProducts.first : null;
          final count = category.productCount ?? categoryProducts.length;

          return Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: _CategoryHeroCard(
              title: category.name,
              count: count,
              imageUrl: category.imageUrl ?? _productImage(imageProduct),
              textAlignment:
                  index.isEven
                      ? _CategoryCardTextAlignment.right
                      : _CategoryCardTextAlignment.left,
              onTap:
                  () => ZayRouter.goto(ZayRoutes.category, {
                    'categorySlug': category.slug ?? category.id,
                    'categoryName': category.name,
                  }),
            ),
          );
        }),
      ],
    );
  }
}

enum _CategoryCardTextAlignment { left, right }

class _CategoryHeroCard extends StatelessWidget {
  const _CategoryHeroCard({
    required this.title,
    required this.count,
    required this.imageUrl,
    required this.textAlignment,
    required this.onTap,
  });

  final String title;
  final int count;
  final String? imageUrl;
  final _CategoryCardTextAlignment textAlignment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isRight = textAlignment == _CategoryCardTextAlignment.right;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F1F1),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.58,
                child: ZayNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover),
              ),
            ),
            Positioned.fill(
              child: Container(color: ZayColors.white.withAlpha(68)),
            ),
            Positioned(
              left: isRight ? null : 34,
              right: isRight ? 34 : null,
              top: 35,
              width: 172,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ZayTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                      color: ZayColors.textPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$count Product',
                    style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
                      color: ZayColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.actionText, this.onAction});

  final String title;
  final String? actionText;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final actionText = this.actionText;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: ZayTheme.lightTheme.textTheme.bodyLarge?.copyWith(
            color: ZayColors.textPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
        if (actionText != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionText,
              style: ZayTheme.lightTheme.textTheme.displayMedium?.copyWith(
                color: ZayColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
      ],
    );
  }
}

class _InlineErrorState extends StatelessWidget {
  const _InlineErrorState({required this.message, required this.onRetry});

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

class _HomeLoadingState extends StatelessWidget {
  const _HomeLoadingState();

  @override
  Widget build(BuildContext context) {
    return const ZayLoadingState(message: 'Loading catalog...');
  }
}

class _HomeErrorState extends StatelessWidget {
  const _HomeErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return ZayErrorState(
      title: 'Catalog unavailable',
      message: message,
      onRetry: () => onRetry(),
    );
  }
}

class _HomeEmptyState extends StatelessWidget {
  const _HomeEmptyState();

  @override
  Widget build(BuildContext context) {
    return const ZayEmptyState(
      icon: Icons.inventory_2_outlined,
      title: 'No catalog items',
      message: 'No catalog items found.',
    );
  }
}

class _InlineEmptyState extends StatelessWidget {
  const _InlineEmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: ZayTheme.lightTheme.textTheme.displayMedium?.copyWith(
          color: ZayColors.textSecondary,
        ),
      ),
    );
  }
}

String? _productImage(Product? product) {
  if (product == null) {
    return null;
  }

  final thumbnailUrl = product.thumbnailUrl;
  if (thumbnailUrl != null && thumbnailUrl.isNotEmpty) {
    return thumbnailUrl;
  }

  return product.imageUrls.isNotEmpty ? product.imageUrls.first : null;
}

bool _matchesCategory(Product product, Category category) {
  final keys =
      [
        category.id,
        category.slug,
        category.name,
      ].whereType<String>().map((value) => value.toLowerCase()).toSet();

  final productKeys =
      [
        product.categoryId,
        product.categoryName,
      ].whereType<String>().map((value) => value.toLowerCase()).toSet();

  return productKeys.any(keys.contains);
}

String _currencySymbol(String currencyCode) {
  switch (currencyCode.toUpperCase()) {
    case 'USD':
      return r'$';
    default:
      return '$currencyCode ';
  }
}
