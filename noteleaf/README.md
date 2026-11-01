# to run paste these commands in terminal
flutter pub get
dart run flutter_launcher_icons
flutter clean
flutter run

# NoteLeaf

Turn notes in any language into styled pages. Export them as images, or as a video with a voice-over.
The app name is one constant: `kAppName` in `lib/core/constants.dart`.

## What it does
- Write, paste, import (.txt, .md, .docx) or dictate notes by voice.
- 24 font styles in four groups: Urdu/Arabic, Hindi, English and Cursive. Bold, italic, underline, colour, highlight.
- Pick a font, size, bold or colour before you type and the next text uses it (like Word); with text selected it changes the selection.
- Font sizes in points (8, 9, 10, 11, 12, 14 ... 96) like Word, with A- / A+ buttons. 1 pt = page short side / 540 px.
- Paper: 13 designs, any single colour, any two-colour gradient (4 directions), or a photo from the gallery.
- Faded text with its own size, colour and opacity, plus an imported logo. Tap or drag on the preview to place either one.
- Page sizes for YouTube, Shorts, square, 4:5 and A4.
- Pages are rebuilt from the text, so extra lines flow to the next page.
- "Edit this page" opens the page itself (paper, font, spacing, logo, faded text exactly as exported) and you type on it.
- Export images or video. Voice-over can be recorded or imported; pages follow the voice by word count.
- Files and folders: create folders, put any number of files in them, rename, move and delete. Home shows names only.
- Projects, folders and settings are stored in SQLite (`noteleaf.db`, version 2; version 1 databases are upgraded automatically).

## Structure
```
lib/
  main.dart, app.dart            entry point and theme (light and dark)
  core/                          constants (fonts, sizes, papers), paper painter
  models/rich_text.dart          per-character styles and the rich text controller
  models/doc.dart                project data, pagination, page painting
  services/storage.dart          SQLite
  services/importer.dart         text, Word, image and audio import
  services/voice.dart            voice typing and voice recording
  services/exporter.dart         images and video (ffmpeg) to the photo album
  screens/                       welcome tour, home (folders + files), folder page, project page, file actions
  screens/tabs/                  write, design, pages (+ page editor), export
  widgets/                       bottom sheets, save button, panel, dock, logo, colour picker, toggle group, fancy title, file tile, style bar, paper swatch, page preview
assets/icon/                     launcher icon (icon.png, icon_fg.png)
test/rich_text_test.dart
```

## Run
```
flutter create . --project-name noteleaf --org com.yourname
flutter pub get
flutter test
flutter run
```

## App icon
```
dart run flutter_launcher_icons
```
Uses `assets/icon/icon.png` and the adaptive foreground `assets/icon/icon_fg.png` (settings are at the end of `pubspec.yaml`).

## Platform setup
Android (`android/app/src/main/AndroidManifest.xml`, `minSdkVersion 24`):
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<queries><intent><action android:name="android.speech.RecognitionService"/></intent></queries>
```
Also add the media permissions listed in the `gal` README. Set `android:label` to your app name.

iOS (`ios/Runner/Info.plist`): `NSPhotoLibraryUsageDescription` (gallery), `NSMicrophoneUsageDescription`, `NSSpeechRecognitionUsageDescription`, `NSPhotoLibraryAddUsageDescription`.

## Known limits
- Voice typing needs the phone's speech service (Google on Android) and usually internet.
- Voice sync is an estimate: time per page is proportional to its words, not exact word timing.
- Fonts download on first use. For release, bundle them as assets so the app works offline.
- Video uses the `ffmpeg_kit_flutter_new` package. If it is unavailable, any ffmpeg Flutter package works with the same commands in `exporter.dart`.
- PDF import is not included.
