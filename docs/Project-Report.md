# Zayrova Project Audit

Date: 2026-06-10

Zayrova is currently a Flutter e-commerce UI prototype with onboarding, auth forms, home browsing, product details, wishlist, category, location, and partial cart screens. The codebase is small and understandable, but it does not yet have a real domain/data layer, shared app state, backend integration, or complete commerce flows.

## 1. Project Structure

### Main folders

- `lib/main.dart`
  - App entry point.
  - Wraps the app in `DevicePreview` and launches `ZayApp`.

- `lib/zay.dart`
  - Main `MaterialApp` configuration.
  - Sets theme, initial route, global navigator key, and route generator.

- `lib/config/`
  - Intended for app/API configuration.
  - `api_constants.dart` is currently empty.

- `lib/core/constants/`
  - Central constants for colors, assets, and string extensions.
  - Contains `ZayColors`, `ZayAssets`, `ZayIllustrations`, `ZayIcons`, and utility string extensions.

- `lib/core/themes/`
  - Contains `ZayTheme.lightTheme`.
  - Defines basic typography and scaffold background.

- `lib/core/utils/`
  - Contains `LocalStorage`, a small wrapper around `shared_preferences`.

- `lib/presentation/routes/`
  - Custom routing layer:
    - `zay_routes.dart`: route name constants.
    - `zay_router.dart`: global navigator helpers.
    - `zay_screens.dart`: route-to-screen mapping.

- `lib/presentation/pages/`
  - Feature screens grouped by area:
    - `auth/`
    - `cart/`
    - `error/`
    - `home/`
    - `location/`
    - `onboarding/`
    - `product/`

- `lib/presentation/components/`
  - Reusable UI components used by screens, such as product cards, bottom navigation, banner carousel, modals, top navigation, dots, image picker, and low-level text input.

- `lib/presentation/widgets/`
  - Higher-level reusable widgets for buttons, form inputs, and social buttons.
  - There is overlap with `components/`.

- `assets/`
  - Static icons, logos, backgrounds, and onboarding illustrations.

- Platform folders: `android/`, `ios/`, `macos/`, `linux/`, `windows/`, `web/`
  - Standard Flutter platform scaffolding.

- `test/`
  - Contains the default Flutter counter test, which does not match this app.

### Architecture/pattern

The project currently follows a simple presentation-first structure. It has a light separation between:

- `core`: constants, theme, utilities.
- `presentation`: routes, screens, widgets.
- `config`: intended configuration, currently unused.

There is no clear `data` layer, `domain` layer, repository layer, model layer, service layer, or state-management layer yet.

### Structure quality

The current structure is clean enough for an early UI prototype, but it is not yet scalable for a production e-commerce app. The biggest gaps are:

- No `models/` for `Product`, `CartItem`, `User`, `Order`, `Category`, etc.
- No `services/`, `repositories/`, or backend clients.
- No feature-owned state.
- UI widgets split between `components` and `widgets` without a clear rule.
- Several route constants exist for screens that are not implemented.

Recommended future structure:

```text
lib/
  core/
    constants/
    theme/
    storage/
    routing/
  features/
    auth/
      data/
      models/
      presentation/
      state/
    catalog/
    cart/
    checkout/
    profile/
    orders/
  shared/
    widgets/
    design_system/
```

## 2. Current App Flow

### Implemented screens

- Splash
  - `Splashscreen`
  - Route: `/`

- Get Started
  - `GetStartedScreen`
  - Route: `/get-started`

- Onboarding
  - `OnboardingScreen`
  - Route: `/onboard-page`

- Auth
  - `SignIn` - `/login`
  - `SignUp` - `/register`
  - `ForgotPassword` - `/forgot-password`
  - `VerifyEmail` - `/verify-email`
  - `SetPassword` - `/set-password`
  - `CompleteProfile` - `/complete-profile`

- Location
  - `LocationAccess` - `/location-access`
  - `LocationPage` - `/location-page`

