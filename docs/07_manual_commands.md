# Manual Commands

Codex must not run these commands.

The developer will run commands manually when needed.

## Initial health checks

```bash
flutter --version
flutter doctor
flutter pub get
flutter analyze
```

## Dependency checks

```bash
flutter pub outdated
```

## Run app

```bash
flutter run
```

## Clean build only when needed

```bash
flutter clean
flutter pub get
```

## Suggested dependencies later

Do not add these until the implementation phase reaches them.

```bash
flutter pub add dio
flutter pub add flutter_riverpod
flutter pub add cached_network_image
flutter pub add equatable
```

## Important

Only run commands after reviewing the file changes Codex made.
