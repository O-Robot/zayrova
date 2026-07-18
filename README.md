# Zayrova

Zayrova is a Flutter e-commerce application with onboarding, authentication, catalog browsing, search and filtering, cart and checkout flows, order tracking, notifications, messaging, wishlist, and profile management. The project uses a layered architecture with Riverpod for state management and is configured to publish a Flutter Web build to GitHub Pages.

## Preview

Live preview: [http://zayrova.ogooluwaniadewale.com/](http://zayrova.ogooluwaniadewale.com/)

Repository: [https://github.com/O-Robot/zayrova](https://github.com/O-Robot/zayrova)

## Highlights

- Multi-screen shopping experience built with Flutter `MaterialApp` and custom theming
- Riverpod-powered state management for auth, catalog, cart, orders, notifications, messages, wishlist, and checkout helpers
- DummyJSON-backed product, cart, auth, and user flows
- Local/session persistence for profile, auth session, created orders, and onboarding flags using `shared_preferences`
- Order tracking UI with map-based courier progress using `flutter_map` and `latlong2`
- Search, category browsing, product details, and wishlist support
- Profile editing with local avatar updates
- Notifications and messages flows, with seeded local fallback data where backend endpoints do not yet exist
- GitHub Actions workflow for automatic web deployment to GitHub Pages

## Feature Overview

### Onboarding and session flow

- Splash screen restores persisted session data before routing
- Onboarding and get-started flow for first-time users
- Login, sign-up, forgot password, email verification, and complete-profile screens
- Guest/onboarding state is persisted locally to control startup navigation

### Shopping flow

- Home screen with greeting, tabs, categories, and featured products
- Full catalog browsing and category-specific product views
- Product search and filtering
- Product details with image gallery and wishlist actions
- Cart management and checkout flow
- Address and payment method entry screens
- Payment success and failure screens

### Orders and tracking

- Active orders and order history views
- Order details, order reviews, and order ratings
- Order creation adapted from cart data
- Persisted locally created orders
- Tracking experience with map, courier card, and generated route progress

### Account and support

- Profile screen and edit profile flow
- Settings, security, password change, legal, and help screens
- Notifications center with unread handling
- Messaging inbox and conversation detail screens
- Local fallback conversations/messages until a real messaging API is available

## Tech Stack

- Flutter
- Dart `^3.7.2`
- `flutter_riverpod`
- `http`
- `shared_preferences`
- `flutter_svg`
- `image_picker`
- `flutter_map`
- `latlong2`
- `animate_do`
- `device_preview`

## Architecture

The codebase follows a layered structure:

- `lib/data`: remote datasources, DTO/models, and repository implementations
- `lib/domain`: entities, repository contracts, and use cases
- `lib/presentation`: UI pages, reusable components, route configuration, and Riverpod feature controllers
- `lib/features/tracking`: tracking-specific models, services, providers, and widgets
- `lib/core`: shared constants, theme, networking, exceptions, storage, and utilities
- `lib/config`: API and feature-specific constants

The app flow is generally:

1. UI screens dispatch actions through Riverpod notifiers/controllers.
2. Controllers call domain use cases.
3. Use cases delegate to repository interfaces.
4. Repository implementations use datasources to fetch, adapt, and return entity-safe results.

## State Management

Riverpod notifiers are used across the app, including:

- `authControllerProvider`
- `catalogControllerProvider`
- `cartControllerProvider`
- `orderControllerProvider`
- `notificationControllerProvider`
- `messageControllerProvider`
- `wishlistControllerProvider`
- local checkout-related controllers such as address and payment helpers

This keeps async loading, error handling, and screen state centralized instead of embedding those concerns directly in widgets.

## Data Sources

### Remote

The app currently uses DummyJSON as its primary API base:

- Base URL: `https://dummyjson.com`
- Product endpoints
- Cart endpoints
- Auth endpoints
- User endpoints

### Local and fallback behavior

Some flows are intentionally local or partially mocked while backend support is incomplete:

- Auth session and profile are restored from local storage
- Profile edits are persisted locally for the current app session/device
- Created orders are merged with fetched orders and persisted locally
- Messages fall back to seeded local conversations and messages when remote endpoints are unavailable
- Notifications and some other support surfaces are structured to accept real backend APIs later

## Project Structure

```text
lib/
  config/
  core/
  data/
    datasources/
    models/
    repositories/
  domain/
    entities/
    repositories/
    usecases/
  features/
    tracking/
  presentation/
    components/
    pages/
    providers/
    routes/
    widgets/
  main.dart
  zay.dart
```

## Running Locally

### Prerequisites

- Flutter SDK installed
- Dart SDK compatible with the Flutter version in use
- A configured device, emulator, simulator, or Chrome for web

### Install dependencies

```bash
flutter pub get
```

### Run the app

```bash
flutter run
```

For web:

```bash
flutter run -d chrome
```

## Build Commands

Build Android APK:

```bash
flutter build apk
```

Build iOS:

```bash
flutter build ios
```

Build web:

```bash
flutter build web --release
```

## Development Notes

- `DevicePreview` is enabled in `lib/main.dart`, which is useful during UI work but may not be desirable for production-style local testing.
- The app starts from the splash route and decides the next screen based on persisted auth/onboarding state.
- Route generation is centralized in `lib/presentation/routes/zay_screens.dart`.
- The app uses a custom light theme defined in `lib/core/themes/zay_theme.dart`.

## GitHub Pages Deployment

The repository includes a GitHub Actions workflow at [.github/workflows/zay.yml](/Users/macbookpro/Documents/Mobile%20Projects/flutter/zayrova/.github/workflows/zay.yml:1) that:

- runs on pushes to `main`
- installs Flutter
- fetches dependencies
- builds the web app
- publishes `build/web` to the `gh-pages` branch

Current preview URL:

- `http://zayrova.ogooluwaniadewale.com/`

If the preview is not updating, check:

- GitHub Pages is enabled for the repository
- the latest `main` push completed the `Deploy Zayrova` workflow successfully
- the `gh-pages` branch was updated by the workflow

## Known Limitations

- Some backend-facing features are still backed by local/session data rather than a full production API
- Messages currently use seeded fallback data because DummyJSON does not provide the required conversation endpoints
- Profile image updates are local-state driven and not uploaded to a remote media service
- The app is using DummyJSON, so product/order/auth behavior is suitable for prototyping, demos, and UI development rather than production commerce

## Useful Files

- App entry: [lib/main.dart](/Users/macbookpro/Documents/Mobile%20Projects/flutter/zayrova/lib/main.dart:1)
- App shell: [lib/zay.dart](/Users/macbookpro/Documents/Mobile%20Projects/flutter/zayrova/lib/zay.dart:1)
- Routes: [lib/presentation/routes/zay_routes.dart](/Users/macbookpro/Documents/Mobile%20Projects/flutter/zayrova/lib/presentation/routes/zay_routes.dart:1)
- Route mapping: [lib/presentation/routes/zay_screens.dart](/Users/macbookpro/Documents/Mobile%20Projects/flutter/zayrova/lib/presentation/routes/zay_screens.dart:1)
- API config: [lib/config/api_constants.dart](/Users/macbookpro/Documents/Mobile%20Projects/flutter/zayrova/lib/config/api_constants.dart:1)
- Deployment workflow: [.github/workflows/zay.yml](/Users/macbookpro/Documents/Mobile%20Projects/flutter/zayrova/.github/workflows/zay.yml:1)

## Future Improvements

- Replace DummyJSON-dependent placeholder flows with production APIs
- Add automated tests for controllers, repositories, and critical screen flows
- Add environment-based configuration for API hosts and feature flags
- Disable `DevicePreview` automatically outside development
- Add screenshot assets and release notes to the repository