- Commerce/catalog
  - `HomeScreen` - `/home`
  - `CategoryScreen` - `/category`
  - `ProductDetails` - `/product-details`
  - `WishlistScreen` - `/wishlist`
  - `CartScreen` - `/cart`

- Error
  - `ErrorScreen`

### User movement through the app

Current intended flow:

1. App starts at splash.
2. Splash waits 3 seconds and sends user to Get Started.
3. Get Started sends user to onboarding or sign in.
4. Onboarding pages send user to sign in.
5. Sign in sends user directly to home.
6. Home lets user open category, product details, wishlist, cart, and bottom navigation destinations.

Current actual behavior:

- Splash deletes the `onboard` key every launch, so onboarding persistence is effectively disabled.
- Sign in does not authenticate; it simply routes to home.
- Sign up button currently has no route/action.
- Forgot password routes to verify email.
- Verify email routes to complete profile after all OTP boxes are filled.
- Complete profile button currently has no route/action.
- Product details "Add to Cart" has no action.
- Cart has no real item list or checkout action.

### Navigation setup

Navigation uses:

- `MaterialApp.onGenerateRoute`
- A global `navigatorKey`
- `ZayRouter.goto`, `ZayRouter.exit`, `ZayRouter.goBack`, and `ZayRouter.refresh`
- Route constants in `ZayRoutes`
- Route mapping in `ZayScreens`

This is a custom Navigator 1.0 setup, not `go_router` or declarative routing.

### Missing or incomplete flows

Route constants exist but are not mapped to screens:

- `/checkout`
- `/order-summary`
- `/order-details`
- `/payment`
- `/payment-success`
- `/payment-failed`
- `/order-history`
- `/order-tracking`
- `/order-review`
- `/order-rating`
- `/settings`
- `/notifications`
- `/search`
- `/orders`
- `/chat`
- `/profile`
- `/category-details`

Important incomplete user flows:

- Real sign up/sign in.
- Auth session persistence.
- Forgot password completion.
- Profile completion.
- Location permission and geocoding.
- Search results.
- Filtering/sorting.
- Product listing from data.
- Add to cart.
- Cart quantity changes and removal.
- Checkout.
- Payment.
- Orders/order history.
- Profile/settings.
- Chat/support.

## 3. State Management

### Current approach

The project uses only local `StatefulWidget` state and `setState`.

There is no Provider, Riverpod, Bloc, GetX, Redux, MobX, or custom app store.

### Current state locations

- App/session state
  - Only partially represented through `LocalStorage`.
  - `Splashscreen` checks `guest`, deletes `onboard`, and sets `onboard` in one branch.
  - There is no real session object or auth guard.

- Auth state
  - Text controllers and local booleans inside auth screens.
  - No auth service, token storage, user model, validation state, or loading/error handling.

- Cart state
  - `CartScreen` only has local booleans for showing a checkout/delete UI state.
  - There is no cart model, no cart item collection, and no shared cart state.

- Product state
  - Hardcoded lists and selected indexes inside `HomeScreen` and `ProductDetails`.
  - No product model, catalog provider, product repository, or selected product route argument.

- Wishlist state
  - Hardcoded product cards.
  - Favorite callbacks are empty.

### Issues/improvements

- Introduce a project-wide state approach before major redesign work.
- For this project size, Riverpod or Provider would be sufficient.
- Define models before state:
  - `Product`
  - `ProductVariant`
  - `Category`
  - `CartItem`
  - `UserProfile`
  - `Address`
  - `Order`
- Add dedicated state/controllers for:
  - auth/session
  - catalog/products
  - cart
  - wishlist
  - checkout
  - profile
- Avoid passing around anonymous `Map` objects for route arguments once real data exists.

## 4. UI and Design System

### Reusable widgets/components

Current reusable pieces:

- `ZayButton`
  - `primary`
  - `icon`
  - `cancel`

- `ZayTextInput`
  - `primary`
  - `secondary`
  - `dropdown`

- `TextInput`
  - Lower-level input used by `ZayTextInput`.

- `SocialButtons`
- `ProductCard`
- `BottomNavigation`
- `BannerCarousel`
- `TopNavigation`
- `NavigationDots`
- `ConfirmationModal`
- `ProfileImagePicker`
- `BottomButton`

