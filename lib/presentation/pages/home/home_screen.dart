import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zayrova/core/constants/assets.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/core/themes/zay_theme.dart';
import 'package:zayrova/domain/entities/category_entity.dart';
import 'package:zayrova/domain/entities/product_entity.dart';
import 'package:zayrova/presentation/components/banner_carousel.dart';
import 'package:zayrova/presentation/components/bottom_navigation.dart';
import 'package:zayrova/presentation/components/empty_state.dart';
import 'package:zayrova/presentation/components/error_state.dart';
import 'package:zayrova/presentation/components/loading_state.dart';
import 'package:zayrova/presentation/components/product_card.dart';
import 'package:zayrova/presentation/providers/feature/catalog_controller.dart';
import 'package:zayrova/presentation/routes/zay_router.dart';
import 'package:zayrova/presentation/routes/zay_routes.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
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
            // top side
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Location',
                            style: ZayTheme.lightTheme.textTheme.displaySmall
                                ?.copyWith(color: ZayColors.textSecondary),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                color: ZayColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'New York, USA',
                                style: ZayTheme
                                    .lightTheme
                                    .textTheme
                                    .displayMedium
                                    ?.copyWith(
                                      color: ZayColors.textPrimary,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                              const Icon(Icons.keyboard_arrow_down),
                            ],
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => ZayRouter.goto(ZayRoutes.notifications),
                        child: Container(
                          decoration: BoxDecoration(
                            color: ZayColors.textSecondary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: const Icon(
                            Icons.notifications,
                            color: ZayColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            ZayRouter.goto(ZayRoutes.search);
                          },
                          child: Container(
                            height: 45,
                            decoration: BoxDecoration(
                              color: ZayColors.white,
                              border: Border.all(color: ZayColors.inputBorder),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 21,
                                  height: 21,
                                  child: SvgPicture.asset(ZayIcons.searchIcon),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Search',
                                  style: ZayTheme
                                      .lightTheme
                                      .textTheme
                                      .displayLarge
                                      ?.copyWith(
                                    color: ZayColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => ZayRouter.goto(ZayRoutes.filter),
                        child: Container(
                          decoration: BoxDecoration(
                            color: ZayColors.primary,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: const Icon(Icons.tune, color: ZayColors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: _HomeBody(
                state: catalogState,
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

class _HomeBody extends StatelessWidget {
  const _HomeBody({
    required this.state,
    required this.isInitialLoading,
    required this.shouldShowError,
    required this.shouldShowEmpty,
    required this.onRetry,
  });

  final CatalogState state;
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

    final bannerImages = _bannerImagesFromProducts(state.products);

    return RefreshIndicator(
      color: ZayColors.primary,
      onRefresh: onRetry,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (bannerImages.isNotEmpty) ...[
              BannerCarousel(imageUrls: bannerImages),
              const SizedBox(height: 10),
            ],
            if (state.categories.isNotEmpty)
              _CategorySection(categories: state.categories),
            if (state.hasError)
              _InlineErrorState(
                message: state.errorMessage ?? 'Unable to refresh catalog.',
                onRetry: onRetry,
              ),
            _ProductFilterChips(categories: state.categories),
            _ProductSection(products: state.products),
          ],
        ),
      ),
    );
  }

  List<String> _bannerImagesFromProducts(List<Product> products) {
    final images = <String>[];

    for (final product in products) {
      final thumbnailUrl = product.thumbnailUrl;
      if (thumbnailUrl != null && thumbnailUrl.isNotEmpty) {
        images.add(thumbnailUrl);
      }

      images.addAll(product.imageUrls.where((url) => url.isNotEmpty));

      if (images.length >= 3) {
        break;
      }
    }

    return images.take(3).toList();
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({required this.categories});

  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _SectionHeader(
            title: 'Category',
            actionText: 'See All',
            onAction: () => ZayRouter.goto(ZayRoutes.categories),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.take(8).map((category) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: GestureDetector(
                    onTap: () => ZayRouter.goto(ZayRoutes.category, {
                      'categorySlug': category.slug ?? category.id,
                      'categoryName': category.name,
                    }),
                    child: SizedBox(
                      width: 74,
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 35,
                            backgroundColor: ZayColors.secondary,
                            child: SvgPicture.asset(
                              ZayIcons.logoIcon,
                              colorFilter: const ColorFilter.mode(
                                ZayColors.white,
                                BlendMode.srcIn,
                              ),
                              width: 30,
                              height: 30,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            category.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: ZayTheme.lightTheme.textTheme.displaySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductFilterChips extends StatelessWidget {
  const _ProductFilterChips({required this.categories});

  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    final labels = [
      'All',
      ...categories.take(5).map((category) => category.name),
    ];

    if (labels.length <= 1) {
      return const SizedBox(height: 16);
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: 'Popular Products'),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: labels.map((text) {
                final selected = text == 'All';
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? ZayColors.primary : ZayColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: ZayColors.inputBorder),
                  ),
                  child: Text(
                    text,
                    style: ZayTheme.lightTheme.textTheme.displayMedium
                        ?.copyWith(
                          color:
                              selected ? ZayColors.white : ZayColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductSection extends StatelessWidget {
  const _ProductSection({required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: _InlineEmptyState(message: 'No products available yet.'),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
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
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.actionText,
    this.onAction,
  });

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
          style: ZayTheme.lightTheme.textTheme.displayLarge
              ?.copyWith(color: ZayColors.textPrimary),
        ),
        if (actionText != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionText,
              style: ZayTheme.lightTheme.textTheme.displayMedium
                  ?.copyWith(color: ZayColors.textSecondary),
            ),
          ),
      ],
    );
  }
}

class _InlineErrorState extends StatelessWidget {
  const _InlineErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              style: ZayTheme.lightTheme.textTheme.displayMedium
                  ?.copyWith(color: ZayColors.textPrimary),
            ),
            TextButton(
              onPressed: () => onRetry(),
              child: Text(
                'Retry',
                style: ZayTheme.lightTheme.textTheme.displayMedium
                    ?.copyWith(color: ZayColors.primary),
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
  const _HomeErrorState({
    required this.message,
    required this.onRetry,
  });

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
    return Text(
      message,
      textAlign: TextAlign.center,
      style: ZayTheme.lightTheme.textTheme.displayMedium
          ?.copyWith(color: ZayColors.textSecondary),
    );
  }
}
