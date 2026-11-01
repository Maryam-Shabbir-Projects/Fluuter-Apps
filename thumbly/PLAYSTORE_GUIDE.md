# Thumbly: Launcher Icon + Google Play Store Upload Guide

## Part 1: Set up the launcher icon (one time)

Your zip only contains `lib/` and `pubspec.yaml`, so first create the platform folders.

```bash
flutter create --project-name thumbly --org com.yourname .   # run INSIDE the thumbly folder
flutter pub get
dart run flutter_launcher_icons
```

- Pick your package name now (`--org com.yourname` gives `com.yourname.thumbly`). **It can never be changed after upload.**
- `flutter create .` will not overwrite your `lib/` or `pubspec.yaml` content. If it replaces `lib/main.dart`, re-copy yours from the zip.
- The last command writes the icons into `android/app/src/main/res/mipmap-*` and `ios/`.
- Set the app name shown under the icon: in `android/app/src/main/AndroidManifest.xml` set `android:label="Thumbly"`.

Files included: `assets/icon/icon.png` (1024, legacy), `icon_foreground.png` + `icon_background.png` (adaptive), `store/play_store_icon_512.png` (Play listing icon), `store/feature_graphic_1024x500.png` (Play feature graphic).

## Part 2: Android prerequisites

1. **Min SDK / plugins.** `google_mlkit_text_recognition` needs `minSdk 21+` (ML Kit usually wants 21; set `minSdkVersion 21` in `android/app/build.gradle` if the build complains). `image_background_remover` may need higher: if the build fails, set `minSdk 24`.
2. **Permissions.** `image_picker` needs no manifest permission on modern Android for gallery picking. Add `<uses-permission android:name="android.permission.INTERNET"/>` only if a plugin needs it (`google_fonts` downloads fonts at runtime, which needs internet; to work offline, bundle the fonts as assets).
3. **Unused dependency check.** `flutter_tesseract_ocr` is in `pubspec.yaml` but I found no usage in `lib/`. Removing unused plugins shrinks the app and avoids review issues: `flutter pub remove flutter_tesseract_ocr` (and `google_mlkit_text_recognition` if unused).
4. **Version.** In `pubspec.yaml`, `version: 1.0.0+1` means name 1.0.0, build number 1. Every Play upload needs a higher build number (+2, +3...).

## Part 3: Create a signing key

```bash
keytool -genkey -v -keystore ~/thumbly-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

**Back up this file and its passwords somewhere safe.** Do not commit it to git.

Create `android/key.properties`:

```
storePassword=YOUR_PASSWORD
keyPassword=YOUR_PASSWORD
keyAlias=upload
storeFile=/full/path/to/thumbly-upload.jks
```

In `android/app/build.gradle` (Groovy version; the Kotlin `.kts` equivalent works the same way):

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

(The `signingConfigs` block must come **before** `buildTypes`.)

## Part 4: Build the release bundle

```bash
flutter clean
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`. Play requires `.aab`, not `.apk`.

Test first with `flutter build apk --release` and install it on a real phone.

## Part 5: Google Play Console

1. **Developer account:** https://play.google.com/console, one-time **$25** fee, identity verification (can take days). Personal accounts created after Nov 2023 must run a **closed test with at least 12 testers for 14 days** before applying for production access, so plan for this.
2. **Create app:** *Create app* → name "Thumbly", default language, App (not game), Free/Paid, accept the declarations.
3. **Set up your app** (Dashboard checklist):
   - **Privacy policy URL**: required. Host a simple page (GitHub Pages works). State that designs and photos stay on the device and background removal is on-device.
   - **App access**: all functionality available without login.
   - **Ads**: No (unless you add them).
   - **Content rating**: fill the questionnaire (likely Everyone).
   - **Target audience**: 13+ or 18+ is simplest; avoid "children" to skip extra requirements.
   - **Data safety**: declare honestly. If you collect nothing and send nothing off-device, say so. Note that Google Fonts is fetched at runtime.
   - **Government / financial / health apps**: No.
4. **Store listing:**
   - Short description (80 chars max), e.g. "Design YouTube thumbnails fast with text, icons, shapes and photos."
   - Full description (up to 4000 chars): copy from your README features.
   - **App icon:** `store/play_store_icon_512.png`
   - **Feature graphic:** `store/feature_graphic_1024x500.png`
   - **Phone screenshots:** minimum 2 (aim for 4-8), take them from a real device or emulator, 16:9 or 9:16, 320-3840 px per side.
5. **Upload build:** *Testing → Closed testing* (or Internal testing first for quick checks) → *Create release* → accept **Play App Signing** → upload `app-release.aab` → add release notes → *Save* → *Review release* → *Start rollout*.
6. **Testers:** add 12+ people by email (create a Google Group or email list) and send them the opt-in link. Keep them opted in for 14 days.
7. **Apply for production:** after 14 days, Dashboard → *Apply for production*, answer the questions, then create a Production release with the same `.aab` (or a newer build) and submit.
8. **Review** usually takes a few days (sometimes up to 7+ for new accounts). Once approved, the app goes live.

## Part 6: Tips to avoid rejection

- Don't use YouTube's logo or name as your icon or title. That's why the icon is a "T" lettermark rather than a play button. Describing the app as for "YouTube thumbnails" in the description is fine, but avoid implying it is made or endorsed by YouTube/Google.
- Make sure a privacy policy link is live.
- Make sure the app opens and works without crashing on Android 8 to 15.
- Target the current required API level (Flutter's latest stable does this by default; update Flutter if Play warns).

## Updating later

Bump `version: 1.0.1+2`, run `flutter build appbundle --release`, upload the new `.aab` to a new release.