### Centralized design tokens

Partially centralized:

- Colors are centralized in `ZayColors`.
- Some typography is centralized in `ZayTheme.lightTheme`.
- Asset paths are centralized in `ZayAssets`, `ZayIllustrations`, and `ZayIcons`.
- Button and input styles are partly centralized.

Not centralized enough:

- Spacing values are hardcoded throughout screens.
- Border radii are repeated manually.
- Card styles are not centralized.
- Product image dimensions are hardcoded.
- Bottom navigation style is hardcoded.
- Screen padding is repeated.
- Many `TextStyle` values are inline instead of using theme text styles.
- The theme references `Inter`, but no Inter font is declared in `pubspec.yaml`; Flutter will fall back unless the font is otherwise available.

### UI inconsistencies

- `components` and `widgets` overlap conceptually.
- `ZayButton.primary` forces `minimumSize` and `maximumSize` to `300 x 56`, which can fight parent layouts. Some buttons are wrapped in `SizedBox(width: double.infinity)` but still constrained internally to 300.
- `ProductCard` has fixed width `170`, which can overflow or look uneven on smaller/wider devices.
- `HomeScreen` manually creates product rows instead of a responsive grid/list.
- Mixed currency usage:
  - Product cards use `$`.
  - Cart placeholder uses `₦`.
- Mixed product domain:
  - Categories are fashion-like: T-Shirt, Pant, Dress, Jacket.
  - Products are electronics-like: HP Elitebook.
  - Product details include clothing sizes/colors for a laptop product.
- Some icons use SVG assets; others use Material icons directly.
- Search, category, and product UI use many hardcoded `Colors.*` instead of `ZayColors`.
- `ConfirmationModal` is styled as a reusable component but currently ignores passed callbacks.

## 5. E-commerce Features

### Authentication

Exists as UI only:

- Sign in form.
- Sign up form.
- Forgot password form.
- OTP verification UI.
- Set password form.
- Complete profile form with image picker.
- Social login buttons.

Missing:

- Validation.
- Loading states.
- Error states.
- Backend auth.
- Token/session persistence.
- Real social login.
- Account creation flow completion.

### Product listing

Exists as hardcoded UI:

- Home has hardcoded categories, filters, banner images, and repeated product cards.
- Category screen has hardcoded product cards.

Missing:

- Product model.
- Product list data source.
- Pagination.
- Empty/loading/error states.
- Real category/product filtering.

### Product details

Partially implemented:

- Image gallery.
- Thumbnail selection.
- Expandable description.
- Variant selection.
- Color selection.
- Price area.
- Add to cart button.

Missing:

- Product data passed from listing.
- Real price.
- Stock logic.
- Reviews.
- Quantity selector.
- Real add-to-cart behavior.

### Cart

Very incomplete:

- `CartItem` component exists with `flutter_slidable`.
- `CartScreen` has placeholder comments and modal booleans.
- The cart delete modal currently shows when `showDeleteConfirmation` is false, which appears inverted.

Missing:

- Actual cart list.
- Quantity controls.
- Subtotal/tax/shipping summary.
- Remove/update behavior.
- Checkout button.
- Shared cart state.

### Checkout

Not implemented.

Route constants exist, but screens are missing for checkout, payment, success/failure, and order summary.

### Wishlist

Exists as hardcoded UI only:

- Wishlist screen displays two product cards.
- Favorite toggles do nothing.

Missing:

- Shared wishlist state.
- Add/remove behavior.
- Empty state.

### Categories

Partially implemented:

- Home displays four hardcoded categories.
- Category screen opens with title `Category name`.

Missing:

- Category data model.
- Category details passed by route.
- Real category product filtering.

### Search/filter

Mostly missing:

- Home has a search box that routes to `/search`.
- `/search` is not mapped in `ZayScreens`, so it will go to the 404 error screen.
- Filter icon has no action.
- Filter chips are visual only.

### User profile

Mostly missing:

