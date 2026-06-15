# Progress Tracker

## Current Status

- Current Phase: API Integration
- Current Feature: Shared UI Component Upgrades
- Status: In Progress

## Completed Work

- Read project context, workflow rules, folder structure, design guardrails, API strategy, feature scope, state management plan, manual commands, and project report.
- Inspected current dependencies during initial foundation setup.
- Added centralized DummyJSON API constants.
- Added reusable API exceptions.
- Added a lightweight API result pattern for loading, success, and error states.
- Added a shared API client foundation for future datasources.
- Confirmed `http` and `flutter_riverpod` are now present in `pubspec.yaml`.
- Refactored the shared API client from Dart `HttpClient` to the web-compatible `http` package.
- Cleaned up current Flutter analyze warnings for unused imports and unused variables.
- Restored the complete profile picked image field to preserve existing image picker behavior.
- Added first API-agnostic domain entities for products, categories, cart, users, addresses, payments, orders, notifications, and messaging.
- Attempted `flutter analyze`, but the local Dart VM crashed before analysis could run.
- Added API-ready data models that map JSON responses into the domain entities.
- Kept DummyJSON-specific parsing inside the data model layer.
- Attempted `flutter analyze` after adding data models, but the local Dart VM crashed before analysis could run.
- Added remote datasources for products, categories, carts, auth, users, orders, notifications, and messages.
- Kept temporary DummyJSON cart-to-order adaptation isolated inside the order datasource.
- Attempted `flutter analyze` after adding datasources, but the local Dart VM crashed before analysis could run.
- Added repository contracts for products, categories, cart, auth, users, orders, notifications, and messages.
- Added repository implementations that consume remote datasources and return domain entities through `ApiResult`.
- Attempted `flutter analyze` after adding repositories, but the local Dart VM crashed before analysis could run.
- Added a proper `Cart` domain entity and `CartModel`.
- Updated cart datasource and repository layers to return `Cart` aggregates instead of nested cart item lists.
- Attempted `flutter analyze` after fixing cart structure, but the local Dart VM crashed before analysis could run.
- Added domain use cases for products, categories, cart, auth, users, orders, notifications, and messages.
- Confirmed the new use cases do not import Flutter or data-layer files.
- Attempted `flutter analyze` after adding use cases, but the local Dart VM crashed before analysis could run.
- Wrapped the app with `ProviderScope` while preserving Device Preview.
- Added Riverpod dependency providers for `ApiClient`, remote datasources, repositories, and use cases.
- Confirmed the new providers do not create screen-level notifiers or import UI pages.
- Attempted `flutter analyze` after adding dependency providers, but the local Dart VM crashed before analysis could run.
- Added feature-level Riverpod controllers for Auth, Catalog, and Cart.
- Kept controllers disconnected from UI screens and limited to existing use case providers.
- Confirmed feature controllers do not import data-layer files or UI pages.
- Attempted `flutter analyze` after adding feature controllers, but the local Dart VM crashed before analysis could run.
- Stabilised the app navigation shell with planned route constants and placeholder route mappings for search, filter, checkout, orders, profile, notifications, messages, legal, and help flows.
- Updated the bottom navigation destinations to Home, My Order, Favorite, and My Profile.
- Attempted `flutter analyze` after navigation shell updates, but the local Dart VM crashed before analysis could run.
- Connected Home to the Riverpod CatalogController.
- Replaced hardcoded Home products and categories with Product and Category domain entities from catalog state.
- Added Home loading, empty, full error, partial error, retry, and pull-to-refresh states.
- Updated ProductCard with a Product-based factory while preserving the existing constructor for current screens.
- Passed product ids and category slug/name route arguments from Home without connecting destination screens yet.
- Attempted `flutter analyze` after Home catalog integration, but the local Dart VM crashed before analysis could run.
- Passed `productId` route arguments into ProductDetails.
- Connected ProductDetails to the Riverpod CatalogController and loaded product details by id.
- Replaced hardcoded ProductDetails title, price, description, rating, images, brand/category, and stock display with Product entity data.
- Added ProductDetails loading, error with retry, and missing/invalid product id states.
- Preserved image thumbnail selection and kept Add to Cart visible as a disabled coming-soon action.
- Attempted `flutter analyze` after ProductDetails integration, but the local Dart VM crashed before analysis could run.
- Passed category slug/name route arguments into CategoryScreen.
- Connected CategoryScreen to the Riverpod CatalogController and loaded products by category slug.
- Replaced hardcoded CategoryScreen product cards with Product entity data from category products state.
- Added CategoryScreen loading, error with retry, empty, missing category, pull-to-refresh, and filter placeholder states.
- Cleared stale category products when loading a new category.
- Attempted `flutter analyze` after CategoryScreen integration, but the local Dart VM crashed before analysis could run.
- Replaced the Search placeholder route with a real SearchScreen.
- Connected SearchScreen to CatalogController.searchProducts with submit-based search.
- Added SearchScreen initial, loading, error with retry, empty, and results states.
- Rendered search results with ProductCard using Product domain entities.
- Routed search result taps to ProductDetails with productId and kept Filter as a placeholder route.
- Cleared stale search results when starting a new search.
- Attempted `flutter analyze` after SearchScreen integration, but the local Dart VM crashed before analysis could run.
- Replaced the Filter placeholder route with a real FilterScreen.
- Added filter UI sections for category, price range, rating, sort by, and availability.
- Used existing catalog category state for category filter choices when available.
- Added Reset and Apply Filter actions without connecting final filtering logic or fake product results.
- Attempted `flutter analyze` after FilterScreen UI foundation, but the local Dart VM crashed before analysis could run.
- Enabled ProductDetails add-to-cart through the Riverpod CartController using Product domain entity data.
- Added a ProductDetails quantity selector and loading SnackBar feedback for add-to-cart actions.
- Kept the temporary DummyJSON cart user id isolated in the cart controller layer.
- Connected CartScreen to CartController and loaded the temporary DummyJSON user cart.
- Rendered Cart and CartItem domain entities in CartScreen with loading, error, empty, retry, refresh, quantity update, remove, and summary states.
- Attempted `flutter analyze` after basic cart integration, but the local Dart VM crashed before analysis could run.
- Added a real CheckoutScreen foundation that consumes CartController and displays current Cart and CartItem domain data.
- Added checkout cart summary, subtotal, discount, delivery fee placeholder, total, selected address placeholder, selected payment method placeholder, and Pay Now action.
- Routed Checkout and Payment to the checkout foundation screen while keeping address, change payment method, payment success, and payment failed as navigable placeholder flows.
- Added a CartScreen checkout button that routes to the checkout foundation.
- Attempted `dart format`, but the local Dart VM crashed before formatting could run.
- Attempted `flutter analyze` after checkout foundation work, but the local Dart VM crashed before analysis could run.
- Added temporary in-memory address state for checkout address selection.
- Replaced the Address placeholder with a real Address List screen.
- Added an Add Address screen with full name, phone number, address lines, city, state, country, postal code, default address toggle, and simple required-field validation.
- Added address cards, selected/default address UI, empty state, and add-new-address navigation.
- Integrated the selected address into CheckoutScreen while keeping profile/backend address sync deferred.
- Attempted `flutter analyze` after address management foundation work, but the local Dart VM crashed before analysis could run.
- Added temporary in-memory payment method state for checkout payment selection.
- Replaced the Change Payment Method placeholder with a real Payment Method List screen.
- Added an Add Payment Method screen with card holder name, card number, expiry month/year, CVV, default method toggle, and simple card validation.
- Added payment method cards, selected/default method UI, empty state, and add-new-card navigation.
- Masked card numbers in list and checkout views, and avoided storing full card numbers or CVV after save.
- Integrated the selected payment method into CheckoutScreen while keeping real payment gateway integration deferred.
- Attempted `flutter analyze` after payment method foundation work, but the local Dart VM crashed before analysis could run.
- Extended ZayButton with full-width, loading, disabled, outline, danger, and compact variants while preserving existing calls.
- Upgraded ProductCard styling and kept the existing constructor and ProductCard.fromProduct data-driven API intact.
- Added reusable empty, loading, error, and summary card components for upcoming screen redesigns.
- Reused shared state components in Home and Cart where safe without redesigning the full screens.
- Replaced Cart summary totals with the reusable summary card pattern.
- Attempted `flutter analyze` after shared UI component upgrades, but the local Dart VM crashed before analysis could run.

## Next Task

- Start the Product Details visual redesign using the upgraded shared components.

## Suggested Commit Message

feat: upgrade shared ui components
