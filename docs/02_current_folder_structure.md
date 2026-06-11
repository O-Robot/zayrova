# Current Folder Structure

This is the current project structure and Codex must respect it.

```text
lib/
  config/
    api_constants.dart

  core/
    constants/
    exceptions/
    services/
    themes/
    utils/

  data/
    datasources/
    models/
    repositories/

  domain/
    entities/
    usecases/

  presentation/
    components/
    pages/
    routes/
    widgets/

  main.dart
  zay.dart
```

## Structure rule

Do not replace this structure with a new one.

The project already has a layered structure. Future implementation should build on this structure instead of moving everything into a different pattern.

## Layer responsibilities

### `config/`

App-level configuration.

Use this for:

- API base URLs
- endpoint constants
- environment-related constants

### `core/`

Shared app foundation.

Use this for:

- design constants
- theme setup
- reusable services
- app-wide utilities
- exceptions
- storage helpers

### `data/`

External data and API implementation.

Use this for:

- remote data sources
- API clients
- request/response models
- repository implementations

### `domain/`

Business rules and app contracts.

Use this for:

- entities
- repository contracts
- use cases

### `presentation/`

UI layer.

Use this for:

- screens/pages
- reusable widgets
- reusable components
- navigation routes
- state controllers/providers that are UI-facing

## Feature organisation rule

Do not create a random structure for every feature.

When adding a feature, place files in the correct existing layer.

Example for products:

```text
lib/domain/entities/product_entity.dart
lib/domain/usecases/get_products_usecase.dart
lib/data/models/product_model.dart
lib/data/datasources/product_remote_datasource.dart
lib/data/repositories/product_repository_impl.dart
lib/presentation/pages/product/
lib/presentation/widgets/
```

## Naming rule

Use clear names that explain the file purpose.

Good examples:

- `product_model.dart`
- `cart_item_model.dart`
- `auth_remote_datasource.dart`
- `cart_repository_impl.dart`
- `get_products_usecase.dart`

Avoid vague names like:

- `data.dart`
- `helper.dart`
- `logic.dart`
- `screen2.dart`