- Complete profile screen exists.
- Bottom navigation has a profile route.
- `/profile` is not mapped, so profile navigation goes to 404.

### Order history

Not implemented.

Routes exist for orders/order history/order tracking/review/rating, but screens are missing.

## 6. Data/API Layer

### Current backend/data source

There is no real API/backend layer.

The project currently uses:

- Hardcoded local UI data in screen classes.
- Remote image URLs from Pexels in product/banner placeholders.
- `shared_preferences` through `LocalStorage` for simple key-value storage.
- Empty `lib/config/api_constants.dart`.

There is no Firebase, REST client, GraphQL client, database, repository, model serialization, or local persistence beyond `shared_preferences`.

### Current storage/fetch behavior

- Products
  - Hardcoded directly in `HomeScreen`, `CategoryScreen`, `WishlistScreen`, and `ProductDetails`.

- Users
  - No user model or stored user object.
  - Auth form values are held in screen controllers only.

- Cart items
  - No stored cart items.
  - Placeholder `CartItem` displays hardcoded product name, quantity, and price.

- Orders
  - No order storage or fetching.

### Hardcoded data examples

- `New York, USA`
- `HP Elitebook 840`
- `HP Elitebook 840 Intel Core i7`
- `$899.00`
- `$83.97`
- `₦5,000`
- `Product Name`
- `Nike Air Max 90`
- `example@email.com`
- Pexels image URLs
- Lorem ipsum product description
- Static categories and filter labels

## 7. Code Quality

### Duplicated code

- Auth screens repeat similar layout patterns:
  - back button
  - title/subtitle
  - form padding
  - button blocks
  - sign-in/sign-up RichText links

- Home, category, and wishlist repeat hardcoded `ProductCard` construction.

- Back button styling is repeated in several screens and also exists in `TopNavigation`.

- Product card rows are manually duplicated instead of generated from a list/grid.

### Unused/dead/confusing files

- `lib/config/api_constants.dart` is empty.
- `lib/presentation/components/bottom_button.dart` appears unused.
- `lib/presentation/pages/cart/cart_item.dart` exists but is not used in `CartScreen`.
- `test/widget_test.dart` is the default counter test and does not apply to Zayrova.
- `README.md` is still the default Flutter README.
- Many route constants are defined without screen implementations.

### Large files to split later

- `lib/presentation/pages/product/product_details.dart` - 407 lines.
  - Split into gallery, product info, variant selector, color selector, and add-to-cart bar.

- `lib/presentation/pages/home/home_screen.dart` - 381 lines.
  - Split into home header, search/filter bar, category row, flash sale section, product grid.

- `lib/presentation/widgets/input.dart` - 237 lines.
  - Could be simplified once the design system is finalized.

- `lib/presentation/pages/auth/verify_email.dart` - 227 lines.
  - OTP input can become a reusable component.

### Bugs/risky implementation patterns

- `flutter analyze` could not run in this environment because the local Flutter/Dart VM crashed with:
  - `runtime/vm/cpuinfo_macos.cc: 42: error: unreachable code`
  - This is a local toolchain/runtime issue and should be fixed before relying on analyzer results.

- `DevicePreview` is always enabled in `main.dart`. This should be disabled for production builds, usually by `!kReleaseMode` or an environment flag.

- `Splashscreen._checkSession` deletes `onboard` every launch, preventing normal onboarding persistence.

- Several `TextEditingController`s are not disposed:
  - `SignIn`
  - `SignUp`
  - `ForgotPassword`
  - `SetPassword`
  - `CompleteProfile`
  - `LocationPage`

- `OnboardingScreen` does not dispose its `PageController`.

- `BottomNavigation` includes routes for chat/profile that are not implemented, causing 404 screens.

- Search route is used but not implemented, causing 404.

- `ConfirmationModal` accepts `onCancel` and `onConfirm`, but its buttons call empty functions instead of those callbacks.

- `CartScreen` condition looks inverted:
  - It shows `ConfirmationModal` when `!showDeleteConfirmation`.

