# Progress Tracker

## Current Status

- Current Phase: API Integration
- Current Feature: Category Catalog Integration
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

## Next Task

- Create real Search screen using CatalogController search results while keeping Filter as a placeholder.

## Suggested Commit Message

feat: connect category catalog state
