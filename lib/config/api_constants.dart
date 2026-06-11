class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://dummyjson.com';

  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 20);

  static const String products = '/products';
  static const String productSearch = '/products/search';
  static const String productCategories = '/products/categories';

  static const String carts = '/carts';
  static const String addCart = '/carts/add';

  static const String authLogin = '/auth/login';
  static const String authMe = '/auth/me';
  static const String authRefresh = '/auth/refresh';

  static const String users = '/users';

  static String productById(int id) => '$products/$id';

  static String productsByCategory(String categorySlug) {
    return '$products/category/$categorySlug';
  }

  static String cartById(int id) => '$carts/$id';

  static String cartsByUser(int userId) => '$carts/user/$userId';

  static String userById(int id) => '$users/$id';
}
