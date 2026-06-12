import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zayrova/domain/entities/category_entity.dart';
import 'package:zayrova/domain/entities/product_entity.dart';
import 'package:zayrova/presentation/providers/usecase_providers.dart';

final catalogControllerProvider =
    NotifierProvider<CatalogController, CatalogState>(CatalogController.new);

class CatalogState {
  const CatalogState({
    this.products = const [],
    this.categories = const [],
    this.searchResults = const [],
    this.categoryProducts = const [],
    this.selectedProduct,
    this.isLoading = false,
    this.errorMessage,
    this.hasLoadedProducts = false,
    this.hasLoadedCategories = false,
    this.hasLoadedSearchResults = false,
    this.hasLoadedCategoryProducts = false,
  });

  final List<Product> products;
  final List<Category> categories;
  final List<Product> searchResults;
  final List<Product> categoryProducts;
  final Product? selectedProduct;
  final bool isLoading;
  final String? errorMessage;
  final bool hasLoadedProducts;
  final bool hasLoadedCategories;
  final bool hasLoadedSearchResults;
  final bool hasLoadedCategoryProducts;

  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  bool get isProductsEmpty => hasLoadedProducts && products.isEmpty;

  bool get isCategoriesEmpty => hasLoadedCategories && categories.isEmpty;

  bool get isSearchEmpty => hasLoadedSearchResults && searchResults.isEmpty;

  bool get isCategoryProductsEmpty {
    return hasLoadedCategoryProducts && categoryProducts.isEmpty;
  }

  CatalogState copyWith({
    List<Product>? products,
    List<Category>? categories,
    List<Product>? searchResults,
    List<Product>? categoryProducts,
    Product? selectedProduct,
    bool? isLoading,
    String? errorMessage,
    bool? hasLoadedProducts,
    bool? hasLoadedCategories,
    bool? hasLoadedSearchResults,
    bool? hasLoadedCategoryProducts,
    bool clearSelectedProduct = false,
    bool clearError = false,
  }) {
    return CatalogState(
      products: products ?? this.products,
      categories: categories ?? this.categories,
      searchResults: searchResults ?? this.searchResults,
      categoryProducts: categoryProducts ?? this.categoryProducts,
      selectedProduct: clearSelectedProduct
          ? null
          : selectedProduct ?? this.selectedProduct,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      hasLoadedProducts: hasLoadedProducts ?? this.hasLoadedProducts,
      hasLoadedCategories: hasLoadedCategories ?? this.hasLoadedCategories,
      hasLoadedSearchResults:
          hasLoadedSearchResults ?? this.hasLoadedSearchResults,
      hasLoadedCategoryProducts:
          hasLoadedCategoryProducts ?? this.hasLoadedCategoryProducts,
    );
  }
}

class CatalogController extends Notifier<CatalogState> {
  @override
  CatalogState build() {
    return const CatalogState();
  }

  Future<void> loadProducts({int? limit, int? skip}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await ref.read(getProductsUseCaseProvider).call(
      limit: limit,
      skip: skip,
    );

    if (result.isSuccess) {
      state = state.copyWith(
        products: result.data ?? const [],
        isLoading: false,
        hasLoadedProducts: true,
      );
      return;
    }

    state = state.copyWith(
      isLoading: false,
      errorMessage: result.message ?? 'Unable to load products.',
    );
  }

  Future<void> loadCategories() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await ref.read(getCategoriesUseCaseProvider).call();

    if (result.isSuccess) {
      state = state.copyWith(
        categories: result.data ?? const [],
        isLoading: false,
        hasLoadedCategories: true,
      );
      return;
    }

    state = state.copyWith(
      isLoading: false,
      errorMessage: result.message ?? 'Unable to load categories.',
    );
  }

  Future<void> loadProductDetails(int id) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await ref.read(getProductByIdUseCaseProvider).call(id);

    if (result.isSuccess && result.data != null) {
      state = state.copyWith(selectedProduct: result.data, isLoading: false);
      return;
    }

    state = state.copyWith(
      isLoading: false,
      errorMessage: result.message ?? 'Unable to load product details.',
    );
  }

  Future<void> searchProducts(
    String query, {
    int? limit,
    int? skip,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await ref.read(searchProductsUseCaseProvider).call(
      query,
      limit: limit,
      skip: skip,
    );

    if (result.isSuccess) {
      state = state.copyWith(
        searchResults: result.data ?? const [],
        isLoading: false,
        hasLoadedSearchResults: true,
      );
      return;
    }

    state = state.copyWith(
      isLoading: false,
      errorMessage: result.message ?? 'Unable to search products.',
    );
  }

  Future<void> loadProductsByCategory(
    String categorySlug, {
    int? limit,
    int? skip,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await ref.read(getProductsByCategoryUseCaseProvider).call(
      categorySlug,
      limit: limit,
      skip: skip,
    );

    if (result.isSuccess) {
      state = state.copyWith(
        categoryProducts: result.data ?? const [],
        isLoading: false,
        hasLoadedCategoryProducts: true,
      );
      return;
    }

    state = state.copyWith(
      isLoading: false,
      errorMessage: result.message ?? 'Unable to load category products.',
    );
  }
}
