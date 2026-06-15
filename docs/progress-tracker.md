# Progress Tracker

## Current Status

- Current Phase: Commerce UI Implementation
- Current Feature: Cart Experience Redesign
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
- Audited reusable UI patterns across Home, Category, Search, Product Details, Cart, Checkout, and Auth screens.
- Extended the product card system with compact, standard, and horizontal variants, favorite placeholder support, ratings, old price display, discount badges, and shared image loading/error handling.
- Extended the button system with primary, secondary, outline, danger, disabled, loading, full-width, and compact support while preserving existing constructor usage.
- Extended the input system with helper text, validation text, prefix/suffix icon aliases, and a reusable password visibility toggle wrapper.
- Added reusable image, list item, state, price row, order summary row, and checkout summary components for later screen redesigns.
- Cleaned up the low-level text input hint styling to use the app text color system.
- Attempted `flutter analyze` after the component-system preparation pass, but the local Dart VM crashed before analysis could run.
- Added a real View All Products screen for the Home `See All` flow.
- Routed `/categories` to the new all-products catalog browsing screen.
- Kept `/category` reserved for category-specific product browsing.
- Built the all-products screen with a design-aligned header, search action, filter action, sort chips, catalog summary, responsive ProductCard grid, and reusable loading/error/empty states.
- Updated Home `See All` to navigate to the all-products screen.
- Attempted `flutter analyze` after the View All Products work, but the local Dart VM crashed before analysis could run.
- Redesigned CategoryScreen using the docs/new catalog-results pattern.
- Preserved categorySlug/categoryName route arguments and existing CatalogController category product loading.
- Added category header with back navigation, search action, and filter action.
- Added horizontal sort chips, category summary row, responsive ProductCard grid, reusable loading/error/empty states, retry, and pull-to-refresh.
- Kept product taps routed to Product Details with productId.
- Attempted `flutter analyze` after the Category screen design work, but the local Dart VM crashed before analysis could run.
- Migrated SearchScreen to the docs/new search and search-results visual direction.
- Kept the existing submit-based CatalogController.searchProducts flow.
- Added focused search input styling, back navigation, result filter action, sort chips, result summary row, compact ProductCard grid, and reusable loading/error/empty states.
- Avoided fake last-search and popular-search content because no stored/local-backed search history exists yet.
- Preserved Product Details navigation through productId.
- Attempted `flutter analyze` after the Search screen design work, but the local Dart VM crashed before analysis could run.
- Redesigned ProductDetails using docs/new Detail and Detail v2 as the primary references.
- Preserved productId loading, CatalogController product detail state, thumbnail selection, variant selection, quantity selection, cart navigation, and add-to-cart behavior.
- Rebuilt the gallery hero, rounded details sheet, rating row, description, brand/category/stock metadata, variant sections, quantity area, and bottom price/add-to-cart action.
- Used real Product entity data only and hid unsupported variant sections when product data is unavailable.
- Replaced ProductDetails loading/error/invalid states with reusable state components.
- Attempted `flutter analyze` after Product Details design work, but the local Dart VM crashed before analysis could run.
- Redesigned CartScreen using docs/new My Cart, My Cart Selected, and My Cart v2 references.
- Preserved CartController loading, refresh, quantity update, remove item, delete empty cart, checkout navigation, and product navigation behavior.
- Rebuilt the cart item layout with real CartItem entity data, product image, selected state display, product metadata, quantity controls, remove action, and item subtotal.
- Rebuilt the bottom order summary sheet with promo-code visual row, subtotal, discount, total quantity, total amount, and checkout CTA.
- Reused shared loading, error, empty, and network image components in the cart screen.
- Attempted `flutter analyze` after the Cart screen redesign, but the local Dart VM crashed before analysis could run.

## Next Task

- Align Checkout screen visuals with docs/new checkout, address, and payment references.

## Known Risks

- Product sorting is local UI sorting over currently loaded catalog results; backend pagination and server-side sorting are not connected yet.
- The all-products screen currently requests up to 100 products through the existing catalog controller.
- Category sorting is local UI sorting over the loaded category product list.
- Search result sorting is local UI sorting over the loaded search results.
- Product color circles only render for parseable color names/hex values; unparseable color values render as text chips.
- Cart item selection is display-only from `CartItem.isSelected`; no selection toggle/update API exists yet.
- Cart promo code row is visual-only until discount/promo logic is connected.
- Cart summary currency defaults to USD because the Cart aggregate does not expose a currency field.

## Blockers

- `flutter analyze` is blocked by a local Dart VM crash: `runtime/vm/cpuinfo_macos.cc: 42: error: unreachable code`.

## Suggested Commit Message

feat: redesign cart experience
