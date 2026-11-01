## to run paste these commands in terminal
flutter pub get
dart run flutter_launcher_icons
flutter clean
flutter run
<h1 align="center">ScanKit</h1>
<p align="center">Barcode scanner &amp; generator for Android, built with Flutter.</p>

## Features

- **Welcome screen** shown on first launch only
- **Scan** Code 128, Code 39, Code 93, EAN-13, EAN-8, UPC-A, UPC-E, ITF and Codabar, with flash and gallery import
- **Result** screen with Search product, Copy and Share
- **Create** Code 128, EAN-13, UPC-A and Code 39, with input validation, Save and Share
- **History** with separate Scanned and Created tabs and Clear all
- **Settings** for beep, vibrate and save history, plus privacy policy and version
- Light and dark theme, all data stored on the device

## Project structure

```
lib/
├── main.dart                  app entry (Welcome or Home)
├── core/theme.dart            colours and themes
├── models/entry.dart          scan/create record
├── services/store.dart        settings and history (SharedPreferences)
├── widgets/icon_badge.dart    shared UI widget
└── screens/                   welcome, home, scan, result, create, history, settings
```

## Getting started

1. Install [Flutter](https://docs.flutter.dev/get-started/install) 3.19 or newer.
2. Create the platform folders and copy this project over them:
   ```bash
   flutter create scankit
   # replace lib/, pubspec.yaml and assets/ with the ones from this repo
   cd scankit
   flutter pub get
   ```
3. In `android/app/src/main/AndroidManifest.xml`, inside `<manifest>`, add:
   ```xml
   <uses-permission android:name="android.permission.CAMERA"/>
   <uses-permission android:name="android.permission.INTERNET"/>
   <queries>
     <intent>
       <action android:name="android.intent.action.VIEW"/>
       <data android:scheme="https"/>
     </intent>
   </queries>
   ```
4. In `android/app/build.gradle`, set `minSdkVersion 23`.
5. Generate the launcher icon and run:
   ```bash
   dart run flutter_launcher_icons
   flutter run
   ```

## Build for the Play Store

```bash
flutter build appbundle --release
```

Before publishing:

- Set your own application ID and signing key
- Replace the placeholder privacy policy URL in `lib/screens/settings_screen.dart`
- Complete the Data safety form (the app uses the camera only; nothing leaves the device)
- Prepare a 1024×500 feature graphic and phone screenshots

## Customising

- **Add a barcode type to Create:** add one line to the `_types` map in `lib/screens/create_screen.dart`
- **Add a setting:** add a flag in `lib/services/store.dart` and a `SwitchListTile` in `lib/screens/settings_screen.dart`
- **Change the brand colour:** edit `teal` in `lib/core/theme.dart`

  <img width="2400" height="1000" alt="banner" src="https://github.com/user-attachments/assets/bfe14738-8373-4dee-9328-c2763fe38c5b" />


## Packages

[mobile_scanner](https://pub.dev/packages/mobile_scanner), [barcode_widget](https://pub.dev/packages/barcode_widget), [shared_preferences](https://pub.dev/packages/shared_preferences), [share_plus](https://pub.dev/packages/share_plus), [image_picker](https://pub.dev/packages/image_picker), [url_launcher](https://pub.dev/packages/url_launcher)
