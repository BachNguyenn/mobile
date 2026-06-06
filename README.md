# Zen Japanese Mobile

Flutter app for Japanese study with JLPT libraries, sentence practice, SRS
review, handwriting recognition, analytics, and a Zen garden reward loop.

## Project Guide

- [Project structure](docs/project_structure.md) explains each major folder and
  where new code should live.
- [Layered architecture](docs/layered_architecture.md) documents the
  feature-first Clean Architecture boundaries used in `lib/`.

## Setup

1. Install Flutter and platform toolchains.
2. Copy `.env.example` to `.env` for local-only settings. Do not commit `.env`.
3. Configure Firebase:
   - Android uses `android/app/google-services.json`.
   - Dart initialization uses `lib/firebase_options.dart`.
   - iOS requires adding `ios/Runner/GoogleService-Info.plist` before shipping.
4. Install dependencies:

```bash
flutter pub get
```

## Checks

```bash
flutter analyze --no-pub
flutter test --no-pub
```

## Local Cleanup

These files are generated locally and can be removed when the workspace needs a
fresh start:

```bash
build/
.dart_tool/
.sandbox_appdata/
.idea/
*.iml
.flutter
.flutter_tool_state
.flutter-plugins-dependencies
```

## Android Release Signing

Create `android/key.properties` locally:

```properties
storeFile=/absolute/path/to/release.jks
storePassword=...
keyAlias=...
keyPassword=...
```

Then build:

```bash
flutter build appbundle --release
```

Release builds no longer sign with the debug key. If `key.properties` is
missing, Gradle leaves release signing unset so CI/local builds do not
accidentally produce a debug-signed production artifact.
