# Zen Japanese Mobile

Flutter app for Japanese study with JLPT libraries, sentence practice, SRS
review, handwriting recognition, analytics, and a Zen garden reward loop.

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
