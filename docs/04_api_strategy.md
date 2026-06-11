# API Strategy

## Main rule

Do not use mock data as the final strategy.

Zayrova should use real HTTP API calls from the beginning of the rebuild.

Free public APIs can be used for now, but the architecture must allow the API provider to be swapped later without rewriting the UI.

## Recommended API provider for now

Use DummyJSON as the primary temporary API provider.

Base URL:

```text
https://dummyjson.com
```

DummyJSON is suitable because it supports common e-commerce prototype data, including products, carts, users, and authentication.

## Primary API areas

### Products

Use for:

- product listing
- product details
- product search
- category filtering
- pagination

Important endpoints:

```text
GET /products
GET /products/{id}
GET /products/search?q={query}
GET /products/categories
GET /products/category/{categorySlug}
```

### Cart

Use for:

- fetching carts
- fetching user carts
- adding cart products
- updating cart products
- deleting carts

Important endpoints:

```text
GET /carts
GET /carts/{id}
GET /carts/user/{userId}
POST /carts/add
PUT /carts/{id}
DELETE /carts/{id}
```

### Auth

Use for:

- sign in
- current authenticated user
- token-based session testing

Important endpoints:

```text
POST /auth/login
GET /auth/me
POST /auth/refresh
```

### Users

Use for:

- profile data
- user account screens
- address/profile placeholders

Important endpoints:

```text
GET /users
GET /users/{id}
```

## API architecture rule

UI screens must not call HTTP directly.

Use this flow:

```text
UI screen/provider
  -> use case
  -> repository contract
  -> repository implementation
  -> remote datasource
  -> API client
```

## API Client Rule

All HTTP requests must go through a shared API client.

Example:

core/services/network/api_client.dart

Repositories should never call http or dio directly.

Datasource -> ApiClient -> HTTP Layer

## Error handling rule

Every API call must handle:

- loading state
- success state
- empty state where relevant
- error state
- network failure
- unexpected response shape

## No hardcoded data rule

Do not hardcode product lists, cart items, users, or orders inside screens.

Temporary fallback data is only allowed if it is placed in a clearly named datasource and explained. It should not live inside widgets or pages.

## Future backend swap rule

The app may later use a real backend such as Firebase, Supabase, Laravel, Node.js, or a custom REST API.

Because of that, keep API-specific details inside the data layer.

The presentation layer should depend on app entities and state, not raw API response maps.
