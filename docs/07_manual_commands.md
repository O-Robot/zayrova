# Manual Commands

Codex may run safe verification commands.

## Allowed for Codex

```bash
flutter pub get
flutter analyze
flutter test
```

## Developer approval required

flutter pub add <package>
flutter pub upgrade
flutter upgrade
pod install
pod update
flutter run
flutter build apk
flutter build ios
flutter build web
git add
git commit
git push

### Rule

Codex must not install new dependencies or change package versions without approval.

If a dependency is needed, Codex should explain why and ask the developer to approve it first.

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
