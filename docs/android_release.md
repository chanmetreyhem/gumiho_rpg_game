# Android Release Build

## Prerequisites

- Flutter SDK ^3.9.0
- Android SDK with build-tools installed
- Release keystore (create once, keep safe)

## Create a keystore

```bash
keytool -genkey -v -keystore gumiho-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias gumiho
```

Store the `.jks` file **outside** the repo. Never commit it.

## Configure signing

Create `android/key.properties` (gitignored):

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=gumiho
storeFile=../gumiho-release.jks
```

Wire signing in `android/app/build.gradle.kts` using the standard Flutter release signing pattern.

## Build release APK

```bash
flutter clean
flutter pub get
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

## Build App Bundle (Play Store)

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

## App details

| Field | Value |
|-------|-------|
| App label | Gumiho RPG |
| Package | `com.example.gumiho_rpg_game` (change before store upload) |
| Orientation | Portrait |
| Min SDK | Defined by Flutter (see `android/app/build.gradle.kts`) |

## Before uploading to Play Store

1. Change `applicationId` from `com.example.*` to your production package name
2. Add privacy policy URL if using ads or analytics (Phase 6)
3. Upload screenshots (portrait) and store listing from [store_listing.md](store_listing.md)
