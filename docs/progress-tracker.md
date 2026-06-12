# Progress Tracker

## Current Status

- Current Phase: Navigation Setup
- Current Feature: Navigation Shell Stabilisation
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

## Next Task

- Replace placeholder navigation destinations with real screens incrementally, starting with Search and Filter.

## Suggested Commit Message

feat: stabilise navigation shell
