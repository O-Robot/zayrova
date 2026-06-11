# State Management Plan

## Goal

Zayrova needs proper state management before the redesign becomes too large.

The app should not rely on scattered `setState` calls for core commerce flows.

## State Management Decision

Zayrova uses Riverpod.

All app state should be implemented using Riverpod unless explicitly approved otherwise.

## Required state areas

### Auth state

Responsible for:

- current user
- access token
- login status
- logout
- session restoration
- auth loading/error state

### Product/catalog state

Responsible for:

- product list
- product details
- categories
- category products
- search results
- filters
- sorting
- pagination/loading states

### Wishlist state

Responsible for:

- wishlist item IDs
- add to wishlist
- remove from wishlist
- wishlist persistence where possible

### Cart state

Responsible for:

- cart items
- item quantities
- add to cart
- remove from cart
- cart totals
- checkout preparation

### Checkout state

Responsible for:

- selected address
- selected delivery method
- selected payment method
- order summary
- placing order state

### Profile/settings state

Responsible for:

- user profile
- profile edit state
- settings toggles
- address list

## UI rule

Screens should read state and trigger actions.

Screens should not contain business logic for cart calculation, product fetching, auth token storage, or API response parsing.

## Persistence rule

Persist only what is useful:

- auth token
- current user basic info
- onboarding completed flag
- wishlist item IDs
- cart item IDs and quantities if API persistence is not enough

Use the existing local storage utility where appropriate, but improve it if needed.