- `ProfileImagePicker` uses `NetworkImage(_selectedImage!.path)` for a locally picked image. It should use `FileImage(File(path))` on mobile/desktop or a web-safe image approach.

- `CompleteProfile` imports `dart:io` but does not use it. `dart:io` also needs care if targeting web.

- `ZayScreens.generateRoute` casts route arguments to `Map`; non-map arguments could crash.

- `ZayRouter.goBack` pops without checking `canPop`.

- `LocalStorage.set` has a branch checking `storage != null`, but `SharedPreferences.getInstance()` does not return null.

- `LocalStorage.set` falls back to `setString(key, val)` for unsupported values, which can fail if `val` is not a string.

- `BannerCarousel` assumes `imageUrls` is non-empty. An empty list would cause modulo-by-zero.

- `VerifyEmail` creates a new `FocusNode()` inside every `KeyboardListener` during build, separate from the managed `focusNodes` list. This can leak focus nodes and create odd focus behavior.

- RichText recognizers are created inline in build methods and are not disposed. This is common in quick prototypes but should be cleaned up in production code or replaced with buttons/gesture wrappers.

## 8. Dependencies

### Key packages

- `flutter`
  - Flutter SDK.

- `device_preview`
  - Used in `main.dart` to preview devices during development.
  - Should not be always enabled in production.

- `flutter_svg`
  - Used to render SVG logos/icons.

- `shared_preferences`
  - Used by `LocalStorage` for simple key-value persistence.

- `animate_do`
  - Used by splash screen for `FadeInUp`.

- `image_picker`
  - Used by `ProfileImagePicker`.

- `flutter_slidable`
  - Used by `CartItem` for swipe-to-delete UI.
  - `CartItem` is not currently used in `CartScreen`.

- `fluttertoast`
  - Declared but not found in current `lib/` usage.

- `cupertino_icons`
  - Standard Flutter icon package; not directly important here because Material icons are mostly used.

- `flutter_lints`
  - Enables recommended Flutter lint rules.

### Potentially unnecessary right now

- `fluttertoast`
  - Not currently used.

- `flutter_slidable`
  - Useful for cart later, but currently unused because `CartItem` is not wired into cart.

- `device_preview`
  - Useful during design work, but should be development-only.

### Missing packages/capabilities

Depending on final backend choice, the project will likely need:

- State management:
  - `flutter_riverpod`, `provider`, or `bloc`.

- Networking/backend:
  - REST: `dio` or `http`.
  - Firebase: `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`.
  - Supabase: `supabase_flutter`.

- Serialization/models:
  - `freezed`, `json_serializable`, or a lighter manual model approach.

- Routing:
  - `go_router` if the app will have deeper navigation, auth guards, shell navigation, and checkout subflows.

- Forms/validation:
  - Could be manual, or use a form package if needed.

### Outdated check

I did not get a reliable package outdated report because the local Flutter/Dart tool crashes before analysis commands can complete. Run this after fixing the local Flutter toolchain:

```bash
flutter pub outdated
```

## 9. Readiness for Redesign

### How easy is a new UI flow?

The project is fairly easy to redesign visually because most logic is shallow and screen-local. There is not much backend or state logic to preserve.

However, that also means the redesign should not only reskin the existing screens. The app needs a stronger foundation before adding more commerce complexity.

### Preserve

Good candidates to preserve or refactor:

- Basic route names and app entry structure, after cleaning unused routes.
- `ZayColors` and `ZayTheme` as the starting point for a stronger design system.
- Asset constants in `ZayAssets`, `ZayIllustrations`, and `ZayIcons`.
- `ZayButton` concept, but update sizing and variants.
- `ZayTextInput` concept, but simplify and make theme-driven.
- `ProductCard` concept, but make it responsive and model-driven.
- `BannerCarousel`, with empty-state protection.
- `TopNavigation`, if it matches the new design direction.
- OTP logic from `VerifyEmail`, after extracting it into a reusable component.

### Rebuild

Recommended to rebuild or heavily refactor:

- `HomeScreen`
  - Current version is hardcoded and layout-specific.

- `ProductDetails`
  - UI interactions are useful, but file is large and product data is hardcoded.

