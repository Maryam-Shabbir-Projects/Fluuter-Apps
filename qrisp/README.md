# To Run Paste These in PowerShell (Terminal)
flutter pub get
dart run flutter_launcher_icons
flutter clean
flutter run




# Qrisp: QR scanner and generator (Flutter)

Screens: Welcome, Camera permission, Scan, Scan result, Create, forms (Website, Text, Wi-Fi, Contact, Email, Phone), QR ready + customize (colour, dots, error correction, logo, save, share), History, Settings.
Everything runs on the phone. No account, no server, no analytics.

## 1. Set up
```bash
flutter create --org com.yourcompany --project-name qrisp .
# then replace the generated lib/ and pubspec.yaml with the ones in this zip
flutter pub get
```
Pick your own application id (for example `com.yourcompany.qrisp`). It cannot change after you publish.

## 2. Android changes
`android/app/build.gradle(.kts)`: set `minSdk = 23` (needed by mobile_scanner).

`android/app/src/main/AndroidManifest.xml`, inside `<manifest>` and above `<application>`:
```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-feature android:name="android.hardware.camera" android:required="false"/>
<uses-feature android:name="android.hardware.camera.autofocus" android:required="false"/>
<queries>
  <intent><action android:name="android.intent.action.VIEW"/><data android:scheme="https"/></intent>
  <intent><action android:name="android.intent.action.VIEW"/><data android:scheme="http"/></intent>
  <intent><action android:name="android.intent.action.VIEW"/><data android:scheme="mailto"/></intent>
  <intent><action android:name="android.intent.action.VIEW"/><data android:scheme="tel"/></intent>
</queries>
```
Only the CAMERA permission is declared. Gallery access uses the system photo picker, so no storage permission is needed.

## 3. iOS (if you ship it later)
`ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key><string>Qrisp uses the camera to read QR codes.</string>
<key>NSPhotoLibraryUsageDescription</key><string>Pick an image to scan or use as a logo.</string>
<key>NSPhotoLibraryAddUsageDescription</key><string>Save your QR codes to Photos.</string>
```

## 4. Replace before publishing
In `lib/widgets.dart`: `kPrivacyUrl`, `kTermsUrl`, `kStoreUrl` (your hosted pages and package id).
Add your app icon (for example with the `flutter_launcher_icons` package) and, if you like, the Sora font as an asset.

## 5. Release build for Google Play
```bash
keytool -genkey -v -keystore ~/qrisp-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
# add the keystore to android/key.properties and android/app/build.gradle (Flutter docs: "Build and release an Android app")
flutter build appbundle --release
```
Upload `build/app/outputs/bundle/release/app-release.aab` in Play Console.

## Play Console checklist
- Privacy Policy URL (say that scans and history never leave the phone).
- Data safety form: the app collects no data and shares none. Update it if you add ads or analytics.
- Content rating questionnaire, app category (Tools), target audience (not for children).
- Store listing: 512 px icon, 1024x500 feature graphic, 2 to 8 phone screenshots.
- Check Play Console for the current target API level rule and fix it in `build.gradle` if needed.

## Notes
- If the analyzer complains about `errorBuilder` in `scan_screen.dart`, your mobile_scanner version has a different signature; adjust the parameters to match.
- "Connect to network" copies the password and opens Wi-Fi settings. A one-tap connect needs native Android code.
- The generated QR PNG is painted by `QrPainter` at 1024 px, so saved images stay sharp.

## Fonts (cursive headings)
Headings use Dancing Script through the `google_fonts` package (SIL Open Font Licence, free for apps). It downloads the font on first use. For a fully offline app with no font download:
1. Download Dancing Script (Bold) from fonts.google.com and put `DancingScript-Bold.ttf` in `assets/google_fonts/`.
2. In `pubspec.yaml` add under `flutter:` -> `assets:` the line `- assets/google_fonts/`.
3. In `main()` add `GoogleFonts.config.allowRuntimeFetching = false;` (import `package:google_fonts/google_fonts.dart`).
Body text stays in the normal system font so it is easy to read.

## App icon
Icon files are in `assets/icon/`. After `flutter pub get`, run:
```bash
dart run flutter_launcher_icons
```
This creates the Android adaptive icon (including the themed monochrome icon for Android 13+) and the iOS icon.
For the Play Console upload `assets/icon/play_store_icon_512.png` (512 x 512, PNG).

<img width="2400" height="1700" alt="qrisp_all_screens" src="https://github.com/user-attachments/assets/20afb474-a34c-431b-97f7-85ac402eebbf" />

<img width="1024" height="500" alt="qrisp_play_feature_graphic_1024x500" src="https://github.com/user-attachments/assets/e41766d2-45f4-40ff-8ba2-1cb03dc39866" />