- `CartScreen`
  - Too incomplete to preserve as-is.

- `WishlistScreen`
  - Needs real wishlist state and empty/filled states.

- `CategoryScreen`
  - Needs route data and real product grid.

- `BottomNavigation`
  - Needs only implemented tabs or a proper shell navigation setup.

- Auth screens
  - Visual structure can inspire the redesign, but forms need validation, services, and controller cleanup.

- Location screens
  - Need real permission/location handling or should be deferred.

### Safest redesign order

1. Stabilize the foundation
   - Fix Flutter/Dart toolchain issue.
   - Run `flutter analyze`.
   - Replace the default counter test.
   - Disable `DevicePreview` for release.
   - Clean route constants or add placeholder screens intentionally.

2. Define the new design system
   - Colors, typography, spacing, radius, shadows, buttons, inputs, cards, nav, product imagery.
   - Centralize tokens before changing screens.

3. Add core models and mock repositories
   - `Product`, `Category`, `CartItem`, `UserProfile`, `Address`, `Order`.
   - Use mock repositories first so the redesign can move without waiting for backend decisions.

4. Add state management
   - Start with catalog, cart, wishlist, auth/session.
   - Keep state separate from widgets.

5. Rebuild shell navigation
   - Implement only real tabs first: home, wishlist, cart, profile.
   - Hide chat/orders until screens exist, or add real placeholder flows.

6. Redesign commerce screens in this order
   - Home/catalog.
   - Category/product listing.
   - Product details.
   - Cart.
   - Checkout.
   - Wishlist.
   - Profile/orders.

7. Wire backend/API after flows are stable
   - Keep repositories abstract enough to swap mock data for real APIs.

8. Add tests around critical flows
   - Navigation smoke tests.
   - Cart add/remove/quantity behavior.
   - Auth form validation.
   - Product listing/detail rendering from mock data.

## 10. Final Recommendation

Zayrova is currently a halfway UI prototype, not a functional e-commerce app yet. The strongest parts are the early screen coverage, route organization, reusable button/input/card components, and basic visual direction. The weakest parts are the absence of real data models, state management, backend/API integration, complete cart/checkout/order flows, and a production-ready design system.

Before continuing development, the project should be stabilized and restructured just enough to support the new premium direction:

- Fix the local Flutter/Dart toolchain crash.
- Run `flutter analyze` and clean up compile/lint issues.
- Replace the default test.
- Decide the backend approach: mock-first, Firebase, Supabase, or REST.
- Choose a state management package.
- Create core e-commerce models.
- Centralize the new design system.
- Rebuild the main commerce flow around real state, even if the data is still mocked.

The safest path is not to polish the existing screens one by one. Instead, preserve useful building blocks, introduce models/state/mock repositories, then rebuild the premium UI flow on top of that foundation. That will make the redesign feel intentional and prevent the project from becoming a collection of beautiful but disconnected screens.

## 11. Screen Mapping

### Existing Screens

| Current Screen   | Status   | Target Design Reference |
| ---------------- | -------- | ----------------------- |
| Splashscreen     | Keep     | New Design              |
| GetStartedScreen | Merge    | New Design              |
| OnboardingScreen | Merge    | New Design              |
| SignIn           | Rebuild  | New Design              |
| SignUp           | Rebuild  | New Design              |
| ForgotPassword   | Rebuild  | New Design              |
| VerifyEmail      | Refactor | New Design              |
| CompleteProfile  | Refactor | New Design              |
| HomeScreen       | Rebuild  | New Design              |
| CategoryScreen   | Rebuild  | New Design              |
| ProductDetails   | Rebuild  | New Design              |
| WishlistScreen   | Rebuild  | New Design              |
| CartScreen       | Rebuild  | New Design              |

### Missing Screens

- Search
- Filter
- Checkout
- Payment
- Payment Success
- Payment Failed
- Address Management
- Order History
- Order Details
- Order Tracking
- Notifications
- Profile
- Settings
- Security
- Help Centre
- Privacy Policy
- Terms & Conditions
